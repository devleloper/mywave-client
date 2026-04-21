import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../domain/entities/album.dart';
import '../../../../../domain/entities/artist.dart';
import '../../../../../domain/entities/playback_context.dart';
import '../../../../../domain/entities/track.dart';
import '../../../widgets/bounceable.dart';
import '../../../widgets/explicit_badge.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/track_cover.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../player/bloc/audio_player_event.dart';
import '../bloc/search_state.dart';

class SearchLoadedResults extends StatelessWidget {
  const SearchLoadedResults({super.key, required this.state});

  final SearchLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.tracks.isEmpty && state.albums.isEmpty && state.artists.isEmpty) {
      return Center(
        child: Text('No results found.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        if (state.artists.isNotEmpty) ...[
          const SectionHeader('Artists'),
          const SizedBox(height: 12),
          ArtistRow(artists: state.artists),
          const SizedBox(height: 24),
        ],
        if (state.albums.isNotEmpty) ...[
          const SectionHeader('Albums'),
          const SizedBox(height: 12),
          AlbumRow(albums: state.albums),
          const SizedBox(height: 24),
        ],
        if (state.tracks.isNotEmpty) ...[
          const SectionHeader('Tracks'),
          const SizedBox(height: 12),
          ...state.tracks.map((track) => SearchTrackTile(
                track: track,
                allTracks: state.tracks,
              )),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}

class ArtistRow extends StatelessWidget {
  const ArtistRow({super.key, required this.artists});

  final List<Artist> artists;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        itemBuilder: (context, index) => ArtistCard(artist: artists[index]),
      ),
    );
  }
}

class AlbumRow extends StatelessWidget {
  const AlbumRow({super.key, required this.albums});

  final List<Album> albums;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) => AlbumCard(album: albums[index]),
      ),
    );
  }
}

class ArtistCard extends StatelessWidget {
  const ArtistCard({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Bounceable(
      onTap: () => context.push('/search/artist/${artist.id}'),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
                image: artist.pictureUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(artist.pictureUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: artist.pictureUrl == null
                  ? Icon(Icons.person_rounded, color: colorScheme.onSurface.withValues(alpha: 0.2))
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album});

  final Album album;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Bounceable(
      onTap: () => context.push('/search/album/${album.id}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: album.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: album.coverUrl!,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 140,
                      height: 140,
                      color: colorScheme.surface,
                      child: Icon(Icons.album_rounded, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (album.isExplicit) const ExplicitBadge(),
          ],
        ),
      ),
    );
  }
}

class SearchTrackTile extends StatelessWidget {
  const SearchTrackTile({super.key, required this.track, required this.allTracks});

  final Track track;
  final List<Track> allTracks;

  void _play(BuildContext context) {
    context.read<AudioPlayerBloc>().add(PlayTrackEvent(
      track: track,
      initialQueue: List.from(allTracks),
      context: PlaybackContext(
        type: PlaybackContextType.collection,
        id: 'search_${track.id}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Bounceable(
      onTap: () => _play(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            TrackCover(url: track.album?.coverUrl, size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          track.title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (track.isExplicit) ...[
                        const SizedBox(width: 8),
                        const ExplicitBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist?.name ?? 'Unknown',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

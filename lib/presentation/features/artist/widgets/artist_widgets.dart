import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/entities/album.dart';
import '../../../../../domain/entities/playback_context.dart';
import '../../../../../domain/entities/track.dart';
import '../../../widgets/explicit_badge.dart';
import '../../../widgets/track_cover.dart';
import '../../../widgets/bounceable.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../player/bloc/audio_player_event.dart';
import '../bloc/artist_state.dart';

class ArtistHeader extends StatelessWidget {
  const ArtistHeader({super.key, required this.state});

  final ArtistLoaded state;

  void _play() {
    getIt<AudioPlayerBloc>().add(PlayTrackEvent(
      track: state.topTracks.first,
      initialQueue: state.topTracks,
      context: PlaybackContext(
        type: PlaybackContextType.artist,
        id: state.artist.id,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${state.artist.fans ?? 0} fans',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
          ),
        ),
        if (state.topTracks.isNotEmpty)
          Bounceable(
            onTap: _play,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppTheme.tiffanyBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class ArtistTrackTile extends StatelessWidget {
  const ArtistTrackTile({
    super.key,
    required this.track,
    required this.state,
  });

  final Track track;
  final ArtistLoaded state;

  void _play() {
    getIt<AudioPlayerBloc>().add(PlayTrackEvent(
      track: track,
      initialQueue: state.topTracks,
      context: PlaybackContext(
        type: PlaybackContextType.artist,
        id: state.artist.id,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: _play,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            TrackCover(url: track.album?.coverUrl, size: 48, borderRadius: 4),
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
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
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
                    track.album?.title ?? '',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
          ],
        ),
      ),
    );
  }
}

class ArtistAlbumRow extends StatelessWidget {
  const ArtistAlbumRow({super.key, required this.albums});

  final List<Album> albums;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) => ArtistAlbumCard(album: albums[index]),
      ),
    );
  }
}

class ArtistAlbumCard extends StatelessWidget {
  const ArtistAlbumCard({super.key, required this.album});

  final Album album;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () => context.push('/album/${album.id}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: album.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: album.coverUrl!,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                  : Container(width: 140, height: 140, color: Theme.of(context).colorScheme.surface),
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.releaseDate?.split('-').first ?? '',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

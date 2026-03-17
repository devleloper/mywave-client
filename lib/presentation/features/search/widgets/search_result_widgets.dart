import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/entities/album.dart';
import '../../../../../domain/entities/artist.dart';
import '../../../../../domain/entities/track.dart';
import '../../../widgets/explicit_badge.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/track_cover.dart';
import '../bloc/search_state.dart';

class SearchLoadedResults extends StatelessWidget {
  const SearchLoadedResults({super.key, required this.state});

  final SearchLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.tracks.isEmpty && state.albums.isEmpty && state.artists.isEmpty) {
      return const Center(
        child: Text('No results found.', style: TextStyle(color: Colors.white54)),
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
          ...state.tracks.map((track) => SearchTrackTile(track: track)),
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
      height: 160,
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
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.surface,
            backgroundImage: artist.pictureUrl != null
                ? CachedNetworkImageProvider(artist.pictureUrl!)
                : null,
            child: artist.pictureUrl == null
                ? const Icon(Icons.person, color: Colors.white38)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album});

  final Album album;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: album.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: album.coverUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 120,
                    height: 120,
                    color: AppTheme.surface,
                    child: const Icon(Icons.album, color: Colors.white38),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            album.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (album.isExplicit) const ExplicitBadge(),
        ],
      ),
    );
  }
}

class SearchTrackTile extends StatelessWidget {
  const SearchTrackTile({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: TrackCover(url: track.album?.coverUrl, size: 48),
      title: Row(
        children: [
          Expanded(
            child: Text(
              track.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
      subtitle: Text(
        track.artist?.name ?? 'Unknown',
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white38),
    );
  }
}

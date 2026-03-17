import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/playback_context.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/artist.dart';
import '../../../../domain/entities/album.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../player/bloc/audio_player_event.dart';
import '../bloc/collection_bloc.dart';
import '../bloc/collection_event.dart';
import '../bloc/collection_state.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CollectionBloc>()..add(LoadCollectionEvent()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  'Your Collection',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              Expanded(
                child: BlocBuilder<CollectionBloc, CollectionState>(
                  builder: (context, state) {
                    if (state is CollectionLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.tiffanyBlue),
                      );
                    } else if (state is CollectionError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    } else if (state is CollectionLoaded) {
                      final tracks = state.savedTracks;

                      if (tracks.isEmpty) {
                        return const Center(
                          child: Text(
                            'No downloaded tracks yet.\nStart saving your favorites!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: tracks.length + 1, // +1 for the bottom nav spacing
                        itemBuilder: (context, index) {
                          if (index == tracks.length) {
                            return const SizedBox(height: 100);
                          }

                          final localTrack = tracks[index];
                          // Map LocalTrack to Domain Track for the player
                          final track = Track(
                            id: localTrack.providerId,
                            title: localTrack.title,
                            durationSeconds: localTrack.durationSeconds,
                            isExplicit: localTrack.isExplicit,
                            localPath: localTrack.localFilePath,
                            isDownloaded: true,
                            artist: localTrack.artistId != null
                                ? Artist(id: localTrack.artistId!, name: localTrack.artistName ?? 'Unknown')
                                : null,
                            album: localTrack.albumId != null
                                ? Album(id: localTrack.albumId!, title: localTrack.albumTitle ?? 'Unknown', coverUrl: localTrack.coverUrl)
                                : null,
                          );

                          return _CollectionTrackTile(track: track, index: index, allTracks: tracks.map((t) => Track(
                            id: t.providerId,
                            title: t.title,
                            durationSeconds: t.durationSeconds,
                            isExplicit: t.isExplicit,
                            localPath: t.localFilePath,
                            isDownloaded: true,
                            artist: t.artistId != null ? Artist(id: t.artistId!, name: t.artistName ?? '') : null,
                            album: t.albumId != null ? Album(id: t.albumId!, title: t.albumTitle ?? '', coverUrl: t.coverUrl) : null,
                          )).toList());
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionTrackTile extends StatelessWidget {
  final Track track;
  final int index;
  final List<Track> allTracks;

  const _CollectionTrackTile({
    required this.track,
    required this.index,
    required this.allTracks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          getIt<AudioPlayerBloc>().add(PlayTrackEvent(
            track: track,
            initialQueue: allTracks,
            context: const PlaybackContext(
              type: PlaybackContextType.collection,
              id: 'local_saved',
            ),
          ));
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: track.album?.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: track.album!.coverUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Colors.white12,
                        child: const Icon(Icons.music_note, color: Colors.white38),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artist?.name ?? 'Unknown Artist',
                      style: const TextStyle(
                        color: AppTheme.tiffanyBlue,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Saved icon
              const Icon(
                Icons.download_done_rounded,
                color: AppTheme.tiffanyBlue,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

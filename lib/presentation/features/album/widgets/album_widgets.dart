import 'package:flutter/material.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/entities/album.dart';
import '../../../../../domain/entities/playback_context.dart';
import '../../../../../domain/entities/track.dart';
import '../../../widgets/explicit_badge.dart';
import '../../../widgets/bounceable.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../player/bloc/audio_player_event.dart';

class AlbumHeader extends StatelessWidget {
  const AlbumHeader({super.key, required this.album});

  final Album album;

  void _playAlbum(Album album, Track first) {
    getIt<AudioPlayerBloc>().add(PlayTrackEvent(
      track: first,
      initialQueue: album.tracks!,
      context: PlaybackContext(type: PlaybackContextType.album, id: album.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                album.artist?.name ?? 'Unknown Artist',
                style: const TextStyle(
                  color: AppTheme.tiffanyBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${album.tracks?.length ?? 0} tracks',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
              ),
            ],
          ),
        ),
        if (album.tracks?.isNotEmpty == true)
          Bounceable(
            onTap: () => _playAlbum(album, album.tracks!.first),
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

class AlbumTrackTile extends StatelessWidget {
  const AlbumTrackTile({
    super.key,
    required this.track,
    required this.index,
    required this.album,
  });

  final Track track;
  final int index;
  final Album album;

  void _play() {
    getIt<AudioPlayerBloc>().add(PlayTrackEvent(
      track: track,
      initialQueue: album.tracks!,
      context: PlaybackContext(type: PlaybackContextType.album, id: album.id),
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
            SizedBox(
              width: 32,
              child: Text(
                '${index + 1}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
              ),
            ),
            Expanded(
              child: Row(
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
            ),
            const SizedBox(width: 16),
            Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/entities/playback_context.dart';
import '../../../../../domain/entities/track.dart';
import '../../../widgets/explicit_badge.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../player/bloc/audio_player_event.dart';

class ChartList extends StatelessWidget {
  const ChartList({super.key, required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ChartTrackTile(
            track: tracks[index],
            index: index,
            queue: tracks,
          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1),
          childCount: tracks.length,
        ),
      ),
    );
  }
}

class ChartTrackTile extends StatelessWidget {
  const ChartTrackTile({
    super.key,
    required this.track,
    required this.index,
    required this.queue,
  });

  final Track track;
  final int index;
  final List<Track> queue;

  void _play() {
    getIt<AudioPlayerBloc>().add(PlayTrackEvent(
      track: track,
      initialQueue: List.from(queue),
      context: const PlaybackContext(
        type: PlaybackContextType.collection,
        id: 'charts',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _play,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              ChartCover(coverUrl: track.album?.coverUrl),
              const SizedBox(width: 16),
              Expanded(child: ChartTrackInfo(track: track)),
              const SizedBox(width: 12),
              const Icon(Icons.play_circle_fill_rounded, color: Colors.white24, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartCover extends StatelessWidget {
  const ChartCover({super.key, required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: coverUrl != null
          ? CachedNetworkImage(imageUrl: coverUrl!, width: 56, height: 56, fit: BoxFit.cover)
          : const ColoredBox(
              color: Colors.white12,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.music_note, color: Colors.white38),
              ),
            ),
    );
  }
}

class ChartTrackInfo extends StatelessWidget {
  const ChartTrackInfo({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                track.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
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
          track.artist?.name ?? 'Unknown Artist',
          style: const TextStyle(color: AppTheme.tiffanyBlue, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/entities/playback_context.dart';
import '../../../../../domain/entities/track.dart';
import '../../../widgets/bounceable.dart';
import '../../../widgets/explicit_badge.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../player/bloc/audio_player_event.dart';
import '../../player/view/audio_player_screen.dart';

class ChartList extends StatelessWidget {
  const ChartList({super.key, required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 360,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tracks.length,
          itemBuilder: (context, index) => ChartCard(
            track: tracks[index],
            index: index,
            queue: tracks,
          ).animate().fadeIn(delay: (index * 100).ms).scale(begin: const Offset(0.9, 0.9)),
        ),
      ),
    );
  }
}

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.track,
    required this.index,
    required this.queue,
  });

  final Track track;
  final int index;
  final List<Track> queue;

  void _play(BuildContext context) {
    getIt<AudioPlayerBloc>().add(PlayTrackEvent(
      track: track,
      initialQueue: List.from(queue),
      context: const PlaybackContext(
        type: PlaybackContextType.collection,
        id: 'charts',
      ),
    ));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AudioPlayerScreen(),
    );
  }

  void _navigateToAlbum(BuildContext context) {
    if (track.album != null) {
      context.push('/album/${track.album!.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Bounceable(
      onTap: () => _navigateToAlbum(context),
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: track.album?.coverUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.tiffanyBlue,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surface,
                        child: const Icon(Icons.music_note, color: Colors.white24),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Bounceable(
                    onTap: () => _play(context),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: colorScheme.onSurface,
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
            Text(
              track.artist?.name ?? 'Unknown Artist',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.tiffanyBlue,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

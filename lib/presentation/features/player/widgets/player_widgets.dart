import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/entities/track.dart';
import '../../../widgets/explicit_badge.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';

class AlbumArtWidget extends StatelessWidget {
  const AlbumArtWidget({
    super.key,
    required this.track,
    required this.dominantColor,
    required this.pulseController,
  });

  final Track track;
  final Color dominantColor;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final coverUrl = track.album?.coverUrl;
    final size = MediaQuery.sizeOf(context).width * 0.85;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: dominantColor.withValues(
                  alpha: 0.5 + (pulseController.value * 0.5),
                ),
                blurRadius: 60 + (pulseController.value * 40),
                spreadRadius: 10 + (pulseController.value * 20),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: coverUrl != null
            ? CachedNetworkImage(imageUrl: coverUrl, width: size, height: size, fit: BoxFit.cover)
            : ColoredBox(
                color: AppTheme.surface,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: const Icon(Icons.music_note, size: 64, color: Colors.white38),
                ),
              ),
      ),
    ).animate().scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack, duration: 600.ms);
  }
}

class TrackInfoWidget extends StatelessWidget {
  const TrackInfoWidget({super.key, required this.track});

  final Track? track;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track?.title ?? 'Not Playing',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (track?.isExplicit == true) ...[
                    const ExplicitBadge(),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      track?.artist?.name ?? '-',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 32),
          onPressed: () {},
        ).animate().scaleXY(delay: 400.ms, curve: Curves.bounceOut),
      ],
    );
  }
}

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({
    super.key,
    required this.position,
    required this.duration,
  });

  final Duration position;
  final Duration duration;

  String _format(Duration d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.inMinutes.remainder(60).abs())}:${pad(d.inSeconds.remainder(60).abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final posMs = position.inMilliseconds.toDouble().clamp(0.0, maxMs);
    final remaining = duration - position;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayColor: Colors.white.withValues(alpha: 0.1),
          ),
          child: Slider(
            min: 0,
            max: maxMs,
            value: posMs,
            onChanged: (value) =>
                getIt<AudioPlayerBloc>().add(SeekEvent(Duration(milliseconds: value.toInt()))),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _format(position),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
            ),
            Text(
              '-${_format(remaining)}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCirc);
  }
}

class ControlsWidget extends StatelessWidget {
  const ControlsWidget({
    super.key,
    required this.isPlaying,
    required this.isShuffle,
    required this.isRepeat,
    required this.dominantColor,
  });

  final bool isPlaying;
  final bool isShuffle;
  final bool isRepeat;
  final Color dominantColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            color: isShuffle ? AppTheme.tiffanyBlue : Colors.white.withValues(alpha: 0.5),
            size: 28,
          ),
          onPressed: () => getIt<AudioPlayerBloc>().add(ToggleShuffleEvent()),
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 48),
          onPressed: () => getIt<AudioPlayerBloc>().add(SkipToPreviousEvent()),
        ),
        PlayPauseButton(isPlaying: isPlaying, dominantColor: dominantColor),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 48),
          onPressed: () => getIt<AudioPlayerBloc>().add(SkipToNextEvent()),
        ),
        IconButton(
          icon: Icon(
            Icons.repeat_rounded,
            color: isRepeat ? AppTheme.tiffanyBlue : Colors.white.withValues(alpha: 0.5),
            size: 28,
          ),
          onPressed: () => getIt<AudioPlayerBloc>().add(ToggleRepeatEvent()),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack);
  }
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.dominantColor,
  });

  final bool isPlaying;
  final Color dominantColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isPlaying) {
          getIt<AudioPlayerBloc>().add(PauseEvent());
        } else {
          getIt<AudioPlayerBloc>().add(ResumeEvent());
        }
      },
      child: Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dominantColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: dominantColor.withValues(alpha: 0.6),
              blurRadius: 30,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 56,
        ),
      )
          .animate(target: isPlaying ? 1 : 0)
          .scaleXY(begin: 1.0, end: 1.06, duration: 200.ms, curve: Curves.easeInOutSine),
    );
  }
}

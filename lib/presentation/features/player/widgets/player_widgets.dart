import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/entities/track.dart';
import '../../../widgets/bounceable.dart';
import '../../../widgets/explicit_badge.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../../../widgets/marquee_text.dart';

class _SquareRectTween extends RectTween {
  _SquareRectTween({super.begin, super.end});

  @override
  Rect? lerp(double t) {
    if (begin == null || end == null) return Rect.lerp(begin, end, t);
    final center = Offset.lerp(begin!.center, end!.center, t)!;
    final width = begin!.width + (end!.width - begin!.width) * t;
    final height = begin!.height + (end!.height - begin!.height) * t;
    return Rect.fromCenter(center: center, width: width, height: height);
  }
}

Widget _getAlbumFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
  Widget imageChild,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      // Use an ease curve to make the rounding perfectly smooth during flight
      final t = Curves.easeInOutCubic.transform(animation.value);
      // Interpolate radius from 10.0 (miniplayer) to 24.0 (full screen player)
      final radius = 10.0 + 14.0 * t;
      return AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: imageChild,
        ),
      );
    },
  );
}

class AlbumArtWidget extends StatelessWidget {
  const AlbumArtWidget({
    super.key,
    required this.track,
    required this.dominantColor,
    required this.pulseController,
    this.routeOpacity = 1.0,
    this.customSize,
    this.customRadius,
  });

  final Track track;
  final Color dominantColor;
  final AnimationController pulseController;
  final double routeOpacity;
  final double? customSize;
  final double? customRadius;

  @override
  Widget build(BuildContext context) {
    final coverUrl = track.album?.coverUrl;
    final size = customSize ?? MediaQuery.sizeOf(context).shortestSide * 0.85;
    final radius = customRadius ?? 24.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: size),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      builder: (context, animatedSize, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: radius),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          builder: (context, animatedRadius, child) {
            return AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                return Container(
                  clipBehavior: Clip.antiAlias,
                  width: animatedSize,
                  height: animatedSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(animatedRadius),
                    boxShadow: customSize != null
                        ? null // No huge shadow in mini lyrics mode
                        : [
                            BoxShadow(
                              color: dominantColor.withValues(
                                alpha: (0.5 + (pulseController.value * 0.5)) * routeOpacity,
                              ),
                              blurRadius: 50 + (pulseController.value * 30),
                              spreadRadius: 8 + (pulseController.value * 15),
                            ),
                          ],
                  ),
                  child: child,
                );
              },
              child: child,
            );
          },
          child: child,
        );
      },
      child: Hero(
        tag: 'player_cover_${track.id}',
        createRectTween: (begin, end) => _SquareRectTween(begin: begin, end: end),
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
          return _getAlbumFlightShuttleBuilder(
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
            track.album?.coverUrl != null
                ? CachedNetworkImage(imageUrl: track.album!.coverUrl!, fit: BoxFit.cover)
                : ColoredBox(
                    color: Theme.of(flightContext).colorScheme.surface,
                    child: const Center(child: Icon(Icons.music_note, size: 64, color: Colors.white38)),
                  ),
          );
        },
        child: AspectRatio(
          aspectRatio: 1.0,
          child: coverUrl != null
              ? CachedNetworkImage(imageUrl: coverUrl, width: size, height: size, fit: BoxFit.cover)
              : ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: const Icon(Icons.music_note, size: 64, color: Colors.white38),
                  ),
                ),
        ),
      ),
    );
  }
}

class TrackInfoWidget extends StatefulWidget {
  const TrackInfoWidget({super.key, required this.track, this.isMiniMode = false});

  final Track? track;
  final bool isMiniMode;

  @override
  State<TrackInfoWidget> createState() => _TrackInfoWidgetState();
}

class _TrackInfoWidgetState extends State<TrackInfoWidget> {
  double _direction = 1.0;

  @override
  void didUpdateWidget(covariant TrackInfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track?.id != widget.track?.id) {
      final queue = getIt<AudioPlayerBloc>().state.queue;
      final oldIndex = queue.indexWhere((t) => t.id == oldWidget.track?.id);
      final newIndex = queue.indexWhere((t) => t.id == widget.track?.id);

      if (oldIndex != -1 && newIndex != -1) {
        _direction = newIndex > oldIndex ? 1.0 : -1.0;
      } else {
        _direction = 1.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.isMiniMode ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: widget.isMiniMode ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        Flexible(
          fit: widget.isMiniMode ? FlexFit.loose : FlexFit.tight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            reverseDuration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final inAnimation = child.key == ValueKey(widget.track?.id ?? 'none');
              final sign = inAnimation ? _direction : -_direction;
              
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(sign * 0.3, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: Column(
              key: ValueKey(widget.track?.id ?? 'none'),
              mainAxisSize: MainAxisSize.min, // Prevents taking infinite height and moving the like button
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarqueeText(
                  text: widget.track?.title ?? 'Not Playing',
                  style: TextStyle(
                    fontSize: widget.isMiniMode ? 18 : 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: widget.isMiniMode ? 0 : 4),
                Row(
                  children: [
                    if (widget.track?.isExplicit == true) ...[
                      const ExplicitBadge(),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: MarqueeText(
                        text: widget.track?.artist?.name ?? '-',
                        style: TextStyle(
                          fontSize: widget.isMiniMode ? 13 : 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Bounceable(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.favorite_border_rounded, color: Colors.white, size: widget.isMiniMode ? 24 : 32),
          ),
        ),
      ],
    );
  }
}

class ProgressBarWidget extends StatefulWidget {
  const ProgressBarWidget({
    super.key,
    required this.position,
    required this.duration,
  });

  final Duration position;
  final Duration duration;

  @override
  State<ProgressBarWidget> createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends State<ProgressBarWidget> {
  bool _isDragging = false;

  String _format(Duration d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.inMinutes.remainder(60).abs())}:${pad(d.inSeconds.remainder(60).abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = widget.duration.inMilliseconds > 0 ? widget.duration.inMilliseconds.toDouble() : 1.0;
    final posMs = widget.position.inMilliseconds.toDouble().clamp(0.0, maxMs);
    final remaining = widget.duration - widget.position;
    final progressRatio = (posMs / maxMs).clamp(0.0, 1.0);

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) => setState(() => _isDragging = true),
          onHorizontalDragEnd: (details) => setState(() => _isDragging = false),
          onHorizontalDragCancel: () => setState(() => _isDragging = false),
          onHorizontalDragUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final dx = details.localPosition.dx.clamp(0.0, box.size.width);
            final percent = dx / box.size.width;
            getIt<AudioPlayerBloc>().add(SeekEvent(Duration(milliseconds: (percent * maxMs).toInt())));
          },
          onTapDown: (details) {
            setState(() => _isDragging = true);
            final RenderBox box = context.findRenderObject() as RenderBox;
            final dx = details.localPosition.dx.clamp(0.0, box.size.width);
            final percent = dx / box.size.width;
            getIt<AudioPlayerBloc>().add(SeekEvent(Duration(milliseconds: (percent * maxMs).toInt())));
          },
          onTapUp: (_) => setState(() => _isDragging = false),
          onTapCancel: () => setState(() => _isDragging = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            // Visually, the touch target remains large (through the container or GestureDetector's padding logic)
            // but the height of the visual bar changes.
            height: _isDragging ? 12.0 : 6.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), // overall background (grey)
              borderRadius: BorderRadius.circular(20), // fully rounded on both ends
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progressRatio,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ), // White active part: left rounded, right sharp
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _format(widget.position),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              '-${_format(remaining)}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}


class ControlsWidget extends StatelessWidget {
  const ControlsWidget({
    super.key,
    required this.isPlaying,
    required this.isShuffle,
    required this.isRepeat,
    required this.dominantColor,
    required this.hasLyrics,
    required this.isLoadingLyrics,
    this.onLyricsTapped,
  });

  final bool isPlaying;
  final bool isShuffle;
  final bool isRepeat;
  final Color dominantColor;
  final bool hasLyrics;
  final bool isLoadingLyrics;
  final VoidCallback? onLyricsTapped;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Bounceable(
          onTap: () => getIt<AudioPlayerBloc>().add(ToggleRepeatEvent()),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.repeat_rounded,
              color: isRepeat ? AppTheme.tiffanyBlue : Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
        ),
        Bounceable(
          onTap: () => getIt<AudioPlayerBloc>().add(SkipToPreviousEvent()),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.skip_previous_rounded, color: Colors.white, size: 48),
          ),
        ),
        PlayPauseButton(isPlaying: isPlaying, dominantColor: dominantColor),
        Bounceable(
          onTap: () => getIt<AudioPlayerBloc>().add(SkipToNextEvent()),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.skip_next_rounded, color: Colors.white, size: 48),
          ),
        ),
        Bounceable(
          onTap: () {
            if (hasLyrics && !isLoadingLyrics) {
              onLyricsTapped?.call();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.lyrics_rounded,
              color: Colors.white.withValues(
                alpha: isLoadingLyrics ? 0.5 : (hasLyrics ? 1.0 : 0.2),
              ),
              size: 28,
            ),
          ),
        ),
      ],
    );
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
    return Bounceable(
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
      ).animate(target: isPlaying ? 1 : 0).scaleXY(begin: 1.0, end: 1.06, duration: 200.ms, curve: Curves.easeInOutSine),
    );
  }
}

class PlayerTopBarWidget extends StatelessWidget {
  const PlayerTopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 52),
        const Text(
          'Now Playing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 52), // Replaced icon to keep it balanced
      ],
    );
  }
}

class PlayerDragIndicatorWidget extends StatelessWidget {
  const PlayerDragIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/player_transition_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_state.dart';
import '../widgets/player_widgets.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Color? dominantColor;
  final Animation<double>? routeAnimation;

  const AudioPlayerScreen({super.key, this.dominantColor, this.routeAnimation});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  Color? _dominantColor;
  late final AnimationController _pulseController;
  String _lastCoverUrl = '';

  @override
  void initState() {
    super.initState();
    _dominantColor = widget.dominantColor;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    final initialTrack = context.read<AudioPlayerBloc>().state.currentTrack;
    if (initialTrack?.album?.coverUrl != null) {
      _lastCoverUrl = initialTrack!.album!.coverUrl!;
      if (widget.dominantColor == null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _lastCoverUrl = '';
            _extractColor(initialTrack.album!.coverUrl!);
          }
        });
      }
    }

    // Initialize transition listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeAnimation =
          widget.routeAnimation ?? ModalRoute.of(context)?.animation;
      routeAnimation?.addListener(_onAnimationProgressChanged);
    });
  }

  void _onAnimationProgressChanged() {
    final anim = widget.routeAnimation ?? ModalRoute.of(context)?.animation;
    if (anim != null) {
      // Hybrid Curve Logic:
      // Forward: Fast & Responsive but visible expansion (easeOutCubic)
      // Reverse: Buttery smooth & Balanced (easeInOutCubic)
      final bool isReversing = anim.status == AnimationStatus.reverse;
      final curvedValue = isReversing
          ? Curves.easeInOutCubic.transform(anim.value)
          : Curves.easeOutCubic.transform(anim.value);

      getIt<PlayerTransitionService>().updateProgress(curvedValue);
    }
  }

  @override
  void dispose() {
    final routeAnimation =
        widget.routeAnimation ?? ModalRoute.of(context)?.animation;
    routeAnimation?.removeListener(_onAnimationProgressChanged);
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _extractColor(String coverUrl) async {
    if (coverUrl.isEmpty || coverUrl == _lastCoverUrl) return;
    _lastCoverUrl = coverUrl;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(coverUrl),
      );
      if (palette.dominantColor != null && mounted) {
        setState(() => _dominantColor = palette.dominantColor!.color);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final routeAnimation =
        widget.routeAnimation ??
        ModalRoute.of(context)?.animation ??
        const AlwaysStoppedAnimation(1.0);

    return BlocConsumer<AudioPlayerBloc, AudioPlayerState>(
      listenWhen: (prev, curr) =>
          prev.currentTrack?.album?.coverUrl !=
          curr.currentTrack?.album?.coverUrl,
      listener: (context, state) {
        final url = state.currentTrack?.album?.coverUrl;
        if (url != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _extractColor(url);
          });
        }
      },
      builder: (context, state) {
        final isPlaying = state.isPlaying;

        if (isPlaying) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! > 10) {
              Navigator.pop(context);
            }
          },
          child: AnimatedBuilder(
            animation: routeAnimation,
            builder: (context, child) {
              final bool isReversing =
                  routeAnimation.status == AnimationStatus.reverse;
              final t = isReversing
                  ? Curves.easeInOutCubic.transform(routeAnimation.value)
                  : Curves.easeOutCubic.transform(routeAnimation.value);

              final screenH = MediaQuery.sizeOf(context).height;
              final screenW = MediaQuery.sizeOf(context).width;

              final width = (screenW - 32.0) + 32.0 * t;
              final height = 68.0 + (screenH - 68.0) * t;
              final bottom = 110.0 * (1 - t);
              final left = (screenW - width) / 2;

              final deviceRadius =
                  getIt<PlayerTransitionService>().deviceCornerRadius.value;
              final currentRadius = 16.0 * (1 - t) + deviceRadius * t;

              return Stack(
                children: [
                  Positioned(
                    left: left,
                    bottom: bottom,
                    width: width,
                    height: height,
                    child: Opacity(
                      opacity: t > 0.0 ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(currentRadius),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // 1. Base glassmorphic layer (matches the mini player exactly)
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                              child: const SizedBox.expand(),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    (_dominantColor ??
                                            widget.dominantColor ??
                                            AppTheme.tiffanyBlue)
                                        .withValues(alpha: 0.35),
                                    Theme.of(context).colorScheme.surface
                                        .withValues(alpha: 0.5),
                                    Theme.of(context).colorScheme.surface
                                        .withValues(alpha: 0.5),
                                  ],
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                            // 2. Solid color gradient that smoothly fades in as it expands
                            Opacity(
                              opacity: Curves.easeInOut.transform(
                                t,
                              ), // Cross-fade
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      _dominantColor ??
                                          widget.dominantColor ??
                                          AppTheme.tiffanyBlue,
                                      Theme.of(context).scaffoldBackgroundColor,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // 3. Mini Player Replica (crossfades out during early expansion)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 68,
                              child: Opacity(
                                opacity: (1.0 - t * 5).clamp(0.0, 1.0),
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 46,
                                              ), // Space for Hero Cover
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      state
                                                              .currentTrack
                                                              ?.title ??
                                                          '-',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      state
                                                              .currentTrack
                                                              ?.artist
                                                              ?.name ??
                                                          '-',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 32),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 12,
                                        top: 0,
                                        bottom: 0,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.skip_previous_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Icon(
                                                isPlaying
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.skip_next_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -left,
                              bottom: -bottom,
                              width: screenW,
                              height: screenH,
                              child: child!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: routeAnimation,
                        builder: (context, child) {
                          final bool isReversing =
                              routeAnimation.status == AnimationStatus.reverse;
                          // Forward: Fades in quicker (35% to 95%)
                          // Reverse: Fades out immediately between 100% and 70%
                          final opacity = isReversing
                              ? const Interval(
                                  0.7,
                                  1.0,
                                  curve: Curves.easeOut,
                                ).transform(routeAnimation.value)
                              : const Interval(
                                  0.35,
                                  0.95,
                                  curve: Curves.easeOutSine,
                                ).transform(routeAnimation.value);
                          return Opacity(
                            opacity: opacity,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PlayerDragIndicatorWidget(),
                                PlayerTopBarWidget(),
                              ],
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: routeAnimation,
                          builder: (context, child) {
                            final bool isReversing =
                                routeAnimation.status ==
                                AnimationStatus.reverse;
                            // Forward: Fades in slightly faster (25% to 90%)
                            // Reverse: Vanishes early (100% to 60%) to prevent visual clutter
                            final opacity = isReversing
                                ? const Interval(
                                    0.6,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ).transform(routeAnimation.value)
                                : const Interval(
                                    0.25,
                                    0.9,
                                    curve: Curves.easeOutSine,
                                  ).transform(routeAnimation.value);

                            // The smoothest continuous movement to completely eliminate snapping
                            final dy = Curves.easeInOutCubic.transform(
                              routeAnimation.value,
                            );

                            final isLandscape =
                                MediaQuery.orientationOf(context) ==
                                Orientation.landscape;

                            final albumArt = state.currentTrack == null
                                ? const SizedBox.shrink()
                                : AlbumArtWidget(
                                    track: state.currentTrack!,
                                    dominantColor:
                                        _dominantColor ?? Colors.transparent,
                                    pulseController: _pulseController,
                                    routeOpacity: opacity,
                                  );

                            final controls = Transform.translate(
                              offset: Offset(0, 40 * (1 - dy)),
                              child: Opacity(
                                opacity: opacity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TrackInfoWidget(track: state.currentTrack),
                                    SizedBox(height: isLandscape ? 16 : 24),
                                    ProgressBarWidget(
                                      position: state.position,
                                      duration: state.duration,
                                    ),
                                    SizedBox(height: isLandscape ? 24 : 32),
                                    ControlsWidget(
                                      isPlaying: isPlaying,
                                      isShuffle: state.isShuffleEnabled,
                                      isRepeat: state.isRepeatEnabled,
                                      dominantColor:
                                          _dominantColor ??
                                          AppTheme.tiffanyBlue,
                                    ),
                                    SizedBox(height: isLandscape ? 16 : 48),
                                  ],
                                ),
                              ),
                            );

                            if (isLandscape) {
                              return Row(
                                children: [
                                  Expanded(child: Center(child: albumArt)),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: controls,
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Expanded(child: Center(child: albumArt)),
                                controls,
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

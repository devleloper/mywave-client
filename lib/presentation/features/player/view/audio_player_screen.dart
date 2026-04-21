import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/player_transition_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';
import '../widgets/player_widgets.dart';
import '../widgets/lyrics_view_widget.dart';

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

  bool _isLyricsMode = false;
  bool _isControlsVisible = true;
  Timer? _inactivityTimer;

  void _resetInactivityTimer() {
    if (mounted) setState(() => _isControlsVisible = true);
    _inactivityTimer?.cancel();
    if (_isLyricsMode) {
      _inactivityTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _isControlsVisible = false);
      });
    }
  }

  void _toggleLyricsMode() {
    setState(() {
      _isLyricsMode = !_isLyricsMode;
      _resetInactivityTimer();
    });
  }

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
    _inactivityTimer?.cancel();
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
                          final dy = Curves.easeInOutCubic.transform(
                            routeAnimation.value,
                          );
                          return Opacity(
                            opacity: opacity,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                20 * (1 - dy),
                              ), // Slide up 20px when entering route
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 32,
                                    child: Stack(
                                      children: [
                                        const Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: PlayerDragIndicatorWidget(),
                                          ),
                                        ),
                                        if (kDebugMode)
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            top: 0,
                                            child: IconButton(
                                              icon: Icon(
                                                state.isDebugSimulationActive
                                                    ? Icons.bug_report
                                                    : Icons.bug_report_outlined,
                                                color:
                                                    state
                                                        .isDebugSimulationActive
                                                    ? Colors.greenAccent
                                                    : Colors.white30,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<AudioPlayerBloc>()
                                                    .add(
                                                      ToggleDebugSimulationEvent(),
                                                    );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  ClipRect(
                                    child: AnimatedAlign(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeInOutCubic,
                                      alignment: Alignment.topCenter,
                                      heightFactor: _isLyricsMode ? 0.0 : 1.0,
                                      child: AnimatedSlide(
                                        offset: _isLyricsMode
                                            ? const Offset(0, 1.0)
                                            : Offset.zero,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.easeInOutCubic,
                                        child: AnimatedOpacity(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          opacity: _isLyricsMode ? 0.0 : 1.0,
                                          child: const Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: PlayerTopBarWidget(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

                            final albumArtWidget = AlbumArtWidget(
                              track: state.currentTrack!,
                              dominantColor:
                                  _dominantColor ?? Colors.transparent,
                              pulseController: _pulseController,
                              routeOpacity: opacity,
                              customSize: _isLyricsMode ? 46.0 : null,
                              customRadius: _isLyricsMode ? 10.0 : null,
                            );

                            final albumArt = state.currentTrack == null
                                ? const SizedBox.shrink()
                                : AnimatedAlign(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    alignment: _isLyricsMode
                                        ? Alignment.topLeft
                                        : Alignment.center,
                                    child: albumArtWidget,
                                  );

                            final miniTrackInfo = state.currentTrack == null
                                ? const SizedBox.shrink()
                                : Align(
                                    alignment: Alignment.topLeft,
                                    child: AnimatedSlide(
                                      offset: _isLyricsMode
                                          ? Offset.zero
                                          : const Offset(0, 1.0),
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeInOutCubic,
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        opacity: _isLyricsMode ? 1.0 : 0.0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 60.0,
                                            right:
                                                24.0, // Space for the like button
                                          ),
                                          child: TrackInfoWidget(
                                            track: state.currentTrack,
                                            isMiniMode: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                            final controls = Transform.translate(
                              offset: Offset(0, 40 * (1 - dy)),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    top: -200,
                                    left: -50,
                                    right: -50,
                                    bottom: -50,
                                    child: AnimatedSlide(
                                      offset: !_isLyricsMode
                                          ? const Offset(0, 1.0)
                                          : (!_isControlsVisible
                                                ? const Offset(0, 1.2)
                                                : Offset.zero),
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      child: IgnorePointer(
                                        child: ShaderMask(
                                          shaderCallback: (Rect bounds) {
                                            return const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.white,
                                              ],
                                              stops: [0.0, 0.4],
                                            ).createShader(bounds);
                                          },
                                          blendMode: BlendMode.dstIn,
                                          child: ClipRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 24.0,
                                                sigmaY: 24.0,
                                              ),
                                              child: ColoredBox(
                                                color: Color.lerp(
                                                  _dominantColor ??
                                                      Colors.black,
                                                  Colors.black,
                                                  0.5,
                                                )!.withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: opacity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ClipRect(
                                          child: AnimatedAlign(
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            curve: Curves.easeInOutCubic,
                                            alignment: Alignment.topCenter,
                                            heightFactor: _isLyricsMode
                                                ? 0.0
                                                : 1.0,
                                            child: AnimatedSlide(
                                              offset: _isLyricsMode
                                                  ? const Offset(0, 1.0)
                                                  : Offset.zero,
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              curve: Curves.easeInOutCubic,
                                              child: AnimatedOpacity(
                                                duration: const Duration(
                                                  milliseconds: 400,
                                                ),
                                                opacity: _isLyricsMode
                                                    ? 0.0
                                                    : 1.0,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                    bottom: 24.0,
                                                  ), // Padding replaces the SizedBox below
                                                  child: TrackInfoWidget(
                                                    track: state.currentTrack,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isLandscape)
                                          const SizedBox(height: 16),
                                        AnimatedSlide(
                                          offset:
                                              (_isLyricsMode &&
                                                  !_isControlsVisible)
                                              ? const Offset(0, 8.0)
                                              : Offset.zero,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ), // Delayed compared to controls
                                          curve: Curves.easeOutCubic,
                                          child: ProgressBarWidget(
                                            position: state.position,
                                            duration: state.duration,
                                          ),
                                        ),
                                        SizedBox(height: isLandscape ? 24 : 32),
                                        AnimatedSlide(
                                          offset:
                                              (_isLyricsMode &&
                                                  !_isControlsVisible)
                                              ? const Offset(0, 2.0)
                                              : Offset.zero,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ), // Appears first
                                          curve: Curves.easeOutCubic,
                                          child: ControlsWidget(
                                            isPlaying: isPlaying,
                                            isShuffle: state.isShuffleEnabled,
                                            isRepeat: state.isRepeatEnabled,
                                            dominantColor:
                                                _dominantColor ??
                                                AppTheme.tiffanyBlue,
                                            hasLyrics:
                                                state.currentLyrics != null,
                                            isLoadingLyrics:
                                                state.isLoadingLyrics,
                                            onLyricsTapped: _toggleLyricsMode,
                                          ),
                                        ),
                                        SizedBox(height: isLandscape ? 16 : 48),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );

                            final lyricsView = Positioned.fill(
                              child: AnimatedSwitcher(
                                duration: const Duration(
                                  milliseconds: 800,
                                ), // Appears longer
                                reverseDuration: const Duration(
                                  milliseconds: 300,
                                ), // Leaves faster
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                            begin: 0.85,
                                            end: 1.0,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                child:
                                    (_isLyricsMode &&
                                        state.currentLyrics != null)
                                    ? LyricsViewWidget(
                                        key: const ValueKey('lyrics'),
                                        lyrics: state.currentLyrics!,
                                        position: state.position,
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('empty_lyrics'),
                                      ),
                              ),
                            );

                            if (isLandscape) {
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _resetInactivityTimer,
                                child: Stack(
                                  children: [
                                    lyricsView,
                                    Row(
                                      children: [
                                        Expanded(child: albumArt),
                                        const SizedBox(width: 32),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: controls,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _resetInactivityTimer,
                              child: Stack(
                                children: [
                                  lyricsView,
                                  Column(
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [albumArt, miniTrackInfo],
                                        ),
                                      ),
                                      controls,
                                    ],
                                  ),
                                ],
                              ),
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

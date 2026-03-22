import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

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
  }

  @override
  void dispose() {
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
              final t = Curves.easeInOutCubic.transform(routeAnimation.value);
              final screenH = MediaQuery.of(context).size.height;
              final screenW = MediaQuery.of(context).size.width;

              final width = (screenW - 32.0) + 32.0 * t;
              final height = 68.0 + (screenH - 68.0) * t;
              final bottom = 110.0 * (1 - t);
              final left = (screenW - width) / 2;

              return Stack(
                children: [
                  Positioned(
                    left: left,
                    bottom: bottom,
                    width: width,
                    height: height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0 * (1 - t)),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _dominantColor ?? Theme.of(context).colorScheme.surface,
                                  Theme.of(context).scaffoldBackgroundColor,
                                ],
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
                ],
              );
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: AnimatedBuilder(
                  animation: routeAnimation,
                  builder: (context, child) {
                    final opacity = const Interval(0.4, 1.0, curve: Curves.easeIn).transform(
                      routeAnimation.value,
                    );
                    return Opacity(opacity: opacity, child: child);
                  },
                  child: AppBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text(
                      'Now Playing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.queue_music_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedBuilder(
                    animation: routeAnimation,
                    builder: (context, child) {
                      final opacity = const Interval(0.3, 1.0, curve: Curves.easeIn).transform(
                        routeAnimation.value,
                      );
                      final dy = Curves.easeOutCubic.transform(
                        routeAnimation.value,
                      );

                      return Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: state.currentTrack == null
                                  ? const SizedBox.shrink()
                                  : AlbumArtWidget(
                                      track: state.currentTrack!,
                                      dominantColor:
                                          _dominantColor ?? Colors.transparent,
                                      pulseController: _pulseController,
                                      routeOpacity: opacity,
                                    ),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, 40 * (1 - dy)),
                            child: Opacity(
                              opacity: opacity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TrackInfoWidget(track: state.currentTrack),
                                  const SizedBox(height: 24),
                                  ProgressBarWidget(
                                    position: state.position,
                                    duration: state.duration,
                                  ),
                                  const SizedBox(height: 32),
                                  ControlsWidget(
                                    isPlaying: isPlaying,
                                    isShuffle: state.isShuffleEnabled,
                                    isRepeat: state.isRepeatEnabled,
                                    dominantColor:
                                        _dominantColor ?? AppTheme.tiffanyBlue,
                                  ),
                                  const SizedBox(height: 48),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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

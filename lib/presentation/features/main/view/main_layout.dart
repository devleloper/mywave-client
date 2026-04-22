import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/player_transition_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../../widgets/bounceable.dart';
import '../../player/bloc/audio_player_event.dart';
import '../../player/bloc/audio_player_state.dart';
import '../../player/view/audio_player_screen.dart';
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
      // Use the same smooth ease curve for the flight
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

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  Color? _dominantColor;
  String _lastCoverUrl = '';

  Future<void> _openAudioPlayer(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return AudioPlayerScreen(
            dominantColor: _dominantColor ?? AppTheme.tiffanyBlue,
            routeAnimation: animation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
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

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transitionService = getIt<PlayerTransitionService>();

    return Scaffold(
      backgroundColor: const Color(
        0xFF141414,
      ), // Softer, lighter base color instead of pure black
      body: ValueListenableBuilder<double>(
        valueListenable: transitionService.expansionProgress,
        builder: (context, progress, child) {
          // progress is now pre-curved by AudioPlayerScreen
          // Forward: easeOutQuart (instant), Reverse: easeInOutCubic (smooth)
          final curvedProgress = progress;
          final scale = 1.0 - (0.07 * curvedProgress);
          final radius = transitionService.deviceCornerRadius.value;

          return Stack(
            children: [
              // 1. Background Content (Receding Stack)
              Transform.scale(
                scale: scale,
                child: Padding(
                  // Dynamic padding to enhance depth
                  padding: EdgeInsets.all(curvedProgress * 2.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: Stack(
                      children: [
                        widget.navigationShell,
                        // Dimming overlay
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: progress < 0.05,
                            child: ColoredBox(
                              color: Colors.black.withValues(
                                alpha: curvedProgress * 0.55,
                              ),
                            ),
                          ),
                        ),
                        // Liquid Glass Bottom Navigation
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 32,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                              child: Container(
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surface.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _NavItem(
                                      icon: Icons.home_rounded,
                                      label: 'Home',
                                      isSelected:
                                          widget.navigationShell.currentIndex ==
                                          0,
                                      onTap: () => _onTap(0),
                                    ),
                                    _NavItem(
                                      icon: Icons.search_rounded,
                                      label: 'Search',
                                      isSelected:
                                          widget.navigationShell.currentIndex ==
                                          1,
                                      onTap: () => _onTap(1),
                                    ),
                                    _NavItem(
                                      icon: Icons.library_music_rounded,
                                      label: 'Collection',
                                      isSelected:
                                          widget.navigationShell.currentIndex ==
                                          2,
                                      onTap: () => _onTap(2),
                                    ),
                                    _NavItem(
                                      icon: Icons.person_rounded,
                                      label: 'Profile',
                                      isSelected:
                                          widget.navigationShell.currentIndex ==
                                          3,
                                      onTap: () => _onTap(3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Mini Player Layer (Stationary Hero anchor)
              Positioned(
                left: 16,
                right: 16,
                bottom: 110,
                child: Opacity(
                  opacity: (1.0 - progress * 5).clamp(0.0, 1.0),
                  child: BlocConsumer<AudioPlayerBloc, AudioPlayerState>(
                    listenWhen: (prev, curr) =>
                        prev.currentTrack?.album?.coverUrl !=
                        curr.currentTrack?.album?.coverUrl,
                    listener: (context, state) {
                      final url = state.currentTrack?.album?.coverUrl;
                      if (url != null && url != _lastCoverUrl) {
                        _extractColor(url);
                      }
                    },
                    builder: (context, state) {
                      final track = state.currentTrack;
                      if (track == null) return const SizedBox.shrink();

                      if (track.album?.coverUrl != null &&
                          _dominantColor == null &&
                          _lastCoverUrl.isEmpty) {
                        _extractColor(track.album!.coverUrl!);
                      }

                      return SizedBox(
                            height: 68,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Bounceable(
                                    onTap: () => _openAudioPlayer(context),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: progress == 0.0
                                                ? 1.0
                                                : 0.0,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 40,
                                                  sigmaY: 40,
                                                ),
                                                child: const SizedBox.expand(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: progress == 0.0
                                                ? 1.0
                                                : 0.0,
                                            child: Material(
                                              type: MaterialType.transparency,
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 800,
                                                ),
                                                curve: Curves.easeInOutSine,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                    colors: [
                                                      (_dominantColor ??
                                                              AppTheme
                                                                  .tiffanyBlue)
                                                          .withValues(
                                                            alpha: 0.35,
                                                          ),
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                    ],
                                                    stops: const [
                                                      0.0,
                                                      0.4,
                                                      1.0,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.1),
                                                    width: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 46,
                                                  height: 46,
                                                  child: Hero(
                                                    tag:
                                                        'player_cover_${track.id}',
                                                    createRectTween:
                                                        (begin, end) =>
                                                            _SquareRectTween(
                                                              begin: begin,
                                                              end: end,
                                                            ),
                                                    flightShuttleBuilder:
                                                        (
                                                          flightContext,
                                                          animation,
                                                          flightDirection,
                                                          fromHeroContext,
                                                          toHeroContext,
                                                        ) {
                                                          return _getAlbumFlightShuttleBuilder(
                                                            flightContext,
                                                            animation,
                                                            flightDirection,
                                                            fromHeroContext,
                                                            toHeroContext,
                                                            track.album?.coverUrl !=
                                                                    null
                                                                ? CachedNetworkImage(
                                                                    imageUrl: track
                                                                        .album!
                                                                        .coverUrl!,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : Container(
                                                                    color: AppTheme
                                                                        .tiffanyBlue
                                                                        .withValues(
                                                                          alpha:
                                                                              0.2,
                                                                        ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .music_note,
                                                                      color: AppTheme
                                                                          .tiffanyBlue,
                                                                    ),
                                                                  ),
                                                          );
                                                        },
                                                    child: AspectRatio(
                                                      aspectRatio: 1.0,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        child:
                                                            track
                                                                    .album
                                                                    ?.coverUrl !=
                                                                null
                                                            ? CachedNetworkImage(
                                                                imageUrl: track
                                                                    .album!
                                                                    .coverUrl!,
                                                                width: 46,
                                                                height: 46,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Container(
                                                                width: 46,
                                                                height: 46,
                                                                color: AppTheme
                                                                    .tiffanyBlue
                                                                    .withValues(
                                                                      alpha:
                                                                          0.2,
                                                                    ),
                                                                child: const Icon(
                                                                  Icons
                                                                      .music_note,
                                                                  color: AppTheme
                                                                      .tiffanyBlue,
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Opacity(
                                                    opacity: progress == 0.0
                                                        ? 1.0
                                                        : 0.0,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        MarqueeText(
                                                          text: track.title,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                        MarqueeText(
                                                          text:
                                                              track
                                                                  .artist
                                                                  ?.name ??
                                                              '-',
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.6,
                                                                ),
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 140),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 12,
                                          top: 0,
                                          bottom: 0,
                                          child: Opacity(
                                            opacity: progress == 0.0
                                                ? 1.0
                                                : 0.0,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Bounceable(
                                                  onTap: () =>
                                                      getIt<AudioPlayerBloc>()
                                                          .add(
                                                            SkipToPreviousEvent(),
                                                          ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .skip_previous_rounded,
                                                      color: Colors.white,
                                                      size: 28,
                                                    ),
                                                  ),
                                                ),
                                                Bounceable(
                                                  onTap: () {
                                                    if (state.isPlaying) {
                                                      getIt<AudioPlayerBloc>()
                                                          .add(PauseEvent());
                                                    } else {
                                                      getIt<AudioPlayerBloc>()
                                                          .add(ResumeEvent());
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Icon(
                                                      state.isPlaying
                                                          ? Icons.pause_rounded
                                                          : Icons
                                                                .play_arrow_rounded,
                                                      color: Colors.white,
                                                      size: 32,
                                                    ),
                                                  ),
                                                ),
                                                Bounceable(
                                                  onTap: () =>
                                                      getIt<AudioPlayerBloc>()
                                                          .add(
                                                            SkipToNextEvent(),
                                                          ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons.skip_next_rounded,
                                                      color: Colors.white,
                                                      size: 28,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(key: const ValueKey('miniplayer_entrance'))
                          .slideY(
                            begin: 1.0,
                            end: 0.0,
                            duration: 400.ms,
                            curve: Curves.easeOutQuart,
                          );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppTheme.tiffanyBlue
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: isSelected ? 28 : 24),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.tiffanyBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.tiffanyBlue.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:palette_generator/palette_generator.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/bounceable.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../player/bloc/audio_player_event.dart';
import '../../player/bloc/audio_player_state.dart';
import '../../player/view/audio_player_screen.dart';

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
      final radius = 10.0 + 30.0 * animation.value;
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

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  Color? _dominantColor;
  String _lastCoverUrl = '';

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
    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell, // The current branch view
          // Custom Liquid Glass Bottom Navigation
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isSelected: widget.navigationShell.currentIndex == 0,
                        onTap: () => _onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.search_rounded,
                        label: 'Search',
                        isSelected: widget.navigationShell.currentIndex == 1,
                        onTap: () => _onTap(1),
                      ),
                      _NavItem(
                        icon: Icons.library_music_rounded,
                        label: 'Collection',
                        isSelected: widget.navigationShell.currentIndex == 2,
                        onTap: () => _onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        isSelected: widget.navigationShell.currentIndex == 3,
                        onTap: () => _onTap(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Mini Player Layer
          Positioned(
            left: 16,
            right: 16,
            bottom: 110, // Above the liquid glass nav bar
            child: BlocConsumer<AudioPlayerBloc, AudioPlayerState>(
              listenWhen: (prev, curr) => prev.currentTrack?.album?.coverUrl != curr.currentTrack?.album?.coverUrl,
              listener: (context, state) {
                final url = state.currentTrack?.album?.coverUrl;
                if (url != null) _extractColor(url);
              },
              builder: (context, state) {
                final track = state.currentTrack;
                if (track == null) return const SizedBox.shrink();

                // If playing and we haven't extracted yet, do a silent extraction initialization
                if (track.album?.coverUrl != null && _dominantColor == null && _lastCoverUrl.isEmpty) {
                  _extractColor(track.album!.coverUrl!);
                }

                return                  Bounceable(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
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
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
                              ),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 68,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              type: MaterialType.transparency,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      width: 0.5,
                                    ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 46,
                                    height: 46,
                                    child: Hero(
                                      tag: 'player_cover_${track.id}',
                                      createRectTween: (begin, end) => _SquareRectTween(begin: begin, end: end),
                                      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                                        return _getAlbumFlightShuttleBuilder(
                                          flightContext, animation, flightDirection, fromHeroContext, toHeroContext,
                                          track.album?.coverUrl != null
                                            ? CachedNetworkImage(imageUrl: track.album!.coverUrl!, fit: BoxFit.cover)
                                            : Container(color: AppTheme.tiffanyBlue.withValues(alpha: 0.2), child: const Icon(Icons.music_note, color: AppTheme.tiffanyBlue)),
                                        );
                                      },
                                      child: AspectRatio(
                                        aspectRatio: 1.0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: track.album?.coverUrl != null
                                            ? CachedNetworkImage(imageUrl: track.album!.coverUrl!, width: 46, height: 46, fit: BoxFit.cover)
                                            : Container(width: 46, height: 46, color: AppTheme.tiffanyBlue.withValues(alpha: 0.2), child: const Icon(Icons.music_note, color: AppTheme.tiffanyBlue)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          track.title,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          track.artist?.name ?? '-',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                                    onPressed: () => getIt<AudioPlayerBloc>().add(SkipToPreviousEvent()),
                                  ),
                                  IconButton(
                                    icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
                                    onPressed: () {
                                      if (state.isPlaying) {
                                        getIt<AudioPlayerBloc>().add(PauseEvent());
                                      } else {
                                        getIt<AudioPlayerBloc>().add(ResumeEvent());
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                                    onPressed: () => getIt<AudioPlayerBloc>().add(SkipToNextEvent()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().slideY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeOutQuart);
              },
            ),
          ),
        ],
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
    final color = isSelected ? AppTheme.tiffanyBlue : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54);
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
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

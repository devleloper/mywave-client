import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../../player/bloc/audio_player_event.dart';
import '../../player/bloc/audio_player_state.dart';
import '../../player/view/audio_player_screen.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell, // The current branch view
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
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isSelected: navigationShell.currentIndex == 0,
                        onTap: () => _onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.search_rounded,
                        label: 'Search',
                        isSelected: navigationShell.currentIndex == 1,
                        onTap: () => _onTap(1),
                      ),
                      _NavItem(
                        icon: Icons.library_music_rounded,
                        label: 'Collection',
                        isSelected: navigationShell.currentIndex == 2,
                        onTap: () => _onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        isSelected: navigationShell.currentIndex == 3,
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
            child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
              builder: (context, state) {
                final track = state.currentTrack;
                if (track == null) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AudioPlayerScreen(),
                    );
                  },
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        children: [
                          if (track.album?.coverUrl != null)
                            CachedNetworkImage(
                              imageUrl: track.album!.coverUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            )
                          else
                            ColoredBox(
                              color: Color.alphaBlend(
                                AppTheme.tiffanyBlue.withValues(alpha: 0.2),
                                Colors.transparent,
                              ),
                              child: const SizedBox(
                                width: 64,
                                height: 64,
                                child: Icon(Icons.music_note, color: AppTheme.tiffanyBlue),
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
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  track.artist?.name ?? '-',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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
                          const SizedBox(width: 8),
                        ],
                      ),
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
    final color = isSelected ? AppTheme.tiffanyBlue : Colors.white54;
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

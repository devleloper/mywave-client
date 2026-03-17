import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_state.dart';
import '../widgets/player_widgets.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  Color _dominantColor = AppTheme.tiffanyBlue;
  late final AnimationController _pulseController;
  String _lastCoverUrl = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
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
    return BlocConsumer<AudioPlayerBloc, AudioPlayerState>(
      listenWhen: (prev, curr) =>
          prev.currentTrack?.album?.coverUrl != curr.currentTrack?.album?.coverUrl,
      listener: (context, state) {
        final url = state.currentTrack?.album?.coverUrl;
        if (url != null) _extractColor(url);
      },
      builder: (context, state) {
        final isPlaying = state.isPlaying;

        if (isPlaying) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _dominantColor.withValues(alpha: 0.8),
                AppTheme.background,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 36,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ).animate().slideY(begin: -0.2),
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
                ).animate().shimmer(delay: 500.ms, duration: 1000.ms),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: state.currentTrack == null
                            ? const SizedBox.shrink()
                            : AlbumArtWidget(
                                track: state.currentTrack!,
                                dominantColor: _dominantColor,
                                pulseController: _pulseController,
                              ),
                      ),
                    ),
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
                      dominantColor: _dominantColor,
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

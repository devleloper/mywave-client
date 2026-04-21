import 'package:equatable/equatable.dart';

import '../../../../domain/entities/playback_context.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/lyrics.dart';

class AudioPlayerState extends Equatable {
  final Track? currentTrack;
  final bool isPlaying;
  final bool isShuffleEnabled;
  final bool isRepeatEnabled;
  final Duration position;
  final Duration duration;
  final List<Track> queue;
  final PlaybackContext? context;
  final DateTime? lastManualPlay;
  final Lyrics? currentLyrics;
  final bool isLoadingLyrics;
  final bool isDebugSimulationActive;

  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isShuffleEnabled = false,
    this.isRepeatEnabled = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
    this.context,
    this.lastManualPlay,
    this.currentLyrics,
    this.isLoadingLyrics = false,
    this.isDebugSimulationActive = false,
  });

  AudioPlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    bool? isShuffleEnabled,
    bool? isRepeatEnabled,
    Duration? position,
    Duration? duration,
    List<Track>? queue,
    PlaybackContext? context,
    DateTime? lastManualPlay,
    Lyrics? currentLyrics,
    bool? isLoadingLyrics,
    bool? isDebugSimulationActive,
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isRepeatEnabled: isRepeatEnabled ?? this.isRepeatEnabled,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      context: context ?? this.context,
      lastManualPlay: lastManualPlay ?? this.lastManualPlay,
      currentLyrics:
          currentLyrics == null && isLoadingLyrics == null ? this.currentLyrics : currentLyrics,
      isLoadingLyrics: isLoadingLyrics ?? this.isLoadingLyrics,
      isDebugSimulationActive: isDebugSimulationActive ?? this.isDebugSimulationActive,
    );
  }

  @override
  List<Object?> get props => [
        currentTrack,
        isPlaying,
        isShuffleEnabled,
        isRepeatEnabled,
        position,
        duration,
        queue,
        context,
        lastManualPlay,
        currentLyrics,
        isLoadingLyrics,
        isDebugSimulationActive,
      ];
}

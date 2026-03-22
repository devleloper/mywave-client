import 'package:equatable/equatable.dart';

import '../../../../domain/entities/playback_context.dart';
import '../../../../domain/entities/track.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayTrackEvent extends AudioPlayerEvent {
  final Track track;
  final List<Track> initialQueue;
  final PlaybackContext? context;

  const PlayTrackEvent({
    required this.track,
    required this.initialQueue,
    this.context,
  });

  @override
  List<Object?> get props => [track, initialQueue, context];
}

class PauseEvent extends AudioPlayerEvent {}

class ResumeEvent extends AudioPlayerEvent {}

class SkipToNextEvent extends AudioPlayerEvent {}

class SkipToPreviousEvent extends AudioPlayerEvent {}

class SeekEvent extends AudioPlayerEvent {
  final Duration position;

  const SeekEvent(this.position);

  @override
  List<Object> get props => [position];
}

class ToggleShuffleEvent extends AudioPlayerEvent {}

class ToggleRepeatEvent extends AudioPlayerEvent {}

class TrackChangedInternalEvent extends AudioPlayerEvent {
  final Track? track;
  const TrackChangedInternalEvent(this.track);
}

class IsPlayingChangedInternalEvent extends AudioPlayerEvent {
  final bool isPlaying;
  const IsPlayingChangedInternalEvent(this.isPlaying);
}

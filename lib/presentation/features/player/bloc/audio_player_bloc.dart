import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/repositories/audio_player_repository.dart';
import 'audio_player_event.dart';
import 'audio_player_state.dart';

@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayerRepository _playerRepo;

  AudioPlayerBloc(this._playerRepo) : super(const AudioPlayerState()) {
    on<PlayTrackEvent>(_onPlayTrack);
    on<PauseEvent>(_onPause);
    on<ResumeEvent>(_onResume);
    on<SkipToNextEvent>(_onSkipToNext);
    on<SkipToPreviousEvent>(_onSkipToPrevious);
    on<SeekEvent>(_onSeek);
    on<ToggleShuffleEvent>(_onToggleShuffle);
    
    // Internal event to listen to player repository stream
    on<TrackChangedInternalEvent>((event, emit) {
      emit(state.copyWith(
        currentTrack: event.track,
        queue: _playerRepo.currentQueue,
      ));
    });

    on<IsPlayingChangedInternalEvent>((event, emit) {
      emit(state.copyWith(isPlaying: event.isPlaying));
    });

    _playerRepo.currentTrackStream.listen((track) {
      add(TrackChangedInternalEvent(track));
    });
    
    _playerRepo.isPlayingStream.listen((isPlaying) {
      add(IsPlayingChangedInternalEvent(isPlaying));
    });
  }

  Future<void> _onPlayTrack(PlayTrackEvent event, Emitter<AudioPlayerState> emit) async {
    emit(state.copyWith(context: event.context));
    // Do not set isPlaying here synchronously. Let the stream event handle it natively.
    await _playerRepo.playTrack(
      event.track,
      context: event.context,
      initialQueue: event.initialQueue,
    );
  }

  Future<void> _onPause(PauseEvent event, Emitter<AudioPlayerState> emit) async {
    await _playerRepo.pause();
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> _onResume(ResumeEvent event, Emitter<AudioPlayerState> emit) async {
    await _playerRepo.resume();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> _onSkipToNext(SkipToNextEvent event, Emitter<AudioPlayerState> emit) async {
    await _playerRepo.skipToNext();
  }

  Future<void> _onSkipToPrevious(SkipToPreviousEvent event, Emitter<AudioPlayerState> emit) async {
    await _playerRepo.skipToPrevious();
  }

  Future<void> _onSeek(SeekEvent event, Emitter<AudioPlayerState> emit) async {
    await _playerRepo.seek(event.position);
  }

  Future<void> _onToggleShuffle(ToggleShuffleEvent event, Emitter<AudioPlayerState> emit) async {
    final newShuffle = !state.isShuffleEnabled;
    await _playerRepo.setShuffleMode(newShuffle);
    emit(state.copyWith(isShuffleEnabled: newShuffle));
  }
}

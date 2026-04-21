import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/artist.dart';
import '../../../../domain/entities/lyrics.dart';
import '../../../../domain/entities/track.dart';

import '../../../../domain/repositories/audio_player_repository.dart';
import '../../../../domain/repositories/catalog_repository.dart';
import 'audio_player_event.dart';
import 'audio_player_state.dart';

@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayerRepository _playerRepo;
  final CatalogRepository _catalogRepo;
  Timer? _debugTimer;

  AudioPlayerBloc(this._playerRepo, this._catalogRepo) : super(const AudioPlayerState()) {
    on<PlayTrackEvent>(_onPlayTrack);
    on<PauseEvent>(_onPause);
    on<ResumeEvent>(_onResume);
    on<SkipToNextEvent>(_onSkipToNext);
    on<SkipToPreviousEvent>(_onSkipToPrevious);
    on<SeekEvent>(_onSeek);
    on<ToggleShuffleEvent>(_onToggleShuffle);
    on<ToggleDebugSimulationEvent>(_onToggleDebugSimulation);
    
    // Internal event to listen to player repository stream
    on<TrackChangedInternalEvent>((event, emit) async {
      final isNewTrack = state.currentTrack?.id != event.track?.id;
      
      emit(state.copyWith(
        currentTrack: event.track,
        queue: _playerRepo.currentQueue,
        isLoadingLyrics: isNewTrack ? (event.track != null) : state.isLoadingLyrics,
        currentLyrics: isNewTrack ? null : state.currentLyrics,
      ));
      
      if (isNewTrack && event.track != null) {
        final lyrics = await _catalogRepo.getLyrics(event.track!);
        
        // Ensure we are still on the same track before emitting (prevent race conditions)
        if (state.currentTrack?.id == event.track!.id) {
          emit(state.copyWith(
            currentLyrics: lyrics,
            isLoadingLyrics: false,
          ));
        }
      }
    });

    on<IsPlayingChangedInternalEvent>((event, emit) {
      emit(state.copyWith(isPlaying: event.isPlaying));
    });

    on<PositionChangedInternalEvent>((event, emit) {
      emit(state.copyWith(position: event.position));
    });

    on<DurationChangedInternalEvent>((event, emit) {
      emit(state.copyWith(duration: event.duration));
    });

    _playerRepo.currentTrackStream.listen((track) {
      add(TrackChangedInternalEvent(track));
    });
    
    _playerRepo.isPlayingStream.listen((isPlaying) {
      add(IsPlayingChangedInternalEvent(isPlaying));
    });

    _playerRepo.positionStream.listen((pos) {
      add(PositionChangedInternalEvent(pos));
    });

    _playerRepo.durationStream.listen((dur) {
      if (dur != null) {
        add(DurationChangedInternalEvent(dur));
      }
    });
  }

  @override
  Future<void> close() {
    _debugTimer?.cancel();
    return super.close();
  }

  void _onToggleDebugSimulation(ToggleDebugSimulationEvent event, Emitter<AudioPlayerState> emit) {
    if (state.isDebugSimulationActive) {
      _debugTimer?.cancel();
      _debugTimer = null;
      emit(state.copyWith(
        isDebugSimulationActive: false,
        currentTrack: null, // Hack to stop fake track
        isPlaying: false,
        position: Duration.zero,
        duration: Duration.zero,
        currentLyrics: null,
      ));
    } else {
      final mockTrack = const Track(
        id: 'debug_mock_track',
        title: 'Lyrics Debug Simulation',
        artist: Artist(id: 'mock_artist', name: 'Devlet.dev'),
        album: Album(
            id: 'mock_album',
            title: 'Debug Session',
            coverUrl: 'https://i.scdn.co/image/ab67616d0000b2737359994525d219f64872d3b1'),
        durationSeconds: 180,
      );
      final mockLyrics = const Lyrics(
        synced: '''[00:00.00] Welcome to Debug Mode 🐞
[00:04.00] This simulates lyrics scrolling
[00:08.00] Even when the track fails to play!
[00:12.00] Like on an iOS simulator...
[00:16.00] You can test UI easily.
[00:22.00] Enjoy the layout testing ✨
[00:30.00] This mode is only available in debug builds.''',
        source: 'DEBUG_MOCK',
      );

      emit(state.copyWith(
        isDebugSimulationActive: true,
        currentTrack: mockTrack,
        isPlaying: true,
        position: Duration.zero,
        duration: const Duration(minutes: 3),
        currentLyrics: mockLyrics,
        isLoadingLyrics: false,
      ));

      _startDebugTimer();
    }
  }

  void _startDebugTimer() {
    _debugTimer?.cancel();
    _debugTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (state.isPlaying && state.isDebugSimulationActive) {
        final newPosition = state.position + const Duration(milliseconds: 100);
        add(PositionChangedInternalEvent(newPosition));
      }
    });
  }

  Future<void> _onPlayTrack(PlayTrackEvent event, Emitter<AudioPlayerState> emit) async {
    if (state.isDebugSimulationActive) return; // Prevent real playback overriding the simulation
    emit(state.copyWith(context: event.context));
    // Do not set isPlaying here synchronously. Let the stream event handle it natively.
    await _playerRepo.playTrack(
      event.track,
      context: event.context,
      initialQueue: event.initialQueue,
    );
  }

  Future<void> _onPause(PauseEvent event, Emitter<AudioPlayerState> emit) async {
    if (state.isDebugSimulationActive) {
      emit(state.copyWith(isPlaying: false));
      return;
    }
    await _playerRepo.pause();
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> _onResume(ResumeEvent event, Emitter<AudioPlayerState> emit) async {
    if (state.isDebugSimulationActive) {
      emit(state.copyWith(isPlaying: true));
      return;
    }
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
    if (state.isDebugSimulationActive) {
      emit(state.copyWith(position: event.position));
      return;
    }
    await _playerRepo.seek(event.position);
  }

  Future<void> _onToggleShuffle(ToggleShuffleEvent event, Emitter<AudioPlayerState> emit) async {
    final newShuffle = !state.isShuffleEnabled;
    await _playerRepo.setShuffleMode(newShuffle);
    emit(state.copyWith(isShuffleEnabled: newShuffle));
  }
}

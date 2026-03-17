import 'package:just_audio/just_audio.dart' as ja;
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/playback_context.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/repositories/audio_player_repository.dart' as domain;

@LazySingleton(as: domain.AudioPlayerRepository)
class AudioPlayerServiceImpl implements domain.AudioPlayerRepository {
  final ja.AudioPlayer _player;
  
  late final ja.ConcatenatingAudioSource _playlist;
  
  List<Track> _currentQueue = [];
  int _currentIndex = -1;

  final BehaviorSubject<Track?> _currentTrackSubject = BehaviorSubject.seeded(null);
  
  AudioPlayerServiceImpl() : _player = ja.AudioPlayer() {
    _playlist = ja.ConcatenatingAudioSource(children: []);
    _player.setAudioSource(_playlist);
    
    _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _currentQueue.length) {
        _currentIndex = index;
        _currentTrackSubject.add(_currentQueue[index]);
      }
    });
  }

  @override
  Stream<Track?> get currentTrackStream => _currentTrackSubject.stream;

  @override
  Stream<bool> get isPlayingStream => _player.playingStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Track? get currentTrack => _currentTrackSubject.value;

  @override
  List<Track> get currentQueue => List.unmodifiable(_currentQueue);

  @override
  Future<void> playTrack(Track track, {PlaybackContext? context, List<Track>? initialQueue}) async {
    _currentQueue = initialQueue ?? [track];
    
    final sources = _currentQueue.map((t) => _createAudioSource(t)).toList();
    
    await _playlist.clear();
    await _playlist.addAll(sources);
    
    final initialIndex = _currentQueue.indexWhere((t) => t.id == track.id);
    _currentIndex = initialIndex >= 0 ? initialIndex : 0;
    
    await _player.seek(Duration.zero, index: _currentIndex);
    await _player.play();
  }
  
  ja.AudioSource _createAudioSource(Track track) {
    if (track.isDownloaded && track.localPath != null) {
      return ja.AudioSource.file(track.localPath!);
    } else if (track.streamUrl != null) {
      return ja.AudioSource.uri(Uri.parse(track.streamUrl!));
    } else if (track.previewUrl != null) {
      return ja.AudioSource.uri(Uri.parse(track.previewUrl!));
    }
    throw Exception('No playable source available for track ${track.id}');
  }

  @override
  Future<void> addTracksToQueue(List<Track> tracks) async {
    _currentQueue.addAll(tracks);
    final sources = tracks.map((t) => _createAudioSource(t)).toList();
    await _playlist.addAll(sources);
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setShuffleMode(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    if (enabled) {
      await _player.shuffle();
    }
  }

  @override
  Future<void> setRepeatMode(domain.RepeatMode mode) async {
    switch (mode) {
      case domain.RepeatMode.off:
        await _player.setLoopMode(ja.LoopMode.off);
        break;
      case domain.RepeatMode.one:
        await _player.setLoopMode(ja.LoopMode.one);
        break;
      case domain.RepeatMode.all:
        await _player.setLoopMode(ja.LoopMode.all);
        break;
    }
  }
}

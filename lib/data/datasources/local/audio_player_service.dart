// ignore_for_file: deprecated_member_use
import 'package:just_audio/just_audio.dart' as ja;
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../domain/entities/playback_context.dart';
import '../../../domain/entities/track.dart';
import '../../../core/di/injection.dart';
import 'auth_storage.dart';
import '../../../domain/repositories/audio_player_repository.dart' as domain;

@LazySingleton(as: domain.AudioPlayerRepository)
class AudioPlayerServiceImpl implements domain.AudioPlayerRepository {
  final ja.AudioPlayer _player;
  late ja.ConcatenatingAudioSource _playlist;
  
  List<Track> _currentQueue = [];
  int _currentIndex = -1;

  final BehaviorSubject<Track?> _currentTrackSubject = BehaviorSubject.seeded(null);
  
  AudioPlayerServiceImpl() : _player = ja.AudioPlayer() {
    _playlist = ja.ConcatenatingAudioSource(children: [], useLazyPreparation: true);
    _player.setAudioSource(_playlist);
    
    _player.playbackEventStream.listen((event) {
      print('DEBUG_PLAYER: PlaybackEvent: processingState=${event.processingState}, '
            'updatePosition=${event.updatePosition}, index=${event.currentIndex}');
    }, onError: (Object e, StackTrace stackTrace) {
      print('DEBUG_PLAYER: PlaybackEvent ERROR: $e');
    });

    _player.playerStateStream.listen((state) {
      print('DEBUG_PLAYER: PlayerState: playing=${state.playing}, processingState=${state.processingState}');
    });

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
    final initialIndex = _currentQueue.indexWhere((t) => t.id == track.id);
    _currentIndex = initialIndex >= 0 ? initialIndex : 0;
    
    if (_currentQueue.isNotEmpty) {
      _currentTrackSubject.add(_currentQueue[_currentIndex]);
    }
    
    final arl = await getIt<AuthStorage>().getToken() ?? '';
    final sources = _currentQueue.map((t) => _createAudioSource(t, arl)).toList();
    
    try {
      final newPlaylist = ja.ConcatenatingAudioSource(
        children: sources,
      );
      
      _playlist = newPlaylist;
      
      await _player.setAudioSource(_playlist);
      
      if (_currentIndex >= 0 && _currentIndex < _currentQueue.length) {
        // Explicitly seek instead of passing initialIndex to setAudioSource.
        // This mitigates a major ExoPlayer state machine deadlock on Android.
        await _player.seek(Duration.zero, index: _currentIndex);
      }
      
      await _player.play();
    } catch (e) {
      print('DEBUG: AudioPlayer error: $e');
    }
  }
  
  ja.AudioSource _createAudioSource(Track track, String userArl) {
    if (track.isDownloaded && track.localPath != null) {
      return ja.AudioSource.file(track.localPath!);
    } else if (track.streamUrl != null) {
      return ja.AudioSource.uri(Uri.parse(track.streamUrl!));
    }
    
    String baseUrl = dotenv.env['API_URL'] ?? 'https://mywave-api.me1on.duckdns.org/api/v1';
    if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    
    final apiKey = dotenv.env['API_KEY'] ?? '';
    final arl = userArl.isNotEmpty ? userArl : (dotenv.env['PROVIDER_ARL'] ?? '');
    final url = '$baseUrl/stream/${track.id}.flac?quality=FLAC';
    
    print('DEBUG_PLAYER: Creating AudioSource for track ${track.id}');
    print('DEBUG_PLAYER: URL: $url');
    
    return ja.AudioSource.uri(
      Uri.parse(url),
      headers: {
        'x-api-key': apiKey,
        'x-stream-auth': arl,
      },
    );
  }

  @override
  Future<void> addTracksToQueue(List<Track> tracks) async {
    final arl = await getIt<AuthStorage>().getToken() ?? '';
    _currentQueue.addAll(tracks);
    final sources = tracks.map((t) => _createAudioSource(t, arl)).toList();
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

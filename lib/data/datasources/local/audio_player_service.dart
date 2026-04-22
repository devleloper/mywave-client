import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:rxdart/rxdart.dart';

import '../../../core/services/local_proxy_server.dart';
import '../../../domain/entities/playback_context.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/repositories/audio_player_repository.dart' as domain;
import 'auth_storage.dart';

@LazySingleton(as: domain.AudioPlayerRepository)
class AudioPlayerServiceImpl implements domain.AudioPlayerRepository {
  final ja.AudioPlayer _player;
  final AuthStorage _authStorage;
  final LocalProxyServer _proxyServer;

  List<Track> _currentQueue = [];
  int _currentIndex = -1;

  final BehaviorSubject<Track?> _currentTrackSubject =
      BehaviorSubject.seeded(null);

  AudioPlayerServiceImpl(this._authStorage, this._proxyServer)
      : _player = ja.AudioPlayer() {
    _player.playbackEventStream.listen(
      (event) {
        debugPrint(
          '[AudioPlayer] PlaybackEvent: state=${event.processingState}'
          ', index=${event.currentIndex}',
        );
      },
      onError: (Object e, StackTrace st) {
        debugPrint('[AudioPlayer] PlaybackEvent error: $e');
      },
    );

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
  Future<void> playTrack(
    Track track, {
    PlaybackContext? context,
    List<Track>? initialQueue,
  }) async {
    _currentQueue = initialQueue ?? [track];
    final initialIndex = _currentQueue.indexWhere((t) => t.id == track.id);
    _currentIndex = initialIndex >= 0 ? initialIndex : 0;

    if (_currentQueue.isNotEmpty) {
      _currentTrackSubject.add(_currentQueue[_currentIndex]);
    }

    final arl = await _authStorage.getToken() ?? '';
    final sources = _currentQueue.map((t) => _createAudioSource(t, arl)).toList();

    try {
      await _player.setAudioSources(
        sources,
        initialIndex: _currentIndex,
        initialPosition: Duration.zero,
      );
      await _player.play();
    } catch (e) {
      debugPrint('[AudioPlayer] Error starting playback: $e');
    }
  }

  @override
  Future<void> addTracksToQueue(List<Track> tracks) async {
    final arl = await _authStorage.getToken() ?? '';
    _currentQueue.addAll(tracks);
    final allSources = _currentQueue.map((t) => _createAudioSource(t, arl)).toList();
    try {
      await _player.setAudioSources(
        allSources,
        initialIndex: _currentIndex,
        initialPosition: _player.position,
      );
    } catch (e) {
      debugPrint('[AudioPlayer] Error adding tracks to queue: $e');
    }
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
    if (enabled) await _player.shuffle();
  }

  @override
  Future<void> setRepeatMode(domain.RepeatMode mode) async {
    switch (mode) {
      case domain.RepeatMode.off:
        await _player.setLoopMode(ja.LoopMode.off);
      case domain.RepeatMode.one:
        await _player.setLoopMode(ja.LoopMode.one);
      case domain.RepeatMode.all:
        await _player.setLoopMode(ja.LoopMode.all);
    }
  }

  ja.AudioSource _createAudioSource(Track track, String userArl) {
    if (track.isDownloaded && track.localPath != null) {
      return ja.AudioSource.file(track.localPath!);
    }

    if (track.streamUrl != null) {
      return ja.AudioSource.uri(Uri.parse(track.streamUrl!));
    }

    final backendBaseUrl = _resolveBackendBaseUrl();
    final apiKey = dotenv.env['API_KEY'] ?? '';
    final arl = userArl.isNotEmpty ? userArl : (dotenv.env['PROVIDER_ARL'] ?? '');

    _proxyServer.registerTrack(
      trackId: track.id,
      apiKey: apiKey,
      arl: arl,
      backendBaseUrl: backendBaseUrl,
    );

    final proxyUrl = _proxyServer.proxyUrlFor(track.id);
    debugPrint('[AudioPlayer] Proxy URL for ${track.id}: $proxyUrl');

    return ja.AudioSource.uri(Uri.parse(proxyUrl));
  }

  String _resolveBackendBaseUrl() {
    var url = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return url;
  }
}

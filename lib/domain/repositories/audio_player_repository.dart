import '../entities/track.dart';
import '../entities/playback_context.dart';

abstract class AudioPlayerRepository {
  Stream<Track?> get currentTrackStream;
  Stream<bool> get isPlayingStream;
  Stream<Duration> get positionStream;
  Stream<Duration> get bufferedPositionStream;
  Stream<Duration?> get durationStream;

  Track? get currentTrack;
  List<Track> get currentQueue;

  Future<void> playTrack(Track track, {PlaybackContext? context, List<Track>? initialQueue});
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> setShuffleMode(bool enabled);
  Future<void> setRepeatMode(RepeatMode mode);
  
  /// Allows dynamically adding tracks to the end of the queue
  Future<void> addTracksToQueue(List<Track> tracks);
}

enum RepeatMode { off, one, all }

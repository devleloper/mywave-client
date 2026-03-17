import '../entities/track.dart';

abstract class DownloadRepository {
  Future<void> downloadTrack(Track track);
  Future<void> removeDownloadedTrack(String providerId);
  Stream<double> getDownloadProgress(String providerId);
}

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../domain/entities/track.dart';
import '../../../../domain/repositories/download_repository.dart';
import '../../models/local/local_track.dart';
import 'track_storage.dart';

@LazySingleton(as: DownloadRepository)
class DownloadServiceImpl implements DownloadRepository {
  final Dio _dio;
  final TrackStorage _trackStorage;

  DownloadServiceImpl(this._dio, this._trackStorage);

  @override
  Future<void> downloadTrack(Track track) async {
    if (track.streamUrl == null) throw Exception('No stream URL provided');
    
    final appDir = await getApplicationDocumentsDirectory();
    final saveDir = Directory('${appDir.path}/downloads');
    if (!saveDir.existsSync()) {
      saveDir.createSync(recursive: true);
    }
    
    final fileName = '${track.id}.mp3'; // Simplification: in prod, determine extension
    final savePath = '${saveDir.path}/$fileName';
    
    // Download the file
    await _dio.download(
      track.streamUrl!,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          // Can be broadcasted via StreamController
          // final progress = received / total;
        }
      },
    );
    
    // Save to Isar database
    final localTrack = LocalTrack()
      ..providerId = track.id
      ..title = track.title
      ..durationSeconds = track.durationSeconds
      ..isExplicit = track.isExplicit
      ..artistName = track.artist?.name
      ..artistId = track.artist?.id
      ..albumTitle = track.album?.title
      ..albumId = track.album?.id
      ..coverUrl = track.album?.coverUrl
      ..localFilePath = savePath
      ..downloadedAt = DateTime.now();
      
    await _trackStorage.saveTrack(localTrack);
  }

  @override
  Future<void> removeDownloadedTrack(String providerId) async {
    final track = await _trackStorage.getTrackById(providerId);
    if (track != null) {
      final file = File(track.localFilePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      await _trackStorage.deleteTrack(providerId);
    }
  }

  @override
  Stream<double> getDownloadProgress(String providerId) {
    // Return empty stream for now. Detailed implementation could use a behavior subject map.
    return const Stream.empty();
  }
}

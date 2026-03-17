import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

import '../../models/local/local_track.dart';

abstract class TrackStorage {
  Future<void> saveTrack(LocalTrack track);
  Future<List<LocalTrack>> getAllSavedTracks();
  Future<LocalTrack?> getTrackById(String providerId);
  Future<void> deleteTrack(String providerId);
}

@LazySingleton(as: TrackStorage)
class TrackStorageImpl implements TrackStorage {
  final Isar _isar;

  TrackStorageImpl(this._isar);

  @override
  Future<void> saveTrack(LocalTrack track) async {
    await _isar.writeTxn(() async {
      await _isar.localTracks.putByProviderId(track);
    });
  }

  @override
  Future<List<LocalTrack>> getAllSavedTracks() async {
    return await _isar.localTracks.where().sortByDownloadedAtDesc().findAll();
  }

  @override
  Future<LocalTrack?> getTrackById(String providerId) async {
    return await _isar.localTracks.getByProviderId(providerId);
  }

  @override
  Future<void> deleteTrack(String providerId) async {
    await _isar.writeTxn(() async {
      await _isar.localTracks.deleteByProviderId(providerId);
    });
  }
}

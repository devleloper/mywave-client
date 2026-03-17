import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/local/local_track.dart';

@module
abstract class StorageModule {
  @preResolve
  @singleton
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [LocalTrackSchema],
      directory: dir.path,
    );
  }
}

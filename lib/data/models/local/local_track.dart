import 'package:isar/isar.dart';

part 'local_track.g.dart';

@collection
class LocalTrack {
  Id id = Isar.autoIncrement; // Isar unique ID
  
  @Index(unique: true, replace: true)
  late String providerId; // String ID from the remote API

  late String title;
  late int durationSeconds;
  
  bool isExplicit = false;
  
  String? artistName;
  String? artistId;
  String? albumTitle;
  String? albumId;
  String? coverUrl;

  late String localFilePath;
  late DateTime downloadedAt;
}

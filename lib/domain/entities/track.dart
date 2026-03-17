import 'album.dart';
import 'artist.dart';

class Track {
  final String id;
  final String title;
  final int durationSeconds;
  final bool isExplicit;
  final String? previewUrl;
  final String? streamUrl;
  final Artist? artist;
  final Album? album;
  
  // Storage paths if downloaded
  final String? localPath;
  final bool isDownloaded;

  const Track({
    required this.id,
    required this.title,
    required this.durationSeconds,
    this.isExplicit = false,
    this.previewUrl,
    this.streamUrl,
    this.artist,
    this.album,
    this.localPath,
    this.isDownloaded = false,
  });
}

import 'artist.dart';
import 'track.dart';

class Album {
  final String id;
  final String title;
  final String? coverUrl;
  final Artist? artist;
  final int? trackCount;
  final String? releaseDate;
  final bool isExplicit;
  final List<Track>? tracks;

  const Album({
    required this.id,
    required this.title,
    this.coverUrl,
    this.artist,
    this.trackCount,
    this.releaseDate,
    this.isExplicit = false,
    this.tracks,
  });
}

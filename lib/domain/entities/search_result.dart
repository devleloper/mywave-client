import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/track.dart';

class SearchResult {
  final List<Track> tracks;
  final List<Album> albums;
  final List<Artist> artists;

  const SearchResult({
    required this.tracks,
    required this.albums,
    required this.artists,
  });

  factory SearchResult.empty() => const SearchResult(
        tracks: [],
        albums: [],
        artists: [],
      );
}

import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/track.dart';
import '../entities/search_result.dart';
import '../entities/lyrics.dart';

abstract class CatalogRepository {
  Future<SearchResult> search(String query);

  Future<Album> getAlbumDetails(String providerId);
  Future<Artist> getArtistDetails(String providerId);
  
  Future<List<Track>> getArtistTopTracks(String providerId);
  Future<List<Album>> getArtistAlbums(String providerId);

  Future<List<Track>> getCharts();

  Future<Lyrics?> getLyrics(Track track);
}

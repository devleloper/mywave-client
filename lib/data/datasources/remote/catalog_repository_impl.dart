import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/artist.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/search_result.dart';
import '../../../../domain/repositories/catalog_repository.dart';

@LazySingleton(as: CatalogRepository)
class CatalogRepositoryImpl implements CatalogRepository {
  final Dio _dio;

  CatalogRepositoryImpl(this._dio);

  @override
  Future<SearchResult> search(String query) async {
    final response = await _dio.get('search/', queryParameters: {'q': query});
    
    final tracksList = response.data['tracks'] as List? ?? [];
    final albumsList = response.data['albums'] as List? ?? [];
    final artistsList = response.data['artists'] as List? ?? [];

    final tracks = _mapTracks(tracksList);
    
    final albums = albumsList.map((json) {
      return Album(
        id: json['id'].toString(),
        title: json['title'],
        coverUrl: json['cover_xl'] ?? json['cover_medium'],
        artist: json['artist'] != null ? Artist(
          id: json['artist']['id'].toString(),
          name: json['artist']['name'],
          pictureUrl: json['artist']['picture_medium'],
        ) : null,
        isExplicit: json['explicit_lyrics'] ?? false,
      );
    }).toList();

    final artists = artistsList.map((json) {
      return Artist(
        id: json['id'].toString(),
        name: json['name'],
        pictureUrl: json['picture_xl'] ?? json['picture_medium'],
      );
    }).toList();

    return SearchResult(
      tracks: tracks,
      albums: albums,
      artists: artists,
    );
  }

  @override
  Future<Album> getAlbumDetails(String providerId) async {
    final response = await _dio.get('album/$providerId');
    final data = response.data;
    
    List<Track>? tracks;
    if (data['tracks'] != null && data['tracks']['data'] != null) {
      tracks = _mapTracks(data['tracks']['data'] as List);
    }
    
    return Album(
      id: data['id'].toString(),
      title: data['title'],
      coverUrl: data['cover_xl'] ?? data['cover_medium'],
      trackCount: data['nb_tracks'],
      isExplicit: data['explicit_lyrics'] ?? false,
      releaseDate: data['release_date'],
      artist: Artist(
        id: data['artist']['id'].toString(),
        name: data['artist']['name'],
        pictureUrl: data['artist']['picture_medium'],
      ),
      tracks: tracks,
    );
  }

  @override
  Future<Artist> getArtistDetails(String providerId) async {
    final response = await _dio.get('artist/$providerId');
    final data = response.data;
    return Artist(
      id: data['id'].toString(),
      name: data['name'],
      pictureUrl: data['picture_xl'] ?? data['picture_medium'],
      fans: data['nb_fan'],
    );
  }

  @override
  Future<List<Track>> getArtistTopTracks(String providerId) async {
    final response = await _dio.get('artist/$providerId/top', queryParameters: {'limit': 50});
    return _mapTracks(response.data['data'] as List);
  }

  @override
  Future<List<Album>> getArtistAlbums(String providerId) async {
    final response = await _dio.get('artist/$providerId/albums', queryParameters: {'limit': 50});
    final albumsList = response.data['data'] as List? ?? [];
    return albumsList.map((json) {
      return Album(
        id: json['id'].toString(),
        title: json['title'],
        coverUrl: json['cover_xl'] ?? json['cover_medium'],
        releaseDate: json['release_date'],
        isExplicit: json['explicit_lyrics'] ?? false,
      );
    }).toList();
  }

  @override
  Future<List<Track>> getCharts() async {
    final response = await _dio.get('chart');
    return _mapTracks(response.data['tracks']['data'] as List);
  }

  List<Track> _mapTracks(List<dynamic> data) {
    return data.map((json) {
      return Track(
        id: json['id'].toString(),
        title: json['title'],
        durationSeconds: json['duration'] ?? 0,
        isExplicit: json['explicit_lyrics'] ?? false,
        previewUrl: json['preview'],
        streamUrl: null, // Let AudioPlayerService generate the streaming URL with auth headers
        artist: json['artist'] != null ? Artist(
          id: json['artist']['id'].toString(),
          name: json['artist']['name'],
          pictureUrl: json['artist']['picture_medium'],
        ) : null,
        album: json['album'] != null ? Album(
          id: json['album']['id'].toString(),
          title: json['album']['title'],
          coverUrl: json['album']['cover_xl'] ?? json['album']['cover_medium'],
        ) : null,
      );
    }).toList();
  }
}

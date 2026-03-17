import 'package:equatable/equatable.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/artist.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Track> tracks;
  final List<Album> albums;
  final List<Artist> artists;

  const SearchLoaded({
    required this.tracks,
    required this.albums,
    required this.artists,
  });

  @override
  List<Object?> get props => [tracks, albums, artists];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

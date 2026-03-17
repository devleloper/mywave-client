import 'package:equatable/equatable.dart';

import '../../../../domain/entities/artist.dart';
import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/track.dart';

abstract class ArtistState extends Equatable {
  const ArtistState();
  @override
  List<Object?> get props => [];
}

class ArtistInitial extends ArtistState {}
class ArtistLoading extends ArtistState {}

class ArtistLoaded extends ArtistState {
  final Artist artist;
  final List<Track> topTracks;
  final List<Album> albums;

  const ArtistLoaded({
    required this.artist,
    required this.topTracks,
    required this.albums,
  });

  @override
  List<Object?> get props => [artist, topTracks, albums];
}

class ArtistError extends ArtistState {
  final String message;
  const ArtistError(this.message);

  @override
  List<Object?> get props => [message];
}

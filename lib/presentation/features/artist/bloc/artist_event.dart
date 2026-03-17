import 'package:equatable/equatable.dart';

abstract class ArtistEvent extends Equatable {
  const ArtistEvent();
  @override
  List<Object?> get props => [];
}

class LoadArtistEvent extends ArtistEvent {
  final String artistId;
  const LoadArtistEvent(this.artistId);

  @override
  List<Object?> get props => [artistId];
}

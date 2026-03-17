import 'package:equatable/equatable.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();
  @override
  List<Object?> get props => [];
}

class LoadAlbumEvent extends AlbumEvent {
  final String albumId;
  const LoadAlbumEvent(this.albumId);
  
  @override
  List<Object?> get props => [albumId];
}

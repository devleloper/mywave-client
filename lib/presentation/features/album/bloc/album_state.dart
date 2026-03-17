import 'package:equatable/equatable.dart';
import '../../../../domain/entities/album.dart';

abstract class AlbumState extends Equatable {
  const AlbumState();
  @override
  List<Object?> get props => [];
}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final Album album;
  const AlbumLoaded(this.album);
  
  @override
  List<Object?> get props => [album];
}

class AlbumError extends AlbumState {
  final String message;
  const AlbumError(this.message);
  
  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import '../../../../data/models/local/local_track.dart';

abstract class CollectionState extends Equatable {
  const CollectionState();
  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionState {}
class CollectionLoading extends CollectionState {}

class CollectionLoaded extends CollectionState {
  final List<LocalTrack> savedTracks;

  const CollectionLoaded(this.savedTracks);

  @override
  List<Object?> get props => [savedTracks];
}

class CollectionError extends CollectionState {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object?> get props => [message];
}

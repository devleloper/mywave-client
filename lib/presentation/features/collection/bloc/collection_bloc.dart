import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/datasources/local/track_storage.dart';
import 'collection_event.dart';
import 'collection_state.dart';

@injectable
class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final TrackStorage _trackStorage;

  CollectionBloc(this._trackStorage) : super(CollectionInitial()) {
    on<LoadCollectionEvent>(_onLoadCollection);
  }

  Future<void> _onLoadCollection(LoadCollectionEvent event, Emitter<CollectionState> emit) async {
    emit(CollectionLoading());
    try {
      final tracks = await _trackStorage.getAllSavedTracks();
      emit(CollectionLoaded(tracks));
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }
}

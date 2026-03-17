import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/repositories/catalog_repository.dart';
import 'album_event.dart';
import 'album_state.dart';

@injectable
class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final CatalogRepository _catalogRepository;

  AlbumBloc(this._catalogRepository) : super(AlbumInitial()) {
    on<LoadAlbumEvent>(_onLoadAlbum);
  }

  Future<void> _onLoadAlbum(LoadAlbumEvent event, Emitter<AlbumState> emit) async {
    emit(AlbumLoading());
    try {
      final album = await _catalogRepository.getAlbumDetails(event.albumId);
      emit(AlbumLoaded(album));
    } catch (e) {
      emit(AlbumError(e.toString()));
    }
  }
}

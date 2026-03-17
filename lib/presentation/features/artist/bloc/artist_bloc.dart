import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/repositories/catalog_repository.dart';
import 'artist_event.dart';
import 'artist_state.dart';

@injectable
class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final CatalogRepository _catalogRepository;

  ArtistBloc(this._catalogRepository) : super(ArtistInitial()) {
    on<LoadArtistEvent>(_onLoadArtist);
  }

  Future<void> _onLoadArtist(LoadArtistEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoading());
    try {
      final results = await Future.wait([
        _catalogRepository.getArtistDetails(event.artistId),
        _catalogRepository.getArtistTopTracks(event.artistId),
        _catalogRepository.getArtistAlbums(event.artistId),
      ]);

      emit(ArtistLoaded(
        artist: results[0] as dynamic,
        topTracks: results[1] as dynamic,
        albums: results[2] as dynamic,
      ));
    } catch (e) {
      emit(ArtistError(e.toString()));
    }
  }
}

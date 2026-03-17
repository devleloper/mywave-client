import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Track import omitted
// SearchResult import removed
import '../../../../domain/repositories/catalog_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final CatalogRepository _catalogRepository;

  SearchBloc(this._catalogRepository) : super(SearchInitial()) {
    on<PerformSearchEvent>(_onPerformSearch);
    on<ClearSearchEvent>((event, emit) => emit(SearchInitial()));
  }

  Future<void> _onPerformSearch(PerformSearchEvent event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final result = await _catalogRepository.search(event.query);

      emit(SearchLoaded(
        tracks: result.tracks,
        albums: result.albums,
        artists: result.artists,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}

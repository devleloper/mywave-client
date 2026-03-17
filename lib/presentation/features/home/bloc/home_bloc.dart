import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/repositories/catalog_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CatalogRepository _catalogRepository;

  HomeBloc(this._catalogRepository) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(LoadHomeDataEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final charts = await _catalogRepository.getCharts();
      emit(HomeLoaded(charts: charts));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}

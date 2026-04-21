import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../presentation/core/bloc/theme_cubit.dart';
import '../services/player_transition_service.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
  // Manually register ThemeCubit as it's a core requirement for theme switching
  if (!getIt.isRegistered<ThemeCubit>()) {
    getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  }

  if (!getIt.isRegistered<PlayerTransitionService>()) {
    getIt.registerLazySingleton<PlayerTransitionService>(() => PlayerTransitionService());
  }
}

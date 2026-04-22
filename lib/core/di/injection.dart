import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../presentation/core/bloc/theme_cubit.dart';
import '../services/local_proxy_server.dart';
import '../services/player_transition_service.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  if (!getIt.isRegistered<LocalProxyServer>()) {
    getIt.registerSingleton<LocalProxyServer>(LocalProxyServer());
  }

  await getIt.init();
  await getIt<LocalProxyServer>().start();

  if (!getIt.isRegistered<ThemeCubit>()) {
    getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  }

  if (!getIt.isRegistered<PlayerTransitionService>()) {
    getIt.registerLazySingleton<PlayerTransitionService>(() => PlayerTransitionService());
  }
}

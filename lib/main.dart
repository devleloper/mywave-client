import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/core/bloc/theme_cubit.dart';
import 'presentation/features/player/bloc/audio_player_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await configureDependencies();

  runApp(const MyWaveApp());
}

class MyWaveApp extends StatelessWidget {
  const MyWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>().router;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudioPlayerBloc>(create: (_) => getIt<AudioPlayerBloc>()),
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'MyWave',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}

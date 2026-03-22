import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/chart_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(LoadHomeDataEvent()),
      child: const Scaffold(
        body: _HomeScrollView(),
      ),
    );
  }
}

class _HomeScrollView extends StatelessWidget {
  const _HomeScrollView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 24, top: 60, bottom: 20),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Global Charts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ),
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) => switch (state) {
            HomeLoading() => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.tiffanyBlue),
                ),
              ),
            HomeError() => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error loading charts',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            HomeLoaded(:final charts) => ChartList(tracks: charts),
            _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

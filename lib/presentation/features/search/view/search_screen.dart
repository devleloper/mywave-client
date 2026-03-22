import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/mywave_text_field.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_result_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchBloc _searchBloc = getIt<SearchBloc>();

  @override
  void dispose() {
    _searchController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        _searchBloc.add(PerformSearchEvent(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: MyWaveTextField(
                  controller: _searchController,
                  hintText: 'Search tracks, albums, artists...',
                  onChanged: _onSearchChanged,
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.tiffanyBlue),
                ),
              ),
              const Expanded(child: _SearchResults()),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) => switch (state) {
        SearchLoading() => const Center(
            child: CircularProgressIndicator(color: AppTheme.tiffanyBlue),
          ),
        SearchError(:final message) => Center(
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        SearchLoaded() => SearchLoadedResults(state: state),
        _ => Center(
            child: Text(
              'Search for your favorite music',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 16),
            ),
          ),
      },
    );
  }
}

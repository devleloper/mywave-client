import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
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
                child: _SearchField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchController.clear();
                    _searchBloc.add(ClearSearchEvent());
                  },
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search tracks, albums, artists...',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search, color: AppTheme.tiffanyBlue),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white54),
          onPressed: onClear,
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
            child: Text(message, style: const TextStyle(color: Colors.redAccent)),
          ),
        SearchLoaded() => SearchLoadedResults(state: state),
        _ => const Center(
            child: Text(
              'Search for your favorite music',
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ),
      },
    );
  }
}

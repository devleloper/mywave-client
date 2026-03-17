import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/content_sliver_app_bar.dart';
import '../bloc/album_bloc.dart';
import '../bloc/album_event.dart';
import '../bloc/album_state.dart';
import '../widgets/album_widgets.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AlbumBloc>()..add(LoadAlbumEvent(albumId)),
      child: const Scaffold(body: _AlbumBody()),
    );
  }
}

class _AlbumBody extends StatelessWidget {
  const _AlbumBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumBloc, AlbumState>(
      builder: (context, state) => switch (state) {
        AlbumLoading() => const Center(
            child: CircularProgressIndicator(color: AppTheme.tiffanyBlue),
          ),
        AlbumError(:final message) => Center(
            child: Text(message, style: const TextStyle(color: Colors.redAccent)),
          ),
        AlbumLoaded(:final album) => CustomScrollView(
            slivers: [
              ContentSliverAppBar(
                title: album.title,
                imageUrl: album.coverUrl,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AlbumHeader(album: album),
                ),
              ),
              if (album.tracks != null)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => AlbumTrackTile(
                      track: album.tracks![index],
                      index: index,
                      album: album,
                    ),
                    childCount: album.tracks!.length,
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

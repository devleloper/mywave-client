import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/content_sliver_app_bar.dart';
import '../bloc/artist_bloc.dart';
import '../bloc/artist_event.dart';
import '../bloc/artist_state.dart';
import '../widgets/artist_widgets.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ArtistBloc>()..add(LoadArtistEvent(artistId)),
      child: const Scaffold(body: _ArtistBody()),
    );
  }
}

class _ArtistBody extends StatelessWidget {
  const _ArtistBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistBloc, ArtistState>(
      builder: (context, state) => switch (state) {
        ArtistLoading() => const Center(
            child: CircularProgressIndicator(color: AppTheme.tiffanyBlue),
          ),
        ArtistError(:final message) => Center(
            child: Text(message, style: const TextStyle(color: Colors.redAccent)),
          ),
        ArtistLoaded() => _ArtistScrollView(state: state),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _ArtistScrollView extends StatelessWidget {
  const _ArtistScrollView({required this.state});

  final ArtistLoaded state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ContentSliverAppBar(
          title: state.artist.name,
          imageUrl: state.artist.pictureUrl,
          placeholderIcon: Icons.person,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ArtistHeader(state: state),
          ),
        ),
        if (state.topTracks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Top Tracks',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ArtistTrackTile(
                track: state.topTracks[index],
                state: state,
              ),
              childCount: state.topTracks.length.clamp(0, 5),
            ),
          ),
        ],
        if (state.albums.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Albums',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ArtistAlbumRow(albums: state.albums),
          ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }
}

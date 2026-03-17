import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/local/auth_storage.dart';
import '../../presentation/features/album/view/album_screen.dart';
import '../../presentation/features/artist/view/artist_screen.dart';
import '../../presentation/features/main/view/main_layout.dart';
import '../../presentation/features/onboarding/view/onboarding_screen.dart';
import '../../presentation/features/home/view/home_screen.dart';
import '../../presentation/features/search/view/search_screen.dart';
import '../../presentation/features/collection/view/collection_screen.dart';
import '../../presentation/features/profile/view/profile_screen.dart';
import '../di/injection.dart';
import 'routes.dart';

// Placeholder screens for testing navigation shell
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Screen: $title')),
    );
  }
}

@singleton
class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) async {
      final authStorage = getIt<AuthStorage>();
      final token = await authStorage.getToken();
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (token == null || token.isEmpty) {
        return isOnboarding ? null : AppRoutes.onboarding;
      }

      if (isOnboarding) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.collection,
                builder: (context, state) => const CollectionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Deep stacking routes
      GoRoute(
        path: '/${AppRoutes.album}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AlbumScreen(albumId: id);
        },
      ),
      GoRoute(
        path: '/${AppRoutes.artist}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ArtistScreen(artistId: id);
        },
      ),
    ],
  );
}

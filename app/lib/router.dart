import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'home/home_screen.dart';
import 'parents/parents_screen.dart';
import 'profiles/profile_form_screen.dart';
import 'profiles/profiles_screen.dart';
import 'screens/coming_soon_screen.dart';
import 'stories/registry.dart';
import 'story/story_screen.dart';
import 'world/album_screen.dart';
import 'world/treasure_screen.dart';
import 'world/world_map_screen.dart';

/// Les écrans de Lumière, avec un fondu doux entre chacun.
GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', pageBuilder: (context, state) => _fade(state, const HomeScreen())),
      GoRoute(path: '/profils', pageBuilder: (context, state) => _fade(state, const ProfilesScreen())),
      GoRoute(
        path: '/profils/nouveau',
        pageBuilder: (context, state) => _fade(state, const ProfileFormScreen()),
      ),
      GoRoute(
        path: '/profils/:id',
        pageBuilder: (context, state) =>
            _fade(state, ProfileFormScreen(profileId: state.pathParameters['id'])),
      ),
      GoRoute(path: '/carte', pageBuilder: (context, state) => _fade(state, const WorldMapScreen())),
      GoRoute(path: '/parents', pageBuilder: (context, state) => _fade(state, const ParentsScreen())),
      GoRoute(path: '/album', pageBuilder: (context, state) => _fade(state, const AlbumScreen())),
      GoRoute(path: '/tresor', pageBuilder: (context, state) => _fade(state, const TreasureScreen())),
      GoRoute(
        path: '/jardin',
        pageBuilder: (context, state) => _fade(state, const TreasureScreen(garden: true)),
      ),
      GoRoute(
        path: '/histoire/:id',
        redirect: (context, state) => storyPacks.containsKey(state.pathParameters['id']) ? null : '/',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          // Une clé par histoire : passer d'une histoire à l'autre recrée bien l'écran.
          return _fade(state, StoryScreen(key: ValueKey('story-$id'), storyId: id));
        },
      ),
      GoRoute(
        path: '/bientot/:section',
        redirect: (context, state) => Upcoming.byName(state.pathParameters['section']) == null ? '/' : null,
        pageBuilder: (context, state) =>
            _fade(state, ComingSoonScreen(section: Upcoming.byName(state.pathParameters['section'])!)),
      ),
    ],
    errorPageBuilder: (context, state) => _fade(state, const HomeScreen()),
  );
}

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    // Clé propre à l'adresse complète (et pas seulement au modèle de route).
    key: ValueKey(state.uri.toString()),
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

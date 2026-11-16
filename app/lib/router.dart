import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'home/home_screen.dart';
import 'screens/coming_soon_screen.dart';
import 'stories/registry.dart';
import 'story/story_screen.dart';

/// Les écrans de Lumière, avec un fondu doux entre chacun.
GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', pageBuilder: (context, state) => _fade(state, const HomeScreen())),
      GoRoute(
        path: '/histoire/:id',
        redirect: (context, state) => storyPacks.containsKey(state.pathParameters['id']) ? null : '/',
        pageBuilder: (context, state) => _fade(state, StoryScreen(storyId: state.pathParameters['id']!)),
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
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

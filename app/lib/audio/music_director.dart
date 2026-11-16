import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../parents/play_time.dart';
import '../save/game_state.dart';
import 'audio.dart';

/// Le morceau de chaque écran : accueil, carte (et menus), histoire ; les
/// mini-jeux demandent le leur ([AudioScope.musicOverride]). Silence quand le
/// temps de jeu est écoulé.
MusicTrack? trackFor(String path, {MusicTrack? override, bool timeUp = false}) {
  if (timeUp && countsAsPlay(path)) return null;
  if (path == '/') return MusicTrack.home;
  if (path.startsWith('/histoire/')) return override ?? MusicTrack.story;
  return MusicTrack.map;
}

/// Choisit la musique selon l'écran et la relance au premier geste (web).
class MusicDirector extends StatefulWidget {
  const MusicDirector({
    super.key,
    required this.router,
    required this.state,
    required this.music,
    required this.overrideTrack,
    required this.child,
  });

  final GoRouter router;
  final GameState state;
  final MusicPlayer music;
  final ValueNotifier<MusicTrack?> overrideTrack;
  final Widget child;

  @override
  State<MusicDirector> createState() => _MusicDirectorState();
}

class _MusicDirectorState extends State<MusicDirector> {
  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_update);
    widget.state.addListener(_update);
    widget.overrideTrack.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_update);
    widget.state.removeListener(_update);
    widget.overrideTrack.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final path = widget.router.routerDelegate.currentConfiguration.uri.path;
    widget.music.play(trackFor(path, override: widget.overrideTrack.value, timeUp: widget.state.timeIsUp));
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => widget.music.retry(),
      child: widget.child,
    );
  }
}

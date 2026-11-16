import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'audio/audio.dart';
import 'router.dart';
import 'save/game_state.dart';
import 'save/save_store.dart';
import 'theme/lumiere_theme.dart';

class LumiereApp extends StatefulWidget {
  const LumiereApp({super.key, this.narrator, this.sfx, this.gameState});

  /// Remplaçables dans les tests (sons muets).
  final Narrator? narrator;
  final SoundEffects? sfx;

  /// Profils et progression, déjà chargés (sinon : en mémoire seulement).
  final GameState? gameState;

  @override
  State<LumiereApp> createState() => _LumiereAppState();
}

class _LumiereAppState extends State<LumiereApp> {
  late final GoRouter _router = buildRouter();
  late final Narrator _narrator = widget.narrator ?? AudioNarrator();
  late final SoundEffects _sfx = widget.sfx ?? AudioSoundEffects();
  late final GameState _game = widget.gameState ?? GameState(MemorySaveStore());

  @override
  void dispose() {
    _router.dispose();
    _narrator.dispose();
    _sfx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumière',
      debugShowCheckedModeBanner: false,
      theme: buildLumiereTheme(),
      locale: const Locale('fr'),
      routerConfig: _router,
      builder: (context, child) => GameScope(
        state: _game,
        child: AudioScope(narrator: _narrator, sfx: _sfx, child: child!),
      ),
    );
  }
}

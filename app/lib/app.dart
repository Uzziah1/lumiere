import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'audio/audio.dart';
import 'router.dart';
import 'theme/lumiere_theme.dart';

class LumiereApp extends StatefulWidget {
  const LumiereApp({super.key, this.narrator, this.sfx});

  /// Remplaçables dans les tests (sons muets).
  final Narrator? narrator;
  final SoundEffects? sfx;

  @override
  State<LumiereApp> createState() => _LumiereAppState();
}

class _LumiereAppState extends State<LumiereApp> {
  late final GoRouter _router = buildRouter();
  late final Narrator _narrator = widget.narrator ?? AudioNarrator();
  late final SoundEffects _sfx = widget.sfx ?? AudioSoundEffects();

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
      builder: (context, child) => AudioScope(narrator: _narrator, sfx: _sfx, child: child!),
    );
  }
}

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'audio/audio.dart';
import 'audio/music_director.dart';
import 'parents/play_time.dart';
import 'router.dart';
import 'save/game_state.dart';
import 'save/save_store.dart';
import 'theme/lumiere_theme.dart';

class LumiereApp extends StatefulWidget {
  const LumiereApp({
    super.key,
    this.narrator,
    this.sfx,
    this.music,
    this.gameState,
    this.trackPlaytime = true,
  });

  /// Musique de fond (remplaçable dans les tests).
  final MusicPlayer? music;

  /// Compter le temps de jeu (faux dans la plupart des tests : pas de minuterie).
  final bool trackPlaytime;

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
  late final GameState _game = widget.gameState ?? GameState(MemorySaveStore());
  // La voix et les bruitages obéissent aux réglages des parents.
  late final MusicPlayer _music = GatedMusicPlayer(
    widget.music ?? _defaultMusic(),
    () => _game.settings.music,
  );
  final _musicOverride = ValueNotifier<MusicTrack?>(null);
  // La musique baisse quand la conteuse parle.
  late final Narrator _narrator = GatedNarrator(
    DuckingNarrator(widget.narrator ?? AudioNarrator(), _music),
    () => _game.settings.narration,
  );

  // Dans les tests (narration muette fournie), pas de vraie musique non plus.
  MusicPlayer _defaultMusic() => widget.narrator is SilentNarrator ? SilentMusicPlayer() : AudioMusicPlayer();
  late final SoundEffects _sfx = GatedSoundEffects(
    widget.sfx ?? AudioSoundEffects(),
    () => _game.settings.effects,
  );

  @override
  void dispose() {
    _router.dispose();
    _narrator.dispose();
    _sfx.dispose();
    _music.dispose();
    _musicOverride.dispose();
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
        child: ListenableBuilder(
          listenable: _game,
          child: AudioScope(
            narrator: _narrator,
            sfx: _sfx,
            musicOverride: _musicOverride,
            child: MusicDirector(
              router: _router,
              state: _game,
              music: _music,
              overrideTrack: _musicOverride,
              child: PlayTimeKeeper(
                router: _router,
                state: _game,
                enabled: widget.trackPlaytime,
                child: child!,
              ),
            ),
          ),
          builder: (context, child) {
            // « Réduire les animations » et « grand texte » des réglages parents.
            final media = MediaQuery.of(context);
            final settings = _game.settings;
            return MediaQuery(
              data: media.copyWith(
                disableAnimations: media.disableAnimations || settings.reduceMotion,
                textScaler: settings.largeText ? const TextScaler.linear(1.2) : media.textScaler,
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

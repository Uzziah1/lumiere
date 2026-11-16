import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

/// La voix qui raconte. [play] se termine quand la phrase est finie (ou
/// interrompue par [stop] ou un nouveau [play]).
abstract class Narrator {
  /// [asset] : chemin dans `assets/` (ex. `stories/noe/audio/scene.village.all.mp3`).
  /// [text] sert à estimer la durée si le son ne peut pas être joué.
  Future<void> play(String asset, {required String text});

  Future<void> stop();

  void dispose();
}

/// Bruitages courts (toucher, réussite, étoile…), voir `assets/audio/sfx/`.
abstract class SoundEffects {
  void play(Sfx effect);

  void dispose();
}

enum Sfx { tap, pop, success, star, flip, wrong, knock, whoosh, chime }

/// Durée estimée d'une phrase lue à voix haute (repli si le son manque).
Duration estimateSpeech(String text) {
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  return Duration(milliseconds: 600 + words * 380);
}

/// Narration avec de vrais fichiers audio (audioplayers).
class AudioNarrator implements Narrator {
  AudioNarrator() : _player = AudioPlayer(playerId: 'narrator');

  final AudioPlayer _player;
  Completer<void>? _current;
  StreamSubscription<void>? _done;

  @override
  Future<void> play(String asset, {required String text}) async {
    await stop();
    final completer = Completer<void>();
    _current = completer;
    _done = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
    try {
      await _player.play(AssetSource(asset));
    } catch (error) {
      debugPrint('Narration indisponible ($asset) : $error');
      // Sans le son, on laisse le temps de lire le sous-titre.
      Future<void>.delayed(estimateSpeech(text), () {
        if (!completer.isCompleted) completer.complete();
      });
    }
    return completer.future;
  }

  @override
  Future<void> stop() async {
    await _done?.cancel();
    _done = null;
    final current = _current;
    _current = null;
    if (current != null && !current.isCompleted) current.complete();
    try {
      await _player.stop();
    } catch (_) {
      // Rien à arrêter.
    }
  }

  @override
  void dispose() {
    stop();
    _player.dispose();
  }
}

/// Narration muette : attend le temps estimé de lecture (ou rien du tout dans
/// les tests avec [instant]).
class SilentNarrator implements Narrator {
  SilentNarrator({this.instant = false});

  final bool instant;
  final played = <String>[];
  Timer? _timer;
  Completer<void>? _current;

  @override
  Future<void> play(String asset, {required String text}) async {
    await stop();
    played.add(asset);
    if (instant) return;
    final completer = Completer<void>();
    _current = completer;
    _timer = Timer(estimateSpeech(text), () {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    final current = _current;
    _current = null;
    if (current != null && !current.isCompleted) current.complete();
  }

  @override
  void dispose() => stop();
}

/// Bruitages avec audioplayers : un petit groupe de lecteurs réutilisés.
class AudioSoundEffects implements SoundEffects {
  final _players = List.generate(4, (i) => AudioPlayer(playerId: 'sfx$i'));
  var _next = 0;

  @override
  void play(Sfx effect) {
    final player = _players[_next];
    _next = (_next + 1) % _players.length;
    unawaited(() async {
      try {
        await player.stop();
        await player.play(AssetSource('audio/sfx/${effect.name}.mp3'), volume: 0.7);
      } catch (_) {
        // Un bruitage manqué n'est pas grave.
      }
    }());
  }

  @override
  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
  }
}

class SilentSoundEffects implements SoundEffects {
  final played = <Sfx>[];

  @override
  void play(Sfx effect) => played.add(effect);

  @override
  void dispose() {}
}

/// Narration qui se tait quand les parents l'ont coupée : on laisse alors le
/// temps de lire le sous-titre, sans jouer de son.
class GatedNarrator implements Narrator {
  GatedNarrator(this.inner, this.enabled);

  final Narrator inner;
  final bool Function() enabled;
  final _silent = SilentNarrator();

  @override
  Future<void> play(String asset, {required String text}) {
    if (enabled()) return inner.play(asset, text: text);
    inner.stop();
    return _silent.play(asset, text: text);
  }

  @override
  Future<void> stop() async {
    await _silent.stop();
    await inner.stop();
  }

  @override
  void dispose() {
    _silent.dispose();
    inner.dispose();
  }
}

/// Bruitages qui se taisent quand les parents les ont coupés.
class GatedSoundEffects implements SoundEffects {
  GatedSoundEffects(this.inner, this.enabled);

  final SoundEffects inner;
  final bool Function() enabled;

  @override
  void play(Sfx effect) {
    if (enabled()) inner.play(effect);
  }

  @override
  void dispose() => inner.dispose();
}

/// Les morceaux de musique (synthétisés par `tools/music/generate.py`).
enum MusicTrack { home, map, story, games }

/// La musique de fond : un morceau en boucle, plus discret quand la conteuse parle.
abstract class MusicPlayer {
  /// Joue [track] en boucle (null = silence). Ne recommence pas un morceau déjà en cours.
  void play(MusicTrack? track);

  /// Baisse le volume (pendant la narration).
  void duck(bool ducked);

  /// Réessaie après un geste de l'enfant (les navigateurs refusent le son avant).
  void retry();

  void dispose();
}

class AudioMusicPlayer implements MusicPlayer {
  AudioMusicPlayer() : _player = AudioPlayer(playerId: 'music') {
    _player.setReleaseMode(ReleaseMode.loop);
  }

  static const _volume = 0.3;
  static const _duckedVolume = 0.1;

  final AudioPlayer _player;
  MusicTrack? _track;
  bool _playing = false;
  bool _ducked = false;

  @override
  void play(MusicTrack? track) {
    if (track == _track && (_playing || track == null)) return;
    _track = track;
    _playing = false;
    unawaited(() async {
      try {
        if (track == null) {
          await _player.stop();
          return;
        }
        await _player.stop();
        await _player.play(
          AssetSource('audio/music/${track.name}.mp3'),
          volume: _ducked ? _duckedVolume : _volume,
        );
        _playing = _track == track;
      } catch (_) {
        // Sur le web, le son attend un premier geste : on réessaiera (retry).
      }
    }());
  }

  @override
  void duck(bool ducked) {
    if (ducked == _ducked) return;
    _ducked = ducked;
    unawaited(_player.setVolume(ducked ? _duckedVolume : _volume).catchError((_) {}));
  }

  @override
  void retry() {
    if (!_playing && _track != null) {
      final track = _track;
      _track = null;
      play(track);
    }
  }

  @override
  void dispose() => _player.dispose();
}

class SilentMusicPlayer implements MusicPlayer {
  final played = <MusicTrack?>[];
  MusicTrack? current;
  bool ducked = false;

  @override
  void play(MusicTrack? track) {
    if (track == current) return;
    current = track;
    played.add(track);
  }

  @override
  void duck(bool ducked) => this.ducked = ducked;

  @override
  void retry() {}

  @override
  void dispose() {}
}

/// Musique coupée par les parents : on joue le silence.
class GatedMusicPlayer implements MusicPlayer {
  GatedMusicPlayer(this.inner, this.enabled);

  final MusicPlayer inner;
  final bool Function() enabled;

  @override
  void play(MusicTrack? track) => inner.play(enabled() ? track : null);

  @override
  void duck(bool ducked) => inner.duck(ducked);

  @override
  void retry() {
    if (enabled()) inner.retry();
  }

  @override
  void dispose() => inner.dispose();
}

/// Narration qui baisse la musique le temps de parler.
class DuckingNarrator implements Narrator {
  DuckingNarrator(this.inner, this.music);

  final Narrator inner;
  final MusicPlayer music;
  int _speech = 0;

  @override
  Future<void> play(String asset, {required String text}) async {
    final token = ++_speech;
    music.duck(true);
    try {
      await inner.play(asset, text: text);
    } finally {
      if (token == _speech) music.duck(false);
    }
  }

  @override
  Future<void> stop() {
    music.duck(false);
    return inner.stop();
  }

  @override
  void dispose() => inner.dispose();
}

/// Donne accès à la narration et aux bruitages dans tout l'arbre de widgets.
class AudioScope extends InheritedWidget {
  const AudioScope({
    super.key,
    required this.narrator,
    required this.sfx,
    required super.child,
    this.musicOverride,
  });

  final Narrator narrator;
  final SoundEffects sfx;

  /// Un écran peut demander un autre morceau que celui de sa page (les mini-jeux).
  final ValueNotifier<MusicTrack?>? musicOverride;

  static AudioScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AudioScope>();
    assert(scope != null, 'AudioScope manquant au-dessus de ce widget.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AudioScope oldWidget) => narrator != oldWidget.narrator || sfx != oldWidget.sfx;
}

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../audio/audio.dart';
import 'story_game.dart';

/// Comment l'enfant fait avancer une scène scénarisée.
enum Interaction {
  /// Toucher chacune des cibles (une fois chacune).
  tapAll,

  /// Toucher la première cible plusieurs fois ([StageScript.taps]).
  tapRepeat,

  /// Glisser le doigt (de [StageScript.swipeFrom] vers [StageScript.swipeTo]) ;
  /// un simple toucher fait aussi avancer un peu.
  swipe,

  /// Toucher la première cible, puis une animation se déroule
  /// ([StageScript.wait] secondes) avant la fin de la scène.
  tapThenWait,
}

/// Ce que voit le dessin d'une scène scénarisée à chaque image.
class StageView {
  StageView(this.targetCount) : appear = List.filled(targetCount, 0), pulse = List.filled(targetCount, 0);

  /// Une scène terminée et immobile (vignettes, autocollants).
  factory StageView.finished(int targets, {double time = 0.6}) {
    final v = StageView(targets)
      ..time = time
      ..progress = 1
      ..done = true
      ..sinceDone = 10;
    for (var i = 0; i < targets; i++) {
      v.appear[i] = 1;
    }
    return v;
  }

  final int targetCount;

  /// Temps d'ambiance en secondes (s'arrête avec « réduire les animations »).
  double time = 0;

  /// Avancement affiché, de 0 à 1 (lissé).
  double progress = 0;

  /// Pour chaque cible : 0 = pas encore touchée, 1 = touchée (lissé).
  final List<double> appear;

  /// Pour chaque cible : 1 juste après un toucher, puis redescend à 0.
  final List<double> pulse;

  bool done = false;

  /// Secondes écoulées depuis la fin de la scène.
  double sinceDone = 0;

  /// Raccourcis : avancement adouci, et apparition d'une cible.
  double get eased => _smooth(progress);

  double shown(int i) => i < appear.length ? _smooth(appear[i]) : 0;

  static double _smooth(double x) {
    final t = x.clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }
}

typedef StagePainter = void Function(Canvas canvas, Size size, StageView view);

/// Une scène décrite par un dessin et des zones à toucher : la plupart des
/// scènes des histoires suivent ce modèle.
class StageScript {
  const StageScript({
    required this.paint,
    this.targets = const [],
    this.interaction = Interaction.tapAll,
    this.taps = 3,
    this.wait = 2.5,
    this.swipeFrom = const Offset(0.2, 0.4),
    this.swipeTo = const Offset(0.8, 0.4),
    this.sfx = Sfx.pop,
  });

  final StagePainter paint;

  /// Zones à toucher, en coordonnées relatives (0–1). Elles doivent rester
  /// au-dessus des sous-titres (bas < 0,85).
  final List<Rect> targets;
  final Interaction interaction;
  final int taps;
  final double wait;
  final Offset swipeFrom;
  final Offset swipeTo;
  final Sfx sfx;

  int get viewTargets => math.max(1, targets.length);
}

/// Le décor Flame qui joue un [StageScript].
class ScriptedStage extends StoryStage {
  ScriptedStage(this.script) : view = StageView(script.viewTargets);

  final StageScript script;
  final StageView view;
  final _hit = <int>{};
  int _count = 0;
  double _raw = 0;
  bool _started = false;
  double _elapsed = 0;

  Offset _rel(Vector2 p) => Offset(p.x / size.x, p.y / size.y);

  Vector2 _abs(Offset rel) => Vector2(rel.dx * size.x, rel.dy * size.y);

  @override
  Vector2? get hintTarget {
    final targets = script.targets;
    switch (script.interaction) {
      case Interaction.tapAll:
        for (var i = 0; i < targets.length; i++) {
          if (!_hit.contains(i)) return _abs(targets[i].center);
        }
        return targets.isEmpty ? _abs(const Offset(0.5, 0.5)) : _abs(targets.last.center);
      case Interaction.swipe:
        return _abs(Offset.lerp(script.swipeFrom, script.swipeTo, _raw.clamp(0.0, 0.95))!);
      case Interaction.tapRepeat:
      case Interaction.tapThenWait:
        return _abs(targets.isEmpty ? const Offset(0.5, 0.5) : targets.first.center);
    }
  }

  /// Index de la cible sous le point (avec une marge pour les petits doigts), ou -1.
  int _targetAt(Offset rel) {
    const margin = 0.03;
    for (var i = 0; i < script.targets.length; i++) {
      if (script.targets[i].inflate(margin).contains(rel)) return i;
    }
    return -1;
  }

  /// L'enfant touche la cible [i].
  void tapTarget(int i) {
    if (done) return;
    switch (script.interaction) {
      case Interaction.tapAll:
        if (_hit.contains(i)) return;
        _hit.add(i);
        _pulse(i);
        if (_hit.length >= script.targets.length) _finish();
      case Interaction.tapRepeat:
        if (i != 0) return;
        _count++;
        _pulse(0);
        if (_count >= script.taps) _finish();
      case Interaction.tapThenWait:
        if (i != 0 || _started) return;
        _started = true;
        _pulse(0);
        _hit.add(0);
        if (reducedMotion || script.wait <= 0) _finish();
      case Interaction.swipe:
        advanceSwipe(0.18);
    }
  }

  /// Fait avancer une scène « glisser ».
  void advanceSwipe(double amount) {
    if (done || script.interaction != Interaction.swipe) return;
    final before = _raw;
    _raw = (_raw + amount).clamp(0.0, 1.0);
    if ((before * 6).floor() != (_raw * 6).floor()) game.sfx.play(script.sfx);
    if (_raw >= 1) _finish();
  }

  void _pulse(int i) {
    if (i < view.pulse.length) view.pulse[i] = 1;
    game.sfx.play(script.sfx);
    final t = i < script.targets.length ? script.targets[i].center : const Offset(0.5, 0.5);
    game.add(Sparkles(origin: _abs(t), radius: math.min(size.x, size.y) * 0.08, count: 8, seed: i + _count));
  }

  void _finish() {
    if (done) return;
    game.add(
      Sparkles(origin: hintTarget ?? _abs(const Offset(0.5, 0.4)), radius: math.min(size.x, size.y) * 0.15),
    );
    complete();
  }

  /// Joue toute l'interaction d'un coup (tests).
  void autoplay() {
    switch (script.interaction) {
      case Interaction.tapAll:
        for (var i = 0; i < script.targets.length; i++) {
          tapTarget(i);
        }
      case Interaction.tapRepeat:
        for (var i = 0; i < script.taps; i++) {
          tapTarget(0);
        }
      case Interaction.swipe:
        advanceSwipe(1);
      case Interaction.tapThenWait:
        tapTarget(0);
        _elapsed = script.wait;
        _finish();
    }
  }

  double get _progress => switch (script.interaction) {
    Interaction.tapAll => script.targets.isEmpty ? 1 : _hit.length / script.targets.length,
    Interaction.tapRepeat => _count / script.taps,
    Interaction.swipe => _raw,
    Interaction.tapThenWait =>
      script.wait <= 0 ? (_started ? 1 : 0) : (_elapsed / script.wait).clamp(0.0, 1.0),
  };

  @override
  void onTapDown(TapDownEvent event) {
    final i = _targetAt(_rel(event.localPosition));
    if (script.interaction == Interaction.swipe) {
      advanceSwipe(0.15);
    } else if (i >= 0) {
      tapTarget(i);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (script.interaction != Interaction.swipe) return;
    final dir = script.swipeTo - script.swipeFrom;
    final along = Offset(event.localDelta.x / size.x, event.localDelta.y / size.y);
    final length = dir.distance;
    // Seul le mouvement dans le bon sens compte (un peu, même de travers).
    final dot = (along.dx * dir.dx + along.dy * dir.dy) / (length == 0 ? 1 : length);
    advanceSwipe(math.max(dot, along.distance * 0.35) / math.max(0.2, length));
  }

  @override
  void tick(double dt) {
    if (_started && !done) {
      _elapsed += dt;
      if (_elapsed >= script.wait) _finish();
    }
    view
      ..time = ambient
      ..done = done
      ..progress = approach(view.progress, _progress, dt, 1.4);
    if (done) view.sinceDone += reducedMotion ? 10 : dt;
    for (var i = 0; i < view.appear.length; i++) {
      final target = switch (script.interaction) {
        Interaction.tapAll => _hit.contains(i) ? 1.0 : 0.0,
        _ => i == 0 ? _progress : 0.0,
      };
      view.appear[i] = approach(view.appear[i], target, dt, 2);
      view.pulse[i] = approach(view.pulse[i], 0, dt, 2.5);
    }
  }

  @override
  void render(Canvas canvas) => script.paint(canvas, size.toSize(), view);
}

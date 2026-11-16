import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../art/animals.dart';
import '../../art/ark.dart';
import '../../art/colombe.dart';
import '../../art/landscape.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/weather.dart';
import '../../audio/audio.dart';
import '../../story/story_game.dart';
import '../../theme/palette.dart';

/// Les huit décors de l'histoire de Noé (Genèse 6 à 9).
final Map<String, StageBuilder> noeStages = {
  'noah_village': VillageStage.new,
  'god_speaks': GodSpeaksStage.new,
  'building': BuildingStage.new,
  'animals': AnimalsStage.new,
  'rain': RainStage.new,
  'dove': DoveStage.new,
  'exit': ExitStage.new,
  'rainbow': RainbowStage.new,
};

// Palettes partagées.
const _daySky = [Color(0xFF9FD3E8), Color(0xFFCDE8EE), Color(0xFFFFF1D6)];
const _land = [Color(0xFFD8CF98), Color(0xFFB9C47F), Color(0xFF97AE67), Color(0xFF768F4F)];

/// Collines de fond communes à plusieurs décors.
class _Landscape {
  _Landscape(Size s, {List<double> baselines = const [0.62, 0.72, 0.84], int seed = 30})
    : hills = [
        for (var i = 0; i < baselines.length; i++)
          Hill(
            size: s,
            baseline: s.height * baselines[i],
            amplitude: s.height * (0.05 - i * 0.01),
            seed: seed + i * 5,
            waves: 1.4 + i * 0.5,
          ),
      ];

  final List<Hill> hills;
}

/// Rect de l'arche dont le bas est centré en [bottomCenter].
Rect _arkRect(Offset bottomCenter, double width) {
  final h = width / Ark.aspectRatio;
  return Rect.fromLTWH(bottomCenter.dx - width / 2, bottomCenter.dy - h, width, h);
}

Offset _inArk(Rect ark, Offset relative) =>
    Offset(ark.left + ark.width * relative.dx, ark.top + ark.height * relative.dy);

double _blinkAt(double time, double phase) => ((time + phase) % 3.7) < 0.14 ? 1 : 0;

// ─────────────────────────────────────────────────────────────────────────────
// 1. Noé et sa famille dans leur village.

class VillageStage extends StoryStage {
  late _Landscape _land3;
  final _people = <({PersonStyle style, Offset feet, double height, double phase})>[];
  final _wave = List<double>.filled(5, 0);
  double _noahHeight = 0;
  Offset _noahFeet = Offset.zero;

  @override
  void layout(Size s) {
    _land3 = _Landscape(s, seed: 12);
    final ground = _land3.hills.last;
    _noahHeight = s.height * 0.44;
    _noahFeet = Offset(s.width * 0.40, ground.heightAt(s.width * 0.40) + s.height * 0.08);
    _people
      ..clear()
      ..addAll([
        for (final (i, style) in [NoahFamily.ham, NoahFamily.shem, NoahFamily.japheth].indexed)
          (
            style: style,
            feet: Offset(s.width * (0.62 + i * 0.08), ground.heightAt(s.width * (0.62 + i * 0.08)) + s.height * 0.06),
            height: s.height * 0.38,
            phase: i * 0.9 + 0.5,
          ),
        (
          style: NoahFamily.wife,
          feet: Offset(s.width * 0.52, _noahFeet.dy - s.height * 0.005),
          height: s.height * 0.42,
          phase: 1.7,
        ),
        (style: NoahFamily.noah, feet: _noahFeet, height: _noahHeight, phase: 0.0),
      ]);
  }

  @override
  Vector2? get hintTarget => Vector2(_noahFeet.dx, _noahFeet.dy - _noahHeight * 0.8);

  /// Noé salue : c'est l'action attendue.
  void greetNoah() {
    _wave[4] = 1;
    game.sfx.play(Sfx.chime);
    game.add(Sparkles(origin: hintTarget!, radius: _noahHeight * 0.3));
    complete();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = event.localPosition;
    for (var i = _people.length - 1; i >= 0; i--) {
      final person = _people[i];
      final box = Rect.fromLTRB(
        person.feet.dx - person.height * 0.25,
        person.feet.dy - person.height,
        person.feet.dx + person.height * 0.25,
        person.feet.dy,
      );
      if (box.contains(Offset(p.x, p.y))) {
        if (i == 4) {
          greetNoah();
        } else {
          _wave[i] = 1;
          game.sfx.play(Sfx.pop);
        }
        return;
      }
    }
  }

  @override
  void tick(double dt) {
    for (var i = 0; i < _wave.length; i++) {
      _wave[i] = approach(_wave[i], 0, dt, 0.5);
    }
  }

  @override
  void render(Canvas canvas) {
    final s = size.toSize();
    paintSky(canvas, _daySky);
    canvas.drawCircle(Offset(s.width * 0.82, s.height * 0.2), s.height * 0.08, Paint()..color = Palette.sun);
    paintHill(canvas, _land3.hills[0], _land[0], 0);
    final h0 = _land3.hills[0];
    for (final (fx, k) in const [(0.12, 1.0), (0.17, 1.2), (0.22, 0.9), (0.86, 1.1)]) {
      final base = Offset(s.width * fx, h0.heightAt(s.width * fx) + 4);
      final w = s.height * 0.08 * k;
      drawPaper(canvas, housePath(base, w, w * 0.85), const Color(0xFFF1DDB8), elevation: 3);
      drawPaper(canvas, houseOpenings(base, w, w * 0.85), const Color(0xFF8C5A3C), elevation: 0, light: 0);
    }
    paintHill(canvas, _land3.hills[1], _land[1], 1);
    for (final fx in [0.05, 0.93]) {
      final h1 = _land3.hills[1];
      drawPaper(
        canvas,
        palmPath(Offset(s.width * fx, h1.heightAt(s.width * fx) + 6), s.height * 0.3),
        const Color(0xFF6E8A48),
        elevation: 4,
      );
    }
    paintHill(canvas, _land3.hills[2], _land[2], 2);
    final waveAnim = [for (final w in _wave) math.sin(w * math.pi * 3).abs() * w + w * 0.4];
    for (final (i, p) in _people.indexed) {
      paintPerson(
        canvas,
        p.feet,
        p.height,
        p.style,
        wave: waveAnim[i].clamp(0.0, 1.0),
        blink: _blinkAt(ambient, p.phase),
        bob: math.sin(ambient * 2 + p.phase) * p.height * 0.006 + _wave[i] * p.height * 0.04,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Dieu parle à Noé : une lumière qui descend du ciel.

class GodSpeaksStage extends StoryStage {
  late _Landscape _land3;
  double _glow = 0;
  Offset _origin = Offset.zero;
  Offset _noahFeet = Offset.zero;
  double _noahHeight = 0;

  @override
  void layout(Size s) {
    _land3 = _Landscape(s, baselines: const [0.66, 0.78, 0.9], seed: 50);
    _origin = Offset(s.width * 0.30, -s.height * 0.05);
    _noahHeight = s.height * 0.46;
    _noahFeet = Offset(s.width * 0.62, _land3.hills.last.heightAt(s.width * 0.62) + s.height * 0.06);
  }

  @override
  Vector2? get hintTarget => Vector2(size.x * 0.32, size.y * 0.28);

  void touchLight() {
    if (done) return;
    game.sfx.play(Sfx.chime);
    game.add(Sparkles(origin: hintTarget!, radius: size.y * 0.15, count: 18));
    complete();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (event.localPosition.x < size.x * 0.56 && event.localPosition.y < size.y * 0.8) touchLight();
  }

  @override
  void tick(double dt) => _glow = approach(_glow, done ? 1 : 0, dt, 0.8);

  @override
  void render(Canvas canvas) {
    final s = size.toSize();
    paintSky(canvas, const [Color(0xFF3E4C7A), Color(0xFF8A6F9E), Color(0xFFF2B98A)], stops: const [0, 0.55, 1]);
    final star = Paint()..color = const Color(0xCCFFF6DC);
    final random = math.Random(8);
    for (var i = 0; i < 40; i++) {
      final twinkle = 0.5 + 0.5 * math.sin(ambient * 2 + i);
      canvas.drawCircle(
        Offset(random.nextDouble() * s.width, random.nextDouble() * s.height * 0.45),
        1 + twinkle * 1.2,
        star,
      );
    }
    paintHeavenlyLight(canvas, s, _origin, ambient, intensity: 0.6 + _glow * 0.7);
    for (final (i, c) in const [Color(0xFF6D5A80), Color(0xFF54476A), Color(0xFF3F3554)].indexed) {
      paintHill(canvas, _land3.hills[i], c, i.toDouble());
    }
    // Noé, tourné vers la lumière, lève les mains pour écouter.
    paintPerson(
      canvas,
      _noahFeet,
      _noahHeight,
      NoahFamily.noah,
      facingLeft: true,
      raisedBoth: true,
      wave: _glow * 0.55,
      blink: _blinkAt(ambient, 0.4),
      bob: math.sin(ambient * 1.6) * s.height * 0.003,
    );
    // Le halo éclaire Noé.
    canvas.drawCircle(
      Offset(_noahFeet.dx, _noahFeet.dy - _noahHeight * 0.6),
      _noahHeight * 0.7,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.12 + _glow * 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _noahHeight * 0.3),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Noé construit l'arche, planche après planche.

class BuildingStage extends StoryStage {
  late _Landscape _land3;
  int step = 0;
  double _shown = 0;
  double _hammer = 0;
  Rect _ark = Rect.zero;
  Offset _noahFeet = Offset.zero;
  double _noahHeight = 0;

  @override
  void layout(Size s) {
    _land3 = _Landscape(s, seed: 70);
    final w = math.min(s.width * 0.56, s.height * 0.95);
    _ark = _arkRect(Offset(s.width * 0.56, s.height * 0.86), w);
    _noahHeight = s.height * 0.4;
    _noahFeet = Offset(s.width * 0.17, s.height * 0.93);
  }

  @override
  Vector2? get hintTarget => Vector2(_ark.center.dx, _ark.center.dy + _ark.height * 0.2);

  /// Un coup de marteau : une étape de plus.
  void hammer() {
    if (done) return;
    step = math.min(Ark.buildSteps, step + 1);
    _hammer = 1;
    game.sfx.play(Sfx.knock);
    game.add(Sparkles(origin: hintTarget!, radius: _ark.height * 0.35, count: 8, seed: step));
    if (step == Ark.buildSteps) complete();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = Offset(event.localPosition.x, event.localPosition.y);
    if (_ark.inflate(_ark.height * 0.15).contains(p) || (p - _noahFeet).distance < _noahHeight) hammer();
  }

  @override
  void tick(double dt) {
    _shown = approach(_shown, step / Ark.buildSteps, dt, 0.9);
    _hammer = approach(_hammer, 0, dt, 3);
  }

  @override
  void render(Canvas canvas) {
    final s = size.toSize();
    paintSky(canvas, _daySky);
    for (var i = 0; i < 3; i++) {
      paintHill(canvas, _land3.hills[i], _land[i], i.toDouble());
    }
    // Planches empilées à côté du chantier.
    for (var i = 0; i < 4 - (step * 0.8).floor(); i++) {
      final r = Rect.fromLTWH(s.width * 0.82, s.height * 0.9 - i * s.height * 0.025, s.width * 0.14, s.height * 0.022);
      drawPaper(
        canvas,
        Path()..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(3))),
        Ark.woodLight,
        elevation: 2,
      );
    }
    Ark.paint(canvas, _ark, build: math.max(_shown, step / Ark.buildSteps - 0.001));
    final strike = math.sin(_hammer * math.pi);
    paintPerson(
      canvas,
      _noahFeet,
      _noahHeight,
      NoahFamily.noah,
      wave: 0.35 + strike * 0.65,
      blink: _blinkAt(ambient, 1.1),
      bob: strike * s.height * 0.01,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Les animaux entrent dans l'arche, deux par deux.

class _Pair {
  _Pair(this.animal, this.home, this.size);

  final Animal animal;
  Offset home;
  double size;
  Offset position = Offset.zero;

  /// 0 = attend, 1 = marche vers l'arche, 2 = entré.
  int state = 0;
  double walk = 0;
  double progress = 0;
}

class AnimalsStage extends StoryStage {
  late _Landscape _land3;
  Rect _ark = Rect.zero;
  Offset _rampEnd = Offset.zero;
  Offset _door = Offset.zero;
  final pairs = <_Pair>[];

  static const _animals = [Animal.giraffe, Animal.elephant, Animal.lion, Animal.sheep];

  @override
  void layout(Size s) {
    _land3 = _Landscape(s, seed: 90);
    final w = math.min(s.width * 0.5, s.height * 0.85);
    _ark = _arkRect(Offset(s.width * 0.70, s.height * 0.82), w);
    _door = _inArk(_ark, Ark.doorCenter);
    _rampEnd = Offset(_ark.left + _ark.width * (17 / 200), _ark.top + _ark.height * (92 / 120));
    // Tout reste au-dessus du bandeau des sous-titres (bas de l'écran).
    final homes = [
      (Offset(s.width * 0.10, s.height * 0.62), s.height * 0.24),
      (Offset(s.width * 0.27, s.height * 0.64), s.height * 0.18),
      (Offset(s.width * 0.12, s.height * 0.80), s.height * 0.14),
      (Offset(s.width * 0.30, s.height * 0.80), s.height * 0.12),
    ];
    if (pairs.isEmpty) {
      for (var i = 0; i < _animals.length; i++) {
        pairs.add(_Pair(_animals[i], homes[i].$1, homes[i].$2)..position = homes[i].$1);
      }
    } else {
      for (var i = 0; i < pairs.length; i++) {
        pairs[i]
          ..home = homes[i].$1
          ..size = homes[i].$2;
        if (pairs[i].state == 0) pairs[i].position = homes[i].$1;
      }
    }
  }

  _Pair? get _nextWaiting {
    for (final p in pairs) {
      if (p.state == 0) return p;
    }
    return null;
  }

  @override
  Vector2? get hintTarget {
    final p = _nextWaiting;
    return p == null ? null : Vector2(p.home.dx, p.home.dy - p.size * 0.5);
  }

  /// Fait entrer le couple [index] dans l'arche.
  void sendPair(int index) {
    final pair = pairs[index];
    if (pair.state != 0) return;
    pair.state = 1;
    game.sfx.play(Sfx.pop);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = Offset(event.localPosition.x, event.localPosition.y);
    for (var i = 0; i < pairs.length; i++) {
      final pair = pairs[i];
      final box = Rect.fromLTRB(
        pair.home.dx - pair.size * 1.1,
        pair.home.dy - pair.size * 1.05,
        pair.home.dx + pair.size * 1.1,
        pair.home.dy + pair.size * 0.1,
      );
      if (pair.state == 0 && box.contains(p)) {
        sendPair(i);
        return;
      }
    }
  }

  @override
  void tick(double dt) {
    for (final pair in pairs) {
      if (pair.state != 1) continue;
      pair.walk += dt * 1.6;
      pair.progress = approach(pair.progress, 1, dt, 0.45);
      final t = pair.progress;
      // D'abord jusqu'au bas de la rampe, puis on monte jusqu'à la porte.
      pair.position = t < 0.7
          ? Offset.lerp(pair.home, _rampEnd, t / 0.7)!
          : Offset.lerp(_rampEnd, _door + Offset(0, _ark.height * 0.13), (t - 0.7) / 0.3)!;
      if (t >= 1) {
        pair.state = 2;
        game.sfx.play(Sfx.chime);
      }
    }
    if (!done && pairs.isNotEmpty && pairs.every((p) => p.state == 2)) complete();
  }

  @override
  void render(Canvas canvas) {
    paintSky(canvas, _daySky);
    for (var i = 0; i < 3; i++) {
      paintHill(canvas, _land3.hills[i], _land[i], i.toDouble());
    }
    Ark.paint(canvas, _ark, door: 1);
    final ordered = [...pairs]..sort((a, b) => a.position.dy.compareTo(b.position.dy));
    for (final pair in ordered) {
      if (pair.state == 2) continue;
      final shrink = pair.progress > 0.7 ? 1 - (pair.progress - 0.7) / 0.3 * 0.55 : 1.0;
      final sz = pair.size * shrink;
      final bob = pair.state == 0 ? math.sin(ambient * 2 + pair.home.dx) * sz * 0.015 : 0.0;
      for (final dx in [-0.55, 0.45]) {
        final at = pair.position + Offset(dx * sz, (dx < 0 ? -0.04 : 0.02) * sz - bob);
        paintAnimal(
          canvas,
          pair.animal,
          Rect.fromCenter(center: at - Offset(0, sz / 2), width: sz, height: sz),
          walk: pair.walk + (dx < 0 ? 0.25 : 0),
          blink: _blinkAt(ambient, pair.home.dx + dx),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. La pluie tombe, l'arche flotte.

class RainStage extends StoryStage {
  final _rain = RainField();
  double _level = 0;
  double _rock = 0;
  double _rockPhase = 0;
  int rocks = 0;

  /// Niveau d'eau final (Y), atteint quelques secondes après l'arrivée.
  double get _targetLevel => size.y * 0.66;

  @override
  void layout(Size s) {
    _rain.resize(s);
    if (_level == 0) _level = s.height * 0.96;
  }

  Rect get arkRect {
    final w = math.min(size.x * 0.44, size.y * 0.8);
    final bob = math.sin(ambient * 1.4) * size.y * 0.01;
    return _arkRect(Offset(size.x * 0.5, _level + w / Ark.aspectRatio * 0.18 + bob), w);
  }

  @override
  Vector2? get hintTarget => Vector2(arkRect.center.dx, arkRect.center.dy);

  /// Berce l'arche sur les vagues.
  void rock() {
    if (done) return;
    rocks++;
    _rock = 1;
    game.sfx.play(Sfx.whoosh);
    if (rocks >= 3) complete();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = Offset(event.localPosition.x, event.localPosition.y);
    if (arkRect.inflate(arkRect.height * 0.2).contains(p)) rock();
  }

  @override
  void tick(double dt) {
    if (!reducedMotion) _rain.update(dt);
    _level = approach(_level, _targetLevel, dt, size.y * 0.06);
    _rock = approach(_rock, 0, dt, 0.6);
    _rockPhase += dt * 5;
  }

  @override
  void render(Canvas canvas) {
    final s = size.toSize();
    paintSky(canvas, const [Color(0xFF4F5E78), Color(0xFF7C8BA0), Color(0xFFAAB7C4)]);
    for (final (i, fx) in const [0.15, 0.5, 0.82].indexed) {
      final x = (fx * s.width + ambient * (8 + i * 4)) % (s.width + 200) - 100;
      canvas.save();
      canvas.translate(x, s.height * (0.12 + i * 0.05));
      drawPaper(canvas, cloudPath(Offset.zero, s.width * 0.28), const Color(0xFF6B7891), elevation: 4, light: 0.15);
      canvas.restore();
    }
    paintWaves(canvas, s, _level - s.height * 0.05, ambient, to: 2);
    final ark = arkRect;
    canvas.save();
    canvas.translate(ark.bottomCenter.dx, ark.bottom);
    canvas.rotate(math.sin(ambient * 0.9) * 0.03 + math.sin(_rockPhase) * 0.09 * _rock);
    canvas.translate(-ark.bottomCenter.dx, -ark.bottom);
    Ark.paint(canvas, ark);
    canvas.restore();
    paintWaves(canvas, s, _level - s.height * 0.05, ambient, from: 2);
    _rain.paint(canvas);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Noé lâche la colombe ; elle revient avec une feuille d'olivier.

class DoveStage extends StoryStage {
  double _window = 0;

  /// 0 attend, 1 s'envole, 2 au loin, 3 revient, 4 posée sur le toit.
  int phase = 0;
  double _t = 0;
  Rect _ark = Rect.zero;

  static const _durations = [0.0, 2.4, 1.2, 2.6];

  @override
  void layout(Size s) {
    final w = math.min(s.width * 0.42, s.height * 0.78);
    _ark = _arkRect(Offset(s.width * 0.40, s.height * 0.76), w);
  }

  Offset get _windowPos => _inArk(_ark, Ark.windowCenter);
  Offset get _roof => _inArk(_ark, const Offset(0.5, 0.0));

  @override
  Vector2? get hintTarget => Vector2(_windowPos.dx, _windowPos.dy);

  void openWindow() {
    if (phase != 0) return;
    phase = 1;
    _t = 0;
    game.sfx.play(Sfx.whoosh);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = Offset(event.localPosition.x, event.localPosition.y);
    if ((p - _windowPos).distance < _ark.height * 0.4) openWindow();
  }

  @override
  void tick(double dt) {
    _window = approach(_window, phase > 0 ? 1 : 0, dt, 2);
    if (phase >= 1 && phase <= 3) {
      _t += dt;
      if (reducedMotion || _t >= _durations[phase]) {
        phase++;
        _t = 0;
        if (phase == 4) {
          game.sfx.play(Sfx.chime);
          game.add(Sparkles(origin: Vector2(_roof.dx, _roof.dy), radius: _ark.height * 0.4));
          complete();
        }
      }
    }
  }

  Offset _dovePosition() {
    final far = Offset(size.x * 1.15, size.y * 0.12);
    final t = phase >= 1 && phase <= 3 ? (_t / _durations[phase]).clamp(0.0, 1.0) : 0.0;
    final ease = t * t * (3 - 2 * t);
    return switch (phase) {
      1 => Offset.lerp(_windowPos, far, ease)! + Offset(0, -math.sin(ease * math.pi) * size.y * 0.12),
      2 => far,
      3 =>
        Offset.lerp(far, _roof - Offset(0, size.y * 0.04), ease)! + Offset(0, -math.sin(ease * math.pi) * size.y * 0.1),
      4 => _roof - Offset(0, size.y * 0.04),
      _ => _windowPos,
    };
  }

  @override
  void render(Canvas canvas) {
    final s = size.toSize();
    paintSky(canvas, const [Color(0xFF8EC5E0), Color(0xFFC4E2EC), Color(0xFFFDF0D8)]);
    canvas.drawCircle(Offset(s.width * 0.8, s.height * 0.22), s.height * 0.09, Paint()..color = Palette.sun);
    for (final (fx, h) in const [(0.78, 0.18), (0.92, 0.12)]) {
      drawPaper(
        canvas,
        mountainPath(s, s.height * 0.78, peakX: fx, height: h, width: 0.3),
        const Color(0xFF8C9A84),
        elevation: 4,
      );
    }
    paintWaves(canvas, s, s.height * 0.72, ambient * 0.6, to: 2);
    Ark.paint(canvas, _ark, window: _window);
    paintWaves(canvas, s, s.height * 0.72, ambient * 0.6, from: 2);
    if (phase >= 1) {
      final pos = _dovePosition();
      final h = s.height * 0.12;
      final returning = phase >= 3;
      canvas.save();
      canvas.translate(pos.dx - h * Colombe.aspectRatio / 2, pos.dy - h / 2);
      Colombe.paint(
        canvas,
        Size(h * Colombe.aspectRatio, h),
        flap: phase == 4 ? 0.2 : 0.5 + 0.5 * math.sin(ambient * 14 + _t * 10),
        facingLeft: returning,
        withBranch: returning,
        blink: _blinkAt(ambient, 0.2),
      );
      canvas.restore();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. Tout le monde sort de l'arche.

class _Walker {
  _Walker({this.person, this.animal, required this.delay, required this.target, required this.height});

  final PersonStyle? person;
  final Animal? animal;
  final double delay;
  final double target;
  final double height;
  double x = 0;
  double walk = 0;
}

class ExitStage extends StoryStage {
  late _Landscape _land3;
  double _door = 0;
  bool opened = false;
  double _since = 0;
  Rect _ark = Rect.zero;
  final walkers = <_Walker>[];

  @override
  void layout(Size s) {
    _land3 = _Landscape(s, baselines: const [0.7, 0.8, 0.9], seed: 110);
    final w = math.min(s.width * 0.44, s.height * 0.8);
    _ark = _arkRect(Offset(s.width * 0.34, s.height * 0.80), w);
    final h = s.height * 0.26;
    final family = [NoahFamily.noah, NoahFamily.wife, NoahFamily.shem, NoahFamily.ham, NoahFamily.japheth];
    walkers
      ..clear()
      ..addAll([
        for (final (i, p) in family.indexed)
          _Walker(person: p, delay: 0.4 + i * 0.7, target: 0.56 + i * 0.075, height: h),
        for (final (i, a) in const [Animal.elephant, Animal.giraffe, Animal.lion, Animal.sheep, Animal.rabbit].indexed)
          _Walker(animal: a, delay: 0.75 + i * 0.7, target: 0.6 + i * 0.07, height: s.height * (0.12 - i * 0.01)),
      ]);
  }

  Offset get _doorPos => _inArk(_ark, Ark.doorCenter);
  double get _ground => size.y * 0.93;

  @override
  Vector2? get hintTarget => Vector2(_doorPos.dx, _doorPos.dy);

  void openDoor() {
    if (opened) return;
    opened = true;
    game.sfx.play(Sfx.knock);
    complete();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = Offset(event.localPosition.x, event.localPosition.y);
    if ((p - _doorPos).distance < _ark.height * 0.45) openDoor();
  }

  @override
  void tick(double dt) {
    _door = approach(_door, opened ? 1 : 0, dt, 0.8);
    if (_door < 1) return;
    _since += dt;
    final start = _ark.left + _ark.width * 0.08;
    for (final w in walkers) {
      if (!reducedMotion && _since < w.delay) {
        w.x = start;
        continue;
      }
      final target = size.x * w.target;
      if (w.x == 0) w.x = start;
      final before = w.x;
      w.x = approach(w.x, target, dt, size.x * 0.12);
      if (w.x != before) w.walk += dt * 1.8;
    }
  }

  @override
  void render(Canvas canvas) {
    final s = size.toSize();
    paintSky(canvas, _daySky);
    drawPaper(
      canvas,
      mountainPath(s, s.height * 0.75, peakX: 0.62, height: 0.5, width: 0.9),
      const Color(0xFF9AA8B8),
      elevation: 4,
    );
    // Neige au sommet de l'Ararat.
    canvas.save();
    canvas.clipPath(mountainPath(s, s.height * 0.75, peakX: 0.62, height: 0.5, width: 0.9));
    drawPaper(
      canvas,
      Path()..addOval(
        Rect.fromCenter(center: Offset(s.width * 0.62, s.height * 0.27), width: s.width * 0.2, height: s.height * 0.16),
      ),
      const Color(0xFFF7F4EE),
      elevation: 0,
    );
    canvas.restore();
    for (var i = 0; i < 3; i++) {
      paintHill(canvas, _land3.hills[i], _land[i + 1], i.toDouble());
    }
    Ark.paint(canvas, _ark, door: _door);
    if (_door >= 1) {
      final ordered = [...walkers]..sort((a, b) => a.height.compareTo(b.height));
      for (final w in ordered.reversed) {
        if (w.x == 0) continue;
        final feet = Offset(w.x, _ground - (w.animal != null ? 0 : s.height * 0.01));
        if (w.person != null) {
          paintPerson(
            canvas,
            feet,
            w.height,
            w.person!,
            wave: w.x >= size.x * w.target - 1 ? 0.8 + 0.2 * math.sin(ambient * 4 + w.delay) : 0,
            bob: (math.sin(w.walk * math.pi * 2)).abs() * w.height * 0.02,
            blink: _blinkAt(ambient, w.delay),
          );
        } else {
          paintAnimal(
            canvas,
            w.animal!,
            Rect.fromLTWH(feet.dx - w.height / 2, feet.dy - w.height, w.height, w.height),
            walk: w.walk,
            blink: _blinkAt(ambient, w.delay),
          );
        }
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. L'arc-en-ciel : l'enfant le dessine du doigt.

class RainbowStage extends StoryStage {
  late _Landscape _land3;
  double progress = 0;
  double _shown = 0;
  Rect _ark = Rect.zero;

  Offset get _center => Offset(size.x * 0.5, size.y * 0.8);
  double get _radius => math.min(size.x * 0.44, size.y * 0.66);

  @override
  void layout(Size s) {
    _land3 = _Landscape(s, baselines: const [0.76, 0.86], seed: 130);
    final w = s.width * 0.14;
    _ark = _arkRect(Offset(s.width * 0.18, s.height * 0.62), w);
  }

  @override
  Vector2? get hintTarget {
    final a = math.pi + math.pi * progress.clamp(0.0, 0.95);
    final r = _radius * 0.84;
    return Vector2(_center.dx + math.cos(a) * r, _center.dy + math.sin(a) * r);
  }

  /// Ajoute un morceau d'arc-en-ciel.
  void addRainbow(double amount) {
    if (done) return;
    final before = progress;
    progress = (progress + amount).clamp(0.0, 1.0);
    if ((before * 7).floor() != (progress * 7).floor()) game.sfx.play(Sfx.pop);
    if (progress >= 1) {
      game.add(Sparkles(origin: Vector2(_center.dx, _center.dy - _radius), radius: _radius * 0.4, count: 20));
      complete();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (event.localPosition.y < _center.dy) addRainbow(0.2);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    addRainbow(event.localDelta.length / (size.x * 0.9));
  }

  @override
  void tick(double dt) => _shown = approach(_shown, progress, dt, 1.5);

  @override
  void render(Canvas canvas) {
    final s = size.toSize();
    paintSky(canvas, const [Color(0xFF7EC3E6), Color(0xFFBFE3F0), Color(0xFFFFF4DC)]);
    canvas.drawCircle(Offset(s.width * 0.86, s.height * 0.16), s.height * 0.08, Paint()..color = Palette.sun);
    paintRainbow(canvas, _center, _radius, _radius * 0.3, progress: 1, bands: 0);
    paintRainbow(canvas, _center, _radius, _radius * 0.3, progress: _shown);
    for (final (i, fx) in const [0.25, 0.7].indexed) {
      final x = (fx * s.width + ambient * (6 + i * 3)) % (s.width + 200) - 100;
      canvas.save();
      canvas.translate(x, s.height * (0.18 + i * 0.1));
      drawPaper(canvas, cloudPath(Offset.zero, s.width * 0.16), Palette.cloud, elevation: 4, light: 0.3);
      canvas.restore();
    }
    drawPaper(
      canvas,
      mountainPath(s, s.height * 0.8, peakX: 0.18, height: 0.24, width: 0.4),
      const Color(0xFF8FA07E),
      elevation: 4,
    );
    Ark.paint(canvas, _ark, door: 1);
    paintHill(canvas, _land3.hills[0], _land[1], 0);
    paintHill(canvas, _land3.hills[1], _land[2], 1);
    final h = s.height * 0.22;
    for (final (i, p) in [NoahFamily.wife, NoahFamily.noah, NoahFamily.shem].indexed) {
      paintPerson(
        canvas,
        Offset(s.width * (0.66 + i * 0.07), s.height * 0.97),
        h,
        p,
        wave: done ? 0.7 + 0.3 * math.sin(ambient * 3 + i) : 0,
        blink: _blinkAt(ambient, i * 1.3),
      );
    }
    paintAnimal(canvas, Animal.sheep, Rect.fromLTWH(s.width * 0.42, s.height * 0.86, s.height * 0.11, s.height * 0.11));
    paintAnimal(
      canvas,
      Animal.rabbit,
      Rect.fromLTWH(s.width * 0.52, s.height * 0.89, s.height * 0.08, s.height * 0.08),
      facingLeft: true,
    );
  }
}

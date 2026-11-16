import 'dart:math' as math;
import 'dart:ui';

import '../../art/animals.dart';
import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../art/weather.dart';
import '../../audio/audio.dart';
import '../../story/scripted_stage.dart';
import '../../theme/palette.dart';
import '../nt/nt.dart';
import '../registry.dart';

/// Le baptême de Jésus et l'appel des premiers disciples (Matthieu 3 et 4).
final baptemePack = StoryPack.scripted(
  scripts: {
    'desert': StageScript(
      targets: [for (var i = 0; i < 3; i++) Rect.fromLTRB(0.52 + i * 0.14, 0.44, 0.64 + i * 0.14, 0.82)],
      paint: _desert,
    ),
    'jourdain': StageScript(
      targets: [for (final x in _bathers) Rect.fromLTRB(x - 0.07, 0.40, x + 0.07, 0.80)],
      paint: _jourdain,
    ),
    'arrivee': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.1, 0.6),
      swipeTo: Offset(0.5, 0.6),
      paint: _arrivee,
    ),
    'bapteme': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.38, 0.32, 0.62, 0.78)],
      sfx: Sfx.chime,
      paint: _bapteme,
    ),
    'colombe': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.5, 0.08),
      swipeTo: Offset(0.5, 0.4),
      sfx: Sfx.chime,
      paint: _colombe,
    ),
    'pecheurs': StageScript(
      targets: [for (final x in _fishers) Rect.fromLTRB(x - 0.06, 0.40, x + 0.06, 0.74)],
      paint: _pecheurs,
    ),
  },
  stickerScene: 'colombe',
  seekScene: PaintedSeekScene(
    spots: const {
      'fish': (Offset(0.36, 0.86), 0.09),
      'frog': (Offset(0.70, 0.66), 0.08),
      'bird': (Offset(0.82, 0.20), 0.1),
      'dove': (Offset(0.20, 0.34), 0.09),
      'shell': (Offset(0.56, 0.92), 0.06),
      'tortoise': (Offset(0.12, 0.72), 0.11),
      'ladybug': (Offset(0.92, 0.56), 0.05),
      'snail': (Offset(0.46, 0.66), 0.06),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

/// Jean-Baptiste : vêtement de poils de chameau, ceinture de cuir.
const _john = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFFA9824F),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFF5C3A22),
  beard: Color(0xFF2E1E15),
  bareHead: true,
);

const _bathers = [0.26, 0.5, 0.74];
const _fishers = [0.2, 0.34, 0.66, 0.8];

// Le Jourdain : désert, roseaux et eau qui coule.
void _river(Canvas canvas, Size s, double time, {List<Color> sky = Skies.desert, double level = 0.72}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 2);
  paintHills(canvas, s, time, baselines: const [0.58, 0.66], colors: Lands.desert, seed: 181);
  paintWaves(canvas, s, s.height * level, time * 0.6, from: 0, to: 2);
  for (final fx in [0.04, 0.1, 0.92]) {
    paintThing(canvas, 'reeds', boxAt(s, fx, level + 0.04, 0.2, aspect: 0.6));
  }
}

void _riverFront(Canvas canvas, Size s, double time, {double level = 0.72}) {
  paintWaves(canvas, s, s.height * (level + 0.08), time * 0.6, from: 2, to: 4);
}

// 1. Jean-Baptiste prêche dans le désert : « Changez de vie ! »
void _desert(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintSun(canvas, Offset(s.width * 0.16, s.height * 0.16), s.height * 0.07);
  paintHills(canvas, s, v.time, baselines: const [0.62, 0.78], colors: Lands.desert, seed: 183);
  paintThing(canvas, 'stone', boxAt(s, 0.3, 0.96, 0.08, aspect: 1.4));
  paintPerson(
    canvas,
    feetAt(s, 0.28, 0.9),
    s.height * 0.46,
    _john,
    wave: 0.4 + 0.3 * math.sin(v.time * 2),
    blink: blinkAt(v.time, 0.3),
  );
  for (var i = 0; i < 3; i++) {
    final t = v.shown(i);
    final x = 0.58 + i * 0.14 - t * 0.04;
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, 0.45 + 0.55 * t));
    paintPerson(
      canvas,
      feetAt(s, x, 0.94),
      s.height * 0.36,
      NT.crowd[(i * 2 + 1) % NT.crowd.length],
      facingLeft: true,
      wave: t * 0.3,
      blink: blinkAt(v.time, i * 1.1),
    );
    canvas.restore();
  }
}

// 2. Beaucoup de gens se font baptiser par Jean dans le Jourdain.
void _jourdain(Canvas canvas, Size s, StageView v) {
  _river(canvas, s, v.time);
  for (var i = 0; i < _bathers.length; i++) {
    final t = v.shown(i);
    final dip = math.sin(t * math.pi) * s.height * 0.08;
    paintPerson(
      canvas,
      feetAt(s, _bathers[i], 0.9) + Offset(0, dip),
      s.height * 0.36,
      NT.crowd[i % NT.crowd.length],
      raisedBoth: t >= 1,
      wave: t >= 1 ? 0.5 : 0,
      blink: blinkAt(v.time, i * 1.3),
    );
  }
  paintPerson(
    canvas,
    feetAt(s, 0.62, 0.9),
    s.height * 0.42,
    _john,
    facingLeft: true,
    blink: blinkAt(v.time, 0.3),
  );
  _riverFront(canvas, s, v.time);
  for (var i = 0; i < _bathers.length; i++) {
    final t = v.shown(i);
    if (t <= 0 || t >= 1) continue;
    // Gerbe d'eau.
    final c = Offset(s.width * _bathers[i], s.height * 0.74);
    for (var k = 0; k < 5; k++) {
      final a = -math.pi / 2 + (k - 2) * 0.4;
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * s.height * 0.08 * t,
        s.height * 0.012,
        Paint()..color = const Color(0xCCEAF6FB),
      );
    }
  }
}

// 3. Jésus vient de Galilée jusqu'au Jourdain pour être baptisé par Jean.
void _arrivee(Canvas canvas, Size s, StageView v) {
  _river(canvas, s, v.time);
  final x = 0.1 + 0.4 * v.eased;
  final bob = v.progress > 0 && v.progress < 1 ? (math.sin(v.time * 6)).abs() * s.height * 0.006 : 0.0;
  paintPerson(canvas, feetAt(s, x, 0.9), s.height * 0.44, NT.jesus, bob: bob, blink: blinkAt(v.time, 0.7));
  paintPerson(
    canvas,
    feetAt(s, 0.7, 0.9),
    s.height * 0.44,
    _john,
    facingLeft: true,
    raisedBoth: v.done,
    wave: v.done ? 0.3 : 0,
    blink: blinkAt(v.time, 0.3),
  );
  _riverFront(canvas, s, v.time);
}

// 4. Jean baptise Jésus dans l'eau du Jourdain.
void _bapteme(Canvas canvas, Size s, StageView v) {
  _river(canvas, s, v.time);
  final t = v.eased;
  final dip = math.sin(math.min(1, t * 1.4) * math.pi) * s.height * 0.12;
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.92) + Offset(0, dip),
    s.height * 0.44,
    NT.jesus,
    blink: blinkAt(v.time, 0.7),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.64, 0.92),
    s.height * 0.44,
    _john,
    facingLeft: true,
    wave: 0.5,
    blink: blinkAt(v.time, 0.3),
  );
  _riverFront(canvas, s, v.time);
  if (t > 0.7) {
    final c = Offset(s.width * 0.5, s.height * 0.5);
    canvas.drawCircle(
      c,
      s.height * 0.16,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.25 * (t - 0.7) / 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.06),
    );
  }
}

// 5. Le ciel s'ouvre, l'Esprit descend comme une colombe, et la voix de Dieu parle.
void _colombe(Canvas canvas, Size s, StageView v) {
  _river(canvas, s, v.time);
  final t = v.eased;
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.4 + 0.8 * t);
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.86),
    s.height * 0.44,
    NT.jesus,
    raisedBoth: true,
    wave: 0.3,
    blink: blinkAt(v.time, 0.7),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.7, 0.9),
    s.height * 0.44,
    _john,
    facingLeft: true,
    raisedBoth: t > 0.5,
    blink: blinkAt(v.time, 0.3),
  );
  paintCrowd(canvas, s, v.time, from: 0.12, to: 0.3, fy: 0.9, h: 0.32, count: 3, wave: t * 0.4);
  final dove = Offset(s.width * 0.5, s.height * (0.08 + 0.18 * t));
  paintAnimal(
    canvas,
    Animal.dove,
    Rect.fromCenter(center: dove, width: s.height * 0.22, height: s.height * 0.18),
    blink: blinkAt(v.time, 2),
  );
  _riverFront(canvas, s, v.time);
}

// 6. Au bord du lac de Galilée, Jésus appelle des pêcheurs : « Suivez-moi ! »
void _pecheurs(Canvas canvas, Size s, StageView v) {
  paintGalilee(canvas, s, v.time, level: 0.62);
  paintThing(canvas, 'boat', boxAt(s, 0.26, 0.8, 0.3, aspect: 1.3));
  paintThing(canvas, 'boat', boxAt(s, 0.76, 0.78, 0.26, aspect: 1.3));
  paintWaves(canvas, s, s.height * 0.72, v.time * 0.5, from: 2, to: 4);
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.86, s.width, s.height * 0.14)),
    const Color(0xFFE6CFA3),
    elevation: 3,
  );
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.97),
    s.height * 0.44,
    NT.jesus,
    wave: 0.5,
    blink: blinkAt(v.time, 0.7),
  );
  for (var i = 0; i < _fishers.length; i++) {
    final t = v.shown(i);
    final home = _fishers[i];
    final to = home < 0.5 ? 0.42 - (1 - i) * 0.06 : 0.58 + (i - 2) * 0.06;
    final x = home + (to - home) * t;
    final y = 0.72 + 0.25 * t;
    paintPerson(
      canvas,
      feetAt(s, x, y),
      s.height * 0.32,
      NT.disciples[i],
      facingLeft: home > 0.5,
      wave: t >= 1 ? 0.4 : 0,
      blink: blinkAt(v.time, i * 1.2),
    );
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _river(canvas, s, 0, sky: Skies.day, level: 0.6);
  paintThing(canvas, 'tree', boxAt(s, 0.88, 0.64, 0.4));
}

void _seekForeground(Canvas canvas, Size s) {
  paintWaves(canvas, s, s.height * 0.8, 0, from: 2, to: 4);
  paintThing(canvas, 'reeds', boxAt(s, 0.26, 1.0, 0.26, aspect: 0.6));
  paintThing(canvas, 'reeds', boxAt(s, 0.78, 1.0, 0.24, aspect: 0.6));
  paintThing(canvas, 'stone', boxAt(s, 0.62, 1.0, 0.1, aspect: 1.4));
}

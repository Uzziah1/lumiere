import 'dart:math' as math;
import 'dart:ui';

import '../../art/animals.dart';
import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../audio/audio.dart';
import '../../story/scripted_stage.dart';
import '../../theme/palette.dart';
import '../nt/nt.dart';
import '../registry.dart';

/// Le fils prodigue (Luc 15.11-32).
final prodiguePack = StoryPack.scripted(
  scripts: {
    'depart': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.4, 0.6),
      swipeTo: Offset(0.9, 0.6),
      paint: _depart,
    ),
    'depense': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.36, 0.30, 0.64, 0.80)],
      sfx: Sfx.whoosh,
      paint: _depense,
    ),
    'cochons': StageScript(
      targets: [for (final x in _pigs) Rect.fromCenter(center: Offset(x, 0.74), width: 0.14, height: 0.18)],
      sfx: Sfx.tap,
      paint: _cochons,
    ),
    'retour': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.85, 0.6),
      swipeTo: Offset(0.3, 0.6),
      paint: _retour,
    ),
    'accueil': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.10, 0.36, 0.32, 0.82)],
      sfx: Sfx.chime,
      paint: _accueil,
    ),
    'festin': StageScript(
      targets: [
        for (final (x, _) in _gifts) Rect.fromCenter(center: Offset(x, 0.24), width: 0.14, height: 0.22),
      ],
      sfx: Sfx.chime,
      paint: _festin,
    ),
  },
  stickerScene: 'accueil',
  seekScene: PaintedSeekScene(
    spots: const {
      'pig': (Offset(0.20, 0.82), 0.14),
      'ring': (Offset(0.54, 0.92), 0.05),
      'coin': (Offset(0.34, 0.66), 0.05),
      'wheat': (Offset(0.08, 0.66), 0.14),
      'sheep': (Offset(0.70, 0.74), 0.12),
      'bird': (Offset(0.62, 0.18), 0.08),
      'jar': (Offset(0.92, 0.84), 0.12),
      'mouse': (Offset(0.42, 0.90), 0.06),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _father = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFF3A7CA5),
  headcloth: Color(0xFFF5EEE0),
  sash: Color(0xFFD9B27A),
  beard: Color(0xFFE6E0D6),
);

const _son = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFFE9B949),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFFB0413E),
  bareHead: true,
);

/// Le fils, ruiné : vêtement terne et usé.
const _poorSon = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFF9C8B74),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFF6B5A44),
  bareHead: true,
);

const _pigs = [0.5, 0.66, 0.82];
const _gifts = [(0.3, 'coat'), (0.5, 'ring'), (0.7, 'bread')];

// La ferme du père : collines vertes, maison, champs.
void _farm(Canvas canvas, Size s, double time, {List<Color> sky = Skies.day}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 2);
  paintHills(canvas, s, time, baselines: const [0.6, 0.74], colors: Lands.green, seed: 231);
  paintThing(canvas, 'city', boxAt(s, 0.14, 0.72, 0.24, aspect: 1.2));
  for (final fx in [0.32, 0.38]) {
    paintThing(canvas, 'wheat', boxAt(s, fx, 0.76, 0.12, aspect: 0.6));
  }
}

// 1. Le fils cadet demande sa part d'héritage et part loin de chez lui.
void _depart(Canvas canvas, Size s, StageView v) {
  _farm(canvas, s, v.time);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.26, 0.92),
    s.height * 0.46,
    _father,
    wave: 0.3 + 0.3 * t,
    blink: blinkAt(v.time, 0.4),
  );
  final x = 0.42 + 0.48 * t;
  paintPerson(
    canvas,
    feetAt(s, x, 0.94 - 0.1 * t),
    s.height * (0.44 - 0.16 * t),
    _son,
    bob: t > 0 && t < 1 ? (math.sin(v.time * 7)).abs() * s.height * 0.006 : 0,
    blink: blinkAt(v.time, 1),
  );
  paintThing(canvas, 'coin', boxAt(s, x + 0.03, 0.82 - 0.1 * t, 0.06 * (1 - 0.4 * t)));
}

// 2. Dans un pays lointain, il dépense tout son argent en faisant la fête.
void _depense(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.dusk);
  paintStarField(canvas, s, v.time, count: 20, opacity: 0.5);
  paintHills(canvas, s, v.time, baselines: const [0.62, 0.74], colors: Lands.desert, seed: 233);
  for (final (fx, h) in [(0.12, 0.26), (0.86, 0.3)]) {
    paintThing(canvas, 'city', boxAt(s, fx, 0.76, h, aspect: 1.2));
  }
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.94),
    s.height * 0.46,
    v.done ? _poorSon : _son,
    raisedBoth: !v.done,
    wave: v.done ? 0 : 0.6,
    blink: blinkAt(v.time, 1),
  );
  paintCrowd(
    canvas,
    s,
    v.time,
    from: 0.24,
    to: 0.34,
    fy: 0.96,
    h: 0.38,
    count: 2,
    wave: v.done ? 0 : 0.5,
    offset: 1,
  );
  paintCrowd(
    canvas,
    s,
    v.time,
    from: 0.66,
    to: 0.76,
    fy: 0.96,
    h: 0.38,
    count: 2,
    wave: v.done ? 0 : 0.5,
    facingLeft: true,
    offset: 3,
  );
  // Les pièces s'envolent une à une.
  final left = 6 - (v.progress * 6).round();
  for (var k = 0; k < 6; k++) {
    final fly = k >= left;
    final y = fly ? 0.1 + ((v.time * 0.3 + k * 0.17) % 1) * 0.2 : 0.62;
    final x = fly ? 0.3 + k * 0.08 + math.sin(v.time + k) * 0.02 : 0.44 + (k % 3) * 0.04;
    if (fly && v.done) continue;
    paintThing(
      canvas,
      'coin',
      Rect.fromCenter(
        center: Offset(s.width * x, s.height * y),
        width: s.height * 0.05,
        height: s.height * 0.05,
      ),
    );
  }
}

// 3. Une famine arrive. Il garde des cochons et il a faim.
void _cochons(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintSun(canvas, Offset(s.width * 0.84, s.height * 0.14), s.height * 0.06);
  paintHills(canvas, s, v.time, baselines: const [0.62, 0.76], colors: Lands.desert, seed: 235);
  paintThing(canvas, 'tree', boxAt(s, 0.1, 0.8, 0.3));
  paintPerson(canvas, feetAt(s, 0.28, 0.94), s.height * 0.44, _poorSon, blink: blinkAt(v.time, 1), wave: 0.1);
  for (var i = 0; i < _pigs.length; i++) {
    final t = v.shown(i);
    paintThing(canvas, 'pig', boxAt(s, _pigs[i], 0.88 - math.sin(t * math.pi) * 0.04, 0.16, aspect: 1.3));
  }
  // Le fils pense à la maison de son père : une petite bulle.
  final think = (v.shown(0) + v.shown(1) + v.shown(2)) / 3;
  if (think > 0) {
    final c = Offset(s.width * 0.3, s.height * 0.24);
    final r = s.height * 0.1 * think;
    drawPaper(
      canvas,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      const Color(0xFFFFFBF0),
      elevation: 4,
    );
    paintThing(canvas, 'bread', Rect.fromCircle(center: c, radius: r * 0.6));
    for (var k = 0; k < 2; k++) {
      canvas.drawCircle(
        Offset(s.width * 0.29, s.height * (0.4 + k * 0.06)),
        s.height * (0.016 - k * 0.005) * think,
        Paint()..color = const Color(0xFFFFFBF0),
      );
    }
  }
}

// 4. Il se dit : « Je vais retourner chez mon père et lui demander pardon. »
void _retour(Canvas canvas, Size s, StageView v) {
  paintRoad(canvas, s, v.time, sky: Skies.dawn);
  paintThing(canvas, 'city', boxAt(s, 0.12, 0.66, 0.16, aspect: 1.2));
  final t = v.eased;
  final x = 0.85 - 0.5 * t;
  paintPerson(
    canvas,
    feetAt(s, x, 0.92),
    s.height * 0.44,
    _poorSon,
    facingLeft: true,
    bob: t > 0 && t < 1 ? (math.sin(v.time * 6)).abs() * s.height * 0.006 : 0,
    blink: blinkAt(v.time, 1),
  );
}

// 5. Le père le voit de loin, court vers lui et le serre dans ses bras.
void _accueil(Canvas canvas, Size s, StageView v) {
  _farm(canvas, s, v.time, sky: Skies.dawn);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.22 + 0.24 * t, 0.94),
    s.height * 0.46,
    _father,
    raisedBoth: true,
    wave: 0.6,
    bob: t > 0 && t < 1 ? (math.sin(v.time * 9)).abs() * s.height * 0.012 : 0,
    blink: blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.6 - 0.06 * t, 0.95),
    s.height * 0.44,
    _poorSon,
    facingLeft: true,
    raisedBoth: t > 0.8,
    wave: t * 0.5,
    blink: blinkAt(v.time, 1),
  );
  if (t > 0.8) {
    final c = Offset(s.width * 0.5, s.height * 0.62);
    canvas.drawCircle(
      c,
      s.height * 0.2,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.3 * (t - 0.8) / 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.08),
    );
  }
}

// 6. « Apportez la plus belle robe, une bague, et faisons la fête ! »
void _festin(Canvas canvas, Size s, StageView v) {
  _farm(canvas, s, v.time, sky: Skies.dusk);
  final dressed = v.shown(0) >= 1;
  paintPerson(canvas, feetAt(s, 0.4, 0.95), s.height * 0.46, _father, wave: 0.5, blink: blinkAt(v.time, 0.4));
  paintPerson(
    canvas,
    feetAt(s, 0.54, 0.95),
    s.height * 0.44,
    dressed ? _son : _poorSon,
    facingLeft: true,
    raisedBoth: v.done,
    wave: 0.4,
    blink: blinkAt(v.time, 1),
  );
  paintCrowd(
    canvas,
    s,
    v.time,
    from: 0.68,
    to: 0.92,
    fy: 0.97,
    h: 0.36,
    count: 3,
    wave: v.done ? 0.6 : 0.2,
    facingLeft: true,
    offset: 2,
  );
  for (var i = 0; i < _gifts.length; i++) {
    final (x, id) = _gifts[i];
    final t = v.shown(i);
    final c = Offset.lerp(Offset(s.width * x, s.height * 0.24), Offset(s.width * 0.54, s.height * 0.68), t)!;
    if (t >= 1 && id != 'bread') continue;
    final size = s.height * (0.14 - 0.06 * t);
    paintThing(
      canvas,
      id,
      Rect.fromCenter(center: c, width: size, height: size),
      glow: 1 - t,
    );
  }
  if (v.shown(2) >= 1) {
    paintThing(canvas, 'bread', boxAt(s, 0.22, 0.96, 0.08, aspect: 1.2));
    paintThing(canvas, 'fruit', boxAt(s, 0.28, 0.96, 0.07));
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _farm(canvas, s, 0);
  paintThing(canvas, 'tree', boxAt(s, 0.84, 0.72, 0.38));
}

void _seekForeground(Canvas canvas, Size s) {
  final grass = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.3, s.height * 0.99),
        width: s.width * 0.2,
        height: s.height * 0.12,
      ),
    )
    ..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.76, s.height * 0.99),
        width: s.width * 0.18,
        height: s.height * 0.12,
      ),
    );
  drawPaper(canvas, grass, const Color(0xFF6FAE4E), elevation: 4, light: 0.15);
  paintThing(canvas, 'crate', boxAt(s, 0.62, 1.0, 0.1));
  paintAnimal(canvas, Animal.rabbit, boxAt(s, 0.04, 1.0, 0.08));
}

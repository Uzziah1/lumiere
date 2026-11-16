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
import '../ot/heroes.dart';
import '../registry.dart';

/// Ruth et Naomi (Ruth 1 à 4).
final ruthPack = StoryPack.scripted(
  scripts: {
    'promesse': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.36, 0.60, 0.82)],
      sfx: Sfx.chime,
      paint: _promesse,
    ),
    'voyage': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.15, 0.6),
      swipeTo: Offset(0.6, 0.6),
      paint: _voyage,
    ),
    'glaner': StageScript(
      targets: [for (final x in _ears) Rect.fromCenter(center: Offset(x, 0.74), width: 0.1, height: 0.18)],
      sfx: Sfx.tap,
      paint: _glaner,
    ),
    'boaz': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.66, 0.36, 0.88, 0.82)],
      paint: _boaz,
    ),
    'mariage': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.36, 0.30, 0.64, 0.82)],
      sfx: Sfx.chime,
      paint: _mariage,
    ),
    'obed': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.44, 0.60, 0.70)],
      sfx: Sfx.chime,
      paint: _obed,
    ),
  },
  stickerScene: 'mariage',
  seekScene: PaintedSeekScene(
    spots: const {
      'wheat': (Offset(0.20, 0.70), 0.14),
      'basket': (Offset(0.62, 0.86), 0.11),
      'jar': (Offset(0.90, 0.84), 0.12),
      'bread': (Offset(0.40, 0.90), 0.07),
      'mouse': (Offset(0.30, 0.92), 0.06),
      'bird': (Offset(0.56, 0.18), 0.08),
      'rabbit': (Offset(0.80, 0.70), 0.1),
      'ladybug': (Offset(0.10, 0.88), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _ruth = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFFB0413E),
  headcloth: Color(0xFFF2C14E),
  sash: Color(0xFFF5EEE0),
  veil: true,
);

const _naomi = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFF6E5A8A),
  headcloth: Color(0xFFE6E0D6),
  sash: Color(0xFFD9B27A),
  veil: true,
);

const _orpah = PersonStyle(
  skin: Color(0xFF9C6440),
  robe: Color(0xFF2F8F6E),
  headcloth: Color(0xFFF0E2C8),
  veil: true,
);

const _boazStyle = PersonStyle(
  skin: Color(0xFF7D4A30),
  robe: Color(0xFF3A7CA5),
  headcloth: Color(0xFFF5EEE0),
  sash: Color(0xFFE9B949),
  beard: Color(0xFF4A3323),
);

const _ears = [0.3, 0.42, 0.54, 0.66];

// Un champ d'orge doré, avec des gerbes.
void _field(Canvas canvas, Size s, double time, {List<Color> sky = Skies.day}) {
  paintSkyGradient(canvas, s, sky);
  paintSun(canvas, Offset(s.width * 0.86, s.height * 0.16), s.height * 0.06);
  paintClouds(canvas, s, time, count: 2);
  paintHills(canvas, s, time, baselines: const [0.56, 0.64], colors: Lands.green, seed: 321);
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.66, s.width, s.height * 0.34)),
    const Color(0xFFE6C15A),
    elevation: 3,
    light: 0.2,
  );
  for (var k = 0; k < 9; k++) {
    paintThing(canvas, 'wheat', boxAt(s, 0.04 + k * 0.12, 0.72, 0.12, aspect: 0.6), time: time);
  }
}

// 1. Naomi rentre chez elle. Ruth refuse de la quitter : « Ton Dieu sera mon Dieu. »
void _promesse(Canvas canvas, Size s, StageView v) {
  paintRoad(canvas, s, v.time, sky: Skies.dawn);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.94),
    s.height * 0.44,
    _naomi,
    blink: blinkAt(v.time, 0.4),
    wave: t * 0.4,
  );
  paintPerson(
    canvas,
    feetAt(s, 0.5 - 0.08 * t, 0.95),
    s.height * 0.42,
    _ruth,
    facingLeft: true,
    raisedBoth: t > 0.5,
    wave: 0.3,
    blink: blinkAt(v.time, 1),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.74 + 0.2 * t, 0.94 - 0.06 * t),
    s.height * (0.42 - 0.12 * t),
    _orpah,
    blink: blinkAt(v.time, 2),
  );
  if (t > 0) {
    canvas.drawCircle(
      Offset(s.width * 0.38, s.height * 0.62),
      s.height * 0.16 * t,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.25 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.06),
    );
  }
}

// 2. Ensemble, elles arrivent à Bethléhem au début de la moisson de l'orge.
void _voyage(Canvas canvas, Size s, StageView v) {
  paintRoad(canvas, s, v.time, sky: Skies.day);
  paintThing(canvas, 'city', boxAt(s, 0.86, 0.68, 0.2, aspect: 1.4));
  final x = 0.12 + 0.46 * v.eased;
  final bob = v.progress > 0 && v.progress < 1 ? (math.sin(v.time * 6)).abs() * s.height * 0.006 : 0.0;
  paintPerson(canvas, feetAt(s, x, 0.94), s.height * 0.42, _naomi, bob: bob, blink: blinkAt(v.time, 0.4));
  paintPerson(canvas, feetAt(s, x + 0.1, 0.95), s.height * 0.4, _ruth, bob: bob, blink: blinkAt(v.time, 1));
}

// 3. Ruth ramasse les épis oubliés par les moissonneurs, pour nourrir Naomi.
void _glaner(Canvas canvas, Size s, StageView v) {
  _field(canvas, s, v.time);
  paintPeople(
    canvas,
    s,
    v.time,
    from: 0.78,
    to: 0.94,
    fy: 0.9,
    h: 0.3,
    count: 2,
    facingLeft: true,
    offset: 2,
  );
  final picked = [for (var i = 0; i < _ears.length; i++) v.shown(i)];
  final count = picked.where((p) => p >= 1).length;
  paintPerson(canvas, feetAt(s, 0.16, 0.96), s.height * 0.44, _ruth, wave: 0.4, blink: blinkAt(v.time, 1));
  paintThing(canvas, 'basket', boxAt(s, 0.24, 0.98, 0.1));
  for (var k = 0; k < count; k++) {
    paintThing(canvas, 'wheat', boxAt(s, 0.21 + k * 0.02, 0.9, 0.08, aspect: 0.6));
  }
  for (var i = 0; i < _ears.length; i++) {
    final t = picked[i];
    if (t >= 1) continue;
    final c = Offset.lerp(
      Offset(s.width * _ears[i], s.height * 0.8),
      Offset(s.width * 0.24, s.height * 0.86),
      t,
    )!;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(1.2 * (1 - t));
    paintThing(
      canvas,
      'wheat',
      Rect.fromCenter(center: Offset.zero, width: s.height * 0.06, height: s.height * 0.1),
    );
    canvas.restore();
  }
}

// 4. Boaz, le maître du champ, est bon pour Ruth : il fait laisser des épis exprès pour elle.
void _boaz(Canvas canvas, Size s, StageView v) {
  _field(canvas, s, v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.22, 0.96),
    s.height * 0.42,
    _ruth,
    raisedBoth: v.done,
    wave: 0.4,
    blink: blinkAt(v.time, 1),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.77, 0.95),
    s.height * 0.46,
    _boazStyle,
    facingLeft: true,
    wave: 0.4 + 0.3 * v.pulse[0],
    blink: blinkAt(v.time, 0.4),
  );
  final ears = (v.progress * 9).round();
  for (var k = 0; k < ears; k++) {
    final x = 0.3 + (k % 5) * 0.08;
    final y = 0.86 + (k ~/ 5) * 0.06;
    canvas.save();
    canvas.translate(s.width * x, s.height * y);
    canvas.rotate(1.3);
    paintThing(
      canvas,
      'wheat',
      Rect.fromCenter(center: Offset.zero, width: s.height * 0.05, height: s.height * 0.09),
    );
    canvas.restore();
  }
}

// 5. Boaz épouse Ruth. Tout le village se réjouit.
void _mariage(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.dusk);
  paintHills(canvas, s, v.time, baselines: const [0.62, 0.74], colors: Lands.green, seed: 323);
  for (final fx in [0.1, 0.9]) {
    paintThing(canvas, 'city', boxAt(s, fx, 0.74, 0.22, aspect: 1.2));
  }
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.42 + 0.02 * t, 0.94),
    s.height * 0.46,
    _boazStyle,
    raisedBoth: t > 0.6,
    wave: 0.4,
    blink: blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.58 - 0.02 * t, 0.95),
    s.height * 0.42,
    _ruth,
    facingLeft: true,
    raisedBoth: t > 0.6,
    wave: 0.4,
    blink: blinkAt(v.time, 1),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.26, 0.96),
    s.height * 0.4,
    _naomi,
    wave: 0.5 * t,
    blink: blinkAt(v.time, 2),
  );
  paintPeople(
    canvas,
    s,
    v.time,
    from: 0.72,
    to: 0.9,
    fy: 0.97,
    h: 0.34,
    count: 2,
    wave: t * 0.5,
    facingLeft: true,
  );
  if (t > 0) {
    for (var k = 0; k < 10; k++) {
      final x = 0.3 + (k * 0.37 % 0.4);
      final y = 0.2 + ((v.time * 0.1 + k * 0.13) % 0.5);
      paintThing(canvas, 'flower', boxAt(s, x, y, 0.04 * t));
    }
  }
}

// 6. Ils ont un fils, Obed : le grand-père du roi David. Naomi le berce avec joie.
void _obed(Canvas canvas, Size s, StageView v) {
  paintHouse(canvas, s, wall: const Color(0xFFE9D3A8), lamp: 0.5 + 0.5 * v.eased);
  paintPerson(canvas, feetAt(s, 0.3, 0.95), s.height * 0.44, _ruth, wave: 0.4, blink: blinkAt(v.time, 1));
  paintPerson(
    canvas,
    feetAt(s, 0.72, 0.95),
    s.height * 0.46,
    _boazStyle,
    facingLeft: true,
    wave: 0.3,
    blink: blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.95),
    s.height * 0.42,
    _naomi,
    raisedBoth: true,
    wave: 0.2,
    blink: blinkAt(v.time, 2),
  );
  paintBaby(
    canvas,
    Offset(s.width * 0.5, s.height * 0.6 - math.sin(v.time * 2) * s.height * 0.005),
    s.height * 0.04,
    glow: v.eased,
  );
  if (v.done) {
    paintThing(canvas, 'harp', boxAt(s, 0.86, 0.7, 0.14));
    paintThing(canvas, 'crown', boxAt(s, 0.86, 0.44, 0.08), glow: 1);
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _field(canvas, s, 0);
  paintThing(canvas, 'tree', boxAt(s, 0.9, 0.7, 0.36));
}

void _seekForeground(Canvas canvas, Size s) {
  for (final fx in [0.16, 0.48, 0.74]) {
    paintThing(canvas, 'wheat', boxAt(s, fx, 1.0, 0.18, aspect: 0.6));
  }
  paintAnimal(canvas, Animal.sheep, boxAt(s, 0.98, 1.0, 0.1), facingLeft: true);
}

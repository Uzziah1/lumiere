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
import '../registry.dart';

/// Abraham et les étoiles (Genèse 12, 15, 18 et 21).
final abrahamPack = StoryPack.scripted(
  scripts: {
    'call': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2,
      targets: [Rect.fromLTRB(0.18, 0.04, 0.42, 0.34)],
      sfx: Sfx.chime,
      paint: _call,
    ),
    'journey': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.04, 0.40, 0.44, 0.80)],
      paint: _journey,
    ),
    'tent': const StageScript(
      targets: [Rect.fromLTRB(0.20, 0.36, 0.46, 0.80), Rect.fromLTRB(0.60, 0.46, 0.80, 0.80)],
      paint: _tent,
    ),
    'stars': StageScript(
      targets: [for (final (x, y) in _bigStars) Rect.fromCenter(center: Offset(x, y), width: 0.12, height: 0.16)],
      sfx: Sfx.chime,
      paint: _stars,
    ),
    'promise': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2,
      targets: [Rect.fromLTRB(0.06, 0.34, 0.34, 0.80)],
      paint: _promise,
    ),
    'isaac': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.50, 0.56, 0.78)],
      sfx: Sfx.chime,
      paint: _isaac,
    ),
  },
  stickerScene: 'stars',
  seekScene: PaintedSeekScene(
    spots: const {
      'sheep': (Offset(0.30, 0.74), 0.18),
      'jar': (Offset(0.52, 0.80), 0.12),
      'mouse': (Offset(0.66, 0.86), 0.08),
      'owl': (Offset(0.88, 0.32), 0.13),
      'rabbit': (Offset(0.08, 0.82), 0.12),
      'tortoise': (Offset(0.80, 0.86), 0.1),
      'bird': (Offset(0.44, 0.22), 0.09),
      'snail': (Offset(0.18, 0.56), 0.07),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const abram = PersonStyle(
  skin: Color(0xFF946042),
  robe: Color(0xFFB0563A),
  headcloth: Color(0xFFF1E4CC),
  sash: Color(0xFFE9B949),
  beard: Color(0xFFE6E0D6),
);

const sarai = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFF6F8FB0),
  headcloth: Color(0xFFF3E2C0),
  veil: true,
  scale: 0.95,
);

const _lot = PersonStyle(
  skin: Color(0xFF7D4A30),
  robe: Color(0xFF7FA650),
  headcloth: Color(0xFFE8D6B3),
  beard: Color(0xFF3E2A1E),
  scale: 0.95,
);

const _visitors = [
  PersonStyle(
    skin: Color(0xFF8A5537),
    robe: Color(0xFFF2EBDD),
    headcloth: Color(0xFFFFFFFF),
    sash: Color(0xFFD9B27A),
    beard: Color(0xFF3E2A1E),
  ),
  PersonStyle(
    skin: Color(0xFF6E4029),
    robe: Color(0xFFE8DCC6),
    headcloth: Color(0xFFFFFBF2),
    sash: Color(0xFFD9B27A),
    beard: Color(0xFF2E1E15),
  ),
  PersonStyle(
    skin: Color(0xFFA06A45),
    robe: Color(0xFFEFE4D0),
    headcloth: Color(0xFFFFFFFF),
    sash: Color(0xFFD9B27A),
    beard: Color(0xFF4A3323),
  ),
];

const _bigStars = [(0.16, 0.16), (0.34, 0.1), (0.52, 0.18), (0.7, 0.08), (0.86, 0.2)];

void _desert(
  Canvas canvas,
  Size s,
  double time, {
  List<Color> sky = Skies.desert,
  List<Color> land = Lands.desert,
  int seed = 91,
}) {
  paintSkyGradient(canvas, s, sky);
  paintHills(canvas, s, time, baselines: const [0.6, 0.7, 0.84], colors: land, seed: seed);
}

// 1. Dieu appelle Abram : « Va dans le pays que je te montrerai. »
void _call(Canvas canvas, Size s, StageView v) {
  _desert(canvas, s, v.time, sky: Skies.dawn, land: Lands.green);
  paintThing(canvas, 'city', boxAt(s, 0.82, 0.66, 0.22, aspect: 1.6));
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.3, -s.height * 0.05), v.time, intensity: 0.5 + 0.7 * v.eased);
  paintPerson(
    canvas,
    feetAt(s, 0.56, 0.92),
    s.height * 0.44,
    abram,
    facingLeft: true,
    raisedBoth: true,
    wave: 0.5 * v.eased,
    blink: blinkAt(v.time, 0.4),
  );
}

// 2. Le grand voyage, avec Saraï, Lot, les troupeaux et les chameaux.
void _journey(Canvas canvas, Size s, StageView v) {
  _desert(canvas, s, v.time);
  paintClouds(canvas, s, v.time, count: 2);
  final shift = v.eased * s.width * 0.42;
  final walk = v.time * 3;
  canvas.save();
  canvas.translate(shift, 0);
  final bob = (math.sin(walk)).abs() * s.height * 0.006 * (v.progress < 1 ? 1 : 0);
  paintThing(canvas, 'camel', boxAt(s, 0.08, 0.86, 0.24, aspect: 1.1).translate(0, -bob));
  paintPerson(canvas, feetAt(s, 0.2, 0.9), s.height * 0.34, sarai, bob: bob, blink: blinkAt(v.time, 1));
  paintPerson(
    canvas,
    feetAt(s, 0.28, 0.9),
    s.height * 0.36,
    abram,
    bob: bob,
    wave: v.pulse[0] * 0.8,
    blink: blinkAt(v.time, 0.2),
  );
  paintPerson(canvas, feetAt(s, 0.36, 0.9), s.height * 0.34, _lot, bob: bob, blink: blinkAt(v.time, 2));
  for (final fx in [0.42, 0.47]) {
    paintAnimal(canvas, Animal.sheep, boxAt(s, fx, 0.93, 0.1), walk: walk / 6, facingLeft: false);
  }
  canvas.restore();
  // Le pays promis, au loin.
  canvas.save();
  canvas.translate((1 - v.eased) * s.width * 0.1, 0);
  paintThing(canvas, 'tree', boxAt(s, 0.92, 0.72, 0.22));
  canvas.restore();
}

// 3. Au pays de Canaan : la tente et l'autel pour remercier Dieu.
void _tent(Canvas canvas, Size s, StageView v) {
  _desert(canvas, s, v.time, land: Lands.green);
  paintSun(canvas, Offset(s.width * 0.84, s.height * 0.18), s.height * 0.07, halo: 0.5);
  paintThing(canvas, 'tree', boxAt(s, 0.92, 0.82, 0.36));
  final tent = v.shown(0);
  final altar = v.shown(1);
  if (tent > 0) {
    paintThing(canvas, 'tent', boxAt(s, 0.33, 0.86, 0.42 * tent, aspect: 1.3));
  } else {
    _dashed(canvas, boxAt(s, 0.33, 0.86, 0.36, aspect: 1.3));
  }
  if (altar > 0) {
    paintThing(canvas, 'altar', boxAt(s, 0.7, 0.86, 0.3 * altar), time: v.time);
  } else {
    _dashed(canvas, boxAt(s, 0.7, 0.86, 0.26));
  }
  paintPerson(
    canvas,
    feetAt(s, 0.53, 0.94),
    s.height * 0.4,
    abram,
    blink: blinkAt(v.time, 0.7),
    wave: v.done ? 0.6 : 0,
  );
}

void _dashed(Canvas canvas, Rect r) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.1)),
    Paint()
      ..color = const Color(0x88FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
}

// 4. « Regarde le ciel et compte les étoiles : telle sera ta descendance. »
void _stars(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, v.time, count: (30 + 170 * v.eased).round(), area: 0.65, seed: 15);
  for (var i = 0; i < _bigStars.length; i++) {
    final (x, y) = _bigStars[i];
    final t = v.shown(i);
    final side = s.height * (0.09 + 0.07 * t) * (1 + v.pulse[i] * 0.3);
    final c = Offset(s.width * x, s.height * y);
    if (t > 0) {
      canvas.drawCircle(
        c,
        side,
        Paint()
          ..color = Palette.sun.withValues(alpha: 0.3 * t)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.6),
      );
    }
    canvas.save();
    canvas.saveLayer(
      Rect.fromCircle(center: c, radius: side),
      Paint()..color = Color.fromRGBO(0, 0, 0, 0.35 + 0.65 * t),
    );
    paintThing(canvas, 'star', Rect.fromCenter(center: c, width: side, height: side));
    canvas.restore();
    canvas.restore();
  }
  paintHills(canvas, s, v.time, baselines: const [0.72, 0.84], colors: Lands.night, seed: 19);
  paintThing(canvas, 'tent', boxAt(s, 0.18, 0.9, 0.24, aspect: 1.3));
  paintPerson(
    canvas,
    feetAt(s, 0.62, 0.95),
    s.height * 0.38,
    abram,
    raisedBoth: true,
    wave: 0.7,
    blink: blinkAt(v.time, 0.3),
  );
}

// 5. Trois visiteurs : « L'an prochain, Sara aura un fils. » Sara rit.
void _promise(Canvas canvas, Size s, StageView v) {
  _desert(canvas, s, v.time, land: Lands.green);
  paintThing(canvas, 'tree', boxAt(s, 0.62, 0.8, 0.5));
  paintThing(canvas, 'tent', boxAt(s, 0.2, 0.86, 0.42, aspect: 1.3));
  if (v.eased > 0) {
    // Sara regarde depuis la tente, et rit.
    final laugh = v.done ? math.sin(v.time * 10) * s.height * 0.004 : 0.0;
    paintPerson(
      canvas,
      feetAt(s, 0.22, 0.86),
      s.height * 0.26 * (0.6 + 0.4 * v.eased),
      sarai,
      bob: laugh,
      wave: 0.4,
      blink: 1,
    );
  }
  for (var i = 0; i < 3; i++) {
    paintPerson(
      canvas,
      feetAt(s, 0.62 + i * 0.1, 0.92),
      s.height * 0.38,
      _visitors[i],
      facingLeft: true,
      blink: blinkAt(v.time, i * 1.2),
    );
  }
  paintPerson(canvas, feetAt(s, 0.44, 0.94), s.height * 0.38, abram, blink: blinkAt(v.time, 2.2));
}

// 6. Isaac est né ! Son nom veut dire « il rit ».
void _isaac(Canvas canvas, Size s, StageView v) {
  _desert(canvas, s, v.time, sky: Skies.dawn, land: Lands.green);
  paintThing(canvas, 'tent', boxAt(s, 0.16, 0.84, 0.36, aspect: 1.3));
  paintPerson(canvas, feetAt(s, 0.44, 0.94), s.height * 0.42, sarai, blink: blinkAt(v.time, 0.6));
  paintPerson(
    canvas,
    feetAt(s, 0.62, 0.94),
    s.height * 0.44,
    abram,
    facingLeft: true,
    wave: v.done ? 0.7 + 0.3 * math.sin(v.time * 3) : 0,
    blink: blinkAt(v.time, 1.6),
  );
  // Le bébé Isaac dans les bras de Sara.
  final baby = Offset(s.width * 0.47, s.height * 0.66 - v.pulse[0] * s.height * 0.02);
  final r = s.height * 0.05;
  drawPaper(
    canvas,
    Path()..addOval(Rect.fromCenter(center: baby, width: r * 3, height: r * 1.8)),
    const Color(0xFFFFF7EA),
    elevation: 3,
  );
  drawPaper(
    canvas,
    Path()..addOval(Rect.fromCircle(center: baby + Offset(r * 1.1, -r * 0.3), radius: r * 0.7)),
    const Color(0xFFA9714B),
    elevation: 2,
  );
  final eye = Paint()..color = const Color(0xFF2A1A12);
  final happy = v.eased;
  canvas.drawArc(
    Rect.fromCircle(center: baby + Offset(r * 1.25, -r * 0.2), radius: r * 0.2),
    math.pi * (happy > 0.5 ? 0.1 : 1.1),
    math.pi * 0.8,
    false,
    eye
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round,
  );
  if (happy > 0) {
    for (var k = 0; k < 3; k++) {
      final a = -math.pi / 2 + (k - 1) * 0.6;
      final d = r * (1.8 + 0.5 * math.sin(v.time * 4 + k));
      paintThing(
        canvas,
        'star',
        Rect.fromCenter(
          center: baby + Offset(math.cos(a) * d + r, math.sin(a) * d),
          width: r * happy,
          height: r * happy,
        ),
      );
    }
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _desert(canvas, s, 0, land: Lands.desert, seed: 97);
  paintThing(canvas, 'tent', boxAt(s, 0.2, 0.66, 0.34, aspect: 1.3));
  paintThing(canvas, 'tent', boxAt(s, 0.62, 0.62, 0.28, aspect: 1.3));
  paintThing(canvas, 'tree', boxAt(s, 0.88, 0.66, 0.46));
  paintThing(canvas, 'well', boxAt(s, 0.42, 0.7, 0.2));
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'camel', boxAt(s, 0.38, 1.0, 0.3, aspect: 1.1));
  paintThing(canvas, 'crate', boxAt(s, 0.7, 1.0, 0.14));
  paintThing(canvas, 'bush', boxAt(s, 0.1, 1.0, 0.14, aspect: 1.3));
  drawPaper(
    canvas,
    Path()..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.84, s.height * 0.96), width: s.width * 0.1, height: s.height * 0.1),
    ),
    const Color(0xFFC9B48A),
    elevation: 4,
  );
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.82, s.height * 0.36, s.width * 0.12, s.height * 0.04)),
    const Color(0xFF8A5634),
    elevation: 3,
  );
  paintWaves(canvas, s, s.height * 1.3, 0);
}

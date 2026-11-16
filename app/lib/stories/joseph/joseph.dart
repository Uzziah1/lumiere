import 'dart:math' as math;
import 'dart:ui';

import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../art/weather.dart';
import '../../audio/audio.dart';
import '../../story/scripted_stage.dart';
import '../../theme/palette.dart';
import '../registry.dart';

/// Joseph et ses frères (Genèse 37 à 45).
final josephPack = StoryPack.scripted(
  scripts: {
    'coat': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 4,
      targets: [Rect.fromLTRB(0.40, 0.30, 0.60, 0.70)],
      paint: _coat,
    ),
    'dreams': const StageScript(
      targets: [
        Rect.fromLTRB(0.30, 0.06, 0.48, 0.40),
        Rect.fromLTRB(0.52, 0.04, 0.68, 0.30),
        Rect.fromLTRB(0.70, 0.06, 0.88, 0.36),
      ],
      sfx: Sfx.chime,
      paint: _dreams,
    ),
    'pit': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 3,
      targets: [Rect.fromLTRB(0.60, 0.40, 0.92, 0.80)],
      sfx: Sfx.whoosh,
      paint: _pit,
    ),
    'pharaoh': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.60, 0.26, 0.80, 0.80)],
      sfx: Sfx.chime,
      paint: _pharaoh,
    ),
    'granary': StageScript(
      targets: [for (final fx in _granaries) Rect.fromLTRB(fx - 0.09, 0.30, fx + 0.09, 0.80)],
      paint: _granary,
    ),
    'forgive': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.42, 0.30, 0.58, 0.80)],
      sfx: Sfx.chime,
      paint: _forgive,
    ),
  },
  stickerScene: 'coat',
  seekScene: PaintedSeekScene(
    spots: const {
      'mouse': (Offset(0.30, 0.86), 0.08),
      'jar': (Offset(0.12, 0.76), 0.14),
      'basket': (Offset(0.56, 0.82), 0.12),
      'bird': (Offset(0.70, 0.18), 0.09),
      'frog': (Offset(0.86, 0.86), 0.1),
      'tortoise': (Offset(0.44, 0.88), 0.1),
      'snail': (Offset(0.92, 0.56), 0.07),
      'ladybug': (Offset(0.22, 0.42), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _granaries = [0.24, 0.5, 0.76];

const _jacob = PersonStyle(
  skin: Color(0xFF946042),
  robe: Color(0xFF6E8FB8),
  headcloth: Color(0xFFF1E4CC),
  beard: Color(0xFFE6E0D6),
);

const _joseph = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFFE8DCC6),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFFD9922B),
  bareHead: true,
  scale: 0.92,
);

const _governor = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFFFFFBF2),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFFF2C14E),
  bareHead: true,
);

const _pharaohStyle = PersonStyle(
  skin: Color(0xFF7D4A30),
  robe: Color(0xFFFFFBF2),
  headcloth: Color(0xFF3A7CA5),
  sash: Color(0xFFF2C14E),
  crown: true,
);

const _brothers = [
  PersonStyle(skin: Color(0xFF7D4A30), robe: Color(0xFFB0563A), headcloth: Color(0xFFE8D6B3), beard: Color(0xFF2E1E15)),
  PersonStyle(skin: Color(0xFF9C6440), robe: Color(0xFF5F9E7E), headcloth: Color(0xFFF0E2C8), beard: Color(0xFF3E2A1E)),
  PersonStyle(skin: Color(0xFF6E4029), robe: Color(0xFFD08A47), headcloth: Color(0xFFEADBC0), beard: Color(0xFF2A1A12)),
  PersonStyle(skin: Color(0xFFA9714B), robe: Color(0xFF8C79B5), headcloth: Color(0xFFF3E2C0), beard: Color(0xFF4A3323)),
];

void _canaan(Canvas canvas, Size s, double time, {List<Color> sky = Skies.day}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 2);
  paintHills(canvas, s, time, baselines: const [0.6, 0.7, 0.84], colors: Lands.green, seed: 101);
}

void _egypt(Canvas canvas, Size s, double time) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintSun(canvas, Offset(s.width * 0.88, s.height * 0.16), s.height * 0.07, halo: 0.6);
  paintHills(canvas, s, time, baselines: const [0.66, 0.78, 0.88], colors: Lands.desert, seed: 111);
  paintThing(canvas, 'city', boxAt(s, 0.1, 0.7, 0.16, aspect: 1.6));
}

/// La tunique dessinée sur un personnage, révélée de bas en haut ([reveal]).
void _coatOn(Canvas canvas, Size s, Offset feet, double h, double reveal) {
  if (reveal <= 0) return;
  final box = Rect.fromLTWH(feet.dx - h * 0.27, feet.dy - h * 0.72, h * 0.54, h * 0.72);
  canvas.save();
  canvas.clipRect(Rect.fromLTRB(box.left - 10, box.bottom - box.height * reveal, box.right + 10, box.bottom + 10));
  paintThing(canvas, 'coat', box);
  canvas.restore();
}

// 1. Jacob donne à Joseph une tunique de toutes les couleurs.
void _coat(Canvas canvas, Size s, StageView v) {
  _canaan(canvas, s, v.time);
  paintThing(canvas, 'tent', boxAt(s, 0.14, 0.86, 0.34, aspect: 1.3));
  paintPerson(
    canvas,
    feetAt(s, 0.32, 0.92),
    s.height * 0.44,
    _jacob,
    wave: 0.4 + v.pulse[0] * 0.4,
    blink: blinkAt(v.time, 0.5),
  );
  final joseph = feetAt(s, 0.5, 0.92);
  paintPerson(
    canvas,
    joseph,
    s.height * 0.4,
    _joseph,
    facingLeft: true,
    blink: blinkAt(v.time, 1.4),
    wave: v.done ? 0.6 + 0.4 * math.sin(v.time * 3) : 0,
  );
  _coatOn(canvas, s, joseph, s.height * 0.4 * _joseph.scale, v.eased);
  for (var i = 0; i < 3; i++) {
    paintPerson(
      canvas,
      feetAt(s, 0.7 + i * 0.09, 0.9),
      s.height * 0.38,
      _brothers[i],
      facingLeft: true,
      blink: blinkAt(v.time, i * 0.8),
    );
  }
}

// 2. Les rêves de Joseph : les gerbes, le soleil, la lune et onze étoiles.
void _dreams(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, v.time, count: 40, seed: 4);
  paintHills(canvas, s, v.time, baselines: const [0.74, 0.86], colors: Lands.night, seed: 103);
  // La bulle du rêve.
  final bubble = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s.width * 0.27, s.height * 0.02, s.width * 0.91, s.height * 0.44),
        Radius.circular(s.height * 0.08),
      ),
    );
  canvas.drawPath(bubble, Paint()..color = const Color(0x33FFFFFF));
  for (final (fx, fy, r) in const [(0.24, 0.5, 0.025), (0.2, 0.58, 0.018)]) {
    canvas.drawCircle(Offset(s.width * fx, s.height * fy), s.height * r, Paint()..color = const Color(0x33FFFFFF));
  }
  final items = [('wheat', 0.39, 0.38, 0.3), ('sun', 0.6, 0.28, 0.22), ('moon', 0.79, 0.3, 0.2)];
  for (var i = 0; i < 3; i++) {
    final (id, fx, fy, h) = items[i];
    final t = v.shown(i);
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, 0.25 + 0.75 * t));
    paintThing(canvas, id, boxAt(s, fx, fy, h * (0.7 + 0.3 * t)), time: v.time);
    canvas.restore();
  }
  if (v.shown(2) > 0) {
    for (var k = 0; k < 11; k++) {
      final a = k / 11 * math.pi * 2 + v.time * 0.2;
      final c = Offset(s.width * 0.79 + math.cos(a) * s.height * 0.13, s.height * 0.2 + math.sin(a) * s.height * 0.1);
      paintThing(
        canvas,
        'star',
        Rect.fromCenter(center: c, width: s.height * 0.035 * v.shown(2), height: s.height * 0.035 * v.shown(2)),
      );
    }
  }
  paintPerson(
    canvas,
    feetAt(s, 0.14, 0.94),
    s.height * 0.4,
    _joseph,
    raisedBoth: true,
    wave: 0.6,
    blink: blinkAt(v.time, 0.8),
  );
}

// 3. Les frères jaloux ; des marchands emmènent Joseph en Égypte.
void _pit(Canvas canvas, Size s, StageView v) {
  _canaan(canvas, s, v.time, sky: Skies.desert);
  paintThing(canvas, 'well', boxAt(s, 0.12, 0.88, 0.2));
  for (var i = 0; i < 4; i++) {
    paintPerson(
      canvas,
      feetAt(s, 0.22 + i * 0.08, 0.92),
      s.height * 0.36,
      _brothers[i],
      blink: blinkAt(v.time, i * 0.9),
    );
  }
  final go = v.eased * s.width * 0.5;
  canvas.save();
  canvas.translate(go, 0);
  paintThing(canvas, 'camel', boxAt(s, 0.66, 0.86, 0.26, aspect: 1.1));
  paintThing(canvas, 'camel', boxAt(s, 0.84, 0.86, 0.24, aspect: 1.1));
  paintPerson(canvas, feetAt(s, 0.75, 0.9), s.height * 0.32, _joseph, facingLeft: true, blink: blinkAt(v.time, 2));
  canvas.restore();
}

// 4. Joseph explique les rêves de Pharaon, qui fait de lui le gouverneur.
void _pharaoh(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, const [Color(0xFFF6E3B4), Color(0xFFEFD39A), Color(0xFFE2BC72)]);
  // Colonnes du palais.
  for (var k = 0; k < 5; k++) {
    final x = s.width * (0.06 + k * 0.22);
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(x, s.height * 0.08, s.width * 0.06, s.height * 0.8)),
      const Color(0xFFF1E0B8),
      elevation: 4,
    );
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(x - s.width * 0.01, s.height * 0.06, s.width * 0.08, s.height * 0.05)),
      const Color(0xFF3A7CA5),
      elevation: 2,
    );
  }
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.86, s.width, s.height * 0.14)),
    const Color(0xFFD9B27A),
    elevation: 3,
  );
  // Le rêve de Pharaon : des épis pleins et des épis maigres.
  paintThing(canvas, 'wheat', boxAt(s, 0.16, 0.48, 0.2));
  paintPerson(
    canvas,
    feetAt(s, 0.7, 0.92),
    s.height * 0.46,
    _pharaohStyle,
    facingLeft: true,
    wave: v.eased * 0.6,
    blink: blinkAt(v.time, 0.6),
  );
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.42, 0.92),
    s.height * 0.42,
    t > 0.5 ? _governor : _joseph,
    blink: blinkAt(v.time, 1.4),
    wave: v.done ? 0.5 : 0,
  );
  if (t > 0) {
    // Le collier d'or donné à Joseph (Genèse 41.42).
    final c = Offset(s.width * 0.42, s.height * 0.92 - s.height * 0.42 * 0.66);
    canvas.drawArc(
      Rect.fromCenter(center: c, width: s.height * 0.12, height: s.height * 0.08),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = const Color(0xFFF2C14E).withValues(alpha: t)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.height * 0.012,
    );
  }
}

// 5. Les sept bonnes années : on remplit les greniers de blé.
void _granary(Canvas canvas, Size s, StageView v) {
  _egypt(canvas, s, v.time);
  for (var i = 0; i < _granaries.length; i++) {
    final box = boxAt(s, _granaries[i], 0.86, 0.46, aspect: 0.8);
    paintThing(canvas, 'granary', box);
    final fill = v.shown(i);
    if (fill > 0) {
      paintThing(canvas, 'wheat', boxAt(s, _granaries[i], 0.86 - 0.02, 0.18 * fill));
    }
  }
  paintPerson(canvas, feetAt(s, 0.92, 0.94), s.height * 0.38, _governor, facingLeft: true, blink: blinkAt(v.time, 0.3));
}

// 6. Joseph pardonne à ses frères.
void _forgive(Canvas canvas, Size s, StageView v) {
  _egypt(canvas, s, v.time);
  for (var i = 0; i < 4; i++) {
    final fx = i < 2 ? 0.2 + i * 0.1 : 0.7 + (i - 2) * 0.1;
    paintPerson(
      canvas,
      feetAt(s, fx, 0.92),
      s.height * 0.38,
      _brothers[i],
      facingLeft: i >= 2,
      wave: v.done ? 0.5 + 0.5 * math.sin(v.time * 3 + i) : 0,
      blink: blinkAt(v.time, i.toDouble()),
    );
  }
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.92),
    s.height * 0.42,
    _governor,
    raisedBoth: true,
    wave: 0.3 + 0.6 * v.eased,
    blink: blinkAt(v.time, 0.7),
  );
  if (v.eased > 0) {
    final c = Offset(s.width * 0.5, s.height * 0.3);
    canvas.drawCircle(
      c,
      s.height * 0.25 * v.eased,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.3 * v.eased)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.08),
    );
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _egypt(canvas, s, 0);
  for (final fx in [0.34, 0.62, 0.86]) {
    paintThing(canvas, 'granary', boxAt(s, fx, 0.72, 0.36, aspect: 0.8));
  }
  paintThing(canvas, 'wheat', boxAt(s, 0.2, 0.62, 0.2));
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'crate', boxAt(s, 0.32, 1.0, 0.14));
  paintThing(canvas, 'wheat', boxAt(s, 0.56, 1.0, 0.18));
  paintThing(canvas, 'jar', boxAt(s, 0.16, 1.0, 0.18));
  paintThing(canvas, 'reeds', boxAt(s, 0.88, 1.0, 0.16, aspect: 1.2));
  paintThing(canvas, 'wheat', boxAt(s, 0.46, 1.02, 0.14));
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.88, s.height * 0.58, s.width * 0.08, s.height * 0.05)),
    const Color(0xFFD9B27A),
    elevation: 3,
  );
  paintWaves(canvas, s, s.height * 1.3, 0);
}

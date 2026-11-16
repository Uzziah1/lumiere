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
import '../registry.dart';

/// Moïse et la mer (Exode 2 à 15).
final moisePack = StoryPack.scripted(
  scripts: {
    'basket': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 3,
      targets: [Rect.fromLTRB(0.08, 0.46, 0.30, 0.74)],
      sfx: Sfx.whoosh,
      paint: _basket,
    ),
    'bush': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.54, 0.44, 0.80, 0.80)],
      sfx: Sfx.chime,
      paint: _bush,
    ),
    'plagues': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.18, 0.30, 0.36, 0.80)],
      paint: _plagues,
    ),
    'pillar': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 3,
      targets: [Rect.fromLTRB(0.68, 0.06, 0.88, 0.70)],
      sfx: Sfx.chime,
      paint: _pillar,
    ),
    'sea': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.2, 0.5),
      swipeTo: Offset(0.8, 0.5),
      sfx: Sfx.whoosh,
      paint: _sea,
    ),
    'cross': const StageScript(
      targets: [
        Rect.fromLTRB(0.02, 0.44, 0.20, 0.80),
        Rect.fromLTRB(0.20, 0.44, 0.36, 0.80),
        Rect.fromLTRB(0.36, 0.44, 0.52, 0.80),
      ],
      paint: _cross,
    ),
  },
  stickerScene: 'sea',
  seekScene: PaintedSeekScene(
    spots: const {
      'frog': (Offset(0.22, 0.80), 0.1),
      'fish': (Offset(0.56, 0.54), 0.1),
      'bird': (Offset(0.76, 0.2), 0.1),
      'tortoise': (Offset(0.66, 0.82), 0.1),
      'snail': (Offset(0.06, 0.70), 0.07),
      'mouse': (Offset(0.88, 0.74), 0.08),
      'shell': (Offset(0.40, 0.90), 0.07),
      'ladybug': (Offset(0.32, 0.46), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const moses = PersonStyle(
  skin: Color(0xFF8A5537),
  robe: Color(0xFF9A5E36),
  headcloth: Color(0xFFEADBC0),
  sash: Color(0xFFB0563A),
  beard: Color(0xFF4A3323),
);

const _aaron = PersonStyle(
  skin: Color(0xFF7D4A30),
  robe: Color(0xFF6E8FB8),
  headcloth: Color(0xFFF1E4CC),
  beard: Color(0xFF3E2A1E),
);

const _pharaoh = PersonStyle(
  skin: Color(0xFF7D4A30),
  robe: Color(0xFFFFFBF2),
  headcloth: Color(0xFF3A7CA5),
  sash: Color(0xFFF2C14E),
  crown: true,
);

const _princess = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFFFFFBF2),
  headcloth: Color(0xFF3A7CA5),
  sash: Color(0xFFF2C14E),
  veil: true,
);

const _miriam = PersonStyle(
  skin: Color(0xFF9C6440),
  robe: Color(0xFFC0656B),
  headcloth: Color(0xFFF3D9A4),
  veil: true,
  scale: 0.85,
);

const _people = [
  PersonStyle(skin: Color(0xFF7D4A30), robe: Color(0xFFE0A35A), headcloth: Color(0xFFF6E7C8), veil: true, scale: 0.9),
  PersonStyle(skin: Color(0xFF9C6440), robe: Color(0xFF5F9E7E), headcloth: Color(0xFFF0E2C8), beard: Color(0xFF3E2A1E)),
  PersonStyle(skin: Color(0xFF6E4029), robe: Color(0xFF8C79B5), headcloth: Color(0xFFEADBC0), scale: 0.7),
  PersonStyle(skin: Color(0xFFA9714B), robe: Color(0xFFB0563A), headcloth: Color(0xFFF3E2C0), beard: Color(0xFF4A3323)),
  PersonStyle(skin: Color(0xFF8E5A3B), robe: Color(0xFF6FA8A3), headcloth: Color(0xFFF2D6B8), veil: true, scale: 0.88),
  PersonStyle(skin: Color(0xFF7D4A30), robe: Color(0xFFD08A47), headcloth: Color(0xFFE8D6B3), scale: 0.65),
];

void _moses(Canvas canvas, Size s, double fx, double fy, double h, double time, {bool left = false, double raise = 0}) {
  final feet = feetAt(s, fx, fy);
  paintPerson(
    canvas,
    feet,
    h,
    moses,
    facingLeft: left,
    raisedBoth: raise > 0,
    wave: raise,
    blink: blinkAt(time, fx * 3),
  );
  final dir = left ? -1 : 1;
  final staff = Rect.fromLTWH(feet.dx + dir * h * 0.2 - h * 0.25, feet.dy - h * (1.05 + raise * 0.25), h * 0.5, h);
  paintThing(canvas, 'staff', staff, glow: raise);
}

// 1. Le bébé Moïse dans un panier sur le Nil ; la fille de Pharaon le trouve.
void _basket(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintHills(canvas, s, v.time, baselines: const [0.56, 0.64], colors: Lands.desert, seed: 121);
  paintSea(canvas, s, s.height * 0.62, v.time * 0.5);
  final x = 0.18 + 0.5 * v.eased;
  final bob = math.sin(v.time * 2) * s.height * 0.01;
  paintThing(canvas, 'basket', boxAt(s, x, 0.66 + bob / s.height, 0.16, aspect: 1.4));
  paintSea(canvas, s, s.height * 0.62, v.time * 0.5, front: true);
  // La berge où se baigne la fille de Pharaon.
  final bank = Path()
    ..moveTo(s.width * 0.7, s.height)
    ..quadraticBezierTo(s.width * 0.74, s.height * 0.74, s.width, s.height * 0.7)
    ..lineTo(s.width, s.height)
    ..close();
  drawPaper(canvas, bank, const Color(0xFFE8CF96), elevation: 4);
  paintThing(canvas, 'reeds', boxAt(s, 0.06, 0.98, 0.34, aspect: 0.8));
  paintPerson(canvas, feetAt(s, 0.05, 0.86), s.height * 0.26, _miriam, blink: blinkAt(v.time, 1.2));
  paintThing(canvas, 'reeds', boxAt(s, 0.16, 1.0, 0.26, aspect: 0.8));
  paintPerson(
    canvas,
    feetAt(s, 0.87, 0.86),
    s.height * 0.4,
    _princess,
    facingLeft: true,
    wave: v.done ? 0.7 : 0,
    blink: blinkAt(v.time, 0.4),
  );
}

// 2. Le buisson qui brûle sans se consumer : Dieu appelle Moïse.
void _bush(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.desert);
  final mountain = Path()
    ..moveTo(0, s.height * 0.86)
    ..quadraticBezierTo(s.width * 0.3, s.height * 0.1, s.width * 0.6, s.height * 0.86)
    ..close();
  drawPaper(canvas, mountain, const Color(0xFFC9A877), elevation: 4);
  paintHills(canvas, s, v.time, baselines: const [0.8, 0.9], colors: Lands.desert, seed: 123);
  final fire = 0.35 + 0.65 * v.eased;
  final bush = boxAt(s, 0.67, 0.86, 0.36, aspect: 1.3);
  canvas.drawCircle(
    bush.center,
    bush.height * (0.8 + 0.4 * v.eased),
    Paint()
      ..color = Palette.sunHalo.withValues(alpha: 0.35 * fire)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, bush.height * 0.3),
  );
  paintThing(canvas, 'bush', bush, time: v.time, glow: fire);
  for (final fx in [0.08, 0.15]) {
    paintAnimal(canvas, Animal.sheep, boxAt(s, fx, 0.93, 0.1));
  }
  _moses(canvas, s, 0.34, 0.93, s.height * 0.42, v.time, raise: 0.3 * v.eased);
}

// 3. « Laisse aller mon peuple ! » — Pharaon refuse, puis cède.
void _plagues(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, const [Color(0xFFF6E3B4), Color(0xFFEFD39A), Color(0xFFE2BC72)]);
  for (var k = 0; k < 4; k++) {
    final x = s.width * (0.42 + k * 0.15);
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(x, s.height * 0.08, s.width * 0.05, s.height * 0.8)),
      const Color(0xFFF1E0B8),
      elevation: 4,
    );
  }
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.86, s.width, s.height * 0.14)),
    const Color(0xFFD9B27A),
    elevation: 3,
  );
  _moses(canvas, s, 0.27, 0.92, s.height * 0.42, v.time, raise: v.pulse[0] * 0.8);
  paintPerson(canvas, feetAt(s, 0.14, 0.92), s.height * 0.4, _aaron, blink: blinkAt(v.time, 1));
  paintPerson(
    canvas,
    feetAt(s, 0.74, 0.92),
    s.height * 0.46,
    _pharaoh,
    facingLeft: true,
    blink: blinkAt(v.time, 0.6),
    wave: v.done ? 0.8 : 0,
  );
  // Les grenouilles envahissent le palais (Exode 8).
  final frogs = (v.progress * 9).round();
  final random = math.Random(3);
  for (var k = 0; k < frogs; k++) {
    final fx = 0.38 + random.nextDouble() * 0.56;
    final hop = (math.sin(v.time * 6 + k)).abs() * s.height * 0.02;
    paintThing(canvas, 'frog', boxAt(s, fx, 0.97 - hop / s.height, 0.11));
  }
}

// 4. Le peuple sort d'Égypte ; une colonne de nuée le guide.
void _pillar(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintHills(canvas, s, v.time, baselines: const [0.68, 0.8, 0.9], colors: Lands.desert, seed: 125);
  // La colonne de nuée : la présence de Dieu qui conduit son peuple.
  final c = Offset(s.width * 0.78, s.height * 0.4);
  for (var k = 0; k < 7; k++) {
    final y = s.height * (0.1 + k * 0.09);
    final w = s.width * (0.07 + 0.012 * math.sin(v.time * 1.5 + k));
    drawPaper(
      canvas,
      Path()..addOval(
        Rect.fromCenter(center: Offset(c.dx + math.sin(v.time + k) * 4, y), width: w * 1.6, height: s.height * 0.12),
      ),
      const Color(0xFFFFFBF2),
      elevation: 2,
      light: 0.2,
    );
  }
  canvas.drawCircle(
    c,
    s.height * 0.35,
    Paint()
      ..color = Palette.sun.withValues(alpha: 0.18 + 0.2 * v.eased)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.1),
  );
  final march = v.eased * s.width * 0.3;
  canvas.save();
  canvas.translate(march, 0);
  _moses(canvas, s, 0.36, 0.92, s.height * 0.36, v.time);
  for (var k = 0; k < _people.length; k++) {
    paintPerson(
      canvas,
      feetAt(s, 0.05 + k * 0.05, 0.92 + (k % 2) * 0.02),
      s.height * 0.32,
      _people[k],
      bob: (math.sin(v.time * 6 + k)).abs() * s.height * 0.006 * (v.done ? 0 : 1),
      blink: blinkAt(v.time, k.toDouble()),
    );
  }
  canvas.restore();
}

/// Les deux murs d'eau, écartés de [open] (0 = mer fermée, 1 = passage ouvert).
void _parting(Canvas canvas, Size s, double open, double time) {
  final gap = s.width * 0.22 * open;
  final top = s.height * (0.6 - 0.32 * open);
  for (final left in [true, false]) {
    final edge = s.width * 0.5 + (left ? -gap : gap);
    final wall = Path();
    if (left) {
      wall.moveTo(0, s.height);
      wall.lineTo(0, top);
      for (var x = 0.0; x <= edge; x += 12) {
        wall.lineTo(x, top + math.sin(x / 30 + time * 2) * s.height * 0.012);
      }
      wall.quadraticBezierTo(edge + s.width * 0.02, top + s.height * 0.1, edge, s.height);
    } else {
      wall.moveTo(s.width, s.height);
      wall.lineTo(s.width, top);
      for (var x = s.width; x >= edge; x -= 12) {
        wall.lineTo(x, top + math.sin(x / 30 + time * 2) * s.height * 0.012);
      }
      wall.quadraticBezierTo(edge - s.width * 0.02, top + s.height * 0.1, edge, s.height);
    }
    wall.close();
    canvas.save();
    canvas.clipPath(wall);
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = Gradient.linear(Offset(0, top), Offset(0, s.height), const [Color(0xFF7CC7DD), Color(0xFF2E78A3)]),
    );
    final foam = Paint()
      ..color = const Color(0x55FFFFFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (var k = 0; k < 6; k++) {
      final y = top + s.height * (0.06 + k * 0.07);
      canvas.drawLine(Offset(0, y + math.sin(time + k) * 3), Offset(s.width, y + math.cos(time + k) * 3), foam);
    }
    canvas.restore();
    canvas.drawPath(
      wall.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }
}

// 5. Moïse étend la main : la mer s'ouvre !
void _sea(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(
    canvas,
    s,
    Skies.storm.map((c) => Color.lerp(c, Skies.sea[Skies.storm.indexOf(c)], v.eased)!).toList(),
  );
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.86, s.width, s.height * 0.14)),
    const Color(0xFFE8CF96),
    elevation: 0,
  );
  _parting(canvas, s, v.eased, v.time);
  _moses(canvas, s, 0.5, 0.97, s.height * 0.34, v.time, raise: 0.6 + 0.4 * v.eased);
}

// 6. Le peuple traverse à pied sec ; Miriam danse avec son tambourin.
void _cross(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.sea);
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.82, s.width, s.height * 0.18)),
    const Color(0xFFE8CF96),
    elevation: 0,
  );
  _parting(canvas, Size(s.width, s.height * 0.92), 1, v.time);
  for (var g = 0; g < 3; g++) {
    final t = v.shown(g);
    final x = 0.1 + g * 0.16 + t * (0.62 - g * 0.04);
    for (var k = 0; k < 2; k++) {
      final style = _people[g * 2 + k];
      paintPerson(
        canvas,
        feetAt(s, x + k * 0.04, 0.9),
        s.height * 0.3,
        style,
        wave: t >= 1 ? 0.7 : 0,
        bob: t > 0 && t < 1 ? (math.sin(v.time * 8 + k)).abs() * s.height * 0.008 : 0,
        blink: blinkAt(v.time, g * 2.0 + k),
      );
    }
  }
  if (v.done) {
    final dance = math.sin(v.time * 5) * s.height * 0.01;
    paintPerson(canvas, feetAt(s, 0.9, 0.9), s.height * 0.3, _miriam, raisedBoth: true, wave: 0.8, bob: dance.abs());
    paintThing(canvas, 'tambourine', boxAt(s, 0.95, 0.66 - dance / s.height, 0.08), time: v.time);
  }
}

void _seekBackground(Canvas canvas, Size s) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintHills(canvas, s, 0, baselines: const [0.36, 0.42], colors: Lands.desert, seed: 127);
  paintSea(canvas, s, s.height * 0.46, 0.4);
  paintSea(canvas, s, s.height * 0.46, 0.4, front: true);
  // La berge de sable, où se cachent les animaux.
  final bank = Path()
    ..moveTo(0, s.height * 0.66)
    ..quadraticBezierTo(s.width * 0.3, s.height * 0.6, s.width * 0.6, s.height * 0.68)
    ..quadraticBezierTo(s.width * 0.85, s.height * 0.74, s.width, s.height * 0.64)
    ..lineTo(s.width, s.height)
    ..lineTo(0, s.height)
    ..close();
  drawPaper(canvas, bank, const Color(0xFFE8CF96), elevation: 4);
  paintThing(canvas, 'reeds', boxAt(s, 0.08, 0.66, 0.28, aspect: 0.8));
  paintThing(canvas, 'tree', boxAt(s, 0.86, 0.66, 0.4));
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'reeds', boxAt(s, 0.2, 1.0, 0.26, aspect: 0.9));
  paintThing(canvas, 'reeds', boxAt(s, 0.7, 1.0, 0.22, aspect: 0.9));
  paintThing(canvas, 'basket', boxAt(s, 0.42, 1.0, 0.1, aspect: 1.4));
  paintThing(canvas, 'bush', boxAt(s, 0.9, 0.8, 0.14, aspect: 1.3));
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.7, s.height * 0.24, s.width * 0.12, s.height * 0.04)),
    const Color(0xFF8A5634),
    elevation: 3,
  );
  drawPaper(
    canvas,
    Path()..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.3, s.height * 0.5), width: s.width * 0.1, height: s.height * 0.07),
    ),
    const Color(0xFF6FA84F),
    elevation: 3,
  );
}

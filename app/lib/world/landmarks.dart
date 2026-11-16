import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../art/animals.dart';
import '../art/ark.dart';
import '../art/objects.dart';
import '../art/paper.dart';
import '../art/shapes.dart';
import '../art/weather.dart';
import '../theme/palette.dart';
import 'world.dart';

/// Dessine le monument d'une île dans [box] (posé en bas).
void paintLandmark(Canvas canvas, Landmark landmark, Rect box) {
  canvas.save();
  fitBox(canvas, box, const Size(100, 100));
  switch (landmark) {
    case Landmark.creation:
      _creation(canvas);
    case Landmark.tree:
      _tree(canvas);
    case Landmark.ark:
      paintRainbow(canvas, const Offset(50, 78), 44, 16);
      Ark.paint(canvas, const Rect.fromLTWH(8, 48, 84, 50), door: 0, window: 1);
    case Landmark.tent:
      _tent(canvas);
    case Landmark.pyramid:
      _pyramids(canvas);
    case Landmark.sea:
      _sea(canvas);
    case Landmark.harp:
      _harp(canvas);
    case Landmark.fish:
      _fish(canvas);
    case Landmark.stable:
      _things(canvas, [('stable', 10, 6, 74), ('star', 64, -2, 30)]);
    case Landmark.temple:
      _things(canvas, [('temple', 6, 10, 88)]);
    case Landmark.dove:
      paintWaves(canvas, const Size(100, 100), 74, 0.3, from: 0, to: 2);
      _things(canvas, [('dove', 22, 10, 56)]);
    case Landmark.storm:
      _things(canvas, [('boat', 14, 12, 70)]);
      paintWaves(canvas, const Size(100, 100), 80, 1.2, from: 2, to: 4);
    case Landmark.loaves:
      _things(canvas, [('basket', 8, 40, 60), ('bread', 30, 18, 46), ('fish', 52, 42, 42)]);
    case Landmark.sycamore:
      _things(canvas, [('tree', 8, 0, 96)]);
    case Landmark.donkey:
      _things(canvas, [('donkey', 6, 16, 84)]);
    case Landmark.homecoming:
      _things(canvas, [('ring', 54, 30, 40), ('pig', 4, 34, 60)]);
    case Landmark.tomb:
      _things(canvas, [('tomb', 6, 10, 88)], glow: 1);
    case Landmark.flames:
      _things(canvas, [('flame', 8, 30, 46), ('flame', 30, 8, 60), ('flame', 54, 30, 46)]);
    case Landmark.walls:
      _things(canvas, [('wall', 4, 24, 72), ('horn', 60, 40, 40)]);
    case Landmark.torches:
      _things(canvas, [('torch', 4, 24, 52), ('torch', 46, 14, 56)]);
    case Landmark.sheaves:
      _things(canvas, [('wheat', 10, 14, 50), ('wheat', 34, 6, 58), ('wheat', 58, 14, 50)]);
    case Landmark.lamp:
      _things(canvas, [('lamp', 10, 20, 80)], glow: 1);
    case Landmark.raven:
      _things(canvas, [('altar', 8, 30, 64), ('flame', 20, 2, 40), ('raven', 54, 4, 44)]);
    case Landmark.lions:
      _things(canvas, [('lion', 4, 20, 76), ('stone', 62, 56, 34)]);
    case Landmark.scepter:
      _things(canvas, [('crown', 6, 34, 54), ('scepter', 52, 6, 46)], glow: 1);
    case Landmark.jars:
      _things(canvas, [('jar', 4, 34, 46), ('jar', 34, 26, 52), ('grapes', 64, 30, 34)]);
  }
  canvas.restore();
}

/// Plusieurs objets dans la boîte 100 × 100 : (id, gauche, haut, taille).
void _things(Canvas c, List<(String, double, double, double)> items, {double glow = 0}) {
  for (final (id, x, y, size) in items) {
    paintThing(c, id, Rect.fromLTWH(x, y, size, size), glow: glow);
  }
}

void _p(Canvas c, Path path, Color color, [double e = 2]) =>
    drawPaper(c, path, color, elevation: e, light: 0.14);

void _star(Canvas c, Offset at, double r) {
  final i = r * 0.38;
  final path = Path();
  for (var k = 0; k < 10; k++) {
    final a = -math.pi / 2 + k * math.pi / 5;
    final rr = k.isEven ? r : i;
    final p = at + Offset(math.cos(a) * rr, math.sin(a) * rr);
    k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  _p(c, path..close(), Palette.gold, 1);
}

void _creation(Canvas c) {
  final rays = Paint()
    ..color = Palette.gold
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  for (var k = 0; k < 10; k++) {
    final a = k * math.pi / 5;
    c.drawLine(
      Offset(38 + math.cos(a) * 18, 40 + math.sin(a) * 18),
      Offset(38 + math.cos(a) * 26, 40 + math.sin(a) * 26),
      rays,
    );
  }
  _p(c, circle(const Offset(38, 40), 14), const Color(0xFFFFD45E));
  _p(
    c,
    Path.combine(PathOperation.difference, circle(const Offset(76, 26), 10), circle(const Offset(81, 22), 9)),
    const Color(0xFFFFF3C4),
    1,
  );
  _star(c, const Offset(66, 52), 5);
  _star(c, const Offset(86, 46), 4);
  // Jeune pousse.
  c.drawLine(
    const Offset(70, 98),
    const Offset(70, 78),
    Paint()
      ..color = const Color(0xFF5E8A3A)
      ..strokeWidth = 3,
  );
  _p(c, ellipse(const Offset(62, 78), 14, 7), const Color(0xFF7FA650), 1);
  _p(c, ellipse(const Offset(78, 72), 14, 7), const Color(0xFF7FA650), 1);
}

void _tree(Canvas c) {
  _p(c, capsule(const Offset(50, 98), const Offset(50, 56), 6), const Color(0xFF8A5634));
  _p(
    c,
    unite([
      circle(const Offset(50, 40), 26),
      circle(const Offset(30, 52), 16),
      circle(const Offset(70, 52), 16),
    ]),
    const Color(0xFF6FA24C),
    3,
  );
  for (final o in const [Offset(40, 36), Offset(60, 30), Offset(66, 52), Offset(34, 56), Offset(50, 50)]) {
    _p(c, circle(o, 4.5), const Color(0xFFE5523F), 1);
  }
}

void _tent(Canvas c) {
  _star(c, const Offset(24, 18), 6);
  _star(c, const Offset(50, 10), 7);
  _star(c, const Offset(76, 20), 5);
  _p(
    c,
    Path()
      ..moveTo(10, 98)
      ..lineTo(50, 40)
      ..lineTo(90, 98)
      ..close(),
    const Color(0xFFD9B27A),
    3,
  );
  _p(
    c,
    Path()
      ..moveTo(42, 98)
      ..lineTo(50, 62)
      ..lineTo(58, 98)
      ..close(),
    const Color(0xFF6B4630),
    0,
  );
  final stripe = Paint()
    ..color = const Color(0xFFB8864E)
    ..strokeWidth = 2;
  c.drawLine(const Offset(30, 70), const Offset(70, 70), stripe);
}

void _pyramids(Canvas c) {
  _p(
    c,
    Path()
      ..moveTo(44, 98)
      ..lineTo(72, 50)
      ..lineTo(100, 98)
      ..close(),
    const Color(0xFFE2BC72),
    3,
  );
  _p(
    c,
    Path()
      ..moveTo(2, 98)
      ..lineTo(36, 40)
      ..lineTo(70, 98)
      ..close(),
    const Color(0xFFEAC985),
    3,
  );
  _p(
    c,
    Path()
      ..moveTo(36, 40)
      ..lineTo(70, 98)
      ..lineTo(44, 98)
      ..close(),
    const Color(0xFFCFA45C),
    0,
  );
  // Gerbe de blé (les greniers de Joseph).
  for (final dx in [-4.0, 0.0, 4.0]) {
    c.drawLine(
      Offset(86 + dx, 98),
      Offset(86 + dx * 2.5, 72),
      Paint()
        ..color = const Color(0xFFC79B35)
        ..strokeWidth = 2,
    );
    _p(c, ellipse(Offset(86 + dx * 2.6, 70), 5, 10), const Color(0xFFE6C15A), 1);
  }
}

void _sea(Canvas c) {
  for (final (x, flip) in const [(6.0, false), (62.0, true)]) {
    final wall = Path()
      ..moveTo(x, 98)
      ..lineTo(x, 46)
      ..quadraticBezierTo(x + 16, 30, x + 32, 40)
      ..lineTo(x + 32, 98)
      ..close();
    _p(
      c,
      flip
          ? wall.transform(Float64List.fromList([-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2 * x + 32, 0, 0, 1]))
          : wall,
      const Color(0xFF4FA3C7),
      3,
    );
    final crest = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    c.drawArc(Rect.fromLTWH(x + 4, 38, 24, 14), math.pi * 1.1, math.pi * 0.8, false, crest);
  }
  _p(
    c,
    Path()
      ..moveTo(38, 98)
      ..lineTo(46, 60)
      ..lineTo(54, 60)
      ..lineTo(62, 98)
      ..close(),
    const Color(0xFFE8CF96),
    0,
  );
  c.drawLine(
    const Offset(50, 92),
    const Offset(54, 58),
    Paint()
      ..color = const Color(0xFF7E4A2A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round,
  );
}

void _harp(Canvas c) {
  final frame = Path()
    ..moveTo(30, 96)
    ..lineTo(30, 30)
    ..quadraticBezierTo(30, 14, 46, 18)
    ..quadraticBezierTo(70, 26, 76, 50)
    ..quadraticBezierTo(80, 70, 70, 96)
    ..close();
  _p(c, frame, const Color(0xFFE2A93B), 3);
  _p(
    c,
    Path()
      ..moveTo(38, 88)
      ..lineTo(38, 34)
      ..quadraticBezierTo(40, 26, 48, 28)
      ..quadraticBezierTo(64, 34, 68, 52)
      ..quadraticBezierTo(70, 70, 62, 88)
      ..close(),
    const Color(0xFFFDF1DE),
    0,
  );
  final string = Paint()
    ..color = const Color(0xFFB9772F)
    ..strokeWidth = 1.4;
  for (var x = 44.0; x <= 62; x += 4.5) {
    c.drawLine(Offset(x, 34 + (x - 44) * 0.6), Offset(x, 88), string);
  }
  paintAnimal(c, Animal.sheep, const Rect.fromLTWH(70, 70, 30, 30));
}

void _fish(Canvas c) {
  const blue = Color(0xFF4F86C6);
  _p(
    c,
    Path()
      ..moveTo(14, 60)
      ..lineTo(0, 44)
      ..lineTo(2, 78)
      ..close(),
    blue,
    2,
  );
  _p(c, ellipse(const Offset(52, 62), 84, 52), blue, 3);
  _p(c, ellipse(const Offset(56, 74), 60, 22), const Color(0xFF9CC3E6), 0);
  c.drawCircle(const Offset(80, 52), 4.5, Paint()..color = const Color(0xFFFFFFFF));
  c.drawCircle(const Offset(81, 52), 2.6, Paint()..color = const Color(0xFF2A1A12));
  final jet = Paint()
    ..color = const Color(0xFF9CD3EE)
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  c.drawLine(const Offset(60, 36), const Offset(56, 18), jet);
  c.drawLine(const Offset(60, 36), const Offset(66, 20), jet);
}

import 'dart:math' as math;
import 'dart:ui';

import 'colombe.dart';
import 'paper.dart';
import 'shapes.dart';

/// Les animaux de Lumière, en papier découpé, tournés vers la droite.
///
/// Chacun est dessiné dans une boîte de 100 × 100 unités, les pattes posées en
/// bas, puis ajusté dans le rectangle demandé.
enum Animal {
  lion('le lion'),
  elephant("l'éléphant"),
  giraffe('la girafe'),
  sheep('le mouton'),
  rabbit('le lapin'),
  tortoise('la tortue'),
  mouse('la souris'),
  owl('le hibou'),
  snail("l'escargot"),
  ladybug('la coccinelle'),
  dove('la colombe');

  const Animal(this.label);

  final String label;

  static Animal byName(String name) => values.firstWhere((a) => a.name == name);
}

const _design = Size(100, 100);
const _eye = Color(0xFF2A1A12);

/// Dessine [animal] dans [box]. [walk] fait avancer les pattes (cycle de 0 à 1),
/// [blink] ferme les yeux.
void paintAnimal(
  Canvas canvas,
  Animal animal,
  Rect box, {
  double walk = 0,
  double blink = 0,
  bool facingLeft = false,
}) {
  if (box.isEmpty) return;
  if (animal == Animal.dove) {
    canvas.save();
    final h = math.min(box.height, box.width / Colombe.aspectRatio);
    final w = h * Colombe.aspectRatio;
    canvas.translate(box.center.dx - w / 2, box.bottom - h);
    Colombe.paint(canvas, Size(w, h), facingLeft: facingLeft, blink: blink, flap: 0.4);
    canvas.restore();
    return;
  }
  canvas.save();
  fitBox(canvas, box, _design, flip: facingLeft);
  final step = math.sin(walk * math.pi * 2);
  switch (animal) {
    case Animal.lion:
      _lion(canvas, step, blink);
    case Animal.elephant:
      _elephant(canvas, step, blink);
    case Animal.giraffe:
      _giraffe(canvas, step, blink);
    case Animal.sheep:
      _sheep(canvas, step, blink);
    case Animal.rabbit:
      _rabbit(canvas, step, blink);
    case Animal.tortoise:
      _tortoise(canvas, step, blink);
    case Animal.mouse:
      _mouse(canvas, step, blink);
    case Animal.owl:
      _owl(canvas, blink);
    case Animal.snail:
      _snail(canvas, step, blink);
    case Animal.ladybug:
      _ladybug(canvas, step);
    case Animal.dove:
      break;
  }
  canvas.restore();
}

void _paper(Canvas c, Path p, Color color, [double e = 1.6]) =>
    drawPaper(c, p, color, elevation: e, light: 0.12);

void _eyes(Canvas c, Offset at, double r, double blink, {double gap = 0}) {
  final open = 1 - blink.clamp(0.0, 1.0);
  final paint = Paint()..color = _eye;
  for (final dx in gap == 0 ? [0.0] : [-gap / 2, gap / 2]) {
    c.drawOval(
      Rect.fromCenter(center: at + Offset(dx, 0), width: r * 2, height: math.max(r * 0.35, r * 2.2 * open)),
      paint,
    );
    if (open > 0.5) {
      c.drawCircle(at + Offset(dx + r * 0.35, -r * 0.4), r * 0.35, Paint()..color = const Color(0xFFFFFFFF));
    }
  }
}

void _legs(
  Canvas c,
  List<double> xs,
  double top,
  double bottom,
  double r,
  Color color,
  double step, {
  Color? back,
}) {
  for (var i = 0; i < xs.length; i++) {
    final swing = (i.isEven ? step : -step) * 3;
    final isBack = i % 2 == 1;
    _paper(
      c,
      capsule(Offset(xs[i], top), Offset(xs[i] + swing, bottom - r), r),
      isBack ? (back ?? Color.lerp(color, const Color(0xFF000000), 0.12)!) : color,
      1,
    );
  }
}

void _lion(Canvas c, double step, double blink) {
  const body = Color(0xFFE8A94C);
  const mane = Color(0xFFB8662A);
  const face = Color(0xFFF2BE5E);
  _legs(c, [30, 38, 60, 68], 66, 100, 5, body, step);
  // Queue avec sa touffe.
  c.drawPath(
    Path()
      ..moveTo(22, 60)
      ..quadraticBezierTo(8, 58, 10, 42),
    Paint()
      ..color = body
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round,
  );
  _paper(c, circle(const Offset(10, 41), 5), mane, 1);
  _paper(c, ellipse(const Offset(48, 62), 58, 30), body);
  // Crinière toute ronde.
  _paper(
    c,
    unite([
      for (var i = 0; i < 10; i++)
        circle(Offset(74 + math.cos(i * math.pi / 5) * 16, 44 + math.sin(i * math.pi / 5) * 16), 8),
    ]),
    mane,
    2,
  );
  _paper(c, circle(const Offset(75, 45), 13), face, 1.5);
  _paper(c, circle(const Offset(66, 33), 4.5), face, 1);
  _paper(c, circle(const Offset(85, 34), 4.5), face, 1);
  _paper(c, ellipse(const Offset(79, 51), 14, 9), const Color(0xFFF8DDA0), 0.6);
  c.drawPath(
    Path()
      ..moveTo(76.5, 47)
      ..lineTo(81.5, 47)
      ..lineTo(79, 50.5)
      ..close(),
    Paint()..color = const Color(0xFF6B3A22),
  );
  _eyes(c, const Offset(75, 41), 1.8, blink, gap: 9);
}

void _elephant(Canvas c, double step, double blink) {
  const skin = Color(0xFF9AA3B5);
  const dark = Color(0xFF858EA2);
  _legs(c, [28, 36, 56, 64], 66, 100, 7, skin, step, back: dark);
  c.drawPath(
    Path()
      ..moveTo(16, 56)
      ..quadraticBezierTo(8, 62, 10, 72),
    Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round,
  );
  _paper(c, ellipse(const Offset(44, 58), 64, 42), skin, 2);
  // Trompe recourbée.
  _paper(
    c,
    Path()
      ..moveTo(84, 46)
      ..quadraticBezierTo(98, 56, 95, 78)
      ..quadraticBezierTo(94, 84, 89, 82)
      ..quadraticBezierTo(87, 79, 90, 77)
      ..quadraticBezierTo(91, 62, 80, 56)
      ..close(),
    skin,
    1.4,
  );
  _paper(c, circle(const Offset(77, 44), 17), skin, 1.8);
  _paper(c, ellipse(const Offset(66, 46), 22, 28), dark, 1.4);
  _paper(c, ellipse(const Offset(66, 46), 14, 19), const Color(0xFFE8B4BE), 0.5);
  _paper(
    c,
    Path()
      ..moveTo(84, 56)
      ..quadraticBezierTo(90, 62, 94, 60)
      ..quadraticBezierTo(90, 58, 87, 54)
      ..close(),
    const Color(0xFFFFF8EE),
    0.6,
  );
  _eyes(c, const Offset(82, 40), 1.9, blink);
}

void _giraffe(Canvas c, double step, double blink) {
  const coat = Color(0xFFF2C04E);
  const spot = Color(0xFFC98B2E);
  _legs(c, [26, 32, 50, 56], 64, 100, 3.2, coat, step);
  _paper(c, ellipse(const Offset(40, 58), 46, 24), coat, 1.8);
  // Long cou.
  _paper(
    c,
    Path()
      ..moveTo(48, 56)
      ..quadraticBezierTo(58, 34, 66, 14)
      ..lineTo(76, 16)
      ..quadraticBezierTo(68, 40, 62, 58)
      ..close(),
    coat,
    1.5,
  );
  final spotPaint = Paint()..color = spot;
  for (final (o, r) in const [
    (Offset(30, 54), 4.0),
    (Offset(42, 62), 3.5),
    (Offset(48, 52), 3.0),
    (Offset(24, 62), 2.6),
    (Offset(58, 44), 2.6),
    (Offset(63, 32), 2.4),
    (Offset(68, 22), 2.0),
    (Offset(36, 50), 2.2),
  ]) {
    c.drawCircle(o, r, spotPaint);
  }
  // Petites cornes (ossicônes).
  for (final x in [72.0, 78.0]) {
    c.drawLine(
      Offset(x, 8),
      Offset(x, 2),
      Paint()
        ..color = spot
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    c.drawCircle(Offset(x, 2), 2, spotPaint);
  }
  _paper(c, ellipse(const Offset(78, 11), 20, 12), coat, 1.2);
  _paper(c, ellipse(const Offset(86, 13), 8, 7), const Color(0xFFE8B26A), 0.6);
  _paper(c, ellipse(const Offset(70, 8), 7, 4), coat, 0.6);
  _eyes(c, const Offset(78, 9), 1.5, blink);
}

void _sheep(Canvas c, double step, double blink) {
  const wool = Color(0xFFFFF7EA);
  const face = Color(0xFF5B4636);
  _legs(c, [32, 38, 58, 64], 70, 100, 3.5, face, step);
  _paper(
    c,
    unite([
      for (final (o, r) in const [
        (Offset(30, 62), 13.0),
        (Offset(44, 54), 14.0),
        (Offset(58, 56), 13.0),
        (Offset(66, 66), 11.0),
        (Offset(48, 70), 14.0),
        (Offset(32, 72), 11.0),
      ])
        circle(o, r),
    ]),
    wool,
    2,
  );
  _paper(c, ellipse(const Offset(76, 58), 18, 22), face, 1.4);
  _paper(c, ellipse(const Offset(67, 52), 10, 5), face, 0.8);
  _paper(c, unite([circle(const Offset(74, 46), 5), circle(const Offset(80, 46), 5)]), wool, 0.8);
  _eyes(c, const Offset(79, 56), 1.5, blink);
}

void _rabbit(Canvas c, double step, double blink) {
  const fur = Color(0xFFD9CBBE);
  const pink = Color(0xFFF2B1B8);
  for (final (x, tilt) in const [(64.0, -4.0), (72.0, 3.0)]) {
    _paper(c, ellipse(Offset(x + tilt, 38), 8, 26), fur, 1);
    _paper(c, ellipse(Offset(x + tilt, 39), 4, 18), pink, 0.3);
  }
  _paper(c, ellipse(Offset(40 + step * 2, 96), 16, 7), fur, 0.8);
  _paper(c, ellipse(const Offset(48, 78), 38, 28), fur, 1.6);
  _paper(c, circle(const Offset(29, 74), 6), const Color(0xFFFFFFFF), 1);
  _paper(c, circle(const Offset(68, 62), 13), fur, 1.4);
  _paper(c, ellipse(Offset(60 - step * 2, 96), 12, 6), fur, 0.8);
  c.drawCircle(const Offset(80, 64), 2, Paint()..color = pink);
  _eyes(c, const Offset(72, 59), 1.7, blink);
}

void _tortoise(Canvas c, double step, double blink) {
  const shell = Color(0xFF6E9A4E);
  const skin = Color(0xFFA3B86C);
  _legs(c, [32, 40, 58, 66], 86, 100, 4.5, skin, step * 0.5);
  _paper(
    c,
    Path()
      ..moveTo(84, 84)
      ..lineTo(90, 80)
      ..quadraticBezierTo(96, 70, 90, 66)
      ..quadraticBezierTo(82, 64, 80, 74)
      ..close(),
    skin,
    1,
  );
  _paper(
    c,
    Path()
      ..moveTo(20, 88)
      ..quadraticBezierTo(22, 56, 50, 54)
      ..quadraticBezierTo(78, 56, 80, 88)
      ..close(),
    shell,
    2,
  );
  final line = Paint()
    ..color = const Color(0xFF8DB86A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeJoin = StrokeJoin.round;
  c.drawPath(
    Path()
      ..moveTo(40, 64)
      ..lineTo(60, 64)
      ..lineTo(66, 76)
      ..lineTo(60, 87)
      ..moveTo(40, 64)
      ..lineTo(34, 76)
      ..lineTo(40, 87)
      ..moveTo(34, 76)
      ..lineTo(66, 76)
      ..moveTo(50, 54)
      ..lineTo(50, 64),
    line,
  );
  _paper(c, RRectPath.bottomBand(20, 80, 86, 90), const Color(0xFF55803A), 0.6);
  _eyes(c, const Offset(89, 70), 1.4, blink);
}

void _mouse(Canvas c, double step, double blink) {
  const fur = Color(0xFFB7AFA8);
  c.drawPath(
    Path()
      ..moveTo(36, 88)
      ..quadraticBezierTo(18, 98, 12, 82),
    Paint()
      ..color = const Color(0xFFE2A3A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round,
  );
  _paper(c, ellipse(const Offset(50, 86), 34, 22), fur, 1.4);
  _paper(c, circle(const Offset(68, 82), 10), fur, 1.2);
  _paper(c, circle(const Offset(63, 72), 7), fur, 1);
  _paper(c, circle(const Offset(63, 72), 4.5), const Color(0xFFF2B1B8), 0.3);
  c.drawCircle(const Offset(78, 84), 1.8, Paint()..color = const Color(0xFFE07A86));
  for (final x in [44.0, 56.0]) {
    _paper(c, ellipse(Offset(x + step * 1.5, 97), 7, 4), fur, 0.4);
  }
  _eyes(c, const Offset(71, 80), 1.4, blink);
}

void _owl(Canvas c, double blink) {
  const feathers = Color(0xFFA0754F);
  const belly = Color(0xFFE6CDA6);
  _paper(
    c,
    Path()
      ..moveTo(36, 30)
      ..lineTo(32, 16)
      ..lineTo(44, 26)
      ..close(),
    feathers,
    1,
  );
  _paper(
    c,
    Path()
      ..moveTo(64, 30)
      ..lineTo(68, 16)
      ..lineTo(56, 26)
      ..close(),
    feathers,
    1,
  );
  _paper(c, ellipse(const Offset(50, 60), 48, 66), feathers, 2);
  _paper(c, ellipse(const Offset(50, 70), 30, 40), belly, 0.8);
  for (final x in [28.0, 72.0]) {
    _paper(c, ellipse(Offset(x, 64), 12, 32), const Color(0xFF85603F), 1);
  }
  for (final x in [40.0, 60.0]) {
    _paper(c, circle(Offset(x, 44), 10), const Color(0xFFFFF8EE), 0.8);
    _eyes(c, Offset(x, 44), 3.4, blink);
  }
  _paper(
    c,
    Path()
      ..moveTo(46, 52)
      ..lineTo(54, 52)
      ..lineTo(50, 60)
      ..close(),
    const Color(0xFFF4A340),
    0.5,
  );
  for (final x in [43.0, 57.0]) {
    _paper(c, ellipse(Offset(x, 94), 9, 5), const Color(0xFFF4A340), 0.4);
  }
}

void _snail(Canvas c, double step, double blink) {
  const body = Color(0xFFCFB48D);
  _paper(
    c,
    Path()
      ..moveTo(20, 98)
      ..quadraticBezierTo(18, 90, 30, 90)
      ..lineTo(70, 90)
      ..quadraticBezierTo(76, 74, 82, 74)
      ..quadraticBezierTo(90, 74, 88, 88)
      ..quadraticBezierTo(86 + step, 98, 76, 98)
      ..close(),
    body,
    1.2,
  );
  for (final (x, tip) in const [(80.0, Offset(78, 58)), (86.0, Offset(90, 60))]) {
    c.drawLine(
      Offset(x, 76),
      tip,
      Paint()
        ..color = body
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    c.drawCircle(tip, 2.2, Paint()..color = _eye);
  }
  _paper(c, circle(const Offset(48, 72), 20), const Color(0xFFE2A85A), 2);
  c.drawPath(
    _spiral(const Offset(48, 72), 16, 2.4),
    Paint()
      ..color = const Color(0xFFB9772F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round,
  );
  _eyes(c, const Offset(84, 82), 1.1, blink);
}

void _ladybug(Canvas c, double step) {
  const red = Color(0xFFE3483B);
  final ink = Paint()..color = const Color(0xFF2A1A12);
  for (final x in [36.0, 50.0, 64.0]) {
    c.drawLine(
      Offset(x, 90),
      Offset(x + step * 2 - 2, 99),
      ink
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }
  _paper(c, circle(const Offset(72, 86), 8), const Color(0xFF2A1A12), 1);
  for (final dx in [-3.0, 3.0]) {
    c.drawLine(Offset(74 + dx, 79), Offset(78 + dx * 2, 70), ink..strokeWidth = 1.4);
  }
  _paper(
    c,
    Path()
      ..moveTo(26, 92)
      ..quadraticBezierTo(26, 66, 50, 66)
      ..quadraticBezierTo(74, 66, 74, 92)
      ..close(),
    red,
    1.8,
  );
  c.drawLine(const Offset(50, 67), const Offset(50, 92), ink..strokeWidth = 1.4);
  for (final o in const [Offset(40, 76), Offset(60, 76), Offset(36, 86), Offset(64, 86), Offset(50, 72)]) {
    c.drawCircle(o, 3.2, ink);
  }
}

Path _spiral(Offset c, double r, double turns) {
  final path = Path()..moveTo(c.dx, c.dy);
  const steps = 60;
  for (var i = 1; i <= steps; i++) {
    final t = i / steps;
    final a = t * turns * math.pi * 2;
    path.lineTo(c.dx + math.cos(a) * r * t, c.dy + math.sin(a) * r * t);
  }
  return path;
}

/// Bande arrondie en bas d'une forme (bord de carapace…).
abstract final class RRectPath {
  static Path bottomBand(double left, double right, double top, double bottom) => Path()
    ..addRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(left, top, right, bottom), Radius.circular((bottom - top) / 2)),
    );
}

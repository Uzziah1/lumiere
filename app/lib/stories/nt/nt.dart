import 'dart:math' as math;
import 'dart:ui';

import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../art/shapes.dart';
import '../../art/weather.dart';
import '../../theme/palette.dart';

/// Personnages et décors partagés par les histoires du Nouveau Testament.
abstract final class NT {
  /// Jésus, représenté avec douceur et dignité.
  static const jesus = PersonStyle(
    skin: Color(0xFF9C6440),
    robe: Color(0xFFF5EEE0),
    headcloth: Color(0xFF4A3323),
    sash: Color(0xFFB0413E),
    beard: Color(0xFF4A3323),
    bareHead: true,
  );

  static const childJesus = PersonStyle(
    skin: Color(0xFF9C6440),
    robe: Color(0xFFF5EEE0),
    headcloth: Color(0xFF4A3323),
    sash: Color(0xFFB0413E),
    bareHead: true,
    scale: 0.72,
  );

  static const mary = PersonStyle(
    skin: Color(0xFFA06A45),
    robe: Color(0xFF6E8FB8),
    headcloth: Color(0xFFDCE7F5),
    veil: true,
    scale: 0.95,
  );

  static const joseph = PersonStyle(
    skin: Color(0xFF8A5537),
    robe: Color(0xFF9A5E36),
    headcloth: Color(0xFFEADBC0),
    beard: Color(0xFF3E2A1E),
  );

  static const angel = PersonStyle(
    skin: Color(0xFFB47E57),
    robe: Color(0xFFFFFDF6),
    headcloth: Color(0xFF6B4630),
    sash: Color(0xFFF2C14E),
    bareHead: true,
  );

  static const disciples = [
    PersonStyle(
      skin: Color(0xFF7D4A30),
      robe: Color(0xFF6E8FB8),
      headcloth: Color(0xFFE8D6B3),
      beard: Color(0xFF2E1E15),
    ),
    PersonStyle(
      skin: Color(0xFF9C6440),
      robe: Color(0xFFD08A47),
      headcloth: Color(0xFFF0E2C8),
      beard: Color(0xFF3E2A1E),
    ),
    PersonStyle(
      skin: Color(0xFF6E4029),
      robe: Color(0xFF5F9E7E),
      headcloth: Color(0xFFEADBC0),
      beard: Color(0xFF2A1A12),
    ),
    PersonStyle(skin: Color(0xFFA9714B), robe: Color(0xFF8C79B5), headcloth: Color(0xFFF3E2C0)),
  ];

  /// Une foule variée : hommes, femmes, enfants.
  static const crowd = [
    PersonStyle(
      skin: Color(0xFF7D4A30),
      robe: Color(0xFFE0A35A),
      headcloth: Color(0xFFF6E7C8),
      veil: true,
      scale: 0.92,
    ),
    PersonStyle(
      skin: Color(0xFF9C6440),
      robe: Color(0xFF5F9E7E),
      headcloth: Color(0xFFF0E2C8),
      beard: Color(0xFF3E2A1E),
    ),
    PersonStyle(
      skin: Color(0xFF6E4029),
      robe: Color(0xFFB0563A),
      headcloth: Color(0xFF2E1E15),
      bareHead: true,
      scale: 0.68,
    ),
    PersonStyle(skin: Color(0xFFA9714B), robe: Color(0xFF6FA8A3), headcloth: Color(0xFFF2D6B8), veil: true, scale: 0.9),
    PersonStyle(
      skin: Color(0xFF8E5A3B),
      robe: Color(0xFF8C79B5),
      headcloth: Color(0xFFE8D6B3),
      beard: Color(0xFF4A3323),
    ),
    PersonStyle(
      skin: Color(0xFF7D4A30),
      robe: Color(0xFFD9B27A),
      headcloth: Color(0xFF2A1A12),
      bareHead: true,
      scale: 0.62,
    ),
  ];

  static const elder = PersonStyle(
    skin: Color(0xFF946042),
    robe: Color(0xFFF2EBDD),
    headcloth: Color(0xFF3A7CA5),
    sash: Color(0xFFD9B27A),
    beard: Color(0xFFE6E0D6),
  );
}

/// Un ange : une silhouette lumineuse aux grandes ailes.
void paintAngel(Canvas canvas, Offset feet, double h, double time, {double glow = 1, bool facingLeft = false}) {
  final center = feet - Offset(0, h * 0.55);
  canvas.drawCircle(
    center,
    h * 0.7,
    Paint()
      ..shader = Gradient.radial(center, h * 0.7, [
        Palette.sun.withValues(alpha: 0.7 * glow),
        Palette.sunHalo.withValues(alpha: 0),
      ]),
  );
  final flap = math.sin(time * 2) * 0.08;
  for (final side in [-1.0, 1.0]) {
    canvas.save();
    canvas.translate(feet.dx + side * h * 0.08, feet.dy - h * 0.62);
    canvas.rotate(side * (0.5 + flap));
    final wing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(side * h * 0.34, -h * 0.2, side * h * 0.3, h * 0.24)
      ..quadraticBezierTo(side * h * 0.12, h * 0.12, 0, h * 0.06)
      ..close();
    drawPaper(canvas, wing, const Color(0xFFFFFBF0), elevation: h * 0.02, light: 0.1);
    canvas.restore();
  }
  paintPerson(
    canvas,
    feet,
    h,
    NT.angel,
    raisedBoth: true,
    wave: 0.55,
    facingLeft: facingLeft,
    blink: blinkAt(time, 0.4),
  );
}

/// Une rangée de personnes (foule), pieds sur la ligne [fy].
void paintCrowd(
  Canvas canvas,
  Size s,
  double time, {
  double from = 0.05,
  double to = 0.4,
  double fy = 0.92,
  double h = 0.3,
  int count = 5,
  double wave = 0,
  int offset = 0,
  bool facingLeft = false,
}) {
  for (var i = 0; i < count; i++) {
    final fx = count == 1 ? from : from + (to - from) * i / (count - 1);
    final style = NT.crowd[(i + offset) % NT.crowd.length];
    paintPerson(
      canvas,
      feetAt(s, fx, fy + (i.isOdd ? 0.015 : 0)),
      s.height * h,
      style,
      wave: wave > 0 ? wave * (0.7 + 0.3 * math.sin(time * 3 + i)) : 0,
      facingLeft: facingLeft,
      blink: blinkAt(time, i * 1.3 + offset),
    );
  }
}

/// Le lac de Galilée : collines vertes autour d'une eau claire.
void paintGalilee(Canvas canvas, Size s, double time, {List<Color> sky = Skies.day, double level = 0.66}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 2);
  paintHills(canvas, s, time, baselines: const [0.56, 0.62], colors: Lands.green, seed: 151);
  paintWaves(canvas, s, s.height * level, time * 0.5, from: 0, to: 2);
}

/// Jérusalem au loin : murailles claires et le temple.
void paintJerusalem(Canvas canvas, Size s, double time, {List<Color> sky = Skies.desert, double horizon = 0.62}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 2);
  final wall = Path()
    ..addRect(Rect.fromLTWH(s.width * 0.08, s.height * (horizon - 0.12), s.width * 0.84, s.height * 0.14));
  drawPaper(canvas, wall, const Color(0xFFE6CFA3), elevation: 3);
  for (var k = 0; k < 14; k++) {
    final x = s.width * (0.08 + k * 0.06);
    canvas.drawRect(
      Rect.fromLTWH(x, s.height * (horizon - 0.15), s.width * 0.03, s.height * 0.03),
      Paint()..color = const Color(0xFFE6CFA3),
    );
  }
  paintThing(canvas, 'temple', boxAt(s, 0.5, horizon - 0.1, 0.3, aspect: 1.2));
  for (final fx in [0.2, 0.34, 0.68, 0.82]) {
    paintThing(canvas, 'city', boxAt(s, fx, horizon - 0.04, 0.12, aspect: 1.4));
  }
  paintHills(canvas, s, time, baselines: [horizon + 0.08, horizon + 0.22], colors: Lands.desert, seed: 153);
}

/// L'intérieur d'une maison : murs de terre, poutres, une fenêtre.
void paintHouse(Canvas canvas, Size s, {Color wall = const Color(0xFFE6CFA3), double lamp = 0.6}) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = Gradient.linear(Offset.zero, Offset(0, s.height), [
        wall,
        Color.lerp(wall, const Color(0xFF8A5634), 0.25)!,
      ]),
  );
  for (final y in [0.08, 0.2]) {
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(0, s.height * y, s.width, s.height * 0.04)),
      const Color(0xFF8A5634),
      elevation: 3,
    );
  }
  final window = Rect.fromLTWH(s.width * 0.74, s.height * 0.3, s.width * 0.12, s.height * 0.2);
  canvas.drawRRect(
    RRect.fromRectAndRadius(window, Radius.circular(s.height * 0.02)),
    Paint()..color = const Color(0xFF8CCFE6),
  );
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.84, s.width, s.height * 0.16)),
    const Color(0xFFC9A877),
    elevation: 3,
  );
  final l = Offset(s.width * 0.3, s.height * 0.32);
  canvas.drawCircle(
    l,
    s.height * 0.2,
    Paint()
      ..shader = Gradient.radial(l, s.height * 0.2, [
        Palette.sunHalo.withValues(alpha: 0.5 * lamp),
        Palette.sunHalo.withValues(alpha: 0),
      ]),
  );
  drawPaper(canvas, ellipse(l, s.height * 0.07, s.height * 0.035), const Color(0xFFC8744A), elevation: 2);
  final flame = Path()
    ..moveTo(l.dx + s.height * 0.03, l.dy - s.height * 0.01)
    ..quadraticBezierTo(
      l.dx + s.height * 0.025,
      l.dy - s.height * 0.05,
      l.dx + s.height * 0.035,
      l.dy - s.height * 0.07,
    )
    ..quadraticBezierTo(l.dx + s.height * 0.05, l.dy - s.height * 0.04, l.dx + s.height * 0.04, l.dy - s.height * 0.01)
    ..close();
  canvas.drawPath(flame, Paint()..color = const Color(0xFFF29A45));
}

/// Une route qui serpente dans le désert.
void paintRoad(Canvas canvas, Size s, double time, {List<Color> sky = Skies.desert}) {
  paintSkyGradient(canvas, s, sky);
  paintHills(canvas, s, time, baselines: const [0.58, 0.7, 0.82], colors: Lands.desert, seed: 157);
  final road = Path()
    ..moveTo(0, s.height * 0.92)
    ..quadraticBezierTo(s.width * 0.4, s.height * 0.78, s.width * 0.6, s.height * 0.84)
    ..quadraticBezierTo(s.width * 0.8, s.height * 0.9, s.width, s.height * 0.82)
    ..lineTo(s.width, s.height * 0.94)
    ..quadraticBezierTo(s.width * 0.8, s.height * 1.0, s.width * 0.6, s.height * 0.96)
    ..quadraticBezierTo(s.width * 0.4, s.height * 0.9, 0, s.height * 1.02)
    ..close();
  drawPaper(canvas, road, const Color(0xFFEAD5A8), elevation: 1);
}

/// Un enfant emmailloté (Jésus bébé), centré en [c].
void paintBaby(Canvas canvas, Offset c, double r, {double glow = 0}) {
  if (glow > 0) {
    canvas.drawCircle(
      c,
      r * 3,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.5 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r),
    );
  }
  drawPaper(
    canvas,
    Path()..addOval(Rect.fromCenter(center: c, width: r * 3, height: r * 1.6)),
    const Color(0xFFFFF7EA),
    elevation: 2,
  );
  drawPaper(canvas, circle(c + Offset(r * 1.1, -r * 0.2), r * 0.65), const Color(0xFF9C6440), elevation: 1);
  canvas.drawArc(
    Rect.fromCircle(center: c + Offset(r * 1.25, -r * 0.15), radius: r * 0.18),
    math.pi * 0.1,
    math.pi * 0.8,
    false,
    Paint()
      ..color = const Color(0xFF2A1A12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, r * 0.08)
      ..strokeCap = StrokeCap.round,
  );
}

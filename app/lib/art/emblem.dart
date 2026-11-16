import 'dart:math' as math;
import 'dart:ui';

/// L'emblème de Lumière : une colombe stylisée, ailes levées, rameau d'olivier
/// doré, sur un ciel de nuit avec un halo de lumière. Sert pour l'icône de
/// l'application ; dessinée dans une boîte 100 × 100.
abstract final class Emblem {
  static const nightTop = Color(0xFF14183A);
  static const nightBottom = Color(0xFF2B2463);
  static const gold = Color(0xFFF2C14E);
  static const goldDeep = Color(0xFFC98A1E);
  static const white = Color(0xFFFFFDF7);
  static const shade = Color(0xFFDCD8EE);

  /// Fond : dégradé de nuit, disque de lumière doré et quelques étoiles.
  static void paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..shader = Gradient.linear(rect.topCenter, rect.bottomCenter, const [nightTop, nightBottom]),
    );
    final c = Offset(size.width * 0.56, size.height * 0.44);
    final r = size.width * 0.3;
    canvas.drawCircle(
      c,
      r * 1.7,
      Paint()
        ..shader = Gradient.radial(c, r * 1.7, [
          const Color(0xFFFFD98A).withValues(alpha: 0.32),
          const Color(0xFFFFD98A).withValues(alpha: 0),
        ]),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = Gradient.radial(
          c - Offset(r * 0.3, r * 0.3),
          r * 1.3,
          const [Color(0xFFFFE9A8), gold, Color(0xFFE59E2C)],
          const [0, 0.55, 1],
        ),
    );
    final random = math.Random(5);
    for (var i = 0; i < 10; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      if ((p - c).distance < r * 1.5) continue;
      canvas.drawCircle(
        p,
        size.width * (0.005 + random.nextDouble() * 0.006),
        Paint()..color = const Color(0xDDFFF3D6),
      );
    }
  }

  /// La colombe dans une boîte 100 × 100 (à placer avec `canvas.scale`).
  static void paintDove(Canvas canvas) {
    final soft = Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    // Aile arrière, un peu plus sombre.
    final backWing = Path()
      ..moveTo(52, 52)
      ..cubicTo(44, 40, 34, 24, 18, 14)
      ..cubicTo(30, 16, 38, 20, 44, 26)
      ..cubicTo(42, 20, 40, 15, 36, 9)
      ..cubicTo(48, 14, 56, 26, 60, 44)
      ..close();
    canvas.drawPath(backWing.shift(const Offset(0, 1.5)), soft);
    canvas.drawPath(backWing, Paint()..color = shade);

    // Corps : tête ronde, poitrine bombée, queue en éventail.
    final body = Path()
      ..moveTo(74, 34)
      ..cubicTo(82, 33, 87, 38, 86, 44)
      ..cubicTo(85, 52, 76, 62, 62, 68)
      ..cubicTo(52, 72, 40, 72, 30, 70)
      ..lineTo(12, 80)
      ..lineTo(16, 72)
      ..lineTo(6, 70)
      ..lineTo(18, 64)
      ..lineTo(12, 58)
      ..cubicTo(26, 60, 40, 58, 52, 52)
      ..cubicTo(60, 48, 64, 38, 74, 34)
      ..close();
    canvas.drawPath(body.shift(const Offset(0, 2)), soft);
    canvas.drawPath(body, Paint()..color = white);

    // Aile avant, grande, levée, avec trois plumes découpées.
    final wing = Path()
      ..moveTo(50, 56)
      ..cubicTo(44, 42, 44, 24, 54, 6)
      ..cubicTo(56, 14, 58, 18, 62, 20)
      ..cubicTo(62, 14, 64, 10, 68, 6)
      ..cubicTo(68, 16, 70, 22, 74, 26)
      ..cubicTo(70, 30, 66, 34, 64, 38)
      ..cubicTo(62, 46, 58, 52, 50, 56)
      ..close();
    canvas.drawPath(wing.shift(const Offset(0, 2)), soft);
    canvas.drawPath(wing, Paint()..color = white);
    // Bec et œil.
    canvas.drawPath(
      Path()
        ..moveTo(85, 40)
        ..lineTo(94, 43)
        ..lineTo(85, 46)
        ..close(),
      Paint()..color = gold,
    );
    canvas.drawCircle(const Offset(78, 40), 2.2, Paint()..color = nightTop);

    // Rameau d'olivier doré dans le bec.
    final stem = Paint()
      ..color = goldDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(90, 44)
        ..quadraticBezierTo(94, 52, 92, 62),
      stem,
    );
    for (final (x, y, a) in [(91.5, 49.0, 2.6), (93.0, 52.0, 0.5), (93.5, 57.0, 2.8), (92.0, 61.5, 0.9)]) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(4.6, 0), width: 9.5, height: 4.2),
        Paint()..color = const Color(0xFF7FC25A),
      );
      canvas.restore();
    }
  }

  /// L'icône complète dans [size] : [inset] = marge autour de la colombe.
  static void paintIcon(Canvas canvas, Size size, {double inset = 0.1}) {
    paintBackground(canvas, size);
    final side = size.width * (1 - inset * 2);
    canvas.save();
    // Boîte utile de la colombe : x 6–96, y 6–80 ; on la centre.
    canvas.translate(size.width / 2 - side * 0.51, size.height / 2 - side * 0.43);
    canvas.scale(side / 100);
    paintDove(canvas);
    canvas.restore();
  }
}

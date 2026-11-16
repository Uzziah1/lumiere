import 'dart:ui';

import 'paper.dart';
import 'shapes.dart';

/// L'arche de Noé en papier découpé, dessinée dans une boîte de 200 × 120.
abstract final class Ark {
  static const design = Size(200, 120);
  static const aspectRatio = 200 / 120;

  static const wood = Color(0xFFA86A3E);
  static const woodLight = Color(0xFFC68A55);
  static const woodDark = Color(0xFF7E4A2A);
  static const roof = Color(0xFF8E4F2E);
  static const pitch = Color(0xFF5C3520);

  /// Nombre d'étapes de construction (voir [paint]).
  static const buildSteps = 5;

  /// Position relative (0–1 dans la boîte) de la fenêtre et de la porte,
  /// pour poser une colombe ou faire entrer les animaux.
  static const windowCenter = Offset(136 / 200, 33 / 120);
  static const doorCenter = Offset(70 / 200, 42 / 120);

  /// Dessine l'arche dans [box] (proportions gardées, posée en bas).
  ///
  /// [build] de 0 à 1 : charpente, coque du bas, coque entière, cabine, toit,
  /// puis porte et fenêtre. [door] : 0 fermée, 1 ouverte (rampe posée au sol).
  /// [window] : 0 fermée, 1 volet ouvert.
  static void paint(Canvas canvas, Rect box, {double build = 1, double door = 0, double window = 0}) {
    if (box.isEmpty) return;
    canvas.save();
    fitBox(canvas, box, design);
    final step = (build.clamp(0.0, 1.0) * buildSteps).floor();

    final hull = Path()
      ..moveTo(4, 52)
      ..lineTo(196, 52)
      ..quadraticBezierTo(192, 70, 178, 84)
      ..cubicTo(162, 118, 38, 118, 22, 84)
      ..quadraticBezierTo(8, 70, 4, 52)
      ..close();

    // Charpente : quille et membrures, visibles tant que la coque n'est pas finie.
    if (step < 2) {
      final beam = Paint()
        ..color = woodDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(
        Path()
          ..moveTo(22, 84)
          ..cubicTo(38, 118, 162, 118, 178, 84),
        beam,
      );
      for (var x = 22.0; x <= 178; x += 17) {
        final bottom = 84 + 26 * (1 - ((x - 100) / 80) * ((x - 100) / 80));
        canvas.drawLine(Offset(x, 50), Offset(x, bottom), beam..strokeWidth = 3);
      }
    }

    if (step >= 1) {
      canvas.save();
      if (step == 1) canvas.clipRect(const Rect.fromLTRB(0, 80, 200, 120));
      drawPaper(canvas, hull, wood, elevation: 4, light: 0.1);
      canvas.clipPath(hull);
      final plank = Paint()
        ..color = woodDark.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      for (final y in [64.0, 74.0, 84.0, 94.0, 104.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(8, y - 6)
            ..quadraticBezierTo(100, y + 10, 192, y - 6),
          plank,
        );
      }
      canvas.restore();
    }

    if (step >= 2) {
      // Liston de poix sur le haut de la coque.
      drawPaper(
        canvas,
        Path()
          ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(2, 48, 198, 55), const Radius.circular(3))),
        pitch,
        elevation: 1.5,
        light: 0.1,
      );
    }

    if (step >= 3) {
      final cabin = Path()
        ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(36, 20, 166, 50), const Radius.circular(3)));
      drawPaper(canvas, cabin, woodLight, elevation: 3, light: 0.1);
      final board = Paint()
        ..color = wood.withValues(alpha: 0.6)
        ..strokeWidth = 1.2;
      for (var x = 46.0; x < 166; x += 10) {
        canvas.drawLine(Offset(x, 22), Offset(x, 49), board);
      }
    }

    if (step >= 4) {
      final roofPath = Path()
        ..moveTo(26, 24)
        ..quadraticBezierTo(28, 18, 36, 16)
        ..lineTo(96, 3)
        ..quadraticBezierTo(100, 2, 104, 3)
        ..lineTo(164, 16)
        ..quadraticBezierTo(172, 18, 174, 24)
        ..close();
      drawPaper(canvas, roofPath, roof, elevation: 3, light: 0.14);
    }

    if (step >= 5) {
      _window(canvas, window.clamp(0.0, 1.0));
      _door(canvas, door.clamp(0.0, 1.0));
    }
    canvas.restore();
  }

  static void _window(Canvas canvas, double open) {
    const frame = Rect.fromLTRB(126, 25, 146, 41);
    drawPaper(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(2))),
      pitch,
      elevation: 0,
      light: 0,
    );
    // Le volet pivote sur sa charnière de droite : il s'affine en s'ouvrant.
    final w = frame.width * (1 - open * 0.85);
    final shutter = Rect.fromLTRB(
      frame.right - w + (open > 0 ? frame.width * open * 0.55 : 0),
      frame.top,
      frame.right + (open > 0 ? frame.width * open * 0.55 : 0),
      frame.bottom,
    );
    drawPaper(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius(shutter, const Radius.circular(2))),
      woodDark,
      elevation: 1 + open,
      light: 0.15,
    );
  }

  static void _door(Canvas canvas, double open) {
    const doorway = Rect.fromLTRB(58, 26, 82, 58);
    final arch = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          doorway,
          topLeft: const Radius.circular(11),
          topRight: const Radius.circular(11),
        ),
      );
    if (open <= 0) {
      drawPaper(canvas, arch, woodDark, elevation: 1, light: 0.12);
      canvas.drawCircle(const Offset(78, 44), 1.6, Paint()..color = const Color(0xFFE9B949));
      return;
    }
    drawPaper(canvas, arch, const Color(0xFF3A2216), elevation: 0, light: 0);
    // La porte se rabat vers l'extérieur et devient une rampe jusqu'au sol.
    const length = 62.0;
    final end = Offset.lerp(
      const Offset(70, 26),
      const Offset(70 - length * 0.85, 58 + length * 0.55),
      open,
    )!;
    final ramp = Path()
      ..moveTo(58, 58)
      ..lineTo(82, 58)
      ..lineTo(end.dx + 12, end.dy)
      ..lineTo(end.dx - 12, end.dy)
      ..close();
    drawPaper(canvas, ramp, woodLight, elevation: 3, light: 0.15);
    final cleat = Paint()
      ..color = wood
      ..strokeWidth = 1.4;
    for (var t = 0.2; t < 1; t += 0.2) {
      final a = Offset.lerp(const Offset(58, 58), Offset(end.dx - 12, end.dy), t)!;
      final b = Offset.lerp(const Offset(82, 58), Offset(end.dx + 12, end.dy), t)!;
      canvas.drawLine(a, b, cleat);
    }
  }
}

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart' show CustomPainter;
import 'package:flutter/animation.dart' show Animation;

import '../theme/palette.dart';
import 'paper.dart';

/// Colombe, la petite colombe guide de Lumière, en papier découpé.
///
/// Dessinée dans une boîte de 100 × 80 unités, tournée vers la droite, puis
/// mise à l'échelle (proportions conservées) et centrée dans la taille demandée.
abstract final class Colombe {
  static const designSize = Size(100, 80);

  /// Proportion largeur / hauteur de Colombe.
  static const aspectRatio = 100 / 80;

  static const _frontPivot = Offset(50, 41);
  static const _backPivot = Offset(44, 38);

  /// Aile relevée (battement vers le haut) et abaissée, en radians.
  static const _wingUp = 0.95;
  static const _wingDown = -0.35;

  static final Path _body = _buildBody();
  static final Path _wing = _buildWing();
  static final Path _beak = Path()
    ..moveTo(79, 29.5)
    ..quadraticBezierTo(85, 31, 89, 33)
    ..quadraticBezierTo(85, 35, 79, 36.5)
    ..close();

  /// Dessine Colombe.
  ///
  /// [flap] : 0 = ailes basses, 1 = ailes hautes. [blink] : 0 = yeux ouverts,
  /// 1 = fermés. [withBranch] : le rameau d'olivier de Noé dans le bec.
  static void paint(
    Canvas canvas,
    Size size, {
    double flap = 0.5,
    double blink = 0,
    bool facingLeft = false,
    bool withBranch = false,
  }) {
    if (size.isEmpty) return;
    final scale = math.min(size.width / designSize.width, size.height / designSize.height);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(facingLeft ? -scale : scale, scale);
    canvas.translate(-designSize.width / 2, -designSize.height / 2);

    final angle = _wingDown + (_wingUp - _wingDown) * flap.clamp(0.0, 1.0);

    // Aile arrière, un peu en retard sur l'aile avant.
    _drawWing(canvas, _backPivot, angle + 0.18, Palette.doveWingBack, elevation: 1.5, light: 0.05);

    // Queue et corps.
    drawPaper(canvas, _body, Palette.dove, elevation: 3, light: 0);
    canvas.drawPath(
      _body,
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, 22),
          const Offset(0, 60),
          const [Color(0x00EDE5F6), Palette.doveShade],
          const [0.45, 1],
        ),
    );

    if (withBranch) _drawBranch(canvas);

    drawPaper(canvas, _beak, Palette.beak, elevation: 1, light: 0.2);

    // Joue rose.
    canvas.drawCircle(const Offset(69.5, 36.5), 3.2, Paint()..color = Palette.blush.withValues(alpha: 0.55));

    // Œil : un ovale qui s'aplatit quand Colombe cligne.
    final openness = 1 - blink.clamp(0.0, 1.0);
    final eye = Rect.fromCenter(
      center: const Offset(73.5, 29),
      width: 4.6,
      height: math.max(0.7, 5.2 * openness),
    );
    canvas.drawOval(eye, Paint()..color = Palette.ink);
    if (openness > 0.5) {
      canvas.drawCircle(const Offset(74.6, 27.8), 0.9, Paint()..color = const Color(0xFFFFFFFF));
    }

    // Aile avant.
    _drawWing(canvas, _frontPivot, angle, Palette.dove, elevation: 2.5, light: 0, feathers: true);

    canvas.restore();
  }

  static void _drawWing(
    Canvas canvas,
    Offset pivot,
    double angle,
    Color color, {
    required double elevation,
    required double light,
    bool feathers = false,
  }) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);
    drawPaper(canvas, _wing, color, elevation: elevation, light: light);
    if (feathers) {
      final line = Paint()
        ..color = Palette.doveFeather
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round;
      for (final x in const [-12.0, -20.0, -28.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(x + 5, -6)
            ..quadraticBezierTo(x + 1, -2, x - 1, 2),
          line,
        );
      }
    }
    canvas.restore();
  }

  static void _drawBranch(Canvas canvas) {
    final stem = Paint()
      ..color = Palette.oliveDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(84, 33)
        ..quadraticBezierTo(91, 31, 98, 26),
      stem,
    );
    for (final (at, rotation) in const [
      (Offset(90, 31.5), -0.9),
      (Offset(94.5, 28.5), 0.6),
      (Offset(97.5, 25.5), -0.5),
    ]) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(rotation);
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(3, -2.6, 7, 0)
        ..quadraticBezierTo(3, 2.6, 0, 0)
        ..close();
      drawPaper(canvas, leaf, Palette.olive, elevation: 0.8, light: 0.15);
      canvas.restore();
    }
  }

  static Path _buildBody() {
    final tail = Path()
      ..moveTo(32, 43)
      ..quadraticBezierTo(18, 40, 7, 35)
      ..quadraticBezierTo(3, 41, 8, 45.5)
      ..quadraticBezierTo(2, 50, 8, 55)
      ..quadraticBezierTo(18, 53, 32, 52)
      ..close();
    final body = Path()..addOval(Rect.fromCenter(center: const Offset(49, 46), width: 46, height: 27));
    final neck = Path()..addOval(Rect.fromCircle(center: const Offset(63.5, 38.5), radius: 9.5));
    final head = Path()..addOval(Rect.fromCircle(center: const Offset(70, 31), radius: 11));
    var path = Path.combine(PathOperation.union, tail, body);
    path = Path.combine(PathOperation.union, path, neck);
    return Path.combine(PathOperation.union, path, head);
  }

  /// L'aile au repos pointe vers l'arrière ; son pivot (l'épaule) est en (0, 0).
  static Path _buildWing() {
    return Path()
      ..moveTo(3, -4)
      ..cubicTo(-10, -15, -30, -15, -41, -8)
      ..quadraticBezierTo(-37, -2, -31, -3)
      ..quadraticBezierTo(-28, 2.5, -22, 1)
      ..quadraticBezierTo(-18, 6.5, -11.5, 4)
      ..quadraticBezierTo(-5, 8.5, 3, 4)
      ..close();
  }
}

/// Colombe pour les écrans Flutter (hors scène de jeu).
///
/// Avec [animation] (valeur qui court de 0 à 1 en boucle), elle bat des ailes.
class ColombePainter extends CustomPainter {
  ColombePainter({this.animation, this.facingLeft = false, this.withBranch = false})
    : super(repaint: animation);

  final Animation<double>? animation;
  final bool facingLeft;
  final bool withBranch;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation?.value ?? 0.25;
    Colombe.paint(
      canvas,
      size,
      flap: 0.5 + 0.5 * math.sin(t * math.pi * 2),
      facingLeft: facingLeft,
      withBranch: withBranch,
    );
  }

  @override
  bool shouldRepaint(ColombePainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.facingLeft != facingLeft ||
      oldDelegate.withBranch != withBranch;
}

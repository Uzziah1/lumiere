import 'dart:math' as math;
import 'dart:ui';

import 'paper.dart';
import 'shapes.dart';

/// Apparence d'un personnage biblique en papier découpé.
class PersonStyle {
  const PersonStyle({
    required this.skin,
    required this.robe,
    required this.headcloth,
    this.sash = const Color(0xFFE9B949),
    this.beard,
    this.veil = false,
    this.scale = 1,
  });

  final Color skin;
  final Color robe;
  final Color headcloth;
  final Color sash;

  /// Couleur de la barbe (null : pas de barbe).
  final Color? beard;

  /// Voile long (femmes) plutôt que coiffe courte avec cordon.
  final bool veil;

  /// Taille relative (enfants, adultes).
  final double scale;
}

/// La famille de Noé (Genèse 7.13) : peaux brunes de différents tons.
abstract final class NoahFamily {
  static const noah = PersonStyle(
    skin: Color(0xFF9C6440),
    robe: Color(0xFF6E8FB8),
    headcloth: Color(0xFFF1E4CC),
    sash: Color(0xFFD9922B),
    beard: Color(0xFFF4EFE6),
  );
  static const wife = PersonStyle(
    skin: Color(0xFFA9714B),
    robe: Color(0xFFC0656B),
    headcloth: Color(0xFFF3D9A4),
    veil: true,
  );
  static const shem = PersonStyle(
    skin: Color(0xFF8A5537),
    robe: Color(0xFF5F9E7E),
    headcloth: Color(0xFFE8D6B3),
    beard: Color(0xFF3E2A1E),
    scale: 0.95,
  );
  static const ham = PersonStyle(
    skin: Color(0xFF6E4029),
    robe: Color(0xFFD08A47),
    headcloth: Color(0xFFF0E2C8),
    beard: Color(0xFF2E1E15),
    scale: 0.97,
  );
  static const japheth = PersonStyle(
    skin: Color(0xFFB47E57),
    robe: Color(0xFF8C79B5),
    headcloth: Color(0xFFEADBC0),
    beard: Color(0xFF4A3323),
    scale: 0.93,
  );
  static const daughtersInLaw = [
    PersonStyle(
      skin: Color(0xFF7D4A30),
      robe: Color(0xFFE0A35A),
      headcloth: Color(0xFFF6E7C8),
      veil: true,
      scale: 0.9,
    ),
    PersonStyle(
      skin: Color(0xFFA06A45),
      robe: Color(0xFF6FA8A3),
      headcloth: Color(0xFFF2D6B8),
      veil: true,
      scale: 0.9,
    ),
    PersonStyle(
      skin: Color(0xFF8E5A3B),
      robe: Color(0xFFB77AA6),
      headcloth: Color(0xFFF5E1C0),
      veil: true,
      scale: 0.88,
    ),
  ];

  static const all = [noah, wife, shem, ham, japheth, ...daughtersInLaw];
}

/// Dessine un personnage debout, les pieds en [feet], haut de [height] pixels
/// (avant [PersonStyle.scale]).
///
/// [wave] : 0 = bras le long du corps, 1 = bras levé (salut, joie).
/// [bob] : petit rebond vertical en pixels. [blink] : 0 ouvert, 1 fermé.
void paintPerson(
  Canvas canvas,
  Offset feet,
  double height,
  PersonStyle style, {
  double wave = 0,
  double blink = 0,
  double bob = 0,
  bool facingLeft = false,
  bool raisedBoth = false,
}) {
  final h = height * style.scale;
  canvas.save();
  canvas.translate(feet.dx, feet.dy - bob);
  if (facingLeft) canvas.scale(-1, 1);

  final robeShade = Color.lerp(style.robe, const Color(0xFF2B1A12), 0.18)!;
  final headY = -h * 0.80;
  final headR = h * 0.13;
  final shoulderY = -h * 0.66;

  // Bras arrière (derrière la robe).
  _arm(
    canvas,
    Offset(-h * 0.11, shoulderY + h * 0.03),
    h,
    raisedBoth ? wave : 0,
    robeShade,
    style.skin,
    back: true,
  );

  // Robe : un trapèze aux coins très arrondis.
  final robe = Path()
    ..moveTo(-h * 0.13, shoulderY)
    ..quadraticBezierTo(-h * 0.17, shoulderY - h * 0.02, -h * 0.19, shoulderY + h * 0.08)
    ..lineTo(-h * 0.24, -h * 0.03)
    ..quadraticBezierTo(-h * 0.24, 0, -h * 0.20, 0)
    ..lineTo(h * 0.20, 0)
    ..quadraticBezierTo(h * 0.24, 0, h * 0.24, -h * 0.03)
    ..lineTo(h * 0.19, shoulderY + h * 0.08)
    ..quadraticBezierTo(h * 0.17, shoulderY - h * 0.02, h * 0.13, shoulderY)
    ..close();
  drawPaper(canvas, robe, style.robe, elevation: h * 0.025, light: 0.14);
  // Pli central et ceinture.
  canvas.drawPath(
    Path()
      ..moveTo(h * 0.02, -h * 0.40)
      ..quadraticBezierTo(h * 0.04, -h * 0.2, h * 0.03, -h * 0.02),
    Paint()
      ..color = robeShade
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.012
      ..strokeCap = StrokeCap.round,
  );
  final sash = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(-h * 0.205, -h * 0.45, h * 0.205, -h * 0.40),
        Radius.circular(h * 0.02),
      ),
    );
  drawPaper(canvas, sash, style.sash, elevation: h * 0.008, light: 0.1);

  // Pieds.
  for (final x in [-h * 0.09, h * 0.09]) {
    drawPaper(
      canvas,
      ellipse(Offset(x, -h * 0.005), h * 0.12, h * 0.05),
      const Color(0xFF6B4630),
      elevation: h * 0.01,
      light: 0,
    );
  }

  // Voile long (derrière la tête) pour les femmes.
  if (style.veil) {
    final veil = Path()
      ..moveTo(0, headY - headR * 1.25)
      ..cubicTo(
        headR * 1.8,
        headY - headR * 1.2,
        headR * 1.6,
        headY + headR * 1.4,
        headR * 1.7,
        shoulderY + h * 0.20,
      )
      ..lineTo(-headR * 1.7, shoulderY + h * 0.20)
      ..cubicTo(-headR * 1.6, headY + headR * 1.4, -headR * 1.8, headY - headR * 1.2, 0, headY - headR * 1.25)
      ..close();
    drawPaper(canvas, veil, style.headcloth, elevation: h * 0.015, light: 0.1);
  } else {
    // Pan de la coiffe qui tombe sur les épaules.
    final drape = Path()
      ..moveTo(-headR * 1.05, headY)
      ..lineTo(-headR * 1.35, shoulderY + h * 0.07)
      ..quadraticBezierTo(0, shoulderY + h * 0.11, headR * 1.35, shoulderY + h * 0.07)
      ..lineTo(headR * 1.05, headY)
      ..close();
    drawPaper(
      canvas,
      drape,
      Color.lerp(style.headcloth, const Color(0xFF000000), 0.06)!,
      elevation: h * 0.012,
      light: 0,
    );
  }

  // Tête.
  drawPaper(canvas, circle(Offset(0, headY), headR), style.skin, elevation: h * 0.012, light: 0.1);

  // Barbe.
  if (style.beard != null) {
    final beard = Path()
      ..moveTo(-headR * 0.92, headY + headR * 0.05)
      ..quadraticBezierTo(-headR * 0.85, headY + headR * 1.25, 0, headY + headR * 1.55)
      ..quadraticBezierTo(headR * 0.85, headY + headR * 1.25, headR * 0.92, headY + headR * 0.05)
      ..quadraticBezierTo(headR * 0.5, headY + headR * 0.55, 0, headY + headR * 0.5)
      ..quadraticBezierTo(-headR * 0.5, headY + headR * 0.55, -headR * 0.92, headY + headR * 0.05)
      ..close();
    drawPaper(canvas, beard, style.beard!, elevation: h * 0.008, light: 0.08);
  }

  // Visage : yeux, joues, sourire.
  final eyeY = headY - headR * 0.08;
  final openness = 1 - blink.clamp(0.0, 1.0);
  final eyePaint = Paint()..color = const Color(0xFF2A1A12);
  for (final x in [-headR * 0.38, headR * 0.38]) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, eyeY),
        width: headR * 0.22,
        height: math.max(headR * 0.04, headR * 0.26 * openness),
      ),
      eyePaint,
    );
  }
  final blush = Paint()..color = const Color(0x55F07F7F);
  for (final x in [-headR * 0.6, headR * 0.6]) {
    canvas.drawCircle(Offset(x, eyeY + headR * 0.32), headR * 0.16, blush);
  }
  final smileY = style.beard != null ? headY + headR * 0.38 : headY + headR * 0.34;
  canvas.drawPath(
    Path()
      ..moveTo(-headR * 0.22, smileY)
      ..quadraticBezierTo(0, smileY + headR * 0.2, headR * 0.22, smileY),
    Paint()
      ..color = const Color(0xFF5A2E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = headR * 0.08
      ..strokeCap = StrokeCap.round,
  );

  // Coiffe : calotte et cordon (hommes) ou bord du voile (femmes).
  final cap = Path()
    ..moveTo(-headR * 1.08, headY + headR * 0.05)
    ..quadraticBezierTo(-headR * 1.15, headY - headR * 1.3, 0, headY - headR * 1.3)
    ..quadraticBezierTo(headR * 1.15, headY - headR * 1.3, headR * 1.08, headY + headR * 0.05)
    ..quadraticBezierTo(headR * 0.9, headY - headR * 0.55, 0, headY - headR * 0.6)
    ..quadraticBezierTo(-headR * 0.9, headY - headR * 0.55, -headR * 1.08, headY + headR * 0.05)
    ..close();
  drawPaper(canvas, cap, style.headcloth, elevation: h * 0.01, light: 0.12);
  if (!style.veil) {
    canvas.drawPath(
      Path()
        ..moveTo(-headR * 0.98, headY - headR * 0.45)
        ..quadraticBezierTo(0, headY - headR * 0.85, headR * 0.98, headY - headR * 0.45),
      Paint()
        ..color = style.sash
        ..style = PaintingStyle.stroke
        ..strokeWidth = headR * 0.16
        ..strokeCap = StrokeCap.round,
    );
  }

  // Bras avant (celui qui salue).
  _arm(canvas, Offset(h * 0.12, shoulderY + h * 0.03), h, wave, style.robe, style.skin);

  canvas.restore();
}

void _arm(
  Canvas canvas,
  Offset shoulder,
  double h,
  double wave,
  Color sleeve,
  Color skin, {
  bool back = false,
}) {
  // Au repos le bras pend (angle ≈ 90° vers le bas) ; levé, il monte en diagonale.
  final rest = back ? math.pi * 0.56 : math.pi * 0.44;
  final up = back ? -math.pi * 0.25 - math.pi * 0.5 : -math.pi * 0.25;
  final a = rest + (up - rest) * wave.clamp(0.0, 1.0);
  final length = h * 0.30;
  final hand = shoulder + Offset(math.cos(a), math.sin(a)) * length;
  drawPaper(canvas, capsule(shoulder, hand, h * 0.045), sleeve, elevation: h * 0.012, light: 0.1);
  drawPaper(canvas, circle(hand, h * 0.04), skin, elevation: h * 0.008, light: 0.1);
}

import 'dart:math' as math;
import 'dart:ui';

import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../theme/palette.dart';

/// Personnages et décors partagés par les histoires des héros de la foi.
abstract final class Heroes {
  static const joshua = PersonStyle(
    skin: Color(0xFF8E5A3B),
    robe: Color(0xFF3A7CA5),
    headcloth: Color(0xFFF0E2C8),
    sash: Color(0xFFB0413E),
    beard: Color(0xFF4A3323),
  );

  static const priest = PersonStyle(
    skin: Color(0xFFA06A45),
    robe: Color(0xFFF5EEE0),
    headcloth: Color(0xFFF5EEE0),
    sash: Color(0xFF3A7CA5),
    beard: Color(0xFF2E1E15),
  );

  /// Le peuple d'Israël : quelques tenues qui alternent.
  static const people = [
    PersonStyle(
      skin: Color(0xFF7D4A30),
      robe: Color(0xFF9C7A54),
      headcloth: Color(0xFFE6D8BE),
      beard: Color(0xFF2E1E15),
    ),
    PersonStyle(skin: Color(0xFFA06A45), robe: Color(0xFFB0413E), headcloth: Color(0xFFF0E2C8), veil: true),
    PersonStyle(
      skin: Color(0xFF8E5A3B),
      robe: Color(0xFF2F8F6E),
      headcloth: Color(0xFFE9B949),
      beard: Color(0xFF4A3323),
    ),
    PersonStyle(skin: Color(0xFF9C6440), robe: Color(0xFF8C79B5), headcloth: Color(0xFFF5EEE0), veil: true),
    PersonStyle(
      skin: Color(0xFF6E4029),
      robe: Color(0xFFE07A3F),
      headcloth: Color(0xFF2E1E15),
      bareHead: true,
      scale: 0.7,
    ),
    PersonStyle(
      skin: Color(0xFFA9714B),
      robe: Color(0xFF3A7CA5),
      headcloth: Color(0xFFF0E2C8),
      beard: Color(0xFFBDB5A8),
    ),
  ];
}

/// Une rangée de personnes, pieds sur la ligne [fy].
void paintPeople(
  Canvas canvas,
  Size s,
  double time, {
  double from = 0.05,
  double to = 0.4,
  double fy = 0.92,
  double h = 0.3,
  int count = 5,
  double wave = 0,
  bool raised = false,
  int offset = 0,
  bool facingLeft = false,
  double bob = 0,
}) {
  for (var i = 0; i < count; i++) {
    final fx = count == 1 ? from : from + (to - from) * i / (count - 1);
    paintPerson(
      canvas,
      feetAt(s, fx, fy + (i.isOdd ? 0.015 : 0)),
      s.height * h,
      Heroes.people[(i + offset) % Heroes.people.length],
      wave: wave > 0 ? wave * (0.7 + 0.3 * math.sin(time * 3 + i)) : 0,
      raisedBoth: raised,
      facingLeft: facingLeft,
      bob: bob > 0 ? (math.sin(time * 8 + i)).abs() * bob * s.height : 0,
      blink: blinkAt(time, i * 1.3 + offset),
    );
  }
}

/// L'arche de l'alliance : un coffre doré porté sur deux barres, deux ailes dessus.
void paintCovenantArk(Canvas canvas, Offset center, double w) {
  final h = w * 0.5;
  canvas.drawCircle(
    center,
    w * 0.7,
    Paint()
      ..color = Palette.sun.withValues(alpha: 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.2),
  );
  canvas.drawLine(
    center + Offset(-w * 0.9, h * 0.1),
    center + Offset(w * 0.9, h * 0.1),
    Paint()
      ..color = const Color(0xFF8A5A36)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round,
  );
  drawPaper(
    canvas,
    Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        Radius.circular(w * 0.04),
      ),
    ),
    const Color(0xFFE9B949),
    elevation: 3,
    light: 0.3,
  );
  for (final side in [-1.0, 1.0]) {
    final wing = Path()
      ..moveTo(center.dx + side * w * 0.08, center.dy - h * 0.5)
      ..quadraticBezierTo(
        center.dx + side * w * 0.42,
        center.dy - h * 1.3,
        center.dx + side * w * 0.04,
        center.dy - h * 1.1,
      )
      ..close();
    drawPaper(canvas, wing, const Color(0xFFF2C14E), elevation: 2, light: 0.3);
  }
}

/// Une cité fortifiée : maisons derrière une haute muraille ([fall] : 0 debout, 1 écroulée).
void paintWalledCity(Canvas canvas, Size s, double time, {double fall = 0, double horizon = 0.7}) {
  for (final (fx, h) in [(0.3, 0.26), (0.44, 0.32), (0.58, 0.28), (0.72, 0.24)]) {
    paintThing(canvas, 'city', boxAt(s, fx, horizon - 0.16 + fall * 0.06, h, aspect: 1.2));
  }
  for (var k = 0; k < 6; k++) {
    final fx = 0.2 + k * 0.12;
    final drop = fall * (0.03 + (k % 3) * 0.015);
    paintThing(canvas, 'wall', boxAt(s, fx, horizon + drop, 0.32, aspect: 0.75), glow: fall);
  }
}

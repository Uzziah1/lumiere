import 'dart:math' as math;
import 'dart:ui';

/// Une colline : son contour (fermé jusqu'en bas) et sa hauteur en tout point,
/// pour y poser palmiers et maisons. Déterministe : même graine, même colline.
class Hill {
  Hill({
    required this.size,
    required this.baseline,
    required this.amplitude,
    required this.seed,
    this.waves = 2.2,
    this.overscan = 48,
  }) {
    final random = math.Random(seed);
    _phases = List.generate(3, (_) => random.nextDouble() * math.pi * 2);
    path = _buildPath();
  }

  final Size size;

  /// Hauteur moyenne de la crête, en pixels depuis le haut.
  final double baseline;
  final double amplitude;
  final int seed;
  final double waves;

  /// Marge à gauche et à droite pour pouvoir faire onduler la colline sans trou.
  final double overscan;

  late final List<double> _phases;
  late final Path path;

  /// Y de la crête à l'abscisse [x].
  double heightAt(double x) {
    final t = x / size.width * waves * math.pi * 2;
    final wave =
        0.6 * math.sin(t + _phases[0]) +
        0.28 * math.sin(t * 2.3 + _phases[1]) +
        0.12 * math.sin(t * 5.1 + _phases[2]);
    return baseline - amplitude * wave;
  }

  Path _buildPath() {
    const steps = 36;
    final left = -overscan;
    final width = size.width + overscan * 2;
    final points = [
      for (var i = 0; i <= steps; i++) Offset(left + width * i / steps, heightAt(left + width * i / steps)),
    ];
    final path = Path()
      ..moveTo(left, size.height + 20)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final mid = Offset.lerp(points[i], points[i + 1], 0.5)!;
      path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
    }
    path
      ..lineTo(points.last.dx, points.last.dy)
      ..lineTo(left + width, size.height + 20)
      ..close();
    return path;
  }
}

/// Un palmier en papier : tronc légèrement courbé et palmes tombantes.
Path palmPath(Offset base, double height, {double lean = 0.12}) {
  final top = base + Offset(lean * height, -height);
  final bend = base + Offset(lean * height * 0.2, -height * 0.55);
  final w = height * 0.045;
  final trunk = Path()
    ..moveTo(base.dx - w, base.dy)
    ..quadraticBezierTo(bend.dx - w * 0.8, bend.dy, top.dx - w * 0.45, top.dy)
    ..lineTo(top.dx + w * 0.45, top.dy)
    ..quadraticBezierTo(bend.dx + w * 0.8, bend.dy, base.dx + w, base.dy)
    ..close();

  var crown = Path()..addOval(Rect.fromCircle(center: top, radius: w * 1.2));
  const angles = [-172.0, -140.0, -112.0, -68.0, -40.0, -8.0];
  for (final degrees in angles) {
    final a = degrees * math.pi / 180;
    final length = height * (0.36 + 0.06 * math.cos(a * 3));
    final dir = Offset(math.cos(a), math.sin(a));
    final normal = Offset(-dir.dy, dir.dx);
    // Les palmes montent puis retombent.
    final tip = top + dir * length + Offset(0, length * 0.42);
    final mid = top + dir * (length * 0.55) + Offset(0, -length * 0.08);
    final leaf = Path()
      ..moveTo(top.dx, top.dy)
      ..quadraticBezierTo(
        (mid + normal * length * 0.13).dx,
        (mid + normal * length * 0.13).dy,
        tip.dx,
        tip.dy,
      )
      ..quadraticBezierTo(
        (mid - normal * length * 0.09).dx,
        (mid - normal * length * 0.09).dy,
        top.dx,
        top.dy,
      )
      ..close();
    crown = Path.combine(PathOperation.union, crown, leaf);
  }
  return Path.combine(PathOperation.union, trunk, crown);
}

/// Une petite maison à toit plat, comme dans les villages de la Bible.
/// Renvoie le mur ; la porte et la fenêtre sont dans [houseOpenings].
Path housePath(Offset base, double width, double height) {
  final r = width * 0.08;
  return Path()..addRRect(
    RRect.fromRectAndCorners(
      Rect.fromLTWH(base.dx - width / 2, base.dy - height, width, height + 6),
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
    ),
  );
}

Path houseOpenings(Offset base, double width, double height) {
  final doorW = width * 0.26;
  final doorH = height * 0.48;
  final door = Rect.fromLTWH(base.dx - doorW / 2 + width * 0.12, base.dy - doorH, doorW, doorH);
  final window = Rect.fromLTWH(base.dx - width * 0.32, base.dy - height * 0.72, width * 0.18, width * 0.16);
  return Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        door,
        topLeft: Radius.circular(doorW / 2),
        topRight: Radius.circular(doorW / 2),
      ),
    )
    ..addRRect(RRect.fromRectAndRadius(window, Radius.circular(width * 0.04)));
}

/// Un nuage en papier : quelques bosses rondes sur une base plate.
Path cloudPath(Offset center, double width) {
  final h = width * 0.42;
  final bottom = center.dy + h * 0.35;
  var path = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(center.dx - width / 2, bottom - h * 0.4, center.dx + width / 2, bottom),
        Radius.circular(h * 0.2),
      ),
    );
  final bumps = [
    (Offset(center.dx - width * 0.24, bottom - h * 0.38), h * 0.34),
    (Offset(center.dx - width * 0.02, bottom - h * 0.58), h * 0.48),
    (Offset(center.dx + width * 0.24, bottom - h * 0.40), h * 0.36),
  ];
  for (final (c, r) in bumps) {
    path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: c, radius: r)));
  }
  return path;
}

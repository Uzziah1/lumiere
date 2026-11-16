import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// Petites formes de base pour dessiner en papier découpé.
Path circle(Offset c, double r) => Path()..addOval(Rect.fromCircle(center: c, radius: r));

Path ellipse(Offset c, double w, double h) =>
    Path()..addOval(Rect.fromCenter(center: c, width: w, height: h));

/// Un « boudin » arrondi entre [a] et [b] (bras, jambes, cou…).
Path capsule(Offset a, Offset b, double r) {
  final d = b - a;
  final length = d.distance;
  final angle = math.atan2(d.dy, d.dx);
  final path = Path()
    ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-r, -r, length + r * 2, r * 2), Radius.circular(r)));
  final m = Matrix4Lite.rotationTranslation(angle, a);
  return path.transform(m.storage);
}

/// Union de plusieurs formes (évite les trous quand elles se chevauchent).
Path unite(Iterable<Path> paths) {
  Path? result;
  for (final p in paths) {
    result = result == null ? p : Path.combine(PathOperation.union, result, p);
  }
  return result ?? Path();
}

/// Matrice 4×4 minimale (rotation puis translation) pour `Path.transform`.
class Matrix4Lite {
  Matrix4Lite.rotationTranslation(double angle, Offset t)
    : storage = Float64List.fromList([
        math.cos(angle), math.sin(angle), 0, 0, //
        -math.sin(angle), math.cos(angle), 0, 0, //
        0, 0, 1, 0, //
        t.dx, t.dy, 0, 1,
      ]);

  final Float64List storage;
}

/// Transforme un dessin conçu dans une boîte [design] pour qu'il tienne dans
/// [box] (proportions gardées, posé en bas et centré), éventuellement retourné.
void fitBox(Canvas canvas, Rect box, Size design, {bool flip = false}) {
  final s = math.min(box.width / design.width, box.height / design.height);
  canvas.translate(box.center.dx, box.bottom);
  canvas.scale(flip ? -s : s, s);
  canvas.translate(-design.width / 2, -design.height);
}

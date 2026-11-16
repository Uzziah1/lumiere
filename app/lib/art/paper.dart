import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../theme/palette.dart';

/// Dessine une forme en « papier découpé » : une ombre portée douce sous la
/// forme, puis un aplat très légèrement éclairci vers le haut, comme une feuille
/// de papier posée sur une autre.
void drawPaper(
  Canvas canvas,
  Path path,
  Color color, {
  double elevation = 6,
  Color shadow = Palette.shadow,
  double light = 0.12,
}) {
  if (elevation > 0) {
    canvas.drawPath(
      path.shift(Offset(0, elevation * 0.55)),
      Paint()
        ..color = shadow
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, elevation * 0.75),
    );
  }
  final bounds = path.getBounds();
  final paint = Paint()..color = color;
  if (light > 0 && bounds.height > 1) {
    paint.shader = Gradient.linear(
      bounds.topCenter,
      bounds.bottomCenter,
      [Color.lerp(color, const Color(0xFFFFFFFF), light)!, color],
      const [0, 0.65],
    );
  }
  canvas.drawPath(path, paint);
}

/// Grain de papier : des milliers de points clairs et sombres, dessinés une
/// seule fois dans une image (une texture, donc presque gratuite à afficher).
class PaperGrain {
  PaperGrain({this.seed = 7, this.density = 0.010, this.opacity = 0.06});

  final int seed;
  final double density;
  final double opacity;

  Image? _image;
  Size? _size;

  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (_image == null || _size != size) {
      _image?.dispose();
      _image = _render(size);
      _size = size;
    }
    canvas.drawImage(_image!, Offset.zero, Paint());
  }

  Image _render(Size size) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final random = math.Random(seed);
    // Deux nombres (x, y) par point : la longueur doit être paire.
    final count = (size.width * size.height * density).clamp(0, 60000).toInt() & ~1;
    final light = Float32List(count);
    final dark = Float32List(count);
    for (var i = 0; i < count; i += 2) {
      light[i] = random.nextDouble() * size.width;
      light[i + 1] = random.nextDouble() * size.height;
      dark[i] = random.nextDouble() * size.width;
      dark[i + 1] = random.nextDouble() * size.height;
    }
    final alpha = (opacity * 255).round();
    canvas.drawRawPoints(
      PointMode.points,
      light,
      Paint()
        ..color = Color.fromARGB(alpha, 255, 255, 255)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRawPoints(
      PointMode.points,
      dark,
      Paint()
        ..color = Color.fromARGB(alpha, 90, 36, 18)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    final picture = recorder.endRecording();
    final image = picture.toImageSync(size.width.ceil(), size.height.ceil());
    picture.dispose();
    return image;
  }

  void dispose() {
    _image?.dispose();
    _image = null;
  }
}

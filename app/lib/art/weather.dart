import 'dart:math' as math;
import 'dart:ui';

import 'paper.dart';

/// Vagues en couches de papier, du fond vers l'avant.
///
/// [level] : hauteur de la surface (Y en pixels). [time] fait onduler l'eau.
void paintWaves(
  Canvas canvas,
  Size size,
  double level,
  double time, {
  List<Color>? colors,
  int from = 0,
  int? to,
}) {
  final layers = colors ?? const [Color(0xFF6CB8D4), Color(0xFF4FA3C7), Color(0xFF3A8DB8), Color(0xFF2E78A3)];
  final end = to ?? layers.length;
  for (var i = from; i < end; i++) {
    final y = level + i * size.height * 0.035;
    final amp = size.height * (0.012 + i * 0.004);
    final wavelength = size.width / (2.5 + i * 0.6);
    final phase = time * (0.8 + i * 0.35) * (i.isEven ? 1 : -1);
    final path = Path()..moveTo(-20, size.height + 10);
    for (var x = -20.0; x <= size.width + 20; x += 8) {
      path.lineTo(x, y + math.sin(x / wavelength * math.pi * 2 + phase + i) * amp);
    }
    path
      ..lineTo(size.width + 20, size.height + 10)
      ..close();
    drawPaper(canvas, path, layers[i], elevation: 3 + i * 1.5, light: 0.12);
  }
}

/// Pluie : des traits qui tombent en biais, recyclés en haut de l'écran.
class RainField {
  RainField({this.count = 90, int seed = 4}) : _random = math.Random(seed);

  final int count;
  final math.Random _random;
  final _drops = <_Drop>[];
  Size _size = Size.zero;

  /// 0 = pas de pluie, 1 = averse.
  double intensity = 1;

  void resize(Size size) {
    if (size == _size) return;
    _size = size;
    _drops
      ..clear()
      ..addAll([
        for (var i = 0; i < count; i++)
          _Drop(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
            0.6 + _random.nextDouble() * 0.6,
          ),
      ]);
  }

  void update(double dt) {
    for (final d in _drops) {
      d.y += _size.height * 1.1 * d.speed * dt;
      d.x -= _size.height * 0.18 * d.speed * dt;
      if (d.y > _size.height) {
        d.y = -20;
        d.x = _random.nextDouble() * (_size.width + 80);
      }
    }
  }

  void paint(Canvas canvas) {
    if (intensity <= 0) return;
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final shown = (count * intensity.clamp(0.0, 1.0)).round();
    final len = _size.height * 0.035;
    for (var i = 0; i < shown; i++) {
      final d = _drops[i];
      paint.color = Color.fromARGB((140 * d.speed).round().clamp(0, 255), 214, 236, 248);
      canvas.drawLine(Offset(d.x, d.y), Offset(d.x + len * 0.18, d.y - len * d.speed), paint);
    }
  }
}

class _Drop {
  _Drop(this.x, this.y, this.speed);

  double x;
  double y;
  final double speed;
}

/// Les couleurs de l'arc-en-ciel, de l'extérieur vers l'intérieur.
const rainbowColors = [
  Color(0xFFE85A5A),
  Color(0xFFF29A45),
  Color(0xFFF5D04E),
  Color(0xFF7CC66B),
  Color(0xFF4FA8D8),
  Color(0xFF6C7BD0),
  Color(0xFFA77BCB),
];

/// Arc-en-ciel en bandes de papier, centré en [center] (le pied de l'arc).
/// [progress] dévoile l'arc de gauche à droite ; [bands] limite le nombre de
/// bandes colorées (les autres sont des pointillés à colorier).
void paintRainbow(
  Canvas canvas,
  Offset center,
  double radius,
  double width, {
  double progress = 1,
  int? bands,
  double opacity = 1,
}) {
  final n = rainbowColors.length;
  final band = width / n;
  final sweep = math.pi * progress.clamp(0.0, 1.0);
  for (var i = 0; i < n; i++) {
    final r = radius - i * band - band / 2;
    final rect = Rect.fromCircle(center: center, radius: r);
    final colored = bands == null || i < bands;
    if (colored && sweep > 0) {
      final paint = Paint()
        ..color = rainbowColors[i].withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = band * 1.02
        ..strokeCap = StrokeCap.butt;
      if (i == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center + Offset(0, band * 0.35), radius: radius - width / 2),
          math.pi,
          sweep,
          false,
          Paint()
            ..color = const Color(0x1F4A2A1A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, band * 0.4),
        );
      }
      canvas.drawArc(rect, math.pi, sweep, false, paint);
    } else if (!colored) {
      final paint = Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = band * 0.25
        ..strokeCap = StrokeCap.round;
      const dashes = 24;
      for (var d = 0; d < dashes; d++) {
        canvas.drawArc(rect, math.pi + d * math.pi / dashes, math.pi / dashes * 0.5, false, paint);
      }
    }
  }
}

/// La présence de Dieu : jamais un personnage, seulement une lumière qui descend
/// du ciel, avec des rayons et un cœur très clair.
void paintHeavenlyLight(Canvas canvas, Size size, Offset origin, double time, {double intensity = 1}) {
  final i = intensity.clamp(0.0, 1.5);
  final reach = size.height * 1.1;
  canvas.save();
  canvas.translate(origin.dx, origin.dy);
  const rays = 9;
  for (var k = 0; k < rays; k++) {
    final base = math.pi / 2 + (k - (rays - 1) / 2) * 0.16 + math.sin(time * 0.6 + k) * 0.02;
    final spread = 0.035 + 0.01 * math.sin(time + k * 2);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(math.cos(base - spread) * reach, math.sin(base - spread) * reach)
      ..lineTo(math.cos(base + spread) * reach, math.sin(base + spread) * reach)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = Gradient.radial(Offset.zero, reach, [
          Color.fromRGBO(255, 248, 220, 0.55 * i),
          const Color.fromRGBO(255, 248, 220, 0),
        ]),
    );
  }
  final glow = size.shortestSide * (0.28 + 0.03 * math.sin(time * 1.4)) * (0.6 + 0.4 * i);
  canvas.drawCircle(
    Offset.zero,
    glow,
    Paint()
      ..shader = Gradient.radial(
        Offset.zero,
        glow,
        [
          Color.fromRGBO(255, 253, 240, 0.95 * math.min(1, i)),
          Color.fromRGBO(255, 226, 150, 0.45 * math.min(1, i)),
          const Color.fromRGBO(255, 226, 150, 0),
        ],
        const [0, 0.35, 1],
      ),
  );
  canvas.restore();
}

/// Une montagne en papier (le mont Ararat), posée sur [baseY].
Path mountainPath(Size size, double baseY, {double peakX = 0.5, double height = 0.4, double width = 0.8}) {
  final w = size.width * width;
  final h = size.height * height;
  final px = size.width * peakX;
  return Path()
    ..moveTo(px - w / 2, baseY)
    ..quadraticBezierTo(px - w * 0.22, baseY - h * 0.55, px - w * 0.08, baseY - h * 0.95)
    ..quadraticBezierTo(px, baseY - h * 1.06, px + w * 0.08, baseY - h * 0.95)
    ..quadraticBezierTo(px + w * 0.25, baseY - h * 0.5, px + w / 2, baseY)
    ..close();
}

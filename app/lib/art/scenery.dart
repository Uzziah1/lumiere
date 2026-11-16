import 'dart:math' as math;
import 'dart:ui';

import '../theme/palette.dart';
import 'landscape.dart';
import 'paper.dart';
import 'weather.dart';

/// Petits outils de décor partagés par les scènes des histoires.

/// Palettes de ciel.
abstract final class Skies {
  static const day = [Color(0xFF9FD3E8), Color(0xFFCDE8EE), Color(0xFFFFF1D6)];
  static const dawn = [Color(0xFFFF9C7A), Color(0xFFFFC498), Color(0xFFFFE6BE)];
  static const dusk = [Color(0xFF3E4C7A), Color(0xFF8A6F9E), Color(0xFFF2B98A)];
  static const night = [Color(0xFF141C3A), Color(0xFF26335E), Color(0xFF3F4E80)];
  static const storm = [Color(0xFF4F5E78), Color(0xFF7C8BA0), Color(0xFFAAB7C4)];
  static const desert = [Color(0xFF8CCFE6), Color(0xFFE6EEDD), Color(0xFFFFE3B0)];
  static const sea = [Color(0xFF7EC3E6), Color(0xFFBFE3F0), Color(0xFFFFF4DC)];
}

/// Palettes de collines (du fond vers l'avant).
abstract final class Lands {
  static const green = [Color(0xFFD8CF98), Color(0xFFB9C47F), Color(0xFF97AE67), Color(0xFF768F4F)];
  static const lush = [Color(0xFFB6D98A), Color(0xFF8DC26A), Color(0xFF6FA84F), Color(0xFF558C3C)];
  static const desert = [Color(0xFFF0D29A), Color(0xFFE4BC7C), Color(0xFFD3A466), Color(0xFFBE8C52)];
  static const night = [Color(0xFF3A4A6E), Color(0xFF2E3C5C), Color(0xFF243049), Color(0xFF1B2539)];
}

void paintSkyGradient(Canvas canvas, Size size, List<Color> colors) {
  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = Gradient.linear(Offset.zero, Offset(0, size.height), colors, [
        for (var i = 0; i < colors.length; i++) i / (colors.length - 1),
      ]),
  );
}

final _hillCache = <String, Hill>{};

/// Une colline (mise en cache) dont la crête est à [baseline] (part de la hauteur).
Hill hillFor(Size size, double baseline, int seed, {double amplitude = 0.05, double waves = 1.8}) {
  final key = '${size.width.round()}x${size.height.round()}/$baseline/$seed/$amplitude/$waves';
  if (_hillCache.length > 200) _hillCache.clear();
  return _hillCache[key] ??= Hill(
    size: size,
    baseline: size.height * baseline,
    amplitude: size.height * amplitude,
    seed: seed,
    waves: waves,
  );
}

/// Plusieurs rangées de collines en papier, qui ondulent doucement.
void paintHills(
  Canvas canvas,
  Size size,
  double time, {
  List<double> baselines = const [0.62, 0.72, 0.84],
  List<Color> colors = Lands.green,
  int seed = 1,
}) {
  for (var i = 0; i < baselines.length; i++) {
    final hill = hillFor(size, baselines[i], seed + i * 7, amplitude: 0.05 - i * 0.01, waves: 1.4 + i * 0.5);
    canvas.save();
    canvas.translate(math.sin(time * 0.2 + i) * (1 + i * 1.5), 0);
    drawPaper(canvas, hill.path, colors[i % colors.length], elevation: 3 + i * 2, light: 0.1);
    canvas.restore();
  }
}

/// Hauteur du sol (Y) d'une rangée de collines à l'abscisse relative [fx].
double groundAt(Size size, double baseline, int seed, double fx, {int row = 0}) {
  final hill = hillFor(size, baseline, seed + row * 7, amplitude: 0.05 - row * 0.01, waves: 1.4 + row * 0.5);
  return hill.heightAt(size.width * fx);
}

void paintSun(Canvas canvas, Offset c, double r, {Color color = Palette.sun, double halo = 1}) {
  if (halo > 0) {
    canvas.drawCircle(
      c,
      r * 2.4,
      Paint()
        ..shader = Gradient.radial(c, r * 2.4, [
          Palette.sunHalo.withValues(alpha: 0.55 * halo),
          Palette.sunHalo.withValues(alpha: 0),
        ]),
    );
  }
  canvas.drawCircle(c, r, Paint()..color = color);
}

/// Des nuages qui dérivent.
void paintClouds(
  Canvas canvas,
  Size size,
  double time, {
  int count = 3,
  Color color = Palette.cloud,
  double top = 0.1,
}) {
  for (var i = 0; i < count; i++) {
    final fx = (i * 0.37 + 0.12) % 1;
    final x = (fx * size.width + time * (6 + i * 3)) % (size.width + 200) - 100;
    canvas.save();
    canvas.translate(x, size.height * (top + (i % 3) * 0.06));
    drawPaper(
      canvas,
      cloudPath(Offset.zero, size.width * (0.12 + (i % 2) * 0.05)),
      color,
      elevation: 4,
      light: 0.3,
    );
    canvas.restore();
  }
}

/// Étoiles qui scintillent dans un ciel de nuit (zone : haut de l'écran).
void paintStarField(
  Canvas canvas,
  Size size,
  double time, {
  int count = 50,
  double area = 0.6,
  double opacity = 1,
  int seed = 8,
}) {
  final random = math.Random(seed);
  final paint = Paint();
  for (var i = 0; i < count; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height * area;
    final twinkle = 0.5 + 0.5 * math.sin(time * 2 + i);
    paint.color = Color.fromRGBO(255, 246, 220, (0.5 + 0.5 * twinkle) * opacity);
    canvas.drawCircle(Offset(x, y), (1 + twinkle * 1.4) * size.height / 600, paint);
  }
}

/// Mer en couches (fond puis avant) : appeler avec [front] faux puis vrai.
void paintSea(Canvas canvas, Size size, double level, double time, {bool front = false}) {
  paintWaves(canvas, size, level, time, from: front ? 2 : 0, to: front ? 4 : 2);
}

/// Rect d'un objet posé en bas au point relatif ([fx], [fy]), haut de [h] (part de la hauteur).
Rect boxAt(Size size, double fx, double fy, double h, {double aspect = 1}) {
  final hh = size.height * h;
  final w = hh * aspect;
  return Rect.fromLTWH(size.width * fx - w / 2, size.height * fy - hh, w, hh);
}

/// Pieds d'un personnage au point relatif.
Offset feetAt(Size size, double fx, double fy) => Offset(size.width * fx, size.height * fy);

/// Clignement des yeux régulier, décalé par [phase].
double blinkAt(double time, double phase) => ((time + phase) % 3.7) < 0.14 ? 1 : 0;

import 'dart:math' as math;
import 'dart:ui';

import '../../art/animals.dart';
import '../../art/ark.dart';
import '../../art/colombe.dart';
import '../../art/landscape.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/weather.dart';
import '../../theme/palette.dart';
import '../registry.dart';

void _sky(Canvas canvas, Size s, List<Color> colors) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()..shader = Gradient.linear(Offset.zero, Offset(0, s.height), colors),
  );
}

Rect _ark(Size s, double cx, double bottom, double width) {
  final w = s.width * width;
  final h = w / Ark.aspectRatio;
  return Rect.fromLTWH(s.width * cx - w / 2, s.height * bottom - h, w, h);
}

/// Vignettes de la chronologie de Noé.
void paintNoeThumb(Canvas canvas, Size s, String id) {
  const day = [Color(0xFF9FD3E8), Color(0xFFFFF1D6)];
  switch (id) {
    case 'build':
      _sky(canvas, s, day);
      drawPaper(
        canvas,
        Hill(size: s, baseline: s.height * 0.82, amplitude: s.height * 0.04, seed: 3).path,
        const Color(0xFFB9C47F),
        elevation: 2,
      );
      Ark.paint(canvas, _ark(s, 0.6, 0.86, 0.66), build: 0.65);
      paintPerson(
        canvas,
        Offset(s.width * 0.16, s.height * 0.97),
        s.height * 0.5,
        NoahFamily.noah,
        wave: 0.8,
      );
    case 'animals':
      _sky(canvas, s, day);
      drawPaper(
        canvas,
        Hill(size: s, baseline: s.height * 0.84, amplitude: s.height * 0.03, seed: 5).path,
        const Color(0xFFB9C47F),
        elevation: 2,
      );
      Ark.paint(canvas, _ark(s, 0.66, 0.86, 0.62), door: 1);
      paintAnimal(
        canvas,
        Animal.giraffe,
        Rect.fromLTWH(s.width * 0.02, s.height * 0.42, s.height * 0.5, s.height * 0.5),
      );
      paintAnimal(
        canvas,
        Animal.elephant,
        Rect.fromLTWH(s.width * 0.16, s.height * 0.6, s.height * 0.36, s.height * 0.36),
      );
    case 'rain':
      _sky(canvas, s, const [Color(0xFF55657E), Color(0xFFAAB7C4)]);
      paintWaves(canvas, s, s.height * 0.68, 0.4, to: 2);
      Ark.paint(canvas, _ark(s, 0.5, 0.78, 0.62));
      paintWaves(canvas, s, s.height * 0.68, 0.4, from: 2);
      final rain = Paint()
        ..color = const Color(0x99D6ECF8)
        ..strokeWidth = math.max(1, s.width * 0.008)
        ..strokeCap = StrokeCap.round;
      final random = math.Random(2);
      for (var i = 0; i < 26; i++) {
        final x = random.nextDouble() * s.width;
        final y = random.nextDouble() * s.height * 0.9;
        canvas.drawLine(Offset(x, y), Offset(x + s.width * 0.01, y - s.height * 0.07), rain);
      }
    case 'dove':
      _sky(canvas, s, const [Color(0xFF8EC5E0), Color(0xFFFDF0D8)]);
      paintWaves(canvas, s, s.height * 0.76, 0.2);
      Ark.paint(canvas, _ark(s, 0.28, 0.82, 0.42), window: 1);
      final h = s.height * 0.42;
      canvas.save();
      canvas.translate(s.width * 0.42, s.height * 0.12);
      Colombe.paint(canvas, Size(h * Colombe.aspectRatio, h), flap: 0.9, facingLeft: true, withBranch: true);
      canvas.restore();
    case 'rainbow':
      _sky(canvas, s, const [Color(0xFF7EC3E6), Color(0xFFFFF4DC)]);
      paintRainbow(canvas, Offset(s.width * 0.5, s.height * 0.92), s.height * 0.78, s.height * 0.26);
      drawPaper(
        canvas,
        mountainPath(s, s.height, peakX: 0.5, height: 0.36, width: 0.7),
        const Color(0xFF8FA07E),
        elevation: 2,
      );
      Ark.paint(canvas, _ark(s, 0.5, 0.7, 0.34), door: 1);
  }
}

/// L'autocollant « L'arche de Noé » : arc-en-ciel et arche, dans un cercle.
void paintNoeSticker(Canvas canvas, Size s) {
  final c = s.center(Offset.zero);
  final r = s.shortestSide / 2;
  canvas.drawCircle(
    c + Offset(0, r * 0.05),
    r * 0.98,
    Paint()
      ..color = Palette.shadow
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.06),
  );
  canvas.drawCircle(c, r * 0.98, Paint()..color = const Color(0xFFFFFFFF));
  canvas.save();
  canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.9)));
  final inner = Size(r * 1.8, r * 1.8);
  canvas.translate(c.dx - r * 0.9, c.dy - r * 0.9);
  _sky(canvas, inner, const [Color(0xFF7EC3E6), Color(0xFFFFF4DC)]);
  paintRainbow(canvas, Offset(inner.width / 2, inner.height * 0.78), inner.width * 0.46, inner.width * 0.16);
  paintWaves(canvas, inner, inner.height * 0.72, 0.3, to: 2);
  Ark.paint(canvas, _ark(inner, 0.5, 0.84, 0.66), window: 1);
  paintWaves(canvas, inner, inner.height * 0.78, 0.9, from: 2);
  final h = inner.height * 0.18;
  canvas.translate(inner.width * 0.62, inner.height * 0.12);
  Colombe.paint(canvas, Size(h * Colombe.aspectRatio, h), flap: 0.9, facingLeft: true, withBranch: true);
  canvas.restore();
  // Reflet brillant.
  canvas.drawArc(
    Rect.fromCircle(center: c, radius: r * 0.82),
    math.pi * 1.1,
    math.pi * 0.35,
    false,
    Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round,
  );
}

/// L'intérieur de l'arche, où des animaux se sont cachés.
class ArkInterior implements SeekScene {
  @override
  double get aspectRatio => 16 / 9;

  @override
  Map<String, (Offset, double)> get spots => const {
    'dove': (Offset(0.17, 0.205), 0.12),
    'sheep': (Offset(0.29, 0.73), 0.24),
    'rabbit': (Offset(0.56, 0.76), 0.15),
    'tortoise': (Offset(0.86, 0.86), 0.13),
    'mouse': (Offset(0.665, 0.565), 0.07),
    'owl': (Offset(0.84, 0.19), 0.15),
    'snail': (Offset(0.44, 0.42), 0.075),
    'ladybug': (Offset(0.635, 0.345), 0.055),
  };

  @override
  void paintItem(Canvas canvas, String id, Rect box) => paintAnimal(canvas, Animal.byName(id), box);

  @override
  void paintBackground(Canvas canvas, Size s) {
    // Mur de planches.
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = Gradient.linear(Offset.zero, Offset(0, s.height), const [
          Color(0xFF8A5634),
          Color(0xFFB57B4E),
        ]),
    );
    final seam = Paint()
      ..color = const Color(0x553E2214)
      ..strokeWidth = math.max(1, s.width * 0.002);
    for (var x = 0.0; x < s.width; x += s.width / 14) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), seam);
    }
    // Fenêtre et pluie.
    final window = Rect.fromLTWH(s.width * 0.58, s.height * 0.12, s.width * 0.14, s.height * 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(window, Radius.circular(s.width * 0.01)),
      Paint()..color = const Color(0xFF7C93AD),
    );
    final drop = Paint()
      ..color = const Color(0x99E6F2FA)
      ..strokeWidth = math.max(1, s.width * 0.002);
    final random = math.Random(4);
    for (var i = 0; i < 14; i++) {
      final x = window.left + random.nextDouble() * window.width;
      final y = window.top + random.nextDouble() * window.height * 0.8;
      canvas.drawLine(Offset(x, y), Offset(x - s.width * 0.004, y + s.height * 0.03), drop);
    }
    drawPaper(
      canvas,
      Path()..addRect(
        Rect.fromLTWH(
          window.left - s.width * 0.01,
          window.bottom,
          window.width + s.width * 0.02,
          s.height * 0.025,
        ),
      ),
      Ark.woodDark,
      elevation: 2,
    );
    // Poutres.
    for (final y in [0.08, 0.27]) {
      drawPaper(
        canvas,
        Path()..addRect(Rect.fromLTWH(0, s.height * y, s.width, s.height * 0.05)),
        Ark.woodDark,
        elevation: 4,
        light: 0.1,
      );
    }
    // Lanterne.
    final lamp = Offset(s.width * 0.42, s.height * 0.2);
    canvas.drawCircle(
      lamp,
      s.height * 0.16,
      Paint()
        ..shader = Gradient.radial(lamp, s.height * 0.16, [const Color(0x88FFD67E), const Color(0x00FFD67E)]),
    );
    canvas.drawLine(
      Offset(lamp.dx, s.height * 0.1),
      Offset(lamp.dx, lamp.dy - s.height * 0.04),
      Paint()
        ..color = const Color(0xFF3E2214)
        ..strokeWidth = 2,
    );
    drawPaper(
      canvas,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: lamp, width: s.height * 0.06, height: s.height * 0.08),
          Radius.circular(s.height * 0.015),
        ),
      ),
      Palette.sunHalo,
      elevation: 2,
    );
    // Plancher.
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(0, s.height * 0.82, s.width, s.height * 0.18)),
      const Color(0xFF7A4A2C),
      elevation: 3,
      light: 0.08,
    );
    // Tonneau du fond (la souris est dessus).
    _barrel(canvas, Rect.fromLTWH(s.width * 0.62, s.height * 0.58, s.width * 0.09, s.height * 0.27));
  }

  @override
  void paintForeground(Canvas canvas, Size s) {
    // Foin devant le mouton.
    final hay = Path();
    for (final (dx, r) in const [(0.2, 0.09), (0.27, 0.11), (0.35, 0.1), (0.42, 0.08)]) {
      hay.addOval(Rect.fromCircle(center: Offset(s.width * dx, s.height * 0.9), radius: s.height * r));
    }
    drawPaper(
      canvas,
      Path.combine(
        PathOperation.union,
        hay,
        Path()..addRect(Rect.fromLTWH(s.width * 0.15, s.height * 0.9, s.width * 0.32, s.height * 0.12)),
      ),
      const Color(0xFFE6C15A),
      elevation: 5,
      light: 0.18,
    );
    final straw = Paint()
      ..color = const Color(0xFFC79B35)
      ..strokeWidth = math.max(1, s.width * 0.002)
      ..strokeCap = StrokeCap.round;
    final random = math.Random(9);
    for (var i = 0; i < 30; i++) {
      final x = s.width * (0.17 + random.nextDouble() * 0.28);
      final y = s.height * (0.84 + random.nextDouble() * 0.12);
      canvas.drawLine(Offset(x, y), Offset(x + s.width * 0.012, y - s.height * 0.02), straw);
    }
    // Tonneau derrière lequel se cache le lapin.
    _barrel(canvas, Rect.fromLTWH(s.width * 0.565, s.height * 0.70, s.width * 0.1, s.height * 0.28));
    // Caisse au-dessus de la tortue.
    final crate = Rect.fromLTWH(s.width * 0.76, s.height * 0.62, s.width * 0.14, s.height * 0.24);
    drawPaper(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius(crate, Radius.circular(s.width * 0.004))),
      Ark.woodLight,
      elevation: 5,
    );
    final slat = Paint()
      ..color = Ark.wood
      ..strokeWidth = s.width * 0.006;
    canvas.drawLine(crate.topLeft, crate.bottomRight, slat);
    canvas.drawRect(crate.deflate(s.width * 0.003), slat..style = PaintingStyle.stroke);
    // Sacs.
    drawPaper(
      canvas,
      Path()..addOval(Rect.fromLTWH(s.width * 0.02, s.height * 0.72, s.width * 0.1, s.height * 0.26)),
      const Color(0xFFD9C39A),
      elevation: 5,
    );
  }

  void _barrel(Canvas canvas, Rect r) {
    drawPaper(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.3))),
      const Color(0xFF9A5E36),
      elevation: 5,
    );
    final hoop = Paint()
      ..color = const Color(0xFF5C3520)
      ..strokeWidth = r.height * 0.05;
    for (final t in [0.2, 0.8]) {
      canvas.drawLine(
        Offset(r.left + r.width * 0.04, r.top + r.height * t),
        Offset(r.right - r.width * 0.04, r.top + r.height * t),
        hoop,
      );
    }
  }
}

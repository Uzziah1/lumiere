import 'dart:math' as math;
import 'dart:ui';

import '../../art/animals.dart';
import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../art/weather.dart';
import '../../audio/audio.dart';
import '../../story/scripted_stage.dart';
import '../../theme/palette.dart';
import '../nt/nt.dart';
import '../registry.dart';

/// Jésus calme la tempête (Marc 4.35-41).
final tempetePack = StoryPack.scripted(
  scripts: {
    'traversee': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.2, 0.5),
      swipeTo: Offset(0.7, 0.5),
      paint: _traversee,
    ),
    'orage': StageScript(
      targets: [
        for (final x in _splashes) Rect.fromCenter(center: Offset(x, 0.56), width: 0.14, height: 0.2),
      ],
      sfx: Sfx.whoosh,
      paint: _orage,
    ),
    'sommeil': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.56, 0.46, 0.74, 0.70)],
      paint: _sommeil,
    ),
    'calme': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.1, 0.62),
      swipeTo: Offset(0.9, 0.62),
      sfx: Sfx.chime,
      paint: _calme,
    ),
    'question': StageScript(
      targets: [for (final x in _seats.take(3)) Rect.fromLTRB(x - 0.06, 0.30, x + 0.06, 0.62)],
      paint: _question,
    ),
    'rivage': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.30, 0.36, 0.70, 0.78)],
      sfx: Sfx.chime,
      paint: _rivage,
    ),
  },
  stickerScene: 'calme',
  seekScene: PaintedSeekScene(
    spots: const {
      'fish': (Offset(0.24, 0.86), 0.1),
      'shell': (Offset(0.62, 0.92), 0.06),
      'bird': (Offset(0.80, 0.16), 0.09),
      'crate': (Offset(0.10, 0.70), 0.1),
      'basket': (Offset(0.88, 0.76), 0.1),
      'jar': (Offset(0.46, 0.72), 0.1),
      'star': (Offset(0.36, 0.94), 0.07),
      'tortoise': (Offset(0.74, 0.60), 0.09),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _splashes = [0.26, 0.5, 0.74];
const _seats = [0.3, 0.42, 0.54, 0.24];

// Le bateau des disciples, avec Jésus à l'arrière ([sleeping] : couché sur un coussin).
void _boat(
  Canvas canvas,
  Size s,
  Offset c,
  double w,
  double time, {
  double tilt = 0,
  bool sleeping = false,
  double fear = 0,
  double wonder = 0,
  bool jesusStanding = false,
}) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(tilt);
  final h = w * 0.36;
  // Mât et voile.
  canvas.drawLine(
    Offset(-w * 0.12, 0),
    Offset(-w * 0.12, -h * 2.2),
    Paint()
      ..color = const Color(0xFF6B4226)
      ..strokeWidth = w * 0.014,
  );
  final sail = Path()
    ..moveTo(-w * 0.1, -h * 2.1)
    ..quadraticBezierTo(w * 0.14, -h * 1.4, -w * 0.1, -h * 0.5)
    ..close();
  drawPaper(canvas, sail, const Color(0xFFF3E6CC), elevation: 3, light: 0.15);
  // Les disciples.
  for (var i = 0; i < _seats.length; i++) {
    final x = (_seats[i] - 0.5) * w * 1.6 - w * 0.06;
    paintPerson(
      canvas,
      Offset(x, h * 0.2),
      h * 1.5,
      NT.disciples[i],
      facingLeft: i.isOdd,
      raisedBoth: fear > 0.5 || wonder > 0.5,
      wave: math.max(fear * (0.5 + 0.3 * math.sin(time * 8 + i)), wonder * 0.4),
      blink: blinkAt(time, i * 1.3),
    );
  }
  // Jésus à l'arrière.
  if (!sleeping) {
    paintPerson(
      canvas,
      Offset(w * 0.3, h * 0.2),
      h * (jesusStanding ? 1.8 : 1.5),
      NT.jesus,
      facingLeft: true,
      raisedBoth: jesusStanding,
      wave: jesusStanding ? 0.6 : 0,
      blink: blinkAt(time, 0.7),
    );
  }
  // Coque.
  final hull = Path()
    ..moveTo(-w * 0.52, -h * 0.4)
    ..lineTo(w * 0.52, -h * 0.4)
    ..quadraticBezierTo(w * 0.44, h * 0.5, w * 0.2, h * 0.56)
    ..lineTo(-w * 0.2, h * 0.56)
    ..quadraticBezierTo(-w * 0.44, h * 0.5, -w * 0.52, -h * 0.4)
    ..close();
  drawPaper(canvas, hull, const Color(0xFF8A5A36), elevation: 5, light: 0.12);
  canvas.drawLine(
    Offset(-w * 0.48, -h * 0.18),
    Offset(w * 0.48, -h * 0.18),
    Paint()
      ..color = const Color(0xFF6B4226)
      ..strokeWidth = w * 0.01,
  );
  if (sleeping) _sleepingJesus(canvas, w, h);
  canvas.restore();
}

// Jésus endormi à l'arrière du bateau, la tête sur un coussin.
void _sleepingJesus(Canvas canvas, double w, double h) {
  final y = -h * 0.5;
  drawPaper(
    canvas,
    Path()..addOval(Rect.fromCenter(center: Offset(w * 0.42, y), width: w * 0.12, height: h * 0.26)),
    const Color(0xFFB0413E),
    elevation: 2,
  );
  drawPaper(
    canvas,
    Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.08, y - h * 0.12, w * 0.38, y + h * 0.12),
        Radius.circular(h * 0.12),
      ),
    ),
    NT.jesus.robe,
    elevation: 2,
  );
  canvas.drawLine(
    Offset(w * 0.2, y - h * 0.11),
    Offset(w * 0.2, y + h * 0.11),
    Paint()
      ..color = NT.jesus.sash
      ..strokeWidth = h * 0.05,
  );
  final head = Offset(w * 0.4, y - h * 0.08);
  canvas.drawCircle(head + Offset(w * 0.012, -h * 0.02), h * 0.17, Paint()..color = NT.jesus.headcloth);
  drawPaper(
    canvas,
    Path()..addOval(Rect.fromCircle(center: head, radius: h * 0.14)),
    NT.jesus.skin,
    elevation: 2,
  );
  canvas.drawArc(
    Rect.fromCircle(center: head + Offset(-h * 0.05, -h * 0.01), radius: h * 0.03),
    0.2,
    2.6,
    false,
    Paint()
      ..color = const Color(0xFF2E1E15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.02
      ..strokeCap = StrokeCap.round,
  );
}

List<Color> _stormSky(double calm) => [
  for (var i = 0; i < 3; i++) Color.lerp(Skies.storm[i], Skies.dusk[i], calm)!,
];

void _rain(Canvas canvas, Size s, double time, double amount) {
  if (amount <= 0) return;
  final rain = RainField(count: (70 * amount).round().clamp(1, 70))
    ..resize(s)
    ..update(time % 1);
  rain.paint(canvas);
}

// 1. Le soir, Jésus dit : « Passons sur l'autre rive. » Le bateau part sur le lac.
void _traversee(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.dusk);
  paintSun(canvas, Offset(s.width * 0.84, s.height * 0.5), s.height * 0.08);
  paintHills(canvas, s, v.time, baselines: const [0.56, 0.6], colors: Lands.green, seed: 191);
  paintWaves(canvas, s, s.height * 0.62, v.time * 0.5, from: 0, to: 2);
  final x = 0.26 + 0.42 * v.eased;
  _boat(
    canvas,
    s,
    Offset(s.width * x, s.height * 0.74),
    s.height * 0.5,
    v.time,
    tilt: math.sin(v.time) * 0.02,
  );
  paintWaves(canvas, s, s.height * 0.76, v.time * 0.5, from: 2, to: 4);
}

// 2. Un grand vent se lève ; les vagues entrent dans le bateau.
void _orage(Canvas canvas, Size s, StageView v) {
  final bailed = (v.shown(0) + v.shown(1) + v.shown(2)) / 3;
  paintSkyGradient(canvas, s, Skies.storm);
  paintClouds(canvas, s, v.time * 3, count: 3, color: const Color(0xFF6B7891), top: 0.04);
  paintWaves(canvas, s, s.height * 0.6, v.time * 1.8, from: 0, to: 2);
  _boat(
    canvas,
    s,
    Offset(s.width * 0.5, s.height * 0.76),
    s.height * 0.68,
    v.time,
    tilt: math.sin(v.time * 2) * 0.1,
    sleeping: true,
    fear: 1,
  );
  for (var i = 0; i < _splashes.length; i++) {
    final t = v.shown(i);
    if (t >= 1) continue;
    final c = Offset(s.width * _splashes[i], s.height * (0.56 + 0.04 * math.sin(v.time * 3 + i)));
    final splash = Path()
      ..moveTo(c.dx - s.height * 0.07, c.dy + s.height * 0.06)
      ..quadraticBezierTo(
        c.dx - s.height * 0.04,
        c.dy - s.height * 0.1,
        c.dx + s.height * 0.05,
        c.dy - s.height * 0.06,
      )
      ..quadraticBezierTo(c.dx, c.dy - s.height * 0.02, c.dx + s.height * 0.07, c.dy + s.height * 0.06)
      ..close();
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, 1 - t));
    drawPaper(canvas, splash, const Color(0xFFDDF0F7), elevation: 3, light: 0.2);
    canvas.restore();
  }
  paintWaves(canvas, s, s.height * 0.74, v.time * 1.8, from: 2, to: 4);
  _rain(canvas, s, v.time, 1 - bailed * 0.3);
}

// 3. Jésus dort sur le coussin. Les disciples le réveillent : « Maître, nous périssons ! »
void _sommeil(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.storm);
  paintClouds(canvas, s, v.time * 3, count: 3, color: const Color(0xFF6B7891), top: 0.04);
  paintWaves(canvas, s, s.height * 0.6, v.time * 1.8, from: 0, to: 2);
  _boat(
    canvas,
    s,
    Offset(s.width * 0.5, s.height * 0.76),
    s.height * 0.68,
    v.time,
    tilt: math.sin(v.time * 2) * 0.06,
    sleeping: !v.done,
    fear: 1,
  );
  if (!v.done) {
    // « Z » de sommeil, plus faibles à chaque appel.
    for (var k = 0; k < 3; k++) {
      final y = (v.time * 0.4 + k / 3) % 1;
      canvas.drawCircle(
        Offset(s.width * 0.7 + y * s.height * 0.05, s.height * (0.5 - y * 0.16)),
        s.height * (0.008 + 0.006 * k),
        Paint()..color = Color.fromRGBO(255, 255, 255, (1 - y) * (1 - v.progress) * 0.9),
      );
    }
  }
  paintWaves(canvas, s, s.height * 0.74, v.time * 1.8, from: 2, to: 4);
  _rain(canvas, s, v.time, 1);
}

// 4. Jésus se lève et dit à la mer : « Silence ! Tais-toi ! » Et tout devient calme.
void _calme(Canvas canvas, Size s, StageView v) {
  final calm = v.eased;
  paintSkyGradient(canvas, s, _stormSky(calm));
  if (calm > 0.3) {
    paintStarField(canvas, s, v.time, count: 30, opacity: (calm - 0.3) / 0.7);
    paintSun(
      canvas,
      Offset(s.width * 0.84, s.height * 0.18),
      s.height * 0.05,
      color: const Color(0xFFFFF4D6),
      halo: calm,
    );
  }
  paintClouds(
    canvas,
    s,
    v.time * (3 - 2 * calm),
    count: 3 - (calm * 2).floor(),
    color: const Color(0xFF6B7891),
    top: 0.04 - calm * 0.3,
  );
  final speed = 1.8 - 1.4 * calm;
  paintWaves(canvas, s, s.height * 0.6, v.time * speed, from: 0, to: 2);
  _boat(
    canvas,
    s,
    Offset(s.width * 0.5, s.height * 0.76),
    s.height * 0.68,
    v.time,
    tilt: math.sin(v.time * 2) * 0.06 * (1 - calm),
    jesusStanding: true,
    fear: 1 - calm,
  );
  paintWaves(canvas, s, s.height * 0.74, v.time * speed, from: 2, to: 4);
  _rain(canvas, s, v.time, 1 - calm);
}

// 5. « Pourquoi avez-vous peur ? » Les disciples se demandent : « Qui est donc celui-ci ? »
void _question(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, v.time, count: 50);
  paintWaves(canvas, s, s.height * 0.6, v.time * 0.4, from: 0, to: 2);
  final wonder = (v.shown(0) + v.shown(1) + v.shown(2)) / 3;
  _boat(canvas, s, Offset(s.width * 0.5, s.height * 0.76), s.height * 0.68, v.time, wonder: wonder);
  for (var i = 0; i < 3; i++) {
    final t = v.shown(i);
    if (t <= 0) continue;
    final x = (_seats[i] - 0.5) * 1.6 - 0.06;
    final c = Offset(s.width * 0.5 + x * s.height * 0.68, s.height * 0.3);
    canvas.drawCircle(
      c,
      s.height * 0.035 * t,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.7 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.015),
    );
  }
  paintWaves(canvas, s, s.height * 0.74, v.time * 0.4, from: 2, to: 4);
}

// 6. Au matin, le bateau arrive sans danger sur l'autre rive.
void _rivage(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.dawn);
  paintSun(canvas, Offset(s.width * 0.2, s.height * (0.5 - 0.2 * v.eased)), s.height * 0.08);
  paintHills(canvas, s, v.time, baselines: const [0.56, 0.62], colors: Lands.green, seed: 193);
  paintWaves(canvas, s, s.height * 0.64, v.time * 0.3, from: 0, to: 2);
  drawPaper(
    canvas,
    Path()
      ..moveTo(s.width * 0.6, s.height)
      ..quadraticBezierTo(s.width * 0.75, s.height * 0.76, s.width, s.height * 0.72)
      ..lineTo(s.width, s.height)
      ..close(),
    const Color(0xFFE6CFA3),
    elevation: 4,
  );
  paintThing(canvas, 'palm', boxAt(s, 0.92, 0.78, 0.36, aspect: 0.7));
  final x = 0.42 + 0.14 * v.eased;
  _boat(canvas, s, Offset(s.width * x, s.height * 0.78), s.height * 0.62, v.time, wonder: v.eased);
  paintWaves(canvas, s, s.height * 0.8, v.time * 0.3, from: 2, to: 4);
  paintAnimal(canvas, Animal.dove, boxAt(s, 0.7, 0.3, 0.08), blink: blinkAt(v.time, 1));
}

void _seekBackground(Canvas canvas, Size s) {
  paintSkyGradient(canvas, s, Skies.sea);
  paintHills(canvas, s, 0, baselines: const [0.5, 0.56], colors: Lands.green, seed: 195);
  paintWaves(canvas, s, s.height * 0.56, 0, from: 0, to: 3);
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.8, s.width, s.height * 0.2)),
    const Color(0xFFE6CFA3),
    elevation: 3,
  );
  paintThing(canvas, 'boat', boxAt(s, 0.6, 0.66, 0.2, aspect: 1.2));
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'stone', boxAt(s, 0.28, 1.0, 0.1, aspect: 1.4));
  paintThing(canvas, 'reeds', boxAt(s, 0.04, 1.0, 0.22, aspect: 0.6));
  paintThing(canvas, 'stone', boxAt(s, 0.84, 1.0, 0.12, aspect: 1.4));
}

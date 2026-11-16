import 'dart:math' as math;
import 'dart:ui';

import '../../art/animals.dart';
import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../art/shapes.dart';
import '../../art/weather.dart';
import '../../audio/audio.dart';
import '../../story/scripted_stage.dart';
import '../../theme/palette.dart';
import '../registry.dart';

/// Jonas et le grand poisson (Jonas 1 à 4).
final jonasPack = StoryPack.scripted(
  scripts: {
    'flee': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 3,
      targets: [Rect.fromLTRB(0.40, 0.24, 0.70, 0.74)],
      sfx: Sfx.whoosh,
      paint: _flee,
    ),
    'storm': StageScript(
      targets: [for (final x in _crates) Rect.fromCenter(center: Offset(x, 0.5), width: 0.1, height: 0.16)],
      sfx: Sfx.whoosh,
      paint: _storm,
    ),
    'fish': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 3,
      targets: [Rect.fromLTRB(0.04, 0.46, 0.34, 0.80)],
      sfx: Sfx.whoosh,
      paint: _fish,
    ),
    'prayer': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.36, 0.30, 0.64, 0.70)],
      sfx: Sfx.chime,
      paint: _prayer,
    ),
    'nineveh': StageScript(
      targets: [for (final x in _houses) Rect.fromLTRB(x - 0.08, 0.30, x + 0.08, 0.80)],
      paint: _nineveh,
    ),
    'plant': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.44, 0.40, 0.64, 0.80)],
      sfx: Sfx.chime,
      paint: _plant,
    ),
  },
  stickerScene: 'prayer',
  seekScene: PaintedSeekScene(
    spots: const {
      'fish': (Offset(0.6, 0.36), 0.12),
      'shell': (Offset(0.22, 0.88), 0.08),
      'tortoise': (Offset(0.82, 0.62), 0.12),
      'snail': (Offset(0.44, 0.86), 0.07),
      'star': (Offset(0.70, 0.88), 0.08),
      'jar': (Offset(0.10, 0.70), 0.12),
      'crate': (Offset(0.92, 0.84), 0.11),
      'plant': (Offset(0.34, 0.56), 0.14),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _crates = [0.38, 0.5, 0.62];
const _houses = [0.24, 0.5, 0.76];

const jonah = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFF6FA8A3),
  headcloth: Color(0xFFEADBC0),
  sash: Color(0xFFB0563A),
  beard: Color(0xFF3E2A1E),
);

const _sailors = [
  PersonStyle(
    skin: Color(0xFF7D4A30),
    robe: Color(0xFFB0563A),
    headcloth: Color(0xFFF0E2C8),
    beard: Color(0xFF2E1E15),
    scale: 0.95,
  ),
  PersonStyle(skin: Color(0xFFA9714B), robe: Color(0xFF6E8FB8), headcloth: Color(0xFFE8D6B3), scale: 0.95),
];

const _ninevites = [
  PersonStyle(skin: Color(0xFF9C6440), robe: Color(0xFF9C7A54), headcloth: Color(0xFFE6D8BE), beard: Color(0xFF3E2A1E)),
  PersonStyle(skin: Color(0xFF7D4A30), robe: Color(0xFF8C7B66), headcloth: Color(0xFFF3E2C0), veil: true, scale: 0.92),
  PersonStyle(
    skin: Color(0xFFA06A45),
    robe: Color(0xFF7A6A58),
    headcloth: Color(0xFF2E1E15),
    bareHead: true,
    scale: 0.7,
  ),
];

/// Le grand poisson, tourné vers la droite ; [mouth] de 0 (fermée) à 1 (grande ouverte).
void paintBigFish(Canvas canvas, Rect box, {double mouth = 0, double time = 0}) {
  canvas.save();
  fitBox(canvas, box, const Size(200, 120));
  const blue = Color(0xFF4F86C6);
  final tail = math.sin(time * 3) * 6;
  drawPaper(
    canvas,
    Path()
      ..moveTo(30, 60)
      ..lineTo(0, 30 + tail)
      ..lineTo(8, 60)
      ..lineTo(0, 92 + tail)
      ..close(),
    const Color(0xFF3F74B3),
    elevation: 3,
    light: 0.1,
  );
  final open = mouth.clamp(0.0, 1.0) * 26;
  final body = Path()
    ..moveTo(26, 60)
    ..cubicTo(40, 8, 150, 4, 196, 54 - open * 0.4)
    ..lineTo(150, 62)
    ..lineTo(196, 66 + open * 0.6)
    ..cubicTo(160, 118, 40, 116, 26, 60)
    ..close();
  drawPaper(canvas, body, blue, elevation: 5, light: 0.14);
  drawPaper(
    canvas,
    Path()
      ..moveTo(40, 74)
      ..cubicTo(70, 106, 150, 106, 186, 72)
      ..lineTo(150, 66)
      ..close(),
    const Color(0xFF9CC3E6),
    elevation: 0,
    light: 0,
  );
  drawPaper(
    canvas,
    Path()
      ..moveTo(90, 30)
      ..quadraticBezierTo(100, 4, 122, 14)
      ..quadraticBezierTo(112, 24, 110, 34)
      ..close(),
    const Color(0xFF3F74B3),
    elevation: 2,
    light: 0.1,
  );
  canvas.drawCircle(const Offset(158, 40), 7, Paint()..color = const Color(0xFFFFFFFF));
  canvas.drawCircle(const Offset(160, 40), 4, Paint()..color = const Color(0xFF2A1A12));
  canvas.restore();
}

void _boat(
  Canvas canvas,
  Size s,
  Offset bottom,
  double h, {
  double tilt = 0,
  bool withJonah = true,
  List<PersonStyle> crew = _sailors,
}) {
  canvas.save();
  canvas.translate(bottom.dx, bottom.dy);
  canvas.rotate(tilt);
  final box = Rect.fromLTWH(-h * 0.6, -h, h * 1.2, h);
  // L'équipage, sur le pont, derrière le bord du bateau.
  final deck = -h * 0.24;
  for (var k = 0; k < crew.length; k++) {
    paintPerson(canvas, Offset(-h * 0.36 + k * h * 0.2, deck), h * 0.36, crew[k]);
  }
  if (withJonah) paintPerson(canvas, Offset(h * 0.34, deck), h * 0.36, jonah, facingLeft: true);
  paintThing(canvas, 'boat', box);
  canvas.restore();
}

// 1. Dieu envoie Jonas à Ninive ; Jonas s'enfuit en bateau.
void _flee(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.sea);
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.18, -s.height * 0.05), v.time, intensity: 0.5);
  paintThing(canvas, 'city', boxAt(s, 0.12, 0.66, 0.2, aspect: 1.6));
  paintSea(canvas, s, s.height * 0.66, v.time * 0.6);
  final go = v.eased * s.width * 0.5;
  _boat(
    canvas,
    s,
    Offset(s.width * 0.55 + go, s.height * 0.78 + math.sin(v.time * 1.6) * s.height * 0.01),
    s.height * 0.44,
    tilt: math.sin(v.time * 1.2) * 0.03,
  );
  paintSea(canvas, s, s.height * 0.66, v.time * 0.6, front: true);
}

// 2. La tempête : les marins jettent la cargaison à la mer.
void _storm(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.storm);
  paintClouds(canvas, s, v.time, count: 3, color: const Color(0xFF6B7891), top: 0.06);
  paintSea(canvas, s, s.height * 0.62, v.time * 1.6);
  final tilt = math.sin(v.time * 1.8) * 0.08 * (1 - v.eased * 0.6);
  _boat(canvas, s, Offset(s.width * 0.5, s.height * 0.76), s.height * 0.5, tilt: tilt, withJonah: false);
  for (var i = 0; i < _crates.length; i++) {
    final t = v.shown(i);
    final home = Offset(s.width * _crates[i], s.height * 0.56);
    final splash = Offset(s.width * (_crates[i] < 0.5 ? 0.12 : 0.88) + i * 6, s.height * 0.8);
    final at = Offset.lerp(home, splash, t)! + Offset(0, -math.sin(t * math.pi) * s.height * 0.2);
    if (t < 0.98) {
      paintThing(canvas, 'crate', Rect.fromCenter(center: at, width: s.height * 0.1, height: s.height * 0.1));
    }
  }
  paintSea(canvas, s, s.height * 0.62, v.time * 1.6, front: true);
  final rain = RainField(count: 60)
    ..resize(s)
    ..update(v.time % 1);
  rain.paint(canvas);
}

// 3. Jonas est jeté à la mer ; un grand poisson l'avale. La mer se calme.
void _fish(Canvas canvas, Size s, StageView v) {
  final calm = v.eased;
  paintSkyGradient(canvas, s, [for (var i = 0; i < 3; i++) Color.lerp(Skies.storm[i], Skies.sea[i], calm)!]);
  // Sous l'eau.
  canvas.drawRect(
    Rect.fromLTWH(0, s.height * 0.3, s.width, s.height * 0.7),
    Paint()
      ..shader = Gradient.linear(Offset(0, s.height * 0.3), Offset(0, s.height), const [
        Color(0xFF5BB3D3),
        Color(0xFF1F5C86),
      ]),
  );
  paintWaves(canvas, Size(s.width, s.height * 0.4), s.height * 0.28, v.time * (1.6 - calm), from: 0, to: 2);
  _boat(canvas, s, Offset(s.width * 0.8, s.height * 0.32), s.height * 0.28, withJonah: false);
  // Jonas descend doucement, puis le poisson arrive.
  final swim = v.eased;
  final fishBox = Rect.fromLTWH(s.width * (0.0 + 0.28 * swim), s.height * 0.46, s.width * 0.4, s.width * 0.24);
  if (swim < 0.8) {
    paintPerson(
      canvas,
      Offset(s.width * 0.56, s.height * (0.62 + 0.08 * math.sin(v.time))),
      s.height * 0.22,
      jonah,
      raisedBoth: true,
      wave: 0.8,
    );
  }
  paintBigFish(canvas, fishBox, mouth: swim < 0.75 ? swim : 1 - (swim - 0.75) * 4, time: v.time);
  for (var k = 0; k < 6; k++) {
    final phase = (v.time * 0.3 + k / 6) % 1;
    canvas.drawCircle(
      Offset(s.width * (0.2 + k * 0.12), s.height * (0.95 - phase * 0.6)),
      s.height * 0.01,
      Paint()..color = const Color(0x55FFFFFF),
    );
  }
}

// 4. Trois jours dans le poisson : Jonas prie, et le poisson le dépose sur la plage.
void _prayer(Canvas canvas, Size s, StageView v) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()..shader = Gradient.linear(Offset.zero, Offset(0, s.height), const [Color(0xFF5BB3D3), Color(0xFF1F5C86)]),
  );
  final ashore = v.done ? (v.sinceDone / 1.5).clamp(0.0, 1.0) : 0.0;
  // La plage où le poisson va déposer Jonas.
  drawPaper(
    canvas,
    Path()
      ..moveTo(s.width * 0.7, s.height)
      ..quadraticBezierTo(s.width * 0.76, s.height * 0.62, s.width, s.height * 0.58)
      ..lineTo(s.width, s.height)
      ..close(),
    const Color(0xFFE8CF96),
    elevation: 4,
  );
  final fish = Rect.fromLTWH(s.width * (0.16 + 0.12 * ashore), s.height * 0.22, s.width * 0.6, s.width * 0.36);
  paintBigFish(canvas, fish, mouth: ashore, time: v.time);
  // Une fenêtre ronde dans le poisson : Jonas, à genoux, prie.
  final window = Offset(fish.left + fish.width * 0.48, fish.top + fish.height * 0.55);
  final r = fish.height * 0.28;
  if (ashore < 1) {
    canvas.drawCircle(window, r, Paint()..color = const Color(0xFF2E3C5C));
    canvas.save();
    canvas.clipPath(circle(window, r));
    canvas.drawCircle(
      window,
      r * (0.4 + 0.3 * v.eased),
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.4 + 0.4 * v.eased)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4),
    );
    paintPerson(canvas, window + Offset(0, r * 0.75), r * 1.4, jonah, raisedBoth: true, wave: 0.9, blink: 1);
    canvas.restore();
    canvas.drawCircle(
      window,
      r,
      Paint()
        ..color = const Color(0xFF3F74B3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12,
    );
  } else {
    paintPerson(canvas, feetAt(s, 0.88, 0.7), s.height * 0.3, jonah, wave: 0.8, blink: blinkAt(v.time, 0.4));
  }
  // Trois petits soleils : trois jours et trois nuits.
  for (var k = 0; k < 3; k++) {
    final on = v.progress * 3 > k + 0.5;
    paintThing(
      canvas,
      on ? 'sun' : 'moon',
      Rect.fromCenter(
        center: Offset(s.width * (0.08 + k * 0.08), s.height * 0.1),
        width: s.height * 0.08,
        height: s.height * 0.08,
      ),
    );
  }
}

// 5. À Ninive, Jonas annonce le message de Dieu ; les habitants changent de cœur.
void _nineveh(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintHills(canvas, s, v.time, baselines: const [0.64, 0.76, 0.88], colors: Lands.desert, seed: 141);
  for (var i = 0; i < _houses.length; i++) {
    final x = _houses[i];
    paintThing(canvas, 'city', boxAt(s, x, 0.74, 0.3, aspect: 1.1));
    final t = v.shown(i);
    if (t > 0) {
      for (var k = 0; k < 2; k++) {
        paintPerson(
          canvas,
          feetAt(s, x - 0.03 + k * 0.06, 0.9),
          s.height * 0.26 * t,
          _ninevites[(i + k) % 3],
          raisedBoth: true,
          wave: 0.6,
          blink: blinkAt(v.time, i * 2.0 + k),
        );
      }
    }
  }
  paintPerson(canvas, feetAt(s, 0.06, 0.94), s.height * 0.38, jonah, wave: 0.8, blink: blinkAt(v.time, 0.2));
  if (v.done) paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.6);
}

// 6. La plante qui donne de l'ombre : Dieu aime tous les peuples.
void _plant(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintSun(canvas, Offset(s.width * 0.86, s.height * 0.16), s.height * 0.08, halo: 0.8);
  paintHills(canvas, s, v.time, baselines: const [0.68, 0.8, 0.9], colors: Lands.desert, seed: 147);
  paintThing(canvas, 'city', boxAt(s, 0.86, 0.72, 0.24, aspect: 1.6));
  for (final fx in [0.74, 0.8]) {
    paintAnimal(canvas, Animal.sheep, boxAt(s, fx, 0.9, 0.1));
  }
  final grow = v.eased;
  if (grow > 0) {
    // L'ombre de la plante.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.42, s.height * 0.92),
        width: s.width * 0.3 * grow,
        height: s.height * 0.05,
      ),
      Paint()..color = const Color(0x334A2A1A),
    );
  }
  paintThing(canvas, 'plant', boxAt(s, 0.54, 0.92, 0.12 + 0.46 * grow));
  paintPerson(
    canvas,
    feetAt(s, 0.36, 0.94),
    s.height * 0.38,
    jonah,
    blink: blinkAt(v.time, 0.6),
    wave: v.done ? 0.5 : 0,
  );
  if (v.done) paintHeavenlyLight(canvas, s, Offset(s.width * 0.3, -s.height * 0.05), v.time, intensity: 0.5);
}

void _seekBackground(Canvas canvas, Size s) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(0, s.height),
        const [Color(0xFF7CC7DD), Color(0xFF2E78A3), Color(0xFF1F5C86)],
        const [0, 0.5, 1],
      ),
  );
  // Rayons de lumière dans l'eau.
  for (var k = 0; k < 5; k++) {
    final x = s.width * (0.1 + k * 0.2);
    canvas.drawPath(
      Path()
        ..moveTo(x, 0)
        ..lineTo(x + s.width * 0.06, 0)
        ..lineTo(x + s.width * 0.14, s.height)
        ..lineTo(x + s.width * 0.04, s.height)
        ..close(),
      Paint()..color = const Color(0x18FFFFFF),
    );
  }
  paintBigFish(canvas, Rect.fromLTWH(s.width * 0.04, s.height * 0.06, s.width * 0.32, s.width * 0.19));
  drawPaper(
    canvas,
    Path()
      ..moveTo(0, s.height * 0.8)
      ..quadraticBezierTo(s.width * 0.5, s.height * 0.72, s.width, s.height * 0.82)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close(),
    const Color(0xFFE8CF96),
    elevation: 4,
  );
}

void _seekForeground(Canvas canvas, Size s) {
  for (final (fx, h) in const [(0.06, 0.34), (0.3, 0.26), (0.56, 0.2), (0.88, 0.3)]) {
    canvas.saveLayer(
      Offset.zero & s,
      Paint()..colorFilter = const ColorFilter.mode(Color(0xFF3E8E5A), BlendMode.srcATop),
    );
    paintThing(canvas, 'reeds', boxAt(s, fx, 1.0, h, aspect: 0.7));
    canvas.restore();
  }
  drawPaper(
    canvas,
    Path()..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.2, s.height * 0.98), width: s.width * 0.12, height: s.height * 0.12),
    ),
    const Color(0xFF8A8F98),
    elevation: 4,
  );
  drawPaper(
    canvas,
    Path()..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.74, s.height * 0.97), width: s.width * 0.1, height: s.height * 0.1),
    ),
    const Color(0xFF9AA0A8),
    elevation: 4,
  );
  drawPaper(
    canvas,
    Path()..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.84, s.height * 0.7), width: s.width * 0.08, height: s.height * 0.08),
    ),
    const Color(0xFF8A8F98),
    elevation: 4,
  );
  paintThing(canvas, 'flower', boxAt(s, 0.46, 1.0, 0.14));
}

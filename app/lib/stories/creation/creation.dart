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
import '../registry.dart';

/// La Création (Genèse 1 à 2) : six scènes, comme les six jours.
final creationPack = StoryPack.scripted(
  scripts: {
    'light': StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: const [Rect.fromLTRB(0.36, 0.18, 0.64, 0.62)],
      sfx: Sfx.chime,
      paint: _light,
    ),
    'land': StageScript(
      interaction: Interaction.swipe,
      swipeFrom: const Offset(0.5, 0.78),
      swipeTo: const Offset(0.5, 0.36),
      sfx: Sfx.whoosh,
      paint: _land,
    ),
    'plants': StageScript(
      targets: [for (final fx in _plantSpots) Rect.fromLTRB(fx - 0.07, 0.40, fx + 0.07, 0.78)],
      paint: _plants,
    ),
    'lights': const StageScript(
      targets: [
        Rect.fromLTRB(0.12, 0.12, 0.32, 0.46),
        Rect.fromLTRB(0.68, 0.10, 0.88, 0.42),
        Rect.fromLTRB(0.40, 0.06, 0.60, 0.34),
      ],
      sfx: Sfx.chime,
      paint: _lights,
    ),
    'animals': const StageScript(
      targets: [
        Rect.fromLTRB(0.04, 0.52, 0.34, 0.80),
        Rect.fromLTRB(0.36, 0.08, 0.66, 0.36),
        Rect.fromLTRB(0.66, 0.38, 0.96, 0.80),
      ],
      paint: _animals,
    ),
    'humans': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.38, 0.04, 0.62, 0.34)],
      sfx: Sfx.chime,
      paint: _humans,
    ),
  },
  stickerScene: 'humans',
  seekScene: PaintedSeekScene(
    spots: const {
      'rabbit': (Offset(0.18, 0.70), 0.16),
      'ladybug': (Offset(0.43, 0.56), 0.06),
      'snail': (Offset(0.62, 0.86), 0.09),
      'frog': (Offset(0.80, 0.80), 0.12),
      'owl': (Offset(0.88, 0.30), 0.14),
      'tortoise': (Offset(0.36, 0.86), 0.12),
      'mouse': (Offset(0.55, 0.66), 0.08),
      'dove': (Offset(0.12, 0.27), 0.11),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _plantSpots = [0.16, 0.38, 0.62, 0.84];

const adam = PersonStyle(
  skin: Color(0xFF8A5537),
  robe: Color(0xFF7FA650),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFF5E8A3A),
  bareHead: true,
);

const eve = PersonStyle(
  skin: Color(0xFF9C6440),
  robe: Color(0xFFA9C46C),
  headcloth: Color(0xFF2A1A12),
  sash: Color(0xFFF07FA0),
  bareHead: true,
  veil: true,
  scale: 0.96,
);

// 1. « Que la lumière soit ! » — la lumière chasse les ténèbres.
void _light(Canvas canvas, Size s, StageView v) {
  final p = v.eased;
  final sky = [for (var i = 0; i < 3; i++) Color.lerp(Skies.night[i], Skies.dawn[i], p)!];
  paintSkyGradient(canvas, s, sky);
  if (p < 1) paintStarField(canvas, s, v.time, count: 30, opacity: 1 - p);
  // L'eau profonde des débuts (Genèse 1.2).
  paintWaves(
    canvas,
    s,
    s.height * 0.78,
    v.time * 0.5,
    colors: [
      Color.lerp(const Color(0xFF2B3A5E), const Color(0xFF6CB8D4), p)!,
      Color.lerp(const Color(0xFF223050), const Color(0xFF4FA3C7), p)!,
      Color.lerp(const Color(0xFF1B2742), const Color(0xFF3A8DB8), p)!,
      Color.lerp(const Color(0xFF141E36), const Color(0xFF2E78A3), p)!,
    ],
  );
  final center = Offset(s.width * 0.5, s.height * 0.38);
  if (p == 0) {
    final pulse = 0.6 + 0.4 * math.sin(v.time * 3);
    canvas.drawCircle(
      center,
      s.height * 0.04 * (1 + pulse * 0.5),
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.5 + 0.4 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.03),
    );
  }
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: p * 1.2);
}

// 2. Le ciel, les mers et la terre ferme qui apparaît.
void _land(Canvas canvas, Size s, StageView v) {
  final p = v.eased;
  paintSkyGradient(canvas, s, Skies.day);
  paintClouds(canvas, s, v.time, count: 3);
  canvas.save();
  canvas.translate(0, (1 - p) * s.height * 0.45);
  paintHills(canvas, s, v.time, baselines: const [0.56, 0.66], colors: Lands.green, seed: 21);
  canvas.restore();
  paintWaves(canvas, s, s.height * (0.6 + p * 0.22), v.time * 0.7);
}

// 3. Les plantes et les arbres poussent.
void _plants(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.day);
  paintSun(canvas, Offset(s.width * 0.86, s.height * 0.16), s.height * 0.07, halo: 0.6);
  paintHills(canvas, s, v.time, baselines: const [0.58, 0.68, 0.8], colors: Lands.green, seed: 31);
  const kinds = ['tree', 'flower', 'tree', 'plant'];
  for (var i = 0; i < _plantSpots.length; i++) {
    final grow = v.shown(i);
    final fx = _plantSpots[i];
    final ground = s.height * 0.8;
    if (grow <= 0.01) {
      // Une petite graine.
      canvas.drawCircle(
        Offset(s.width * fx, ground - s.height * 0.01),
        s.height * 0.012,
        Paint()..color = const Color(0xFF6B4630),
      );
      continue;
    }
    final h = s.height * (kinds[i] == 'tree' ? 0.36 : 0.22) * grow;
    final sway = math.sin(v.time * 1.2 + i) * 0.03;
    canvas.save();
    canvas.translate(s.width * fx, ground);
    canvas.rotate(sway);
    paintThing(canvas, kinds[i], Rect.fromLTWH(-h / 2, -h, h, h));
    canvas.restore();
  }
}

// 4. Le soleil, la lune et les étoiles.
void _lights(Canvas canvas, Size s, StageView v) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(s.width, 0),
        const [Color(0xFF8CCFE6), Color(0xFF6F7FB0), Color(0xFF26335E)],
        const [0, 0.5, 1],
      ),
  );
  paintStarField(canvas, Size(s.width, s.height), v.time, count: 30, opacity: v.shown(2), seed: 3);
  paintHills(canvas, s, v.time, baselines: const [0.7, 0.82], colors: Lands.green, seed: 41);
  final spots = [(0.22, 0.29, 'sun', 0.26), (0.78, 0.26, 'moon', 0.22), (0.5, 0.2, 'star', 0.16)];
  for (var i = 0; i < spots.length; i++) {
    final (fx, fy, id, h) = spots[i];
    final t = v.shown(i);
    final c = Offset(s.width * fx, s.height * fy);
    if (t < 0.02) {
      canvas.drawCircle(
        c,
        s.height * h * 0.35,
        Paint()
          ..color = const Color(0x55FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      continue;
    }
    final side = s.height * h * (0.4 + 0.6 * t) * (1 + v.pulse[i] * 0.1);
    paintThing(
      canvas,
      id,
      Rect.fromCenter(center: c, width: side, height: side),
      time: v.time,
    );
  }
}

// 5. Les poissons, les oiseaux et les animaux de la terre.
void _animals(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.day);
  paintHills(canvas, s, v.time, baselines: const [0.56, 0.66], colors: Lands.lush, seed: 51);
  // La mer à gauche, la terre à droite.
  canvas.save();
  canvas.clipRect(Rect.fromLTWH(0, 0, s.width * 0.42, s.height));
  paintWaves(canvas, s, s.height * 0.66, v.time * 0.8);
  canvas.restore();
  final sea = v.shown(0);
  if (sea > 0) {
    for (var k = 0; k < 3; k++) {
      final phase = (v.time * 0.6 + k / 3) % 1;
      final x = s.width * (0.08 + k * 0.09);
      final y = s.height * 0.7 - math.sin(phase * math.pi) * s.height * 0.16 * sea;
      final f = s.height * 0.13 * sea;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((phase - 0.5) * 1.6);
      paintThing(canvas, 'fish', Rect.fromCenter(center: Offset.zero, width: f, height: f));
      canvas.restore();
    }
  }
  final sky = v.shown(1);
  if (sky > 0) {
    for (var k = 0; k < 4; k++) {
      final x = s.width * (0.38 + k * 0.07) + math.sin(v.time + k) * s.width * 0.02;
      final y = s.height * (0.16 + (k % 2) * 0.08) + math.cos(v.time * 1.3 + k) * s.height * 0.02;
      final b = s.height * 0.1 * sky;
      paintThing(
        canvas,
        'bird',
        Rect.fromCenter(center: Offset(x, y), width: b, height: b),
        time: v.time + k,
      );
    }
  }
  final land = v.shown(2);
  if (land > 0) {
    final ground = s.height * 0.86;
    for (final (a, fx, h) in [
      (Animal.giraffe, 0.72, 0.42),
      (Animal.elephant, 0.87, 0.28),
      (Animal.lion, 0.58, 0.2),
      (Animal.rabbit, 0.96, 0.12),
    ]) {
      final hh = s.height * h * land;
      paintAnimal(
        canvas,
        a,
        Rect.fromLTWH(s.width * fx - hh / 2, ground - hh, hh, hh),
        blink: blinkAt(v.time, fx * 5),
        facingLeft: fx > 0.8,
      );
    }
  }
}

// 6. L'homme et la femme, puis le septième jour : le repos.
void _humans(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.day);
  paintClouds(canvas, s, v.time, count: 2);
  paintHills(canvas, s, v.time, baselines: const [0.6, 0.7, 0.84], colors: Lands.lush, seed: 61);
  for (final (fx, h) in const [(0.12, 0.44), (0.88, 0.4)]) {
    paintThing(canvas, 'tree', boxAt(s, fx, 0.86, h));
  }
  for (final (fx, fy) in const [(0.3, 0.92), (0.7, 0.94), (0.24, 0.84)]) {
    paintThing(canvas, 'flower', boxAt(s, fx, fy, 0.1));
  }
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.5 + 0.5 * v.eased);
  final t = v.eased;
  if (t > 0) {
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, t));
    final wave = v.done ? 0.6 + 0.4 * math.sin(v.time * 3) : 0.0;
    paintPerson(canvas, feetAt(s, 0.44, 0.9), s.height * 0.42, adam, wave: wave, blink: blinkAt(v.time, 0.3));
    paintPerson(
      canvas,
      feetAt(s, 0.56, 0.9),
      s.height * 0.42,
      eve,
      wave: v.done ? 0.6 + 0.4 * math.sin(v.time * 3 + 1) : 0,
      blink: blinkAt(v.time, 1.5),
      facingLeft: true,
    );
    canvas.restore();
  }
}

void _seekBackground(Canvas canvas, Size s) {
  paintSkyGradient(canvas, s, Skies.day);
  paintSun(canvas, Offset(s.width * 0.7, s.height * 0.15), s.height * 0.08, halo: 0.5);
  paintHills(canvas, s, 0, baselines: const [0.5, 0.62, 0.76], colors: Lands.lush, seed: 71);
  for (final (fx, h) in const [(0.1, 0.5), (0.88, 0.56), (0.5, 0.36)]) {
    paintThing(canvas, 'tree', boxAt(s, fx, 0.66, h));
  }
  paintThing(canvas, 'flower', boxAt(s, 0.44, 0.62, 0.12));
}

void _seekForeground(Canvas canvas, Size s) {
  // Buissons, rochers et grandes fleurs qui cachent à moitié les animaux.
  Path bush(double fx, double fy, double r) => Path()
    ..addOval(Rect.fromCircle(center: Offset(s.width * fx, s.height * fy), radius: s.height * r))
    ..addOval(
      Rect.fromCircle(
        center: Offset(s.width * fx - s.height * r * 0.9, s.height * fy + s.height * r * 0.3),
        radius: s.height * r * 0.75,
      ),
    )
    ..addOval(
      Rect.fromCircle(
        center: Offset(s.width * fx + s.height * r * 0.9, s.height * fy + s.height * r * 0.3),
        radius: s.height * r * 0.75,
      ),
    );
  drawPaper(canvas, bush(0.22, 0.82, 0.1), const Color(0xFF5E9440), elevation: 5);
  drawPaper(canvas, bush(0.84, 0.92, 0.09), const Color(0xFF6FA84F), elevation: 5);
  drawPaper(
    canvas,
    Path()..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.36, s.height * 0.95), width: s.width * 0.12, height: s.height * 0.12),
    ),
    const Color(0xFFB8B3AA),
    elevation: 5,
  );
  drawPaper(
    canvas,
    Path()..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.66, s.height * 0.92), width: s.width * 0.08, height: s.height * 0.1),
    ),
    const Color(0xFFA9A49A),
    elevation: 5,
  );
  paintThing(canvas, 'flower', boxAt(s, 0.5, 1.0, 0.24));
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.82, s.height * 0.34, s.width * 0.12, s.height * 0.05)),
    const Color(0xFF8A5634),
    elevation: 3,
  );
}

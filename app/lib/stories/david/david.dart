import 'dart:math' as math;
import 'dart:ui';

import '../../art/animals.dart';
import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../audio/audio.dart';
import '../../story/scripted_stage.dart';
import '../../theme/palette.dart';
import '../registry.dart';

/// David et Goliath (1 Samuel 16 et 17, Psaume 23).
final davidPack = StoryPack.scripted(
  scripts: {
    'shepherd': StageScript(
      targets: [for (final (x, y) in _sheepHomes) Rect.fromCenter(center: Offset(x, y - 0.06), width: 0.12, height: 0.16)],
      paint: _shepherd,
    ),
    'anoint': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.26, 0.24, 0.44, 0.60)],
      sfx: Sfx.chime,
      paint: _anoint,
    ),
    'goliath': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 1.8,
      targets: [Rect.fromLTRB(0.12, 0.44, 0.28, 0.80)],
      paint: _goliath,
    ),
    'stones': StageScript(
      targets: [for (final x in _stoneSpots) Rect.fromCenter(center: Offset(x, 0.74), width: 0.1, height: 0.14)],
      paint: _stones,
    ),
    'sling': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.14, 0.40, 0.32, 0.80)],
      sfx: Sfx.whoosh,
      paint: _sling,
    ),
    'psalm': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.50, 0.42, 0.66, 0.74)],
      sfx: Sfx.chime,
      paint: _psalm,
    ),
  },
  stickerScene: 'psalm',
  seekScene: PaintedSeekScene(
    spots: const {
      'sheep': (Offset(0.34, 0.74), 0.16),
      'rabbit': (Offset(0.10, 0.80), 0.12),
      'bird': (Offset(0.62, 0.2), 0.09),
      'tortoise': (Offset(0.58, 0.86), 0.1),
      'snail': (Offset(0.82, 0.58), 0.07),
      'mouse': (Offset(0.46, 0.88), 0.08),
      'owl': (Offset(0.9, 0.3), 0.12),
      'harp': (Offset(0.74, 0.84), 0.12),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _sheepHomes = [(0.12, 0.74), (0.3, 0.62), (0.76, 0.66), (0.9, 0.76)];
const _stoneSpots = [0.24, 0.38, 0.52, 0.66, 0.8];

const david = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFFE0A35A),
  headcloth: Color(0xFF6B3A22),
  sash: Color(0xFFB0563A),
  bareHead: true,
  scale: 0.86,
);

const _king = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFF8C79B5),
  headcloth: Color(0xFF6B3A22),
  sash: Color(0xFFF2C14E),
  bareHead: true,
  crown: true,
);

const _samuel = PersonStyle(
  skin: Color(0xFF8A5537),
  robe: Color(0xFFF2EBDD),
  headcloth: Color(0xFFFFFFFF),
  sash: Color(0xFF6E8FB8),
  beard: Color(0xFFF4EFE6),
);

const _goliathStyle = PersonStyle(
  skin: Color(0xFF9C6440),
  robe: Color(0xFF8B8F96),
  headcloth: Color(0xFF3E2A1E),
  sash: Color(0xFFB08D57),
  beard: Color(0xFF2A1A12),
  helmet: true,
);

const _soldiers = [
  PersonStyle(skin: Color(0xFF7D4A30), robe: Color(0xFFB0563A), headcloth: Color(0xFFE8D6B3), beard: Color(0xFF2E1E15), helmet: true),
  PersonStyle(skin: Color(0xFF9C6440), robe: Color(0xFF5F9E7E), headcloth: Color(0xFFF0E2C8), beard: Color(0xFF3E2A1E), helmet: true),
  PersonStyle(skin: Color(0xFF6E4029), robe: Color(0xFF6E8FB8), headcloth: Color(0xFFEADBC0), beard: Color(0xFF2A1A12), helmet: true),
];

void _hills(Canvas canvas, Size s, double time, {List<Color> sky = Skies.day}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 3);
  paintHills(canvas, s, time, baselines: const [0.58, 0.7, 0.84], colors: Lands.green, seed: 131);
}

// 1. Le jeune berger David rassemble ses moutons.
void _shepherd(Canvas canvas, Size s, StageView v) {
  _hills(canvas, s, v.time);
  final center = Offset(s.width * 0.52, s.height * 0.86);
  paintPerson(canvas, feetAt(s, 0.52, 0.9), s.height * 0.4, david, wave: 0.3, blink: blinkAt(v.time, 0.5));
  paintThing(canvas, 'harp', boxAt(s, 0.58, 0.8, 0.14));
  for (var i = 0; i < _sheepHomes.length; i++) {
    final (x, y) = _sheepHomes[i];
    final t = v.shown(i);
    final home = Offset(s.width * x, s.height * y);
    final near = center + Offset((i.isEven ? -1 : 1) * s.width * (0.1 + (i ~/ 2) * 0.06), s.height * 0.06);
    final at = Offset.lerp(home, near, t)!;
    final h = s.height * 0.16;
    final hop = v.pulse[i] * s.height * 0.03;
    paintAnimal(canvas, Animal.sheep, Rect.fromLTWH(at.dx - h / 2, at.dy - h - hop, h, h),
        walk: t > 0 && t < 1 ? v.time : 0, facingLeft: at.dx > center.dx, blink: blinkAt(v.time, i * 1.1));
  }
}

// 2. Le prophète Samuel verse l'huile sur la tête de David.
void _anoint(Canvas canvas, Size s, StageView v) {
  _hills(canvas, s, v.time, sky: Skies.dawn);
  paintPerson(canvas, feetAt(s, 0.36, 0.92), s.height * 0.46, _samuel, wave: 0.7, blink: blinkAt(v.time, 0.8));
  final horn = boxAt(s, 0.46, 0.52, 0.12);
  paintThing(canvas, 'horn', horn, glow: v.eased);
  final head = Offset(s.width * 0.56, s.height * 0.92 - s.height * 0.4 * 0.86 * 0.8);
  if (v.eased > 0) {
    for (var k = 0; k < 4; k++) {
      final y = horn.top + (head.dy - horn.top) * ((v.time * 0.8 + k / 4) % 1);
      canvas.drawCircle(Offset(head.dx - s.width * 0.02, y), s.height * 0.008, Paint()..color = const Color(0xFFF2C14E));
    }
    canvas.drawCircle(head, s.height * 0.22 * v.eased,
        Paint()..color = Palette.sun.withValues(alpha: 0.4 * v.eased)..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.07));
  }
  paintPerson(canvas, feetAt(s, 0.56, 0.92), s.height * 0.4, david, facingLeft: true, blink: blinkAt(v.time, 1.7));
  for (var k = 0; k < 3; k++) {
    paintPerson(canvas, feetAt(s, 0.74 + k * 0.08, 0.9), s.height * 0.38, _soldiers[k].copyWithoutHelmet(), facingLeft: true,
        blink: blinkAt(v.time, k.toDouble()));
  }
}

// 3. Le géant Goliath défie l'armée d'Israël ; David s'avance.
void _goliath(Canvas canvas, Size s, StageView v) {
  _hills(canvas, s, v.time, sky: Skies.desert);
  final shout = math.sin(v.time * 1.5) > 0.6 ? math.sin(v.time * 30) * s.height * 0.004 : 0.0;
  paintPerson(canvas, feetAt(s, 0.78, 0.92), s.height * 0.64, _goliathStyle, facingLeft: true, bob: shout, wave: 0.4,
      blink: blinkAt(v.time, 0.3));
  for (var k = 0; k < 3; k++) {
    paintPerson(canvas, feetAt(s, 0.36 + k * 0.08, 0.9), s.height * 0.34, _soldiers[k], blink: blinkAt(v.time, k * 1.4));
  }
  final step = v.eased * s.width * 0.12;
  paintPerson(canvas, feetAt(s, 0.2, 0.92) + Offset(step, 0), s.height * 0.38, david, blink: blinkAt(v.time, 1.1),
      wave: v.done ? 0.8 : 0);
}

// 4. David choisit cinq pierres bien lisses dans le torrent.
void _stones(Canvas canvas, Size s, StageView v) {
  _hills(canvas, s, v.time);
  final brook = Path()
    ..moveTo(0, s.height * 0.72)
    ..quadraticBezierTo(s.width * 0.5, s.height * 0.64, s.width, s.height * 0.74)
    ..lineTo(s.width, s.height * 0.86)
    ..quadraticBezierTo(s.width * 0.5, s.height * 0.78, 0, s.height * 0.86)
    ..close();
  drawPaper(canvas, brook, const Color(0xFF6CB8D4), elevation: 1, light: 0.25);
  for (var i = 0; i < _stoneSpots.length; i++) {
    final t = v.shown(i);
    final home = Offset(s.width * _stoneSpots[i], s.height * 0.78);
    final bag = Offset(s.width * 0.12, s.height * 0.62);
    final at = Offset.lerp(home, bag, t)!;
    if (t < 0.98) {
      paintThing(canvas, 'stone', Rect.fromCenter(center: at, width: s.height * 0.16 * (1 - t * 0.5), height: s.height * 0.16 * (1 - t * 0.5)));
    }
  }
  paintPerson(canvas, feetAt(s, 0.1, 0.95), s.height * 0.42, david, blink: blinkAt(v.time, 0.7), wave: v.pulse.reduce(math.max) * 0.6);
  // Le petit sac de berger se remplit.
  final count = (v.progress * 5).round();
  for (var k = 0; k < count; k++) {
    canvas.drawCircle(Offset(s.width * (0.14 + k * 0.012), s.height * 0.62), s.height * 0.012, Paint()..color = const Color(0xFFB8B3AA));
  }
}

// 5. Au nom de l'Éternel : la pierre de la fronde fait tomber le géant.
void _sling(Canvas canvas, Size s, StageView v) {
  _hills(canvas, s, v.time, sky: Skies.desert);
  final t = v.eased;
  // Goliath bascule en arrière quand la pierre le touche.
  final fall = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
  canvas.save();
  final feet = feetAt(s, 0.78, 0.92);
  canvas.translate(feet.dx, feet.dy);
  // Il tombe le visage contre terre (1 Samuel 17.49), vers David.
  canvas.rotate(-fall * 1.4);
  canvas.translate(-feet.dx, -feet.dy);
  paintPerson(canvas, feet, s.height * 0.64, _goliathStyle, facingLeft: true, blink: fall > 0 ? 1 : blinkAt(v.time, 0.3));
  canvas.restore();
  if (fall >= 1) {
    for (var k = 0; k < 3; k++) {
      final a = v.time * 3 + k * 2.1;
      paintThing(canvas, 'star', Rect.fromCenter(center: Offset(s.width * 0.5 + math.cos(a) * s.width * 0.03, s.height * 0.8 + math.sin(a) * s.height * 0.03),
          width: s.height * 0.04, height: s.height * 0.04));
    }
  }
  paintPerson(canvas, feetAt(s, 0.22, 0.92), s.height * 0.38, david, raisedBoth: t > 0 && t < 0.55, wave: t > 0 ? 0.9 : 0,
      blink: blinkAt(v.time, 1.5));
  if (t > 0 && t < 0.55) {
    // La fronde tourne, puis la pierre file vers le géant.
    final spin = v.time * 18;
    final hand = Offset(s.width * 0.22, s.height * 0.92 - s.height * 0.38 * 0.86 * 1.05);
    canvas.drawCircle(hand + Offset(math.cos(spin), math.sin(spin) * 0.5) * s.height * 0.05, s.height * 0.012, Paint()..color = const Color(0xFFB8B3AA));
  }
  if (t >= 0.25 && t < 0.6) {
    final k = ((t - 0.25) / 0.35).clamp(0.0, 1.0);
    final from = Offset(s.width * 0.24, s.height * 0.5);
    final to = Offset(s.width * 0.75, s.height * 0.4);
    final p = Offset.lerp(from, to, k)! + Offset(0, -math.sin(k * math.pi) * s.height * 0.1);
    canvas.drawCircle(p, s.height * 0.015, Paint()..color = const Color(0xFF9A948B));
  }
  if (v.done) {
    for (var k = 0; k < 3; k++) {
      paintPerson(canvas, feetAt(s, 0.36 + k * 0.08, 0.9), s.height * 0.34, _soldiers[k], raisedBoth: true,
          wave: 0.6 + 0.4 * math.sin(v.time * 4 + k), blink: blinkAt(v.time, k.toDouble()));
    }
  }
}

// 6. David, devenu roi, chante : « L'Éternel est mon berger. »
void _psalm(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.dusk);
  paintStarField(canvas, s, v.time, count: 30, opacity: 0.8);
  paintHills(canvas, s, v.time, baselines: const [0.66, 0.78, 0.88], colors: Lands.green, seed: 137);
  for (final (fx, i) in const [(0.18, 0), (0.28, 1), (0.82, 2)]) {
    paintAnimal(canvas, Animal.sheep, boxAt(s, fx, 0.94, 0.11), facingLeft: fx > 0.5, blink: blinkAt(v.time, i * 1.3));
  }
  paintPerson(canvas, feetAt(s, 0.48, 0.94), s.height * 0.44, v.eased > 0.5 ? _king : david, blink: blinkAt(v.time, 0.6));
  paintThing(canvas, 'harp', boxAt(s, 0.58, 0.74, 0.2));
  if (v.eased > 0) {
    // Des notes de musique qui s'envolent.
    for (var k = 0; k < 5; k++) {
      final phase = (v.time * 0.4 + k / 5) % 1;
      final p = Offset(s.width * (0.6 + 0.05 * math.sin(phase * 6 + k)), s.height * (0.56 - phase * 0.4));
      final note = Paint()..color = Palette.sun.withValues(alpha: (1 - phase) * v.eased);
      canvas.drawCircle(p, s.height * 0.014, note);
      canvas.drawLine(p + Offset(s.height * 0.012, 0), p + Offset(s.height * 0.012, -s.height * 0.05), note..strokeWidth = 2.5);
    }
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _hills(canvas, s, 0);
  paintThing(canvas, 'tree', boxAt(s, 0.88, 0.62, 0.44));
  paintThing(canvas, 'tree', boxAt(s, 0.18, 0.6, 0.3));
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'stone', boxAt(s, 0.36, 1.0, 0.16, aspect: 1.4));
  paintThing(canvas, 'bush', boxAt(s, 0.1, 1.0, 0.16, aspect: 1.3));
  paintThing(canvas, 'stone', boxAt(s, 0.6, 1.0, 0.1, aspect: 1.3));
  paintThing(canvas, 'bush', boxAt(s, 0.76, 1.0, 0.13, aspect: 1.4));
  paintThing(canvas, 'stone', boxAt(s, 0.47, 1.0, 0.07, aspect: 1.4));
  drawPaper(canvas, Path()..addRect(Rect.fromLTWH(s.width * 0.84, s.height * 0.34, s.width * 0.12, s.height * 0.04)), const Color(0xFF8A5634),
      elevation: 3);
}

extension on PersonStyle {
  /// Les frères de David, sans casque.
  PersonStyle copyWithoutHelmet() => PersonStyle(skin: skin, robe: robe, headcloth: headcloth, sash: sash, beard: beard, scale: 0.95);
}

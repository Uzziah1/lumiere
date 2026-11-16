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
import '../nt/nt.dart';
import '../registry.dart';

/// La naissance de Jésus (Luc 1 et 2, Matthieu 2).
final naissancePack = StoryPack.scripted(
  scripts: {
    'annonce': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.14, 0.20, 0.40, 0.78)],
      sfx: Sfx.chime,
      paint: _annonce,
    ),
    'voyage': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.04, 0.40, 0.36, 0.80)],
      paint: _voyage,
    ),
    'etable': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.34, 0.20, 0.66, 0.74)],
      sfx: Sfx.chime,
      paint: _etable,
    ),
    'bergers': StageScript(
      targets: [for (final (x, y) in _angels) Rect.fromCenter(center: Offset(x, y), width: 0.14, height: 0.26)],
      sfx: Sfx.chime,
      paint: _bergers,
    ),
    'visite': StageScript(
      targets: [for (var i = 0; i < 3; i++) Rect.fromLTRB(0.02 + i * 0.1, 0.46, 0.12 + i * 0.1, 0.80)],
      paint: _visite,
    ),
    'mages': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.12, 0.2),
      swipeTo: Offset(0.74, 0.2),
      sfx: Sfx.chime,
      paint: _mages,
    ),
  },
  stickerScene: 'etable',
  seekScene: PaintedSeekScene(
    spots: const {
      'sheep': (Offset(0.18, 0.76), 0.16),
      'mouse': (Offset(0.44, 0.88), 0.07),
      'owl': (Offset(0.86, 0.22), 0.13),
      'dove': (Offset(0.14, 0.24), 0.1),
      'rabbit': (Offset(0.66, 0.80), 0.12),
      'ladybug': (Offset(0.56, 0.52), 0.05),
      'snail': (Offset(0.92, 0.84), 0.07),
      'star': (Offset(0.78, 0.40), 0.08),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _angels = [(0.24, 0.24), (0.5, 0.16), (0.76, 0.24)];

const _shepherds = [
  PersonStyle(skin: Color(0xFF7D4A30), robe: Color(0xFF9C7A54), headcloth: Color(0xFFE6D8BE), beard: Color(0xFF2E1E15)),
  PersonStyle(skin: Color(0xFFA06A45), robe: Color(0xFF8C7B66), headcloth: Color(0xFFF0E2C8), beard: Color(0xFF4A3323)),
  PersonStyle(
    skin: Color(0xFF8E5A3B),
    robe: Color(0xFFB08A60),
    headcloth: Color(0xFF2E1E15),
    bareHead: true,
    scale: 0.7,
  ),
];

const _magi = [
  PersonStyle(
    skin: Color(0xFF6E4029),
    robe: Color(0xFF8C79B5),
    headcloth: Color(0xFFF2C14E),
    sash: Color(0xFFF2C14E),
    beard: Color(0xFFE6E0D6),
    crown: true,
  ),
  PersonStyle(
    skin: Color(0xFFA9714B),
    robe: Color(0xFFB0413E),
    headcloth: Color(0xFFF2C14E),
    sash: Color(0xFFF2C14E),
    beard: Color(0xFF2E1E15),
    crown: true,
  ),
  PersonStyle(
    skin: Color(0xFF8A5537),
    robe: Color(0xFF3A7CA5),
    headcloth: Color(0xFFF2C14E),
    sash: Color(0xFFF2C14E),
    crown: true,
  ),
];

// 1. L'ange Gabriel annonce à Marie qu'elle aura un fils, Jésus.
void _annonce(Canvas canvas, Size s, StageView v) {
  paintHouse(canvas, s);
  paintPerson(
    canvas,
    feetAt(s, 0.66, 0.92),
    s.height * 0.44,
    NT.mary,
    facingLeft: true,
    blink: blinkAt(v.time, 0.6),
    raisedBoth: v.done,
    wave: v.done ? 0.4 : 0,
  );
  final t = v.eased;
  if (t > 0) {
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, t));
    paintAngel(canvas, feetAt(s, 0.27, 0.9), s.height * 0.46, v.time);
    canvas.restore();
  } else {
    final pulse = 0.5 + 0.5 * math.sin(v.time * 3);
    canvas.drawCircle(
      Offset(s.width * 0.27, s.height * 0.5),
      s.height * (0.05 + 0.02 * pulse),
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.03),
    );
  }
}

// 2. Le voyage vers Bethléhem : Marie sur l'âne, Joseph à côté.
void _voyage(Canvas canvas, Size s, StageView v) {
  paintRoad(canvas, s, v.time, sky: Skies.dawn);
  paintThing(canvas, 'city', boxAt(s, 0.86, 0.72, 0.18, aspect: 1.6));
  final go = v.eased * s.width * 0.42;
  final bob = v.progress < 1 ? (math.sin(v.time * 6)).abs() * s.height * 0.006 : 0.0;
  canvas.save();
  canvas.translate(go, 0);
  paintThing(canvas, 'donkey', boxAt(s, 0.18, 0.92, 0.24, aspect: 1.1).translate(0, -bob));
  paintPerson(canvas, feetAt(s, 0.17, 0.76), s.height * 0.26, NT.mary, blink: blinkAt(v.time, 1), bob: bob);
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.93),
    s.height * 0.36,
    NT.joseph,
    blink: blinkAt(v.time, 0.3),
    wave: v.pulse[0] * 0.6,
    bob: bob,
  );
  canvas.restore();
}

// 3. Pas de place à l'hôtellerie : Jésus naît dans une étable, couché dans une crèche.
void _etable(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, v.time, count: 60);
  paintThing(
    canvas,
    'star',
    Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.1), width: s.height * 0.08, height: s.height * 0.08),
  );
  paintHills(canvas, s, v.time, baselines: const [0.76, 0.88], colors: Lands.night, seed: 161);
  paintThing(canvas, 'city', boxAt(s, 0.14, 0.78, 0.16, aspect: 1.6));
  paintThing(canvas, 'stable', boxAt(s, 0.5, 0.82, 0.58, aspect: 1.1), glow: 0.3 + 0.7 * v.eased);
  if (v.eased > 0.3) {
    paintThing(canvas, 'manger', boxAt(s, 0.5, 0.9, 0.18, aspect: 1.2));
    paintBaby(canvas, Offset(s.width * 0.5, s.height * 0.75), s.height * 0.035, glow: v.eased);
    paintPerson(canvas, feetAt(s, 0.38, 0.94), s.height * 0.36, NT.mary, blink: blinkAt(v.time, 0.5));
    paintPerson(
      canvas,
      feetAt(s, 0.62, 0.94),
      s.height * 0.4,
      NT.joseph,
      facingLeft: true,
      blink: blinkAt(v.time, 1.5),
    );
  }
  paintAnimal(canvas, Animal.sheep, boxAt(s, 0.78, 0.94, 0.12), facingLeft: true);
  paintThing(canvas, 'donkey', boxAt(s, 0.86, 0.9, 0.2, aspect: 1.1));
}

// 4. Des anges annoncent la bonne nouvelle aux bergers.
void _bergers(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, v.time, count: 50);
  paintHills(canvas, s, v.time, baselines: const [0.72, 0.84], colors: Lands.night, seed: 163);
  final glow = v.shown(0) + v.shown(1) + v.shown(2);
  canvas.drawRect(Offset.zero & s, Paint()..color = Palette.sun.withValues(alpha: 0.08 * glow));
  for (var i = 0; i < _angels.length; i++) {
    final t = v.shown(i);
    final (x, y) = _angels[i];
    if (t <= 0) {
      canvas.drawCircle(Offset(s.width * x, s.height * y), s.height * 0.03, Paint()..color = const Color(0x55FFF6DC));
      continue;
    }
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, t));
    paintAngel(canvas, feetAt(s, x, y + 0.12), s.height * 0.22, v.time + i);
    canvas.restore();
  }
  for (var i = 0; i < 3; i++) {
    paintPerson(
      canvas,
      feetAt(s, 0.6 + i * 0.1, 0.94),
      s.height * 0.32,
      _shepherds[i],
      raisedBoth: glow > 0,
      wave: math.min(1, glow / 3) * 0.6,
      facingLeft: true,
      blink: blinkAt(v.time, i.toDouble()),
    );
  }
  for (final fx in [0.12, 0.22, 0.32]) {
    paintAnimal(canvas, Animal.sheep, boxAt(s, fx, 0.95, 0.11), blink: blinkAt(v.time, fx * 4));
  }
}

// 5. Les bergers viennent voir l'enfant Jésus.
void _visite(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, v.time, count: 40);
  paintHills(canvas, s, v.time, baselines: const [0.8, 0.9], colors: Lands.night, seed: 165);
  paintThing(canvas, 'stable', boxAt(s, 0.74, 0.84, 0.56, aspect: 1.1), glow: 1);
  paintThing(canvas, 'manger', boxAt(s, 0.74, 0.92, 0.16, aspect: 1.2));
  paintBaby(canvas, Offset(s.width * 0.74, s.height * 0.78), s.height * 0.032, glow: 1);
  paintPerson(canvas, feetAt(s, 0.64, 0.95), s.height * 0.34, NT.mary, facingLeft: false, blink: blinkAt(v.time, 0.5));
  paintPerson(canvas, feetAt(s, 0.86, 0.95), s.height * 0.38, NT.joseph, facingLeft: true, blink: blinkAt(v.time, 1.5));
  for (var i = 0; i < 3; i++) {
    final t = v.shown(i);
    final fx = 0.07 + i * 0.1 + t * (0.34 - i * 0.04);
    paintPerson(
      canvas,
      feetAt(s, fx, 0.94),
      s.height * 0.32,
      _shepherds[i],
      bob: t > 0 && t < 1 ? (math.sin(v.time * 8)).abs() * s.height * 0.006 : 0,
      blink: blinkAt(v.time, i.toDouble()),
      raisedBoth: t >= 1,
      wave: t >= 1 ? 0.4 : 0,
    );
  }
}

// 6. Des mages suivent l'étoile et apportent leurs cadeaux.
void _mages(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.dusk);
  paintStarField(canvas, s, v.time, count: 30, opacity: 0.7);
  paintHills(canvas, s, v.time, baselines: const [0.7, 0.82], colors: Lands.desert, seed: 167);
  paintThing(canvas, 'city', boxAt(s, 0.84, 0.76, 0.18, aspect: 1.4));
  final star = Offset(s.width * (0.12 + 0.62 * v.eased), s.height * 0.2);
  canvas.drawCircle(
    star,
    s.height * 0.1,
    Paint()
      ..color = Palette.sun.withValues(alpha: 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.05),
  );
  paintThing(canvas, 'star', Rect.fromCenter(center: star, width: s.height * 0.12, height: s.height * 0.12));
  if (v.done) {
    canvas.drawLine(
      star,
      Offset(s.width * 0.84, s.height * 0.6),
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.4)
        ..strokeWidth = 3,
    );
  }
  final go = v.eased * s.width * 0.36;
  for (var i = 0; i < 3; i++) {
    final x = 0.08 + i * 0.12;
    canvas.save();
    canvas.translate(go, 0);
    paintThing(canvas, 'camel', boxAt(s, x, 0.93, 0.26, aspect: 1.1));
    paintPerson(canvas, feetAt(s, x - 0.01, 0.76), s.height * 0.22, _magi[i], blink: blinkAt(v.time, i * 1.2));
    canvas.restore();
  }
}

void _seekBackground(Canvas canvas, Size s) {
  paintHouse(canvas, s, wall: const Color(0xFFC9A066), lamp: 1);
  paintThing(canvas, 'manger', boxAt(s, 0.5, 0.92, 0.2, aspect: 1.2));
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.8, s.height * 0.28, s.width * 0.12, s.height * 0.04)),
    const Color(0xFF7E4A2A),
    elevation: 3,
  );
}

void _seekForeground(Canvas canvas, Size s) {
  final hay = Path()
    ..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.18, s.height * 0.94), width: s.width * 0.2, height: s.height * 0.2),
    )
    ..addOval(
      Rect.fromCenter(center: Offset(s.width * 0.66, s.height * 0.96), width: s.width * 0.16, height: s.height * 0.16),
    );
  drawPaper(canvas, hay, const Color(0xFFE6C15A), elevation: 5, light: 0.18);
  paintThing(canvas, 'crate', boxAt(s, 0.42, 1.0, 0.12));
  paintThing(canvas, 'jar', boxAt(s, 0.92, 1.0, 0.16));
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.06, s.height * 0.28, s.width * 0.12, s.height * 0.04)),
    const Color(0xFF7E4A2A),
    elevation: 3,
  );
}

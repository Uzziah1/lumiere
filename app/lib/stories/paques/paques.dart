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

/// Pâques : la mort et la résurrection de Jésus (Luc 19 à 24).
/// La croix est montrée avec retenue : une silhouette au loin, au crépuscule.
final paquesPack = StoryPack.scripted(
  scripts: {
    'rameaux': StageScript(
      targets: [for (final x in _palms) Rect.fromCenter(center: Offset(x, 0.7), width: 0.12, height: 0.2)],
      paint: _rameaux,
    ),
    'cene': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.42, 0.50, 0.58, 0.76)],
      sfx: Sfx.chime,
      paint: _cene,
    ),
    'croix': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 3,
      targets: [Rect.fromLTRB(0.40, 0.14, 0.60, 0.60)],
      sfx: Sfx.chime,
      paint: _croix,
    ),
    'tombeau': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.40, 0.04, 0.60, 0.30)],
      paint: _tombeau,
    ),
    'matin': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.50, 0.36, 0.86, 0.80)],
      sfx: Sfx.chime,
      paint: _matin,
    ),
    'vivant': StageScript(
      targets: [for (final x in _friends) Rect.fromLTRB(x - 0.06, 0.40, x + 0.06, 0.80)],
      sfx: Sfx.chime,
      paint: _vivant,
    ),
  },
  stickerScene: 'matin',
  seekScene: PaintedSeekScene(
    spots: const {
      'flower': (Offset(0.20, 0.84), 0.08),
      'palm': (Offset(0.88, 0.60), 0.16),
      'dove': (Offset(0.62, 0.18), 0.1),
      'mouse': (Offset(0.40, 0.88), 0.06),
      'jar': (Offset(0.08, 0.80), 0.11),
      'bird': (Offset(0.30, 0.20), 0.08),
      'rabbit': (Offset(0.70, 0.86), 0.1),
      'ladybug': (Offset(0.52, 0.92), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _palms = [0.3, 0.46, 0.62];
const _friends = [0.24, 0.38, 0.66, 0.8];

// 1. Jésus entre à Jérusalem sur un ânon ; la foule agite des palmes : « Hosanna ! »
void _rameaux(Canvas canvas, Size s, StageView v) {
  paintJerusalem(canvas, s, v.time, sky: Skies.day, horizon: 0.56);
  for (var i = 0; i < _palms.length; i++) {
    final t = v.shown(i);
    final c = Offset(s.width * _palms[i], s.height * (0.88 - 0.18 * t));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(t > 0 ? math.sin(v.time * 4 + i) * 0.3 : math.pi / 2);
    paintThing(
      canvas,
      'palm',
      Rect.fromCenter(center: Offset.zero, width: s.height * 0.14, height: s.height * 0.2),
    );
    canvas.restore();
  }
  paintCrowd(
    canvas,
    s,
    v.time,
    from: 0.24,
    to: 0.68,
    fy: 0.97,
    h: 0.32,
    count: 4,
    wave: (v.shown(0) + v.shown(1) + v.shown(2)) / 3,
  );
  final go = v.eased * s.width * 0.1;
  canvas.save();
  canvas.translate(go, 0);
  paintThing(canvas, 'donkey', boxAt(s, 0.84, 0.95, 0.26, aspect: 1.1));
  paintPerson(
    canvas,
    feetAt(s, 0.83, 0.78),
    s.height * 0.3,
    NT.jesus,
    facingLeft: true,
    wave: 0.4,
    blink: blinkAt(v.time, 0.7),
  );
  canvas.restore();
}

// 2. Le dernier repas : Jésus partage le pain et la coupe avec ses disciples.
void _cene(Canvas canvas, Size s, StageView v) {
  paintHouse(canvas, s, wall: const Color(0xFFC9A066), lamp: 0.8);
  canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0x22301A0A));
  for (var i = 0; i < 4; i++) {
    final x = i < 2 ? 0.2 + i * 0.12 : 0.68 + (i - 2) * 0.12;
    paintPerson(
      canvas,
      feetAt(s, x, 0.92),
      s.height * 0.4,
      NT.disciples[i],
      facingLeft: i >= 2,
      blink: blinkAt(v.time, i * 1.3),
    );
  }
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.9),
    s.height * 0.44,
    NT.jesus,
    raisedBoth: v.eased > 0,
    wave: 0.4 * v.eased,
    blink: blinkAt(v.time, 0.7),
  );
  final table = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.14, s.height * 0.7, s.width * 0.72, s.height * 0.08),
        Radius.circular(s.height * 0.02),
      ),
    );
  drawPaper(canvas, table, const Color(0xFF7E4A2A), elevation: 4);
  final t = v.eased;
  paintThing(canvas, 'bread', boxAt(s, 0.47 - 0.03 * t, 0.71, 0.06, aspect: 1.2));
  if (t > 0) paintThing(canvas, 'bread', boxAt(s, 0.53 + 0.03 * t, 0.71, 0.05, aspect: 1.2));
  // La coupe.
  final cup = Path()
    ..moveTo(s.width * 0.6, s.height * 0.63)
    ..lineTo(s.width * 0.64, s.height * 0.63)
    ..quadraticBezierTo(s.width * 0.64, s.height * 0.67, s.width * 0.625, s.height * 0.68)
    ..lineTo(s.width * 0.625, s.height * 0.71)
    ..lineTo(s.width * 0.615, s.height * 0.71)
    ..lineTo(s.width * 0.615, s.height * 0.68)
    ..quadraticBezierTo(s.width * 0.6, s.height * 0.67, s.width * 0.6, s.height * 0.63)
    ..close();
  drawPaper(canvas, cup, const Color(0xFFD9B27A), elevation: 2, light: 0.3);
  paintThing(canvas, 'fruit', boxAt(s, 0.3, 0.71, 0.05));
  paintThing(canvas, 'fruit', boxAt(s, 0.72, 0.71, 0.05));
}

// 3. Jésus meurt sur la croix pour nous. Le ciel s'assombrit.
void _croix(Canvas canvas, Size s, StageView v) {
  final t = v.eased;
  paintSkyGradient(canvas, s, [for (var i = 0; i < 3; i++) Color.lerp(Skies.dusk[i], Skies.night[i], 0.4)!]);
  // La lumière de l'amour de Dieu, qui grandit doucement derrière la croix.
  canvas.drawCircle(
    Offset(s.width * 0.5, s.height * 0.3),
    s.height * (0.18 + 0.2 * t),
    Paint()
      ..shader = Gradient.radial(Offset(s.width * 0.5, s.height * 0.3), s.height * (0.18 + 0.2 * t), [
        Palette.sun.withValues(alpha: 0.2 + 0.4 * t),
        Palette.sunHalo.withValues(alpha: 0),
      ]),
  );
  final hill = Path()
    ..moveTo(0, s.height)
    ..lineTo(0, s.height * 0.78)
    ..quadraticBezierTo(s.width * 0.5, s.height * 0.5, s.width, s.height * 0.78)
    ..lineTo(s.width, s.height)
    ..close();
  drawPaper(canvas, hill, const Color(0xFF4A3A44), elevation: 4);
  for (final (fx, h) in [(0.34, 0.26), (0.5, 0.36), (0.66, 0.26)]) {
    final base = s.height * (0.78 - 0.28 * (1 - ((fx - 0.5).abs() * 2) * ((fx - 0.5).abs() * 2)));
    final rect = Rect.fromLTWH(
      s.width * fx - s.height * h * 0.3,
      base - s.height * h,
      s.height * h * 0.6,
      s.height * h,
    );
    canvas.saveLayer(
      rect.inflate(20),
      Paint()..colorFilter = const ColorFilter.mode(Color(0xFF2A2026), BlendMode.srcIn),
    );
    paintThing(canvas, 'cross', rect);
    canvas.restore();
  }
  paintPerson(canvas, feetAt(s, 0.2, 0.96), s.height * 0.3, NT.mary, blink: blinkAt(v.time, 0.6));
  paintPerson(canvas, feetAt(s, 0.12, 0.98), s.height * 0.3, NT.disciples[3], blink: blinkAt(v.time, 1.6));
}

// 4. On met Jésus dans un tombeau fermé par une grande pierre. Un jour, deux jours…
void _tombeau(Canvas canvas, Size s, StageView v) {
  final days = v.progress * 3;
  final light = v.done ? 0.0 : (math.sin(days * math.pi * 2 - math.pi / 2) + 1) / 2;
  paintSkyGradient(canvas, s, [
    for (var i = 0; i < 3; i++) Color.lerp(Skies.night[i], Skies.dusk[i], light * 0.6)!,
  ]);
  paintStarField(canvas, s, v.time, count: 40, opacity: 1 - light * 0.6);
  paintThing(
    canvas,
    'moon',
    Rect.fromCenter(
      center: Offset(s.width * 0.5, s.height * 0.17),
      width: s.height * 0.12,
      height: s.height * 0.12,
    ),
  );
  for (var d = 0; d < 3; d++) {
    final lit = days > d + 0.5 || v.done;
    canvas.drawCircle(
      Offset(s.width * (0.1 + d * 0.06), s.height * 0.1),
      s.height * 0.022,
      Paint()..color = lit ? Palette.sun : const Color(0x55FFFFFF),
    );
  }
  paintHills(canvas, s, v.time, baselines: const [0.7, 0.84], colors: Lands.night, seed: 241);
  paintThing(canvas, 'tomb', boxAt(s, 0.66, 0.9, 0.46, aspect: 1.1));
  paintThing(canvas, 'tree', boxAt(s, 0.2, 0.88, 0.3));
  paintThing(canvas, 'flower', boxAt(s, 0.44, 0.94, 0.06));
}

// 5. Le dimanche matin, la pierre est roulée ! Un ange dit : « Il est ressuscité ! »
void _matin(Canvas canvas, Size s, StageView v) {
  final t = v.eased;
  paintSkyGradient(canvas, s, Skies.dawn);
  paintSun(canvas, Offset(s.width * 0.12, s.height * (0.5 - 0.3 * t)), s.height * 0.08);
  paintHills(canvas, s, v.time, baselines: const [0.7, 0.84], colors: Lands.lush, seed: 241);
  paintThing(canvas, 'tomb', boxAt(s, 0.66, 0.9, 0.46, aspect: 1.1), glow: t);
  paintThing(canvas, 'tree', boxAt(s, 0.92, 0.88, 0.3));
  for (final fx in [0.44, 0.5, 0.86]) {
    paintThing(canvas, 'flower', boxAt(s, fx, 0.95, 0.06 + 0.02 * t));
  }
  if (t > 0.5) {
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, (t - 0.5) * 2));
    paintAngel(canvas, feetAt(s, 0.86, 0.9), s.height * 0.4, v.time, facingLeft: true);
    canvas.restore();
  }
  for (var i = 0; i < 2; i++) {
    paintPerson(
      canvas,
      feetAt(s, 0.18 + i * 0.1, 0.95),
      s.height * 0.38,
      i == 0 ? NT.mary : NT.crowd[1],
      raisedBoth: t > 0.6,
      wave: t * 0.5,
      blink: blinkAt(v.time, i * 1.4),
    );
  }
  paintThing(canvas, 'jar', boxAt(s, 0.36, 0.95, 0.08));
}

// 6. Jésus vivant apparaît à ses disciples : « La paix soit avec vous ! »
void _vivant(Canvas canvas, Size s, StageView v) {
  paintHouse(canvas, s, wall: const Color(0xFFE6CFA3), lamp: 0.6);
  final joy = v.done ? 1.0 : 0.0;
  canvas.drawCircle(
    Offset(s.width * 0.52, s.height * 0.5),
    s.height * 0.32,
    Paint()
      ..shader = Gradient.radial(Offset(s.width * 0.52, s.height * 0.5), s.height * 0.32, [
        Palette.sun.withValues(alpha: 0.5 + 0.2 * joy),
        Palette.sunHalo.withValues(alpha: 0),
      ]),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.52, 0.94),
    s.height * 0.48,
    NT.jesus,
    raisedBoth: true,
    wave: 0.35,
    blink: blinkAt(v.time, 0.7),
  );
  for (var i = 0; i < _friends.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _friends[i], 0.96),
      s.height * 0.4,
      NT.disciples[i],
      facingLeft: _friends[i] > 0.52,
      raisedBoth: t >= 1,
      wave: t * 0.6,
      bob: t > 0 && t < 1 ? math.sin(t * math.pi) * s.height * 0.04 : 0,
      blink: blinkAt(v.time, i * 1.2),
    );
  }
}

void _seekBackground(Canvas canvas, Size s) {
  paintSkyGradient(canvas, s, Skies.dawn);
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.2, -s.height * 0.05), 0, intensity: 0.3);
  paintHills(canvas, s, 0, baselines: const [0.66, 0.8], colors: Lands.lush, seed: 243);
  paintThing(canvas, 'tomb', boxAt(s, 0.58, 0.84, 0.36, aspect: 1.1), glow: 1);
}

void _seekForeground(Canvas canvas, Size s) {
  final bush = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.3, s.height * 0.98),
        width: s.width * 0.2,
        height: s.height * 0.14,
      ),
    )
    ..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.82, s.height * 0.99),
        width: s.width * 0.18,
        height: s.height * 0.12,
      ),
    );
  drawPaper(canvas, bush, const Color(0xFF5E9B45), elevation: 4, light: 0.15);
  for (final fx in [0.1, 0.46, 0.62, 0.96]) {
    paintThing(canvas, 'flower', boxAt(s, fx, 1.0, 0.07));
  }
  paintAnimal(canvas, Animal.snail, boxAt(s, 0.94, 0.9, 0.05));
}

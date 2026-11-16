import 'dart:math' as math;
import 'dart:ui';

import '../../art/animals.dart';
import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/landscape.dart';
import '../../art/scenery.dart';
import '../../art/weather.dart';
import '../../audio/audio.dart';
import '../../story/scripted_stage.dart';
import '../../theme/palette.dart';
import '../nt/nt.dart';
import '../registry.dart';

/// L'ascension et la Pentecôte (Actes 1 et 2).
final pentecotePack = StoryPack.scripted(
  scripts: {
    'ascension': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.5, 0.7),
      swipeTo: Offset(0.5, 0.15),
      sfx: Sfx.chime,
      paint: _ascension,
    ),
    'priere': StageScript(
      targets: [for (final x in _seats) Rect.fromLTRB(x - 0.06, 0.44, x + 0.06, 0.82)],
      paint: _priere,
    ),
    'vent': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.05, 0.3),
      swipeTo: Offset(0.95, 0.3),
      sfx: Sfx.whoosh,
      paint: _vent,
    ),
    'flammes': StageScript(
      targets: [for (final x in _seats) Rect.fromCenter(center: Offset(x, 0.40), width: 0.1, height: 0.16)],
      sfx: Sfx.chime,
      paint: _flammes,
    ),
    'langues': StageScript(
      targets: [for (final x in _nations) Rect.fromLTRB(x - 0.07, 0.44, x + 0.07, 0.82)],
      paint: _langues,
    ),
    'eglise': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.06, 0.30, 0.30, 0.80)],
      sfx: Sfx.chime,
      paint: _eglise,
    ),
  },
  stickerScene: 'flammes',
  seekScene: PaintedSeekScene(
    spots: const {
      'flame': (Offset(0.70, 0.28), 0.08),
      'scroll': (Offset(0.18, 0.86), 0.09),
      'bread': (Offset(0.52, 0.90), 0.07),
      'dove': (Offset(0.36, 0.16), 0.09),
      'jar': (Offset(0.90, 0.84), 0.12),
      'basket': (Offset(0.64, 0.86), 0.1),
      'mouse': (Offset(0.06, 0.92), 0.06),
      'coin': (Offset(0.40, 0.70), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _seats = [0.2, 0.4, 0.6, 0.8];
const _nations = [0.2, 0.5, 0.8];

/// Des visiteurs venus de nombreux pays.
const _visitors = [
  PersonStyle(
    skin: Color(0xFF5C3A22),
    robe: Color(0xFF2F8F6E),
    headcloth: Color(0xFFF2C14E),
    sash: Color(0xFFB0413E),
    beard: Color(0xFF1E140D),
  ),
  PersonStyle(
    skin: Color(0xFFD6A77A),
    robe: Color(0xFF8C79B5),
    headcloth: Color(0xFFF5EEE0),
    sash: Color(0xFFF2C14E),
    beard: Color(0xFF7A5230),
  ),
  PersonStyle(
    skin: Color(0xFF8E5A3B),
    robe: Color(0xFFE07A3F),
    headcloth: Color(0xFF3A7CA5),
    sash: Color(0xFFF5EEE0),
    veil: true,
  ),
];

// La chambre haute : les disciples réunis.
void _room(Canvas canvas, Size s, StageView v, {double fire = 0, double joy = 0}) {
  paintHouse(canvas, s, wall: const Color(0xFFE6CFA3), lamp: 0.6 + 0.4 * fire);
  for (var i = 0; i < _seats.length; i++) {
    paintPerson(
      canvas,
      feetAt(s, _seats[i], 0.94),
      s.height * 0.42,
      i == 0 ? NT.mary : NT.disciples[i],
      facingLeft: _seats[i] > 0.5,
      raisedBoth: joy > 0.5,
      wave: joy * 0.5,
      blink: blinkAt(v.time, i * 1.3),
    );
  }
}

// La flamme sur une tête.
void _flameOn(Canvas canvas, Size s, double x, double t, double time) {
  if (t <= 0) return;
  final c = Offset(s.width * x, s.height * (0.42 + 0.01 * math.sin(time * 6 + x * 10)));
  final size = s.height * 0.08 * t;
  canvas.drawCircle(
    c,
    size,
    Paint()
      ..color = Palette.sun.withValues(alpha: 0.4 * t)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.6),
  );
  paintThing(
    canvas,
    'flame',
    Rect.fromCenter(center: c, width: size, height: size * 1.2),
    time: time,
  );
}

// 1. Jésus promet l'Esprit saint, puis il monte au ciel et une nuée le cache.
void _ascension(Canvas canvas, Size s, StageView v) {
  final t = v.eased;
  paintSkyGradient(canvas, s, Skies.day);
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.3 + 0.7 * t);
  paintHills(canvas, s, v.time, baselines: const [0.66, 0.8], colors: Lands.green, seed: 251);
  final y = 0.86 - 0.62 * t;
  paintPerson(
    canvas,
    feetAt(s, 0.5, y),
    s.height * 0.42,
    NT.jesus,
    raisedBoth: true,
    wave: 0.4,
    blink: blinkAt(v.time, 0.7),
  );
  if (t > 0.5) {
    final cloud = Offset(s.width * 0.5, s.height * (y - 0.04));
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, (t - 0.5) * 2));
    drawPaper(canvas, cloudPath(cloud, s.width * 0.16), Palette.cloud, elevation: 4, light: 0.3);
    canvas.restore();
  }
  for (var i = 0; i < 4; i++) {
    final x = i < 2 ? 0.14 + i * 0.12 : 0.74 + (i - 2) * 0.12;
    paintPerson(
      canvas,
      feetAt(s, x, 0.96),
      s.height * 0.38,
      NT.disciples[i],
      facingLeft: i >= 2,
      raisedBoth: t > 0.3,
      wave: 0.3,
      blink: blinkAt(v.time, i * 1.1),
    );
  }
}

// 2. Les disciples restent ensemble à Jérusalem et prient.
void _priere(Canvas canvas, Size s, StageView v) {
  _room(canvas, s, v);
  for (var i = 0; i < _seats.length; i++) {
    final t = v.shown(i);
    if (t <= 0) continue;
    canvas.drawCircle(
      Offset(s.width * _seats[i], s.height * 0.62),
      s.height * 0.12 * t,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.25 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.05),
    );
  }
}

// 3. Le jour de la Pentecôte, un bruit comme un vent violent remplit la maison.
void _vent(Canvas canvas, Size s, StageView v) {
  _room(canvas, s, v, joy: v.done ? 1 : 0);
  final t = v.progress;
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = s.height * 0.012;
  for (var k = 0; k < 5; k++) {
    final y = s.height * (0.16 + k * 0.08);
    final start = ((v.time * 0.6 + k * 0.23) % 1) * s.width * 1.4 - s.width * 0.2;
    final strength = v.done ? 0.6 : t;
    if (strength <= 0) continue;
    paint.color = Color.fromRGBO(255, 251, 240, 0.7 * strength);
    final path = Path()
      ..moveTo(start, y)
      ..cubicTo(
        start + s.width * 0.08,
        y - s.height * 0.04,
        start + s.width * 0.16,
        y + s.height * 0.04,
        start + s.width * 0.24,
        y,
      );
    canvas.drawPath(path, paint);
  }
}

// 4. Des flammes comme de feu se posent sur chacun : ils sont remplis du Saint-Esprit.
void _flammes(Canvas canvas, Size s, StageView v) {
  final all = (v.shown(0) + v.shown(1) + v.shown(2) + v.shown(3)) / 4;
  _room(canvas, s, v, fire: all, joy: all);
  for (var i = 0; i < _seats.length; i++) {
    final t = v.shown(i);
    if (t <= 0) {
      canvas.drawCircle(
        Offset(s.width * _seats[i], s.height * 0.4),
        s.height * 0.02,
        Paint()..color = const Color(0x66FFE08A),
      );
      continue;
    }
    _flameOn(canvas, s, _seats[i], t, v.time);
  }
}

// 5. Ils parlent dans d'autres langues, et des gens de tous les pays les comprennent.
void _langues(Canvas canvas, Size s, StageView v) {
  paintJerusalem(canvas, s, v.time, sky: Skies.day, horizon: 0.5);
  for (var i = 0; i < 3; i++) {
    final x = 0.35 + i * 0.15;
    paintPerson(
      canvas,
      feetAt(s, x, 0.76),
      s.height * 0.28,
      NT.disciples[i],
      wave: 0.5,
      blink: blinkAt(v.time, i * 1.5),
    );
  }
  for (var i = 0; i < _nations.length; i++) {
    final t = v.shown(i);
    final x = _nations[i];
    paintPerson(
      canvas,
      feetAt(s, x, 0.97),
      s.height * 0.4,
      _visitors[i],
      raisedBoth: t >= 1,
      wave: t * 0.5,
      facingLeft: x > 0.5,
      blink: blinkAt(v.time, i * 1.1),
    );
    if (t > 0) {
      // Une bulle de couleur : « Je comprends ! »
      final c = Offset(s.width * (x + (x > 0.5 ? -0.06 : 0.06)), s.height * 0.44);
      final r = s.height * 0.05 * t;
      drawPaper(
        canvas,
        Path()..addOval(Rect.fromCircle(center: c, radius: r)),
        const Color(0xFFFFFBF0),
        elevation: 3,
      );
      paintThing(
        canvas,
        'flame',
        Rect.fromCircle(center: c, radius: r * 0.6),
        time: v.time,
      );
    }
  }
}

// 6. Pierre annonce Jésus ; trois mille personnes croient. L'Église est née !
void _eglise(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.dusk);
  paintHills(canvas, s, v.time, baselines: const [0.68, 0.82], colors: Lands.desert, seed: 253);
  paintPerson(
    canvas,
    feetAt(s, 0.18, 0.92),
    s.height * 0.46,
    NT.disciples[0],
    wave: 0.5 + 0.2 * math.sin(v.time * 2),
    blink: blinkAt(v.time, 0.4),
  );
  final groups = (v.progress * 3).round();
  for (var g = 0; g < 3; g++) {
    final shown = g < groups ? 1.0 : 0.25;
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, shown));
    paintCrowd(
      canvas,
      s,
      v.time,
      from: 0.34 + g * 0.2,
      to: 0.48 + g * 0.2,
      fy: 0.96 - g * 0.04,
      h: 0.34 - g * 0.03,
      count: 3,
      wave: g < groups ? 0.5 : 0,
      facingLeft: true,
      offset: g * 2,
    );
    canvas.restore();
  }
  if (v.done) {
    for (final fx in [0.4, 0.6, 0.8]) {
      paintThing(canvas, 'bread', boxAt(s, fx, 0.6, 0.06, aspect: 1.2));
    }
    paintAnimal(canvas, Animal.dove, boxAt(s, 0.5, 0.3, 0.1), blink: blinkAt(v.time, 2));
  }
}

void _seekBackground(Canvas canvas, Size s) {
  paintHouse(canvas, s, wall: const Color(0xFFE6CFA3), lamp: 1);
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.3, s.height * 0.74, s.width * 0.4, s.height * 0.06)),
    const Color(0xFF7E4A2A),
    elevation: 3,
  );
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'crate', boxAt(s, 0.28, 1.0, 0.12));
  paintThing(canvas, 'jar', boxAt(s, 0.76, 1.0, 0.14));
}

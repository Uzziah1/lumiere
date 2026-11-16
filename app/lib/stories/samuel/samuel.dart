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
import '../ot/heroes.dart';
import '../registry.dart';

/// Samuel entend Dieu (1 Samuel 1 à 3).
final samuelPack = StoryPack.scripted(
  scripts: {
    'anne': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.20, 0.36, 0.42, 0.82)],
      sfx: Sfx.chime,
      paint: _anne,
    ),
    'bebe': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.12, 0.6),
      swipeTo: Offset(0.6, 0.6),
      paint: _bebe,
    ),
    'lampes': StageScript(
      targets: [for (final x in _lamps) Rect.fromCenter(center: Offset(x, 0.4), width: 0.12, height: 0.16)],
      sfx: Sfx.chime,
      paint: _lampes,
    ),
    'appel': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.12, 0.50, 0.38, 0.84)],
      paint: _appel,
    ),
    'ecoute': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.20, 0.44, 0.40, 0.84)],
      sfx: Sfx.chime,
      paint: _ecoute,
    ),
    'prophete': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.40, 0.30, 0.62, 0.82)],
      sfx: Sfx.chime,
      paint: _prophete,
    ),
  },
  stickerScene: 'ecoute',
  seekScene: PaintedSeekScene(
    spots: const {
      'lamp': (Offset(0.30, 0.66), 0.1),
      'scroll': (Offset(0.62, 0.88), 0.09),
      'jar': (Offset(0.90, 0.84), 0.12),
      'snail': (Offset(0.14, 0.88), 0.06),
      'dove': (Offset(0.70, 0.22), 0.09),
      'mouse': (Offset(0.46, 0.92), 0.06),
      'owl': (Offset(0.88, 0.40), 0.1),
      'bread': (Offset(0.40, 0.66), 0.07),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _hannah = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFF3A7CA5),
  headcloth: Color(0xFFF0E2C8),
  sash: Color(0xFFE9B949),
  veil: true,
);

const _elkanah = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFF9C7A54),
  headcloth: Color(0xFFE6D8BE),
  beard: Color(0xFF2E1E15),
);

const _eli = PersonStyle(
  skin: Color(0xFF9C6440),
  robe: Color(0xFFF5EEE0),
  headcloth: Color(0xFF3A7CA5),
  sash: Color(0xFFE9B949),
  beard: Color(0xFFE6E0D6),
);

const _samuel = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFFF5EEE0),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFF3A7CA5),
  bareHead: true,
  scale: 0.66,
);

const _lamps = [0.3, 0.5, 0.7];

// La maison de Dieu à Silo : rideaux, colonnes et la lampe qui brûle la nuit.
void _sanctuary(Canvas canvas, Size s, {double night = 0}) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = Gradient.linear(Offset.zero, Offset(0, s.height), [
        Color.lerp(const Color(0xFFF2E2C2), const Color(0xFF2B2440), night)!,
        Color.lerp(const Color(0xFFE0C79A), const Color(0xFF3D3352), night)!,
      ]),
  );
  for (final fx in [0.08, 0.92]) {
    final curtain = Path()
      ..moveTo(s.width * (fx - 0.08), 0)
      ..lineTo(s.width * (fx + 0.08), 0)
      ..quadraticBezierTo(s.width * fx, s.height * 0.5, s.width * (fx + 0.06), s.height)
      ..lineTo(s.width * (fx - 0.06), s.height)
      ..quadraticBezierTo(s.width * fx, s.height * 0.5, s.width * (fx - 0.08), 0)
      ..close();
    drawPaper(
      canvas,
      curtain,
      Color.lerp(const Color(0xFF8C3B5E), const Color(0xFF4A2440), night)!,
      elevation: 4,
    );
  }
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.8, s.width, s.height * 0.2)),
    Color.lerp(const Color(0xFFC9A066), const Color(0xFF5C4A3A), night)!,
    elevation: 2,
  );
}

// 1. Anne prie au temple de Silo : elle demande un enfant à Dieu.
void _anne(Canvas canvas, Size s, StageView v) {
  _sanctuary(canvas, s);
  final t = v.eased;
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.32, -s.height * 0.05), v.time, intensity: 0.15 + 0.6 * t);
  paintPerson(
    canvas,
    feetAt(s, 0.31, 0.92),
    s.height * 0.44,
    _hannah,
    raisedBoth: true,
    wave: 0.2 + 0.2 * t,
    blink: t > 0 ? blinkAt(v.time, 1) : 1,
  );
  paintPerson(
    canvas,
    feetAt(s, 0.74, 0.92),
    s.height * 0.44,
    _eli,
    facingLeft: true,
    wave: t * 0.4,
    blink: blinkAt(v.time, 0.4),
  );
  paintThing(canvas, 'lamp', boxAt(s, 0.56, 0.7, 0.1), time: v.time, glow: 1);
}

// 2. Dieu lui donne un fils, Samuel. Quand il est grand, Anne l'amène au temple pour servir Dieu.
void _bebe(Canvas canvas, Size s, StageView v) {
  paintRoad(canvas, s, v.time, sky: Skies.day);
  paintThing(canvas, 'tent', boxAt(s, 0.86, 0.72, 0.28, aspect: 1.3));
  final x = 0.12 + 0.46 * v.eased;
  final bob = v.progress > 0 && v.progress < 1 ? (math.sin(v.time * 6)).abs() * s.height * 0.006 : 0.0;
  paintPerson(canvas, feetAt(s, x, 0.94), s.height * 0.44, _elkanah, bob: bob, blink: blinkAt(v.time, 0.4));
  paintPerson(
    canvas,
    feetAt(s, x + 0.08, 0.95),
    s.height * 0.42,
    _hannah,
    bob: bob,
    blink: blinkAt(v.time, 1),
  );
  paintPerson(
    canvas,
    feetAt(s, x + 0.15, 0.96),
    s.height * 0.42,
    _samuel,
    bob: bob,
    wave: 0.4,
    blink: blinkAt(v.time, 2),
  );
}

// 3. Samuel grandit auprès du prêtre Éli et l'aide dans la maison de Dieu.
void _lampes(Canvas canvas, Size s, StageView v) {
  _sanctuary(canvas, s, night: 0.4);
  paintPerson(
    canvas,
    feetAt(s, 0.84, 0.92),
    s.height * 0.44,
    _eli,
    facingLeft: true,
    blink: blinkAt(v.time, 0.4),
  );
  var lit = 0;
  for (var i = 0; i < _lamps.length; i++) {
    final t = v.shown(i);
    if (t >= 1) lit++;
    drawPaper(
      canvas,
      Path()..addRect(
        Rect.fromLTWH(s.width * (_lamps[i] - 0.01), s.height * 0.48, s.width * 0.02, s.height * 0.32),
      ),
      const Color(0xFFD9B27A),
      elevation: 2,
    );
    paintThing(canvas, 'lamp', boxAt(s, _lamps[i], 0.5, 0.12), time: v.time, glow: t);
    if (t <= 0) {
      canvas.drawCircle(
        Offset(s.width * (_lamps[i] + 0.035), s.height * 0.42),
        s.height * 0.05,
        Paint()..color = const Color(0x22000000),
      );
    }
  }
  final x = lit == 0 ? 0.16 : _lamps[lit - 1] - 0.06;
  paintPerson(
    canvas,
    feetAt(s, x, 0.95),
    s.height * 0.44,
    _samuel,
    raisedBoth: lit > 0,
    wave: 0.4,
    blink: blinkAt(v.time, 2),
  );
}

// 4. Une nuit, une voix appelle : « Samuel ! » Il court trois fois vers Éli : « Me voici ! »
void _appel(Canvas canvas, Size s, StageView v) {
  _sanctuary(canvas, s, night: 1);
  paintThing(canvas, 'lamp', boxAt(s, 0.5, 0.6, 0.1), time: v.time, glow: 1);
  // Samuel couché sur sa natte, puis debout.
  final up = v.pulse[0] > 0 || v.progress > 0;
  drawPaper(
    canvas,
    Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.12, s.height * 0.84, s.width * 0.26, s.height * 0.05),
        Radius.circular(s.height * 0.02),
      ),
    ),
    const Color(0xFF8C3B5E),
    elevation: 2,
  );
  final runs = (v.progress * 3).round();
  final x = up ? 0.24 + 0.06 * (runs % 2) : 0.24;
  if (up) {
    paintPerson(
      canvas,
      feetAt(s, x, 0.9),
      s.height * 0.44,
      _samuel,
      raisedBoth: true,
      wave: 0.3,
      blink: blinkAt(v.time, 2),
    );
  } else {
    canvas.save();
    canvas.translate(s.width * 0.25, s.height * 0.84);
    canvas.rotate(-math.pi / 2);
    paintPerson(canvas, Offset(0, s.height * 0.1), s.height * 0.4, _samuel, blink: 1);
    canvas.restore();
  }
  paintPerson(
    canvas,
    feetAt(s, 0.8, 0.92),
    s.height * 0.44,
    _eli,
    facingLeft: true,
    blink: blinkAt(v.time, 0.4),
    wave: v.pulse[0] * 0.3,
  );
  // La voix : un doux halo qui pulse.
  final c = Offset(s.width * 0.5, s.height * 0.3);
  canvas.drawCircle(
    c,
    s.height * (0.08 + 0.03 * math.sin(v.time * 3)),
    Paint()
      ..color = const Color(0x55FFF6DC)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.05),
  );
  for (var d = 0; d < 3; d++) {
    canvas.drawCircle(
      Offset(s.width * (0.44 + d * 0.06), s.height * 0.1),
      s.height * 0.02,
      Paint()..color = d < runs ? Palette.sun : const Color(0x44FFFFFF),
    );
  }
}

// 5. Éli comprend que c'est Dieu. Samuel répond : « Parle, car ton serviteur écoute. »
void _ecoute(Canvas canvas, Size s, StageView v) {
  _sanctuary(canvas, s, night: 1);
  final t = v.eased;
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.3, -s.height * 0.05), v.time, intensity: 0.2 + 0.9 * t);
  paintThing(canvas, 'lamp', boxAt(s, 0.6, 0.6, 0.1), time: v.time, glow: 1);
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.92),
    s.height * 0.44,
    _samuel,
    raisedBoth: t > 0,
    wave: 0.2,
    blink: blinkAt(v.time, 2),
  );
  paintPerson(canvas, feetAt(s, 0.84, 0.92), s.height * 0.44, _eli, facingLeft: true, blink: 1);
}

// 6. Samuel grandit ; Dieu est avec lui, et tout le peuple sait que Samuel est son prophète.
void _prophete(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.day);
  paintClouds(canvas, s, v.time, count: 2);
  paintHills(canvas, s, v.time, baselines: const [0.62, 0.76], colors: Lands.green, seed: 331);
  paintThing(canvas, 'tent', boxAt(s, 0.86, 0.76, 0.26, aspect: 1.3));
  final grow = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.94),
    s.height * 0.48,
    _samuel.withScale(_samuel.scale + (1 - _samuel.scale) * grow),
    wave: 0.5,
    raisedBoth: v.done,
    blink: blinkAt(v.time, 2),
  );
  paintPeople(canvas, s, v.time, from: 0.08, to: 0.32, fy: 0.97, h: 0.34, count: 3, wave: grow * 0.4);
  paintPeople(
    canvas,
    s,
    v.time,
    from: 0.68,
    to: 0.76,
    fy: 0.98,
    h: 0.34,
    count: 2,
    facingLeft: true,
    offset: 3,
  );
  paintAnimal(canvas, Animal.dove, boxAt(s, 0.36, 0.3, 0.08), blink: blinkAt(v.time, 1));
}

void _seekBackground(Canvas canvas, Size s) {
  _sanctuary(canvas, s, night: 0.2);
  for (final fx in [0.3, 0.7]) {
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(s.width * (fx - 0.1), s.height * 0.68, s.width * 0.2, s.height * 0.04)),
      const Color(0xFF7E4A2A),
      elevation: 3,
    );
  }
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'crate', boxAt(s, 0.28, 1.0, 0.12));
  paintThing(canvas, 'basket', boxAt(s, 0.74, 1.0, 0.12));
}

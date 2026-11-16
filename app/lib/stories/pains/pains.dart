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

/// La multiplication des pains (Jean 6.1-14).
final painsPack = StoryPack.scripted(
  scripts: {
    'foule': StageScript(
      targets: [for (final x in _groups) Rect.fromLTRB(x - 0.08, 0.46, x + 0.08, 0.82)],
      paint: _foule,
    ),
    'soir': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.5, 0.12),
      swipeTo: Offset(0.86, 0.44),
      paint: _soir,
    ),
    'garcon': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.20, 0.44, 0.40, 0.82)],
      paint: _garcon,
    ),
    'merci': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.24, 0.60, 0.80)],
      sfx: Sfx.chime,
      paint: _merci,
    ),
    'partage': StageScript(
      targets: [for (final x in _groups) Rect.fromLTRB(x - 0.08, 0.50, x + 0.08, 0.82)],
      paint: _partage,
    ),
    'paniers': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.30, 0.50, 0.70, 0.82)],
      sfx: Sfx.chime,
      paint: _paniers,
    ),
  },
  stickerScene: 'merci',
  seekScene: PaintedSeekScene(
    spots: const {
      'bread': (Offset(0.30, 0.86), 0.07),
      'fish': (Offset(0.66, 0.90), 0.08),
      'basket': (Offset(0.12, 0.70), 0.11),
      'sheep': (Offset(0.84, 0.66), 0.12),
      'flower': (Offset(0.46, 0.70), 0.07),
      'bird': (Offset(0.62, 0.18), 0.08),
      'rabbit': (Offset(0.92, 0.88), 0.1),
      'ladybug': (Offset(0.20, 0.92), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _groups = [0.2, 0.44, 0.68];

const _boy = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFFE9B949),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFFB0413E),
  bareHead: true,
  scale: 0.62,
);

// La colline d'herbe verte au bord du lac.
void _hillside(Canvas canvas, Size s, double time, {List<Color> sky = Skies.day}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 2);
  paintWaves(canvas, s, s.height * 0.5, time * 0.4, from: 0, to: 2);
  paintHills(canvas, s, time, baselines: const [0.56, 0.7], colors: Lands.lush, seed: 201);
  for (final (fx, fy) in [(0.08, 0.96), (0.36, 0.98), (0.58, 0.96), (0.9, 0.98)]) {
    paintThing(canvas, 'flower', boxAt(s, fx, fy, 0.05));
  }
}

// Un groupe assis dans l'herbe.
void _seated(Canvas canvas, Size s, double x, double time, int offset, {double joy = 0, double fy = 0.94}) {
  for (var k = 0; k < 3; k++) {
    paintPerson(
      canvas,
      feetAt(s, x + (k - 1) * 0.05, fy + (k.isOdd ? 0.02 : 0)),
      s.height * 0.24,
      NT.crowd[(offset + k) % NT.crowd.length],
      facingLeft: k == 2,
      raisedBoth: joy > 0.5,
      wave: joy * 0.4,
      blink: blinkAt(time, offset + k * 1.1),
    );
  }
}

// 1. Une grande foule suit Jésus sur la colline : il y a plus de cinq mille hommes.
void _foule(Canvas canvas, Size s, StageView v) {
  _hillside(canvas, s, v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.88, 0.86),
    s.height * 0.38,
    NT.jesus,
    facingLeft: true,
    wave: 0.4,
    blink: blinkAt(v.time, 0.7),
  );
  for (var i = 0; i < _groups.length; i++) {
    final t = v.shown(i);
    final x = _groups[i] - 0.14 * (1 - t);
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, 0.35 + 0.65 * t));
    _seated(canvas, s, x, v.time, i * 2, joy: t, fy: 0.9);
    canvas.restore();
  }
}

// 2. Le soir arrive. « Où achèterons-nous du pain pour que ces gens aient à manger ? »
void _soir(Canvas canvas, Size s, StageView v) {
  final t = v.eased;
  _hillside(
    canvas,
    s,
    v.time,
    sky: [for (var i = 0; i < 3; i++) Color.lerp(Skies.day[i], Skies.dusk[i], t)!],
  );
  final sun = Offset.lerp(
    Offset(s.width * 0.5, s.height * 0.12),
    Offset(s.width * 0.86, s.height * 0.44),
    t,
  )!;
  paintSun(canvas, sun, s.height * 0.07);
  for (var i = 0; i < _groups.length; i++) {
    _seated(canvas, s, _groups[i] - 0.08, v.time, i * 2);
  }
  paintPerson(
    canvas,
    feetAt(s, 0.8, 0.9),
    s.height * 0.38,
    NT.jesus,
    facingLeft: true,
    blink: blinkAt(v.time, 0.7),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.7, 0.92),
    s.height * 0.36,
    NT.disciples[1],
    raisedBoth: t > 0.5,
    wave: t * 0.3,
    blink: blinkAt(v.time, 1.2),
  );
  paintThing(canvas, 'coin', boxAt(s, 0.66, 0.66, 0.05));
}

// 3. André amène un petit garçon qui a cinq pains d'orge et deux poissons.
void _garcon(Canvas canvas, Size s, StageView v) {
  _hillside(canvas, s, v.time, sky: Skies.dusk);
  final t = v.eased;
  final x = 0.3 + 0.3 * t;
  paintPerson(
    canvas,
    feetAt(s, 0.78, 0.92),
    s.height * 0.4,
    NT.jesus,
    facingLeft: true,
    wave: t * 0.5,
    blink: blinkAt(v.time, 0.7),
  );
  paintPerson(
    canvas,
    feetAt(s, x - 0.08, 0.93),
    s.height * 0.38,
    NT.disciples[2],
    blink: blinkAt(v.time, 1.6),
  );
  paintPerson(canvas, feetAt(s, x, 0.94), s.height * 0.42, _boy, wave: 0.5, blink: blinkAt(v.time, 0.2));
  paintThing(canvas, 'basket', boxAt(s, x + 0.04, 0.78, 0.1));
  // Les cinq pains et les deux poissons, montrés au-dessus du panier.
  if (t > 0) {
    for (var k = 0; k < 5; k++) {
      paintThing(canvas, 'bread', boxAt(s, x - 0.1 + k * 0.05, 0.58 - 0.04 * t, 0.07 * t, aspect: 1.2));
    }
    for (var k = 0; k < 2; k++) {
      paintThing(canvas, 'fish', boxAt(s, x - 0.04 + k * 0.08, 0.48 - 0.04 * t, 0.07 * t, aspect: 1.4));
    }
  }
}

// 4. Jésus prend les pains, et il remercie Dieu.
void _merci(Canvas canvas, Size s, StageView v) {
  _hillside(canvas, s, v.time, sky: Skies.dusk);
  final t = v.eased;
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.2 + 0.6 * t);
  for (var i = 0; i < 2; i++) {
    _seated(canvas, s, i == 0 ? 0.16 : 0.84, v.time, i * 3);
  }
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.92),
    s.height * 0.46,
    NT.jesus,
    raisedBoth: true,
    wave: 0.3 + 0.4 * t,
    blink: blinkAt(v.time, 0.7),
  );
  paintThing(canvas, 'basket', boxAt(s, 0.6, 0.94, 0.1));
}

// 5. Les disciples distribuent le pain et le poisson : tout le monde mange.
void _partage(Canvas canvas, Size s, StageView v) {
  _hillside(canvas, s, v.time, sky: Skies.dusk);
  for (var i = 0; i < _groups.length; i++) {
    final t = v.shown(i);
    _seated(canvas, s, _groups[i], v.time, i * 2, joy: t);
    paintThing(canvas, 'basket', boxAt(s, _groups[i] + 0.08, 0.96, 0.08));
    if (t > 0) {
      paintThing(canvas, 'bread', boxAt(s, _groups[i] - 0.04, 0.74, 0.05, aspect: 1.2));
      paintThing(canvas, 'fish', boxAt(s, _groups[i] + 0.04, 0.72, 0.05, aspect: 1.4));
    }
  }
  paintPerson(
    canvas,
    feetAt(s, 0.88, 0.88),
    s.height * 0.38,
    NT.jesus,
    facingLeft: true,
    wave: 0.4,
    blink: blinkAt(v.time, 0.7),
  );
}

// 6. On ramasse les morceaux qui restent : douze paniers pleins !
void _paniers(Canvas canvas, Size s, StageView v) {
  _hillside(canvas, s, v.time, sky: Skies.dusk);
  paintPerson(
    canvas,
    feetAt(s, 0.14, 0.9),
    s.height * 0.4,
    NT.jesus,
    wave: v.done ? 0.5 : 0.2,
    blink: blinkAt(v.time, 0.7),
  );
  for (var i = 0; i < 4; i++) {
    paintPerson(
      canvas,
      feetAt(s, 0.78 + (i % 2) * 0.1, 0.86 + (i ~/ 2) * 0.08),
      s.height * 0.34,
      NT.disciples[i],
      facingLeft: true,
      raisedBoth: v.done,
      blink: blinkAt(v.time, i * 1.4),
    );
  }
  final filled = (v.progress * 12).round();
  for (var k = 0; k < 12; k++) {
    final row = k ~/ 6;
    final fx = 0.3 + (k % 6) * 0.08;
    final fy = 0.8 + row * 0.13;
    paintThing(canvas, 'basket', boxAt(s, fx, fy, 0.12));
    if (k < filled) {
      paintThing(canvas, 'bread', boxAt(s, fx, fy - 0.08, 0.05, aspect: 1.2));
    }
  }
  if (v.done) {
    canvas.drawCircle(
      Offset(s.width * 0.5, s.height * 0.76),
      s.height * 0.2,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.18 + 0.06 * math.sin(v.time * 3))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.08),
    );
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _hillside(canvas, s, 0);
  paintThing(canvas, 'tree', boxAt(s, 0.88, 0.7, 0.36));
}

void _seekForeground(Canvas canvas, Size s) {
  final grass = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.24, s.height * 0.98),
        width: s.width * 0.18,
        height: s.height * 0.14,
      ),
    )
    ..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.7, s.height * 0.99),
        width: s.width * 0.2,
        height: s.height * 0.14,
      ),
    );
  drawPaper(canvas, grass, const Color(0xFF6FAE4E), elevation: 4, light: 0.15);
  paintThing(canvas, 'stone', boxAt(s, 0.5, 1.0, 0.08, aspect: 1.4));
  paintAnimal(canvas, Animal.sheep, boxAt(s, 0.06, 1.0, 0.1));
}

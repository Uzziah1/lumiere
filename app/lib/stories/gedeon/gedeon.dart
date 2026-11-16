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

/// Gédéon et les trois cents (Juges 6 et 7).
final gedeonPack = StoryPack.scripted(
  scripts: {
    'appel': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.62, 0.24, 0.86, 0.78)],
      sfx: Sfx.chime,
      paint: _appel,
    ),
    'toison': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 2,
      targets: [Rect.fromLTRB(0.38, 0.56, 0.62, 0.84)],
      sfx: Sfx.chime,
      paint: _toison,
    ),
    'armee': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.04, 0.40, 0.24, 0.82)],
      paint: _armee,
    ),
    'cruches': StageScript(
      targets: [for (final x in _men) Rect.fromLTRB(x - 0.06, 0.44, x + 0.06, 0.82)],
      paint: _cruches,
    ),
    'nuit': StageScript(
      targets: [
        for (final x in _men) Rect.fromCenter(center: Offset(x - 0.06, 0.68), width: 0.12, height: 0.18),
      ],
      sfx: Sfx.knock,
      paint: _nuit,
    ),
    'victoire': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.04, 0.62, 0.30)],
      sfx: Sfx.chime,
      paint: _victoire,
    ),
  },
  stickerScene: 'nuit',
  seekScene: PaintedSeekScene(
    spots: const {
      'torch': (Offset(0.30, 0.86), 0.1),
      'horn': (Offset(0.62, 0.90), 0.08),
      'wheat': (Offset(0.10, 0.70), 0.14),
      'sheep': (Offset(0.82, 0.68), 0.12),
      'camel': (Offset(0.46, 0.60), 0.14),
      'owl': (Offset(0.88, 0.22), 0.1),
      'mouse': (Offset(0.20, 0.92), 0.06),
      'jar': (Offset(0.72, 0.86), 0.1),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _gideon = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFF9C7A54),
  headcloth: Color(0xFFE6D8BE),
  sash: Color(0xFF2F8F6E),
  beard: Color(0xFF2E1E15),
);

const _men = [0.22, 0.42, 0.62];

void _night(Canvas canvas, Size s, double time, {double horizon = 0.66}) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, time, count: 50);
  paintThing(
    canvas,
    'moon',
    Rect.fromCenter(
      center: Offset(s.width * 0.86, s.height * 0.14),
      width: s.height * 0.1,
      height: s.height * 0.1,
    ),
  );
  paintHills(canvas, s, time, baselines: [horizon, horizon + 0.14], colors: Lands.night, seed: 311);
}

// Le camp de Madian dans la vallée : des tentes et des chameaux.
void _camp(Canvas canvas, Size s, {double fled = 0}) {
  for (final (fx, h) in [(0.66, 0.16), (0.78, 0.2), (0.9, 0.16)]) {
    paintThing(canvas, 'tent', boxAt(s, fx, 0.74, h, aspect: 1.2));
  }
  for (var k = 0; k < 2; k++) {
    paintThing(canvas, 'camel', boxAt(s, 0.72 + k * 0.14 + fled * 0.4, 0.82, 0.14, aspect: 1.1));
  }
}

// 1. Gédéon bat le blé en cachette. L'ange de l'Éternel lui dit : « L'Éternel est avec toi, vaillant héros ! »
void _appel(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.day);
  paintHills(canvas, s, v.time, baselines: const [0.6, 0.72], colors: Lands.green, seed: 313);
  paintThing(canvas, 'tree', boxAt(s, 0.94, 0.8, 0.5));
  // Le pressoir creusé dans la roche.
  drawPaper(
    canvas,
    Path()..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.3, s.height * 0.9),
        width: s.width * 0.4,
        height: s.height * 0.16,
      ),
    ),
    const Color(0xFFA9A49A),
    elevation: 3,
  );
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.92),
    s.height * 0.4,
    _gideon,
    wave: v.done ? 0.4 : 0.2 + 0.2 * math.sin(v.time * 5),
    raisedBoth: v.eased > 0.5,
    blink: blinkAt(v.time, 0.4),
  );
  for (final fx in [0.2, 0.4]) {
    paintThing(canvas, 'wheat', boxAt(s, fx, 0.92, 0.1, aspect: 0.6));
  }
  final t = v.eased;
  canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, 0.35 + 0.65 * t));
  paintAngel(canvas, feetAt(s, 0.74, 0.92), s.height * 0.44, v.time, glow: 0.4 + 0.6 * t, facingLeft: true);
  canvas.restore();
}

// 2. La toison : la première nuit, la toison est mouillée et le sol sec ; la deuxième, l'inverse.
void _toison(Canvas canvas, Size s, StageView v) {
  final night = v.progress < 1;
  if (night) {
    _night(canvas, s, v.time);
  } else {
    paintSkyGradient(canvas, s, Skies.dawn);
    paintHills(canvas, s, v.time, baselines: const [0.66, 0.8], colors: Lands.green, seed: 311);
  }
  final step = (v.progress * 2).round();
  // Le sol couvert de rosée (deuxième nuit).
  if (step >= 2) {
    for (var k = 0; k < 30; k++) {
      final x = (k * 37 % 100) / 100;
      final y = 0.8 + (k * 13 % 18) / 100;
      canvas.drawCircle(
        Offset(s.width * x, s.height * y),
        s.height * 0.008,
        Paint()..color = const Color(0xCCDDF0F7),
      );
    }
  }
  final fleece = Rect.fromCenter(
    center: Offset(s.width * 0.5, s.height * 0.76),
    width: s.width * 0.2,
    height: s.height * 0.14,
  );
  drawPaper(canvas, Path()..addOval(fleece), const Color(0xFFF5EEE0), elevation: 3, light: 0.2);
  if (step == 1) {
    for (var k = 0; k < 8; k++) {
      final c = Offset(
        fleece.left + fleece.width * (0.15 + 0.1 * k),
        fleece.center.dy + fleece.height * (k.isEven ? -0.1 : 0.15),
      );
      canvas.drawCircle(c, s.height * 0.012, Paint()..color = const Color(0xCC6CB8D4));
    }
  }
  paintPerson(
    canvas,
    feetAt(s, 0.24, 0.94),
    s.height * 0.42,
    _gideon,
    raisedBoth: step > 0,
    wave: 0.3,
    blink: blinkAt(v.time, 0.4),
  );
}

// 3. Trop de soldats ! Dieu en garde seulement trois cents, pour qu'on sache que la victoire vient de lui.
void _armee(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.day);
  paintHills(canvas, s, v.time, baselines: const [0.62, 0.74], colors: Lands.green, seed: 315);
  paintWaves(canvas, s, s.height * 0.8, v.time * 0.4, from: 2, to: 4);
  paintPerson(
    canvas,
    feetAt(s, 0.14, 0.92),
    s.height * 0.44,
    _gideon,
    wave: 0.4 + 0.2 * v.pulse[0],
    blink: blinkAt(v.time, 0.4),
  );
  final left = 12 - (v.progress * 9).round();
  for (var k = 0; k < left; k++) {
    final row = k ~/ 6;
    final fx = 0.32 + (k % 6) * 0.11 + row * 0.05;
    paintPerson(
      canvas,
      feetAt(s, fx, 0.74 + row * 0.18),
      s.height * (0.24 + row * 0.04),
      Heroes.people[k % 6],
      facingLeft: true,
      blink: blinkAt(v.time, k * 0.7),
    );
  }
}

// 4. Chaque homme reçoit une trompette et une cruche vide, avec une torche cachée dedans.
void _cruches(Canvas canvas, Size s, StageView v) {
  _night(canvas, s, v.time, horizon: 0.7);
  paintPerson(
    canvas,
    feetAt(s, 0.84, 0.94),
    s.height * 0.44,
    _gideon,
    facingLeft: true,
    wave: 0.5,
    blink: blinkAt(v.time, 0.4),
  );
  for (var i = 0; i < _men.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _men[i], 0.95),
      s.height * 0.4,
      Heroes.people[i * 2],
      blink: blinkAt(v.time, i * 1.3),
      wave: t * 0.4,
    );
    if (t > 0) {
      paintThing(canvas, 'torch', boxAt(s, _men[i] + 0.04, 0.78, 0.12 * t), time: v.time);
      paintThing(canvas, 'horn', boxAt(s, _men[i] - 0.04, 0.66, 0.08 * t));
    }
  }
}

// 5. La nuit, ils cassent les cruches, lèvent les torches et sonnent : « Épée pour l'Éternel et pour Gédéon ! »
void _nuit(Canvas canvas, Size s, StageView v) {
  _night(canvas, s, v.time, horizon: 0.62);
  _camp(canvas, s);
  final lit = (v.shown(0) + v.shown(1) + v.shown(2)) / 3;
  canvas.drawRect(Offset.zero & s, Paint()..color = Palette.sun.withValues(alpha: 0.1 * lit));
  for (var i = 0; i < _men.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _men[i] - 0.1, 0.95),
      s.height * 0.38,
      Heroes.people[i * 2],
      raisedBoth: t >= 1,
      wave: 0.5,
      blink: blinkAt(v.time, i * 1.3),
    );
    paintThing(
      canvas,
      'torch',
      boxAt(s, _men[i] - 0.06, t >= 1 ? 0.58 : 0.76, 0.14),
      time: v.time,
      glow: t >= 1 ? 1 : 0,
    );
  }
}

// 6. Le camp ennemi s'enfuit dans la confusion : Dieu a délivré son peuple.
void _victoire(Canvas canvas, Size s, StageView v) {
  final t = v.eased;
  paintSkyGradient(canvas, s, [for (var i = 0; i < 3; i++) Color.lerp(Skies.night[i], Skies.dawn[i], t)!]);
  paintSun(canvas, Offset(s.width * 0.5, s.height * (0.5 - 0.32 * t)), s.height * 0.07);
  paintHills(canvas, s, v.time, baselines: const [0.62, 0.76], colors: Lands.green, seed: 311);
  _camp(canvas, s, fled: t);
  paintPerson(
    canvas,
    feetAt(s, 0.18, 0.95),
    s.height * 0.44,
    _gideon,
    raisedBoth: true,
    wave: 0.6 * t,
    blink: blinkAt(v.time, 0.4),
  );
  paintPeople(
    canvas,
    s,
    v.time,
    from: 0.28,
    to: 0.5,
    fy: 0.97,
    h: 0.34,
    count: 3,
    raised: t > 0.5,
    wave: 0.5,
  );
  paintAnimal(canvas, Animal.dove, boxAt(s, 0.36, 0.36, 0.08 * t), blink: blinkAt(v.time, 2));
}

void _seekBackground(Canvas canvas, Size s) {
  paintSkyGradient(canvas, s, Skies.dusk);
  paintHills(canvas, s, 0, baselines: const [0.6, 0.74], colors: Lands.green, seed: 317);
  for (final (fx, h) in [(0.66, 0.2), (0.86, 0.24)]) {
    paintThing(canvas, 'tent', boxAt(s, fx, 0.76, h, aspect: 1.2));
  }
}

void _seekForeground(Canvas canvas, Size s) {
  final bush = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.18, s.height * 0.99),
        width: s.width * 0.2,
        height: s.height * 0.14,
      ),
    )
    ..addOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.56, s.height * 0.99),
        width: s.width * 0.16,
        height: s.height * 0.12,
      ),
    );
  drawPaper(canvas, bush, const Color(0xFF5E9B45), elevation: 4, light: 0.15);
  paintThing(canvas, 'stone', boxAt(s, 0.94, 1.0, 0.1, aspect: 1.4));
}

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

/// Élie : les corbeaux, la veuve de Sarepta et le feu du Carmel (1 Rois 17 et 18).
final eliePack = StoryPack.scripted(
  scripts: {
    'secheresse': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.20, 0.36, 0.42, 0.82)],
      paint: _secheresse,
    ),
    'corbeaux': StageScript(
      targets: [
        for (final (x, y) in _ravens) Rect.fromCenter(center: Offset(x, y), width: 0.12, height: 0.16),
      ],
      sfx: Sfx.pop,
      paint: _corbeaux,
    ),
    'veuve': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.42, 0.50, 0.60, 0.82)],
      sfx: Sfx.chime,
      paint: _veuve,
    ),
    'eau': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.40, 0.44, 0.66, 0.80)],
      sfx: Sfx.whoosh,
      paint: _eau,
    ),
    'feu': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.8,
      targets: [Rect.fromLTRB(0.40, 0.04, 0.62, 0.30)],
      sfx: Sfx.chime,
      paint: _feu,
    ),
    'pluie': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 7,
      targets: [Rect.fromLTRB(0.66, 0.40, 0.86, 0.82)],
      paint: _pluie,
    ),
  },
  stickerScene: 'feu',
  seekScene: PaintedSeekScene(
    spots: const {
      'raven': (Offset(0.70, 0.18), 0.1),
      'bread': (Offset(0.30, 0.86), 0.07),
      'jar': (Offset(0.88, 0.84), 0.12),
      'flame': (Offset(0.50, 0.50), 0.07),
      'stone': (Offset(0.60, 0.90), 0.07),
      'fish': (Offset(0.14, 0.92), 0.08),
      'snail': (Offset(0.40, 0.70), 0.06),
      'tortoise': (Offset(0.80, 0.62), 0.09),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _elijah = PersonStyle(
  skin: Color(0xFF7D4A30),
  robe: Color(0xFF9C7A54),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFF5C3A22),
  beard: Color(0xFF2E1E15),
  bareHead: true,
);

const _widow = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFF6E5A8A),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFFE6D8BE),
  veil: true,
);

const _ravens = [(0.24, 0.24), (0.5, 0.16), (0.76, 0.26)];

void _dry(Canvas canvas, Size s, double time, {List<Color> sky = Skies.desert}) {
  paintSkyGradient(canvas, s, sky);
  paintSun(canvas, Offset(s.width * 0.84, s.height * 0.16), s.height * 0.08);
  paintHills(canvas, s, time, baselines: const [0.6, 0.74], colors: Lands.desert, seed: 341);
}

// L'autel de pierres du Carmel ; [fire] : il brûle.
void _altar(Canvas canvas, Size s, double fx, {double fire = 0, double water = 0, double time = 0}) {
  paintThing(canvas, 'altar', boxAt(s, fx, 0.86, 0.24, aspect: 1.2));
  if (water > 0) {
    drawPaper(
      canvas,
      Path()..addOval(
        Rect.fromCenter(
          center: Offset(s.width * fx, s.height * 0.87),
          width: s.width * 0.26 * (0.6 + 0.4 * water),
          height: s.height * 0.05,
        ),
      ),
      const Color(0xFF6CB8D4),
      elevation: 1,
    );
  }
  if (fire > 0) {
    for (var k = 0; k < 3; k++) {
      paintThing(
        canvas,
        'flame',
        boxAt(s, fx - 0.05 + k * 0.05, 0.66, 0.16 * fire * (k == 1 ? 1.3 : 1)),
        time: time + k,
      );
    }
  }
}

// 1. Élie annonce au roi Achab : « Il n'y aura ni rosée ni pluie, sauf à ma parole. »
void _secheresse(Canvas canvas, Size s, StageView v) {
  _dry(canvas, s, v.time);
  final dry = v.eased;
  for (final fx in [0.56, 0.64, 0.72]) {
    paintThing(canvas, 'plant', boxAt(s, fx, 0.92, 0.12 * (1 - 0.5 * dry)));
  }
  paintPerson(
    canvas,
    feetAt(s, 0.31, 0.94),
    s.height * 0.46,
    _elijah,
    raisedBoth: dry > 0,
    wave: 0.4,
    blink: blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.86, 0.94),
    s.height * 0.46,
    const PersonStyle(
      skin: Color(0xFFA9714B),
      robe: Color(0xFF7A4E9C),
      headcloth: Color(0xFFF2C14E),
      sash: Color(0xFFF2C14E),
      beard: Color(0xFF2E1E15),
      crown: true,
    ),
    facingLeft: true,
    blink: blinkAt(v.time, 1.2),
  );
}

// 2. Près du torrent, des corbeaux apportent du pain et de la viande à Élie, matin et soir.
void _corbeaux(Canvas canvas, Size s, StageView v) {
  _dry(canvas, s, v.time, sky: Skies.day);
  paintWaves(canvas, s, s.height * 0.86, v.time * 0.5, from: 1, to: 3);
  paintThing(canvas, 'tree', boxAt(s, 0.86, 0.84, 0.4));
  paintPerson(canvas, feetAt(s, 0.3, 0.84), s.height * 0.42, _elijah, wave: 0.4, blink: blinkAt(v.time, 0.4));
  var fed = 0;
  for (var i = 0; i < _ravens.length; i++) {
    final t = v.shown(i);
    if (t >= 1) fed++;
    final (x, y) = _ravens[i];
    final c = Offset.lerp(
      Offset(s.width * x, s.height * y),
      Offset(s.width * (0.36 + i * 0.04), s.height * 0.6),
      t,
    )!;
    paintThing(
      canvas,
      'raven',
      Rect.fromCenter(center: c, width: s.height * 0.12, height: s.height * 0.12),
      time: v.time + i,
      glow: 1 - t,
    );
  }
  for (var k = 0; k < fed; k++) {
    paintThing(canvas, 'bread', boxAt(s, 0.38 + k * 0.05, 0.86, 0.05, aspect: 1.2));
  }
}

// 3. À Sarepta, la farine et l'huile de la veuve ne s'épuisent pas.
void _veuve(Canvas canvas, Size s, StageView v) {
  paintHouse(canvas, s, wall: const Color(0xFFE6CFA3), lamp: 0.5);
  paintPerson(
    canvas,
    feetAt(s, 0.26, 0.94),
    s.height * 0.46,
    _elijah,
    wave: 0.3,
    blink: blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.74, 0.94),
    s.height * 0.44,
    _widow,
    facingLeft: true,
    raisedBoth: v.done,
    wave: 0.4,
    blink: blinkAt(v.time, 1),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.86, 0.95),
    s.height * 0.42,
    Heroes.people[4],
    facingLeft: true,
    blink: blinkAt(v.time, 2),
  );
  paintThing(canvas, 'jar', boxAt(s, 0.5, 0.94, 0.2));
  paintThing(canvas, 'jar', boxAt(s, 0.58, 0.95, 0.12));
  final breads = (v.progress * 6).round();
  for (var k = 0; k < breads; k++) {
    paintThing(canvas, 'bread', boxAt(s, 0.34 + (k % 3) * 0.06, 0.96 - (k ~/ 3) * 0.05, 0.05, aspect: 1.2));
  }
  if (v.pulse[0] > 0) {
    canvas.drawCircle(
      Offset(s.width * 0.5, s.height * 0.78),
      s.height * 0.1 * v.pulse[0],
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.4 * v.pulse[0])
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.04),
    );
  }
}

// 4. Sur le mont Carmel, les prophètes de Baal crient toute la journée : rien. Élie fait verser de l'eau trois fois.
void _eau(Canvas canvas, Size s, StageView v) {
  _dry(canvas, s, v.time, sky: Skies.dusk);
  _altar(canvas, s, 0.18);
  paintPeople(canvas, s, v.time, from: 0.06, to: 0.3, fy: 0.97, h: 0.28, count: 3, offset: 3, raised: true);
  _altar(canvas, s, 0.53, water: v.eased);
  paintPerson(
    canvas,
    feetAt(s, 0.78, 0.94),
    s.height * 0.46,
    _elijah,
    facingLeft: true,
    wave: 0.4,
    blink: blinkAt(v.time, 0.4),
  );
  for (var k = 0; k < (v.progress * 3).round(); k++) {
    paintThing(canvas, 'jar', boxAt(s, 0.66 + k * 0.04, 0.98, 0.08));
  }
  if (v.pulse[0] > 0) {
    for (var k = 0; k < 6; k++) {
      canvas.drawCircle(
        Offset(s.width * (0.5 + k * 0.012), s.height * (0.6 + v.pulse[0] * 0.2 + k * 0.01)),
        s.height * 0.01,
        Paint()..color = const Color(0xCC6CB8D4),
      );
    }
  }
}

// 5. Élie prie, et le feu de l'Éternel tombe du ciel. Le peuple crie : « C'est l'Éternel qui est Dieu ! »
void _feu(Canvas canvas, Size s, StageView v) {
  final t = v.eased;
  _dry(canvas, s, v.time, sky: Skies.dusk);
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.2 + 1.0 * t);
  _altar(canvas, s, 0.53, fire: t, water: 1 - t, time: v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.78, 0.94),
    s.height * 0.46,
    _elijah,
    facingLeft: true,
    raisedBoth: true,
    wave: 0.4,
    blink: blinkAt(v.time, 0.4),
  );
  paintPeople(
    canvas,
    s,
    v.time,
    from: 0.06,
    to: 0.3,
    fy: 0.97,
    h: 0.32,
    count: 3,
    raised: t > 0.6,
    wave: 0.6,
    offset: 1,
  );
}

// 6. Le serviteur d'Élie regarde la mer sept fois : un petit nuage… puis une grosse pluie !
void _pluie(Canvas canvas, Size s, StageView v) {
  final t = v.progress;
  paintSkyGradient(canvas, s, [
    for (var i = 0; i < 3; i++) Color.lerp(Skies.desert[i], Skies.storm[i], v.done ? 0.7 : 0)!,
  ]);
  paintSea(canvas, s, s.height * 0.6, v.time * 0.5);
  paintHills(
    canvas,
    s,
    v.time,
    baselines: const [0.74, 0.86],
    colors: v.done ? Lands.green : Lands.desert,
    seed: 343,
  );
  if (t > 0) {
    paintClouds(canvas, s, v.time, count: v.done ? 4 : 1, color: const Color(0xFF8E9AAE), top: 0.1);
  }
  for (var d = 0; d < 7; d++) {
    canvas.drawCircle(
      Offset(s.width * (0.32 + d * 0.06), s.height * 0.06),
      s.height * 0.018,
      Paint()..color = d < (t * 7).round() ? Palette.sun : const Color(0x66FFFFFF),
    );
  }
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.92),
    s.height * 0.42,
    _elijah,
    raisedBoth: v.done,
    wave: 0.3,
    blink: blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.76, 0.92),
    s.height * 0.4,
    Heroes.people[2],
    facingLeft: false,
    raisedBoth: v.pulse[0] > 0,
    blink: blinkAt(v.time, 1.2),
  );
  if (v.done) {
    final rain = RainField(count: 60)
      ..resize(s)
      ..update(v.time % 1);
    rain.paint(canvas);
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _dry(canvas, s, 0, sky: Skies.day);
  paintWaves(canvas, s, s.height * 0.86, 0, from: 1, to: 3);
  paintThing(canvas, 'tree', boxAt(s, 0.12, 0.8, 0.4));
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'stone', boxAt(s, 0.26, 1.0, 0.1, aspect: 1.4));
  paintThing(canvas, 'stone', boxAt(s, 0.74, 1.0, 0.12, aspect: 1.4));
  paintAnimal(canvas, Animal.rabbit, boxAt(s, 0.98, 1.0, 0.08), facingLeft: true);
}

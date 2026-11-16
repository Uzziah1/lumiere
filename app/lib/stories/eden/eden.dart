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
import '../creation/creation.dart' show adam, eve;
import '../registry.dart';

/// Adam et Ève (Genèse 2 à 3).
final edenPack = StoryPack.scripted(
  scripts: {
    'names': const StageScript(
      targets: [
        Rect.fromLTRB(0.04, 0.34, 0.24, 0.80),
        Rect.fromLTRB(0.26, 0.50, 0.42, 0.80),
        Rect.fromLTRB(0.76, 0.56, 0.92, 0.80),
      ],
      paint: _names,
    ),
    'eve': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.34, 0.36, 0.50, 0.80)],
      sfx: Sfx.chime,
      paint: _eve,
    ),
    'tree': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2,
      targets: [Rect.fromLTRB(0.40, 0.02, 0.60, 0.30)],
      sfx: Sfx.chime,
      paint: _tree,
    ),
    'serpent': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2,
      targets: [Rect.fromLTRB(0.52, 0.20, 0.70, 0.52)],
      sfx: Sfx.whoosh,
      paint: _serpent,
    ),
    'hide': const StageScript(
      targets: [Rect.fromLTRB(0.14, 0.46, 0.38, 0.80), Rect.fromLTRB(0.62, 0.46, 0.86, 0.80)],
      paint: _hide,
    ),
    'clothes': const StageScript(
      targets: [Rect.fromLTRB(0.34, 0.36, 0.48, 0.80), Rect.fromLTRB(0.52, 0.36, 0.66, 0.80)],
      sfx: Sfx.chime,
      paint: _clothes,
    ),
  },
  stickerScene: 'eve',
  seekScene: PaintedSeekScene(
    spots: const {
      'rabbit': (Offset(0.12, 0.74), 0.15),
      'frog': (Offset(0.46, 0.80), 0.1),
      'bird': (Offset(0.78, 0.24), 0.1),
      'ladybug': (Offset(0.30, 0.52), 0.06),
      'tortoise': (Offset(0.66, 0.86), 0.11),
      'snail': (Offset(0.90, 0.78), 0.09),
      'mouse': (Offset(0.56, 0.62), 0.08),
      'owl': (Offset(0.2, 0.26), 0.13),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _skinsAdam = PersonStyle(
  skin: Color(0xFF8A5537),
  robe: Color(0xFF9C7A54),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFF6B4630),
  bareHead: true,
);

const _skinsEve = PersonStyle(
  skin: Color(0xFF9C6440),
  robe: Color(0xFFB08A60),
  headcloth: Color(0xFF2A1A12),
  sash: Color(0xFF6B4630),
  bareHead: true,
  veil: true,
  scale: 0.96,
);

/// Le jardin d'Éden : collines, arbres fruitiers et une rivière (Genèse 2.10).
void _garden(Canvas canvas, Size s, double time, {List<Color> sky = Skies.day, bool river = true}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 2);
  paintHills(canvas, s, time, baselines: const [0.56, 0.66, 0.8], colors: Lands.lush, seed: 81);
  if (river) {
    final river = Path()
      ..moveTo(s.width * 0.46, s.height * 0.62)
      ..quadraticBezierTo(s.width * 0.56, s.height * 0.74, s.width * 0.48, s.height * 0.86)
      ..quadraticBezierTo(s.width * 0.42, s.height * 0.95, s.width * 0.5, s.height * 1.02)
      ..lineTo(s.width * 0.62, s.height * 1.02)
      ..quadraticBezierTo(s.width * 0.54, s.height * 0.94, s.width * 0.6, s.height * 0.86)
      ..quadraticBezierTo(s.width * 0.66, s.height * 0.74, s.width * 0.5, s.height * 0.62)
      ..close();
    drawPaper(canvas, river, const Color(0xFF6CB8D4), elevation: 1, light: 0.2);
  }
  for (final (fx, fy, h) in const [(0.08, 0.7, 0.42), (0.92, 0.7, 0.46), (0.3, 0.62, 0.3), (0.72, 0.6, 0.28)]) {
    paintThing(canvas, 'tree', boxAt(s, fx, fy, h));
  }
}

// 1. Adam donne un nom à chaque animal.
void _names(Canvas canvas, Size s, StageView v) {
  _garden(canvas, s, v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.6, 0.92),
    s.height * 0.42,
    adam,
    wave: v.pulse.reduce(math.max) * 0.9,
    blink: blinkAt(v.time, 0.4),
  );
  final animals = [(Animal.giraffe, 0.14, 0.8, 0.44), (Animal.lion, 0.34, 0.8, 0.28), (Animal.rabbit, 0.84, 0.8, 0.2)];
  for (var i = 0; i < animals.length; i++) {
    final (a, fx, fy, h) = animals[i];
    final hop = v.pulse[i] * s.height * 0.04;
    final box = boxAt(s, fx, fy, h).translate(0, -hop);
    paintAnimal(canvas, a, box, blink: blinkAt(v.time, i * 1.3), facingLeft: fx > 0.6);
    if (v.shown(i) > 0) {
      final heart = Offset(box.center.dx, box.top - s.height * 0.03);
      paintThing(
        canvas,
        'star',
        Rect.fromCenter(center: heart, width: s.height * 0.07 * v.shown(i), height: s.height * 0.07 * v.shown(i)),
      );
    }
  }
}

// 2. Dieu fait la femme : Adam n'est plus seul.
void _eve(Canvas canvas, Size s, StageView v) {
  _garden(canvas, s, v.time);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.42, 0.92),
    s.height * 0.44,
    adam,
    wave: v.done ? 0.6 + 0.4 * math.sin(v.time * 3) : 0,
    blink: blinkAt(v.time, 0.2),
  );
  if (t > 0) {
    canvas.drawCircle(
      Offset(s.width * 0.58, s.height * 0.64),
      s.height * 0.3 * t,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.35 * (1 - v.sinceDone.clamp(0.0, 1.0)))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.08),
    );
    canvas.saveLayer(Offset.zero & s, Paint()..color = Color.fromRGBO(0, 0, 0, t));
    paintPerson(
      canvas,
      feetAt(s, 0.58, 0.92),
      s.height * 0.43,
      eve,
      wave: v.done ? 0.6 + 0.4 * math.sin(v.time * 3 + 1) : 0,
      blink: blinkAt(v.time, 1.4),
      facingLeft: true,
    );
    canvas.restore();
  }
}

// 3. Dieu parle : on peut manger de tous les arbres, sauf d'un seul.
void _tree(Canvas canvas, Size s, StageView v) {
  _garden(canvas, s, v.time, river: false);
  final tree = boxAt(s, 0.5, 0.86, 0.56);
  canvas.drawCircle(
    tree.center,
    tree.height * 0.6,
    Paint()
      ..color = Palette.gold.withValues(alpha: 0.18 + 0.12 * v.eased)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, tree.height * 0.15),
  );
  paintThing(canvas, 'tree', tree);
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.45 + 0.7 * v.eased);
  paintPerson(
    canvas,
    feetAt(s, 0.24, 0.94),
    s.height * 0.38,
    adam,
    blink: blinkAt(v.time, 0.6),
    raisedBoth: true,
    wave: 0.3 * v.eased,
  );
  paintPerson(
    canvas,
    feetAt(s, 0.78, 0.94),
    s.height * 0.37,
    eve,
    blink: blinkAt(v.time, 1.8),
    facingLeft: true,
    raisedBoth: true,
    wave: 0.3 * v.eased,
  );
}

// 4. Le serpent parle à Ève près de l'arbre.
void _serpent(Canvas canvas, Size s, StageView v) {
  _garden(canvas, s, v.time, river: false);
  paintThing(canvas, 'tree', boxAt(s, 0.6, 0.86, 0.58));
  final sway = math.sin(v.time * 2) * s.height * 0.01 + v.pulse[0] * s.height * 0.03;
  paintThing(canvas, 'snake', boxAt(s, 0.61, 0.5 + sway / s.height, 0.24));
  paintPerson(
    canvas,
    feetAt(s, 0.36, 0.92),
    s.height * 0.42,
    eve,
    blink: blinkAt(v.time, 0.9),
    wave: v.done ? 0.45 : 0,
  );
  if (v.done) {
    paintThing(canvas, 'fruit', boxAt(s, 0.44, 0.58, 0.06));
  }
  paintPerson(canvas, feetAt(s, 0.18, 0.94), s.height * 0.4, adam, blink: blinkAt(v.time, 2));
}

// 5. Ils se cachent ; Dieu appelle : « Où es-tu ? »
void _hide(Canvas canvas, Size s, StageView v) {
  _garden(canvas, s, v.time, sky: Skies.dusk, river: false);
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.5);
  final bushes = [0.26, 0.74];
  for (var i = 0; i < 2; i++) {
    final peek = v.shown(i);
    if (peek > 0) {
      paintPerson(
        canvas,
        feetAt(s, bushes[i], 0.86 - peek * 0.0),
        s.height * 0.36,
        i == 0 ? adam : eve,
        blink: blinkAt(v.time, i * 1.7),
        facingLeft: i == 1,
      );
    }
    canvas.save();
    canvas.translate(0, peek * s.height * 0.12);
    paintThing(canvas, 'bush', boxAt(s, bushes[i], 0.84, 0.34, aspect: 1.2));
    canvas.restore();
  }
}

// 6. Dieu leur fait des habits ; ils quittent le jardin, mais Dieu ne les oublie pas.
void _clothes(Canvas canvas, Size s, StageView v) {
  _garden(canvas, s, v.time, river: false);
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.4 + 0.4 * v.eased);
  final styles = [(adam, _skinsAdam, 0.41), (eve, _skinsEve, 0.59)];
  for (var i = 0; i < 2; i++) {
    final (before, after, fx) = styles[i];
    final dressed = v.shown(i) > 0.5;
    paintPerson(
      canvas,
      feetAt(s, fx, 0.92),
      s.height * 0.43,
      dressed ? after : before,
      blink: blinkAt(v.time, i * 1.1),
      facingLeft: i == 1,
      wave: v.pulse[i] * 0.8,
    );
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _garden(canvas, s, 0);
  paintThing(canvas, 'tree', boxAt(s, 0.2, 0.62, 0.44));
  paintThing(canvas, 'tree', boxAt(s, 0.78, 0.6, 0.4));
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'bush', boxAt(s, 0.12, 0.98, 0.18, aspect: 1.3));
  paintThing(canvas, 'bush', boxAt(s, 0.68, 1.0, 0.14, aspect: 1.4));
  paintThing(canvas, 'reeds', boxAt(s, 0.47, 0.96, 0.16, aspect: 0.8));
  paintThing(canvas, 'flower', boxAt(s, 0.9, 0.98, 0.18));
  paintThing(canvas, 'flower', boxAt(s, 0.56, 0.7, 0.1));
  paintWaves(canvas, Size(s.width, s.height), s.height * 1.2, 0);
}

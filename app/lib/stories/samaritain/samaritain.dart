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

/// Le bon Samaritain (Luc 10.25-37).
final samaritainPack = StoryPack.scripted(
  scripts: {
    'question': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.56, 0.36, 0.76, 0.82)],
      paint: _question,
    ),
    'chemin': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.15, 0.62),
      swipeTo: Offset(0.6, 0.62),
      paint: _chemin,
    ),
    'pretre': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.1, 0.5),
      swipeTo: Offset(0.9, 0.5),
      paint: _pretre,
    ),
    'levite': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.1, 0.5),
      swipeTo: Offset(0.9, 0.5),
      paint: _levite,
    ),
    'soin': StageScript(
      targets: [for (final x in _wounds) Rect.fromCenter(center: Offset(x, 0.74), width: 0.1, height: 0.16)],
      sfx: Sfx.chime,
      paint: _soin,
    ),
    'auberge': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.04, 0.40, 0.36, 0.82)],
      sfx: Sfx.chime,
      paint: _auberge,
    ),
  },
  stickerScene: 'soin',
  seekScene: PaintedSeekScene(
    spots: const {
      'donkey': (Offset(0.18, 0.80), 0.16),
      'jar': (Offset(0.70, 0.86), 0.12),
      'coin': (Offset(0.44, 0.92), 0.05),
      'bird': (Offset(0.30, 0.16), 0.08),
      'lion': (Offset(0.90, 0.56), 0.12),
      'tortoise': (Offset(0.56, 0.66), 0.09),
      'snail': (Offset(0.08, 0.92), 0.06),
      'stone': (Offset(0.84, 0.92), 0.08),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _traveler = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFF3A7CA5),
  headcloth: Color(0xFFF0E2C8),
  sash: Color(0xFFE9B949),
  beard: Color(0xFF2E1E15),
);

const _priest = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFFF5EEE0),
  headcloth: Color(0xFFF5EEE0),
  sash: Color(0xFF3A7CA5),
  beard: Color(0xFFBDB5A8),
);

const _leviteStyle = PersonStyle(
  skin: Color(0xFF7D4A30),
  robe: Color(0xFF8C79B5),
  headcloth: Color(0xFFF0E2C8),
  sash: Color(0xFFF2C14E),
  beard: Color(0xFF2E1E15),
);

const _samaritan = PersonStyle(
  skin: Color(0xFF9C6440),
  robe: Color(0xFFB0413E),
  headcloth: Color(0xFFE9B949),
  sash: Color(0xFF2E1E15),
  beard: Color(0xFF4A3323),
);

const _wounds = [0.4, 0.5, 0.6];

// La route qui descend de Jérusalem à Jéricho, entre des rochers.
void _desertRoad(Canvas canvas, Size s, double time, {List<Color> sky = Skies.desert}) {
  paintRoad(canvas, s, time, sky: sky);
  for (final (fx, fy, h) in [(0.08, 0.7, 0.14), (0.9, 0.68, 0.18), (0.76, 0.74, 0.1)]) {
    paintThing(canvas, 'stone', boxAt(s, fx, fy, h, aspect: 1.4));
  }
}

// Le voyageur blessé, couché au bord du chemin ([healed] : pansements posés).
void _lying(Canvas canvas, Size s, double time, {int bandages = 0, double rise = 0}) {
  final c = Offset(s.width * 0.5, s.height * 0.84);
  final h = s.height * 0.34;
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-math.pi / 2 * (1 - rise * 0.3));
  paintPerson(canvas, Offset(h * 0.04, h * 0.5), h, _traveler, blink: rise > 0 ? blinkAt(time, 1) : 1);
  canvas.restore();
  for (var i = 0; i < bandages; i++) {
    final b = Offset(s.width * _wounds[i], s.height * 0.8);
    drawPaper(
      canvas,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: b, width: s.height * 0.07, height: s.height * 0.03),
          Radius.circular(s.height * 0.01),
        ),
      ),
      const Color(0xFFFFFBF0),
      elevation: 2,
    );
  }
}

// 1. Un maître de la loi demande : « Qui est mon prochain ? » Jésus raconte une histoire.
void _question(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.day);
  paintClouds(canvas, s, v.time, count: 2);
  paintHills(canvas, s, v.time, baselines: const [0.62, 0.76], colors: Lands.green, seed: 221);
  paintThing(canvas, 'tree', boxAt(s, 0.12, 0.8, 0.36));
  paintPerson(
    canvas,
    feetAt(s, 0.4, 0.94),
    s.height * 0.46,
    NT.elder,
    wave: 0.3,
    blink: blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.66, 0.94),
    s.height * 0.46,
    NT.jesus,
    facingLeft: true,
    wave: 0.3 + 0.3 * v.eased,
    blink: blinkAt(v.time, 0.7),
  );
  paintCrowd(canvas, s, v.time, from: 0.82, to: 0.94, fy: 0.97, h: 0.34, count: 2, facingLeft: true);
  if (v.eased > 0) {
    // Une bulle d'histoire : la route au loin.
    final c = Offset(s.width * 0.56, s.height * 0.22);
    final r = s.height * 0.12 * v.eased;
    drawPaper(
      canvas,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      const Color(0xFFFFFBF0),
      elevation: 4,
    );
    paintThing(canvas, 'donkey', Rect.fromCircle(center: c, radius: r * 0.7));
  }
}

// 2. Un homme descend de Jérusalem à Jéricho. Des brigands l'attaquent et le laissent blessé.
void _chemin(Canvas canvas, Size s, StageView v) {
  _desertRoad(canvas, s, v.time);
  paintThing(canvas, 'city', boxAt(s, 0.12, 0.64, 0.16, aspect: 1.5));
  final t = v.eased;
  if (t < 0.6) {
    final x = 0.18 + 0.32 * t / 0.6;
    paintPerson(
      canvas,
      feetAt(s, x, 0.9),
      s.height * 0.42,
      _traveler,
      bob: (math.sin(v.time * 6)).abs() * s.height * 0.006,
      blink: blinkAt(v.time, 1),
    );
  } else {
    _lying(canvas, s, v.time);
    // Les brigands s'enfuient au loin.
    final run = (t - 0.6) / 0.4;
    for (var k = 0; k < 2; k++) {
      final x = 0.72 + run * 0.3 + k * 0.06;
      paintPerson(
        canvas,
        feetAt(s, x, 0.84),
        s.height * 0.26,
        NT.crowd[k + 4],
        bob: (math.sin(v.time * 10 + k)).abs() * s.height * 0.01,
      );
    }
  }
}

// Un passant qui change de côté du chemin ([t] : avancement).
void _passerBy(Canvas canvas, Size s, StageView v, PersonStyle style) {
  _desertRoad(canvas, s, v.time, sky: Skies.dusk);
  _lying(canvas, s, v.time);
  final t = v.eased;
  final x = 0.1 + 0.8 * t;
  final y = 0.92 - 0.2 * math.sin(t * math.pi);
  paintPerson(
    canvas,
    feetAt(s, x, y),
    s.height * (0.42 - 0.12 * math.sin(t * math.pi)),
    style,
    bob: t > 0 && t < 1 ? (math.sin(v.time * 6)).abs() * s.height * 0.006 : 0,
    blink: blinkAt(v.time, 0.5),
  );
}

// 3. Un prêtre passe. Il voit l'homme… et passe de l'autre côté.
void _pretre(Canvas canvas, Size s, StageView v) => _passerBy(canvas, s, v, _priest);

// 4. Un Lévite passe aussi, et continue son chemin.
void _levite(Canvas canvas, Size s, StageView v) => _passerBy(canvas, s, v, _leviteStyle);

// 5. Un Samaritain s'arrête, a pitié de lui et soigne ses blessures.
void _soin(Canvas canvas, Size s, StageView v) {
  _desertRoad(canvas, s, v.time, sky: Skies.dusk);
  final healed = (v.shown(0) >= 1 ? 1 : 0) + (v.shown(1) >= 1 ? 1 : 0) + (v.shown(2) >= 1 ? 1 : 0);
  paintThing(canvas, 'donkey', boxAt(s, 0.86, 0.9, 0.26, aspect: 1.1));
  _lying(canvas, s, v.time, bandages: healed, rise: healed / 3);
  paintPerson(
    canvas,
    feetAt(s, 0.7, 0.94),
    s.height * 0.44,
    _samaritan,
    facingLeft: true,
    wave: 0.6,
    blink: blinkAt(v.time, 0.3),
  );
  paintThing(canvas, 'jar', boxAt(s, 0.3, 0.94, 0.1));
  if (healed == 3) {
    canvas.drawCircle(
      Offset(s.width * 0.55, s.height * 0.76),
      s.height * 0.18,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.07),
    );
  }
}

// 6. Il l'emmène à l'auberge sur son âne et paie pour qu'on prenne soin de lui.
void _auberge(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, v.time, count: 40);
  paintHills(canvas, s, v.time, baselines: const [0.7, 0.84], colors: Lands.night, seed: 223);
  // L'auberge, fenêtre allumée.
  final inn = Rect.fromLTWH(s.width * 0.66, s.height * 0.36, s.width * 0.3, s.height * 0.52);
  drawPaper(canvas, Path()..addRect(inn), const Color(0xFFC9A066), elevation: 5);
  drawPaper(
    canvas,
    Path()..addRect(
      Rect.fromLTWH(
        inn.left - s.width * 0.01,
        inn.top - s.height * 0.04,
        inn.width + s.width * 0.02,
        s.height * 0.05,
      ),
    ),
    const Color(0xFF8A5A36),
    elevation: 4,
  );
  canvas.drawRect(
    Rect.fromLTWH(inn.left + inn.width * 0.6, inn.top + inn.height * 0.2, inn.width * 0.2, inn.height * 0.2),
    Paint()..color = const Color(0xFFFFE08A),
  );
  canvas.drawRect(
    Rect.fromLTWH(
      inn.left + inn.width * 0.14,
      inn.top + inn.height * 0.46,
      inn.width * 0.26,
      inn.height * 0.54,
    ),
    Paint()..color = Color.lerp(const Color(0xFF4A3323), const Color(0xFFFFE08A), v.done ? 1 : 0)!,
  );
  final go = v.eased * s.width * 0.4;
  canvas.save();
  canvas.translate(go, 0);
  paintThing(canvas, 'donkey', boxAt(s, 0.18, 0.94, 0.26, aspect: 1.1));
  paintPerson(canvas, feetAt(s, 0.17, 0.76), s.height * 0.26, _traveler, blink: blinkAt(v.time, 1));
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.95),
    s.height * 0.42,
    _samaritan,
    wave: v.pulse[0] * 0.5,
    blink: blinkAt(v.time, 0.3),
  );
  canvas.restore();
  if (v.done) {
    paintPerson(
      canvas,
      feetAt(s, 0.86, 0.95),
      s.height * 0.42,
      NT.crowd[2],
      facingLeft: true,
      wave: 0.4,
      blink: blinkAt(v.time, 2),
    );
    for (var k = 0; k < 2; k++) {
      paintThing(canvas, 'coin', boxAt(s, 0.76 + k * 0.04, 0.6, 0.05));
    }
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _desertRoad(canvas, s, 0);
  paintThing(canvas, 'palm', boxAt(s, 0.6, 0.72, 0.34, aspect: 0.7));
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'stone', boxAt(s, 0.26, 1.0, 0.12, aspect: 1.4));
  paintThing(canvas, 'stone', boxAt(s, 0.94, 1.0, 0.14, aspect: 1.4));
  paintAnimal(canvas, Animal.rabbit, boxAt(s, 0.5, 1.0, 0.08));
}

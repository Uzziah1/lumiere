import 'dart:math' as math;
import 'dart:ui';

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

/// La reine Esther (Esther 2 à 9).
final estherPack = StoryPack.scripted(
  scripts: {
    'reine': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.40, 0.30, 0.60, 0.82)],
      sfx: Sfx.chime,
      paint: _reine,
    ),
    'complot': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.40, 0.50, 0.60, 0.80)],
      sfx: Sfx.knock,
      paint: _complot,
    ),
    'jeune': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.36, 0.30, 0.64, 0.82)],
      sfx: Sfx.chime,
      paint: _jeune,
    ),
    'sceptre': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.56, 0.24, 0.80, 0.70)],
      sfx: Sfx.chime,
      paint: _sceptre,
    ),
    'festin': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.30, 0.60, 0.82)],
      paint: _festin,
    ),
    'sauve': StageScript(
      targets: [for (final x in _joy) Rect.fromLTRB(x - 0.06, 0.44, x + 0.06, 0.82)],
      sfx: Sfx.chime,
      paint: _sauve,
    ),
  },
  stickerScene: 'sceptre',
  seekScene: PaintedSeekScene(
    spots: const {
      'crown': (Offset(0.30, 0.66), 0.08),
      'scepter': (Offset(0.86, 0.60), 0.12),
      'scroll': (Offset(0.62, 0.88), 0.09),
      'ring': (Offset(0.46, 0.92), 0.05),
      'grapes': (Offset(0.14, 0.86), 0.09),
      'jar': (Offset(0.92, 0.86), 0.11),
      'dove': (Offset(0.56, 0.18), 0.09),
      'mouse': (Offset(0.74, 0.92), 0.06),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _esther = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFF3A7CA5),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFFF2C14E),
  veil: true,
  bareHead: true,
);

const _queen = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFF7A4E9C),
  headcloth: Color(0xFF2E1E15),
  sash: Color(0xFFF2C14E),
  veil: true,
  bareHead: true,
  crown: true,
);

const _king = PersonStyle(
  skin: Color(0xFFD6A77A),
  robe: Color(0xFFB0413E),
  headcloth: Color(0xFFF2C14E),
  sash: Color(0xFFF2C14E),
  beard: Color(0xFF2E1E15),
  crown: true,
);

const _mordecai = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFF9C7A54),
  headcloth: Color(0xFFE6D8BE),
  beard: Color(0xFFBDB5A8),
);

const _haman = PersonStyle(
  skin: Color(0xFFC08A62),
  robe: Color(0xFF2E2A33),
  headcloth: Color(0xFFB0413E),
  sash: Color(0xFFE9B949),
  beard: Color(0xFF2E1E15),
);

const _joy = [0.2, 0.36, 0.64, 0.8];

// Le palais de Suse : colonnes, tentures bleues et dorées.
void _palace(Canvas canvas, Size s, {double dim = 0}) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = Gradient.linear(Offset.zero, Offset(0, s.height), [
        Color.lerp(const Color(0xFFF7E7C6), const Color(0xFF3D3352), dim)!,
        Color.lerp(const Color(0xFFE6CFA3), const Color(0xFF2B2440), dim)!,
      ]),
  );
  for (var k = 0; k < 5; k++) {
    final x = s.width * (0.04 + k * 0.24);
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(x, s.height * 0.08, s.width * 0.05, s.height * 0.74)),
      const Color(0xFFF0E2C8),
      elevation: 3,
    );
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(x - s.width * 0.01, s.height * 0.06, s.width * 0.07, s.height * 0.04)),
      const Color(0xFFE9B949),
      elevation: 2,
    );
  }
  for (var k = 0; k < 4; k++) {
    final x = s.width * (0.09 + k * 0.24);
    final drape = Path()
      ..moveTo(x, s.height * 0.1)
      ..quadraticBezierTo(x + s.width * 0.095, s.height * 0.22, x + s.width * 0.19, s.height * 0.1)
      ..lineTo(x + s.width * 0.19, s.height * 0.14)
      ..quadraticBezierTo(x + s.width * 0.095, s.height * 0.26, x, s.height * 0.14)
      ..close();
    drawPaper(canvas, drape, k.isEven ? const Color(0xFF3A7CA5) : const Color(0xFFF5EEE0), elevation: 2);
  }
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.8, s.width, s.height * 0.2)),
    const Color(0xFFC9A066),
    elevation: 2,
  );
}

void _throne(Canvas canvas, Size s, double fx) {
  drawPaper(
    canvas,
    Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * (fx - 0.08), s.height * 0.36, s.width * 0.16, s.height * 0.52),
        Radius.circular(s.height * 0.04),
      ),
    ),
    const Color(0xFFE9B949),
    elevation: 4,
    light: 0.25,
  );
}

// 1. Esther, une jeune juive élevée par son cousin Mardochée, devient reine.
void _reine(Canvas canvas, Size s, StageView v) {
  _palace(canvas, s);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.22, 0.95),
    s.height * 0.44,
    _mordecai,
    wave: 0.3 * t,
    blink: blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.95),
    s.height * 0.44,
    t > 0.5 ? _queen : _esther,
    raisedBoth: t > 0.5,
    wave: 0.3,
    blink: blinkAt(v.time, 1),
  );
  if (t > 0 && t <= 0.5) {
    paintThing(
      canvas,
      'crown',
      Rect.fromCenter(
        center: Offset(s.width * 0.5, s.height * (0.1 + 0.3 * t * 2)),
        width: s.height * 0.08,
        height: s.height * 0.08,
      ),
    );
  }
  paintPerson(
    canvas,
    feetAt(s, 0.8, 0.95),
    s.height * 0.48,
    _king,
    facingLeft: true,
    wave: 0.4 * t,
    blink: blinkAt(v.time, 2),
  );
}

// 2. Le méchant Haman obtient du roi une loi contre tout le peuple juif.
void _complot(Canvas canvas, Size s, StageView v) {
  _palace(canvas, s, dim: 0.3);
  _throne(canvas, s, 0.8);
  paintPerson(
    canvas,
    feetAt(s, 0.8, 0.92),
    s.height * 0.46,
    _king,
    facingLeft: true,
    blink: blinkAt(v.time, 2),
  );
  paintPerson(canvas, feetAt(s, 0.3, 0.95), s.height * 0.46, _haman, wave: 0.5, blink: blinkAt(v.time, 0.8));
  final scroll = boxAt(s, 0.5, 0.8, 0.16, aspect: 1.4);
  paintThing(canvas, 'scroll', scroll);
  if (v.eased > 0) {
    canvas.drawCircle(
      scroll.center + Offset(scroll.width * 0.2, scroll.height * 0.1),
      s.height * 0.025 * v.eased,
      Paint()..color = const Color(0xFFB0413E),
    );
    paintThing(canvas, 'ring', boxAt(s, 0.62, 0.66, 0.06 * v.eased));
  }
}

// 3. Mardochée : « Qui sait si ce n'est pas pour un moment comme celui-ci que tu es reine ? » Tous prient trois jours.
void _jeune(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.night);
  paintStarField(canvas, s, v.time, count: 40);
  paintHeavenlyLight(
    canvas,
    s,
    Offset(s.width * 0.5, -s.height * 0.05),
    v.time,
    intensity: 0.15 + 0.5 * v.progress,
  );
  paintHills(canvas, s, v.time, baselines: const [0.76, 0.88], colors: Lands.night, seed: 351);
  for (var d = 0; d < 3; d++) {
    canvas.drawCircle(
      Offset(s.width * (0.44 + d * 0.06), s.height * 0.08),
      s.height * 0.02,
      Paint()..color = d < (v.progress * 3).round() ? Palette.sun : const Color(0x44FFFFFF),
    );
  }
  paintPerson(canvas, feetAt(s, 0.5, 0.94), s.height * 0.46, _queen, raisedBoth: true, wave: 0.2, blink: 1);
  paintPerson(
    canvas,
    feetAt(s, 0.24, 0.96),
    s.height * 0.42,
    _mordecai,
    raisedBoth: true,
    wave: 0.2,
    blink: 1,
  );
  paintPeople(canvas, s, v.time, from: 0.7, to: 0.92, fy: 0.98, h: 0.32, count: 3, raised: true);
}

// 4. Esther entre chez le roi sans être appelée. Le roi lui tend le sceptre d'or : elle est accueillie !
void _sceptre(Canvas canvas, Size s, StageView v) {
  _palace(canvas, s);
  _throne(canvas, s, 0.74);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.74, 0.88),
    s.height * 0.46,
    _king,
    facingLeft: true,
    blink: blinkAt(v.time, 2),
  );
  final tip = Offset.lerp(Offset(s.width * 0.7, s.height * 0.5), Offset(s.width * 0.56, s.height * 0.4), t)!;
  canvas.save();
  canvas.translate(tip.dx, tip.dy);
  canvas.rotate(-0.6 - 0.6 * t);
  paintThing(
    canvas,
    'scepter',
    Rect.fromCenter(center: Offset.zero, width: s.height * 0.16, height: s.height * 0.26),
    glow: t,
  );
  canvas.restore();
  paintPerson(
    canvas,
    feetAt(s, 0.3 + 0.16 * t, 0.95),
    s.height * 0.44,
    _queen,
    raisedBoth: t > 0.8,
    wave: 0.4,
    blink: blinkAt(v.time, 1),
  );
}

// 5. Au festin, Esther révèle au roi qui veut du mal à son peuple.
void _festin(Canvas canvas, Size s, StageView v) {
  _palace(canvas, s);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.22, 0.94),
    s.height * 0.46,
    _king,
    wave: 0.3 + 0.3 * t,
    raisedBoth: t > 0.6,
    blink: blinkAt(v.time, 2),
  );
  paintPerson(canvas, feetAt(s, 0.5, 0.95), s.height * 0.44, _queen, wave: 0.6, blink: blinkAt(v.time, 1));
  paintPerson(
    canvas,
    feetAt(s, 0.8 + 0.12 * t, 0.95),
    s.height * 0.44,
    _haman,
    facingLeft: true,
    raisedBoth: t > 0.5,
    blink: blinkAt(v.time, 0.8),
  );
  final table = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.14, s.height * 0.72, s.width * 0.48, s.height * 0.06),
        Radius.circular(s.height * 0.02),
      ),
    );
  drawPaper(canvas, table, const Color(0xFF7E4A2A), elevation: 3);
  for (final (fx, id) in [(0.22, 'grapes'), (0.34, 'bread'), (0.46, 'fruit'), (0.56, 'jar')]) {
    paintThing(canvas, id, boxAt(s, fx, 0.73, 0.07, aspect: 1.1));
  }
}

// 6. Le peuple de Dieu est sauvé : grande fête et grande joie !
void _sauve(Canvas canvas, Size s, StageView v) {
  paintJerusalem(canvas, s, v.time, sky: Skies.day, horizon: 0.56);
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.94),
    s.height * 0.46,
    _queen,
    raisedBoth: v.done,
    wave: 0.5,
    blink: blinkAt(v.time, 1),
  );
  for (var i = 0; i < _joy.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _joy[i], 0.96),
      s.height * (i.isOdd ? 0.34 : 0.4),
      i == 1 ? _mordecai : Heroes.people[i + 1],
      facingLeft: _joy[i] > 0.5,
      raisedBoth: t >= 1,
      wave: t * 0.6,
      bob: t >= 1 ? (math.sin(v.time * 7 + i)).abs() * s.height * 0.02 : 0,
      blink: blinkAt(v.time, i * 1.2),
    );
  }
  if (v.done) {
    for (var k = 0; k < 10; k++) {
      final x = 0.1 + (k * 0.37 % 0.8);
      final y = 0.1 + ((v.time * 0.1 + k * 0.13) % 0.4);
      paintThing(canvas, 'flower', boxAt(s, x, y, 0.04));
    }
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _palace(canvas, s);
  for (final fx in [0.3, 0.7]) {
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(s.width * (fx - 0.1), s.height * 0.7, s.width * 0.2, s.height * 0.04)),
      const Color(0xFF7E4A2A),
      elevation: 3,
    );
  }
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'basket', boxAt(s, 0.36, 1.0, 0.12));
  paintThing(canvas, 'crate', boxAt(s, 0.82, 1.0, 0.1));
}

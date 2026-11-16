import 'dart:math' as math;
import 'dart:ui';

import '../../art/objects.dart';
import '../../art/paper.dart';
import '../../art/people.dart';
import '../../art/scenery.dart';
import '../../audio/audio.dart';
import '../../story/scripted_stage.dart';
import '../../theme/palette.dart';
import '../nt/nt.dart';
import '../registry.dart';

/// Les noces de Cana (Jean 2.1-11).
final canaPack = StoryPack.scripted(
  scripts: {
    'noces': StageScript(
      targets: [for (final x in _dancers) Rect.fromLTRB(x - 0.06, 0.44, x + 0.06, 0.82)],
      paint: _noces,
    ),
    'marie': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.20, 0.36, 0.40, 0.82)],
      paint: _marie,
    ),
    'jarres': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 6,
      targets: [Rect.fromLTRB(0.20, 0.50, 0.80, 0.84)],
      sfx: Sfx.whoosh,
      paint: _jarres,
    ),
    'vin': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.40, 0.50, 0.60, 0.84)],
      sfx: Sfx.chime,
      paint: _vin,
    ),
    'maitre': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.56, 0.36, 0.78, 0.82)],
      paint: _maitre,
    ),
    'croire': StageScript(
      targets: [for (final x in _friends) Rect.fromLTRB(x - 0.06, 0.44, x + 0.06, 0.82)],
      sfx: Sfx.chime,
      paint: _croire,
    ),
  },
  stickerScene: 'vin',
  seekScene: PaintedSeekScene(
    spots: const {
      'grapes': (Offset(0.20, 0.86), 0.09),
      'jar': (Offset(0.88, 0.84), 0.12),
      'bread': (Offset(0.44, 0.90), 0.07),
      'flower': (Offset(0.62, 0.62), 0.07),
      'fruit': (Offset(0.30, 0.66), 0.06),
      'dove': (Offset(0.70, 0.18), 0.09),
      'harp': (Offset(0.08, 0.66), 0.12),
      'mouse': (Offset(0.62, 0.92), 0.06),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _bride = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFFF5EEE0),
  headcloth: Color(0xFFF2C14E),
  sash: Color(0xFFE9B949),
  veil: true,
);
const _groom = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFFB0413E),
  headcloth: Color(0xFFF2C14E),
  sash: Color(0xFFF5EEE0),
  beard: Color(0xFF2E1E15),
);
const _steward = PersonStyle(
  skin: Color(0xFF9C6440),
  robe: Color(0xFF2F8F6E),
  headcloth: Color(0xFFF5EEE0),
  sash: Color(0xFFE9B949),
  beard: Color(0xFFBDB5A8),
);
const _servant = PersonStyle(
  skin: Color(0xFF7D4A30),
  robe: Color(0xFFE6D8BE),
  headcloth: Color(0xFF9C7A54),
  beard: Color(0xFF2E1E15),
);

const _dancers = [0.2, 0.36, 0.64, 0.8];
const _friends = [0.18, 0.32, 0.68, 0.82];

// La cour de la maison en fête : guirlandes et lampes.
void _feast(Canvas canvas, Size s, double time) {
  paintSkyGradient(canvas, s, Skies.dusk);
  paintStarField(canvas, s, time, count: 20, opacity: 0.6);
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.3, s.width, s.height * 0.5)),
    const Color(0xFFE6CFA3),
    elevation: 3,
  );
  for (var k = 0; k < 3; k++) {
    final x = s.width * (0.12 + k * 0.32);
    drawPaper(
      canvas,
      Path()..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, s.height * 0.42, s.width * 0.1, s.height * 0.38),
          topLeft: Radius.circular(s.width * 0.05),
          topRight: Radius.circular(s.width * 0.05),
        ),
      ),
      const Color(0xFF8A5634),
      elevation: 1,
    );
  }
  final garland = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = s.height * 0.006
    ..color = const Color(0xFF6FA24C);
  canvas.drawPath(
    Path()
      ..moveTo(0, s.height * 0.32)
      ..quadraticBezierTo(s.width * 0.25, s.height * 0.42, s.width * 0.5, s.height * 0.32)
      ..quadraticBezierTo(s.width * 0.75, s.height * 0.42, s.width, s.height * 0.32),
    garland,
  );
  for (var k = 0; k < 9; k++) {
    final x = k / 8;
    final y = 0.32 + 0.1 * (1 - math.pow((x * 2 % 1) * 2 - 1, 2));
    canvas.drawCircle(
      Offset(s.width * x, s.height * (y - 0.02)),
      s.height * 0.014,
      Paint()..color = k.isEven ? const Color(0xFFFFE08A) : const Color(0xFFF28FB0),
    );
  }
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.8, s.width, s.height * 0.2)),
    const Color(0xFFC9A066),
    elevation: 2,
  );
}

void _jars(
  Canvas canvas,
  Size s, {
  double filled = 0,
  double wine = 0,
  double from = 0.24,
  double step = 0.104,
}) {
  for (var k = 0; k < 6; k++) {
    final box = boxAt(s, from + k * step, 0.97, 0.34, aspect: 0.8);
    paintThing(canvas, 'jar', box);
    final level = (filled * 6 - k).clamp(0.0, 1.0);
    if (level > 0) {
      final c = Color.lerp(const Color(0xFF6CB8D4), const Color(0xFF7A2E4E), wine)!;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(box.center.dx, box.top + box.height * 0.2),
          width: box.width * 0.34,
          height: box.height * 0.08,
        ),
        Paint()..color = c,
      );
    }
  }
}

// 1. À Cana, on fête un mariage. Jésus, sa mère et ses disciples sont invités.
void _noces(Canvas canvas, Size s, StageView v) {
  _feast(canvas, s, v.time);
  paintPerson(canvas, feetAt(s, 0.46, 0.92), s.height * 0.46, _groom, wave: 0.4, blink: blinkAt(v.time, 0.4));
  paintPerson(
    canvas,
    feetAt(s, 0.54, 0.93),
    s.height * 0.42,
    _bride,
    facingLeft: true,
    wave: 0.4,
    blink: blinkAt(v.time, 1),
  );
  final guests = [NT.jesus, NT.mary, NT.disciples[0], NT.disciples[1]];
  for (var i = 0; i < _dancers.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _dancers[i], 0.95),
      s.height * 0.42,
      guests[i],
      facingLeft: _dancers[i] > 0.5,
      raisedBoth: t >= 1 && i > 1,
      wave: t * 0.5,
      bob: t >= 1 && i > 1 ? (math.sin(v.time * 7 + i)).abs() * s.height * 0.015 : 0,
      blink: blinkAt(v.time, i * 1.2),
    );
  }
}

// 2. Il n'y a plus de vin ! Marie le dit à Jésus, puis aux serviteurs : « Faites ce qu'il vous dira. »
void _marie(Canvas canvas, Size s, StageView v) {
  _feast(canvas, s, v.time);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.95),
    s.height * 0.42,
    NT.mary,
    wave: 0.3 + 0.3 * t,
    blink: blinkAt(v.time, 1),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.95),
    s.height * 0.46,
    NT.jesus,
    facingLeft: true,
    blink: blinkAt(v.time, 0.7),
  );
  for (var k = 0; k < 2; k++) {
    paintPerson(
      canvas,
      feetAt(s, 0.72 + k * 0.12, 0.96),
      s.height * 0.4,
      _servant,
      facingLeft: true,
      raisedBoth: t > 0.5,
      blink: blinkAt(v.time, k * 1.5),
    );
  }
  paintThing(canvas, 'jar', boxAt(s, 0.12, 0.96, 0.12));
}

// 3. Jésus dit : « Remplissez d'eau ces six grandes jarres de pierre. » On les remplit jusqu'au bord.
void _jarres(Canvas canvas, Size s, StageView v) {
  _feast(canvas, s, v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.1, 0.94),
    s.height * 0.46,
    NT.jesus,
    wave: 0.4,
    blink: blinkAt(v.time, 0.7),
  );
  _jars(canvas, s, filled: v.progress);
  paintPerson(
    canvas,
    feetAt(s, 0.9, 0.96),
    s.height * 0.42,
    _servant,
    facingLeft: true,
    raisedBoth: v.pulse[0] > 0,
    blink: blinkAt(v.time, 1.5),
  );
}

// 4. L'eau est devenue du vin !
void _vin(Canvas canvas, Size s, StageView v) {
  _feast(canvas, s, v.time);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.1, 0.94),
    s.height * 0.46,
    NT.jesus,
    raisedBoth: t > 0,
    wave: 0.4,
    blink: blinkAt(v.time, 0.7),
  );
  _jars(canvas, s, filled: 1, wine: t);
  if (t > 0) {
    canvas.drawCircle(
      Offset(s.width * 0.5, s.height * 0.8),
      s.height * 0.3 * t,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.2 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.08),
    );
  }
}

// 5. Le maître du repas goûte : « Tu as gardé le meilleur vin jusqu'à maintenant ! »
void _maitre(Canvas canvas, Size s, StageView v) {
  _feast(canvas, s, v.time);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.95),
    s.height * 0.42,
    _servant,
    wave: 0.5,
    blink: blinkAt(v.time, 1.5),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.67, 0.94),
    s.height * 0.46,
    _steward,
    facingLeft: true,
    raisedBoth: t > 0.5,
    wave: 0.5,
    blink: t > 0.2 && t < 0.6 ? 1 : blinkAt(v.time, 0.4),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.86, 0.95),
    s.height * 0.46,
    _groom,
    facingLeft: true,
    wave: 0.3 * t,
    blink: blinkAt(v.time, 2),
  );
  // La coupe passe des mains du serviteur au maître.
  final cup = Offset.lerp(Offset(s.width * 0.36, s.height * 0.68), Offset(s.width * 0.6, s.height * 0.6), t)!;
  final path = Path()
    ..moveTo(cup.dx - s.height * 0.03, cup.dy - s.height * 0.04)
    ..lineTo(cup.dx + s.height * 0.03, cup.dy - s.height * 0.04)
    ..quadraticBezierTo(cup.dx + s.height * 0.03, cup.dy, cup.dx, cup.dy + s.height * 0.01)
    ..quadraticBezierTo(cup.dx - s.height * 0.03, cup.dy, cup.dx - s.height * 0.03, cup.dy - s.height * 0.04)
    ..close();
  drawPaper(canvas, path, const Color(0xFFD9B27A), elevation: 2, light: 0.3);
  canvas.drawOval(
    Rect.fromCenter(
      center: cup + Offset(0, -s.height * 0.035),
      width: s.height * 0.05,
      height: s.height * 0.012,
    ),
    Paint()..color = const Color(0xFF7A2E4E),
  );
}

// 6. Ce fut le premier miracle de Jésus. Ses disciples crurent en lui.
void _croire(Canvas canvas, Size s, StageView v) {
  _feast(canvas, s, v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.94),
    s.height * 0.48,
    NT.jesus,
    raisedBoth: v.done,
    wave: 0.4,
    blink: blinkAt(v.time, 0.7),
  );
  for (var i = 0; i < _friends.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _friends[i], 0.96),
      s.height * 0.42,
      NT.disciples[i],
      facingLeft: _friends[i] > 0.5,
      raisedBoth: t >= 1,
      wave: t * 0.5,
      blink: blinkAt(v.time, i * 1.3),
    );
    if (t > 0) {
      canvas.drawCircle(
        Offset(s.width * _friends[i], s.height * 0.46),
        s.height * 0.035 * t,
        Paint()
          ..color = Palette.sun.withValues(alpha: 0.6 * t)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.015),
      );
    }
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _feast(canvas, s, 0);
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.2, s.height * 0.7, s.width * 0.3, s.height * 0.04)),
    const Color(0xFF7E4A2A),
    elevation: 3,
  );
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'jar', boxAt(s, 0.32, 1.0, 0.16));
  paintThing(canvas, 'basket', boxAt(s, 0.74, 1.0, 0.12));
}

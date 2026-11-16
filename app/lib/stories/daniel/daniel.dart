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

/// Daniel dans la fosse aux lions (Daniel 6).
final danielPack = StoryPack.scripted(
  scripts: {
    'priere': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.20, 0.36, 0.42, 0.82)],
      sfx: Sfx.chime,
      paint: _priere,
    ),
    'loi': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.40, 0.50, 0.60, 0.80)],
      sfx: Sfx.knock,
      paint: _loi,
    ),
    'fidele': StageScript(
      targets: [for (final x in _spies) Rect.fromLTRB(x - 0.06, 0.40, x + 0.06, 0.80)],
      paint: _fidele,
    ),
    'fosse': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.12, 0.3),
      swipeTo: Offset(0.5, 0.3),
      paint: _fosse,
    ),
    'ange': StageScript(
      targets: [for (final x in _lions) Rect.fromCenter(center: Offset(x, 0.72), width: 0.2, height: 0.24)],
      sfx: Sfx.chime,
      paint: _ange,
    ),
    'matin': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.44, 0.60, 0.82)],
      sfx: Sfx.chime,
      paint: _matin,
    ),
  },
  stickerScene: 'ange',
  seekScene: PaintedSeekScene(
    spots: const {
      'lion': (Offset(0.22, 0.84), 0.16),
      'scroll': (Offset(0.62, 0.90), 0.09),
      'crown': (Offset(0.86, 0.30), 0.08),
      'lamp': (Offset(0.40, 0.62), 0.09),
      'stone': (Offset(0.48, 0.92), 0.07),
      'owl': (Offset(0.10, 0.30), 0.1),
      'mouse': (Offset(0.78, 0.92), 0.06),
      'coin': (Offset(0.92, 0.70), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _danielStyle = PersonStyle(
  skin: Color(0xFF8E5A3B),
  robe: Color(0xFF3A7CA5),
  headcloth: Color(0xFFF5EEE0),
  sash: Color(0xFFE9B949),
  beard: Color(0xFFBDB5A8),
);

const _king = PersonStyle(
  skin: Color(0xFFA9714B),
  robe: Color(0xFF7A4E9C),
  headcloth: Color(0xFFF2C14E),
  sash: Color(0xFFF2C14E),
  beard: Color(0xFF2E1E15),
  crown: true,
);

const _officials = [
  PersonStyle(
    skin: Color(0xFF9C6440),
    robe: Color(0xFFB0413E),
    headcloth: Color(0xFF2E1E15),
    sash: Color(0xFFF2C14E),
    beard: Color(0xFF2E1E15),
  ),
  PersonStyle(
    skin: Color(0xFF7D4A30),
    robe: Color(0xFF2F8F6E),
    headcloth: Color(0xFFF2C14E),
    sash: Color(0xFF2E1E15),
    beard: Color(0xFF4A3323),
  ),
  PersonStyle(
    skin: Color(0xFFA06A45),
    robe: Color(0xFFE07A3F),
    headcloth: Color(0xFF3A7CA5),
    sash: Color(0xFFF5EEE0),
    beard: Color(0xFF2E1E15),
  ),
];

const _spies = [0.62, 0.74, 0.86];
const _lions = [0.18, 0.5, 0.82];

// La chambre de Daniel, fenêtre ouverte vers Jérusalem.
void _room(Canvas canvas, Size s, double time) {
  paintHouse(canvas, s, wall: const Color(0xFFE9D3A8), lamp: 0.6);
  final window = Rect.fromLTWH(s.width * 0.08, s.height * 0.18, s.width * 0.2, s.height * 0.3);
  canvas.drawRect(
    window,
    Paint()..shader = Gradient.linear(window.topCenter, window.bottomCenter, Skies.dawn.sublist(0, 2)),
  );
  paintSun(canvas, Offset(window.center.dx, window.bottom - window.height * 0.2), s.height * 0.04);
}

// La fosse aux lions : un creux de pierre sombre.
void _den(Canvas canvas, Size s, {double light = 0}) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = Gradient.linear(Offset.zero, Offset(0, s.height), [
        Color.lerp(const Color(0xFF3D3352), const Color(0xFF8C7B66), light)!,
        Color.lerp(const Color(0xFF2B2440), const Color(0xFF5C4A3A), light)!,
      ]),
  );
  for (final (fx, fy, r) in [(0.1, 0.3, 0.2), (0.9, 0.36, 0.22), (0.3, 0.06, 0.16), (0.72, 0.04, 0.18)]) {
    drawPaper(
      canvas,
      Path()..addOval(Rect.fromCircle(center: Offset(s.width * fx, s.height * fy), radius: s.height * r)),
      const Color(0xFF6B5A4E),
      elevation: 4,
    );
  }
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.86, s.width, s.height * 0.14)),
    const Color(0xFF8A7560),
    elevation: 2,
  );
}

// 1. Daniel prie Dieu trois fois par jour, à sa fenêtre ouverte vers Jérusalem.
void _priere(Canvas canvas, Size s, StageView v) {
  _room(canvas, s, v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.31, 0.94),
    s.height * 0.46,
    _danielStyle,
    raisedBoth: true,
    wave: 0.2 + 0.1 * v.pulse[0],
    blink: 1,
  );
  for (var d = 0; d < 3; d++) {
    canvas.drawCircle(
      Offset(s.width * (0.44 + d * 0.06), s.height * 0.1),
      s.height * 0.02,
      Paint()..color = d < (v.progress * 3).round() ? Palette.sun : const Color(0x55FFFFFF),
    );
  }
  if (v.progress > 0) {
    canvas.drawCircle(
      Offset(s.width * 0.31, s.height * 0.6),
      s.height * 0.18 * v.progress,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.06),
    );
  }
}

// 2. Des chefs jaloux font signer au roi Darius une loi : pendant trente jours, on ne priera que le roi.
void _loi(Canvas canvas, Size s, StageView v) {
  paintJerusalem(canvas, s, v.time, sky: Skies.dusk, horizon: 0.5);
  paintPerson(
    canvas,
    feetAt(s, 0.74, 0.94),
    s.height * 0.48,
    _king,
    facingLeft: true,
    wave: 0.3 + 0.3 * v.eased,
    blink: blinkAt(v.time, 0.4),
  );
  for (var i = 0; i < _officials.length; i++) {
    paintPerson(
      canvas,
      feetAt(s, 0.12 + i * 0.1, 0.95),
      s.height * 0.42,
      _officials[i],
      wave: 0.3,
      blink: blinkAt(v.time, i * 1.3),
    );
  }
  final scroll = boxAt(s, 0.5, 0.78, 0.16, aspect: 1.4);
  paintThing(canvas, 'scroll', scroll);
  if (v.eased > 0) {
    canvas.drawCircle(
      scroll.center + Offset(scroll.width * 0.2, scroll.height * 0.1),
      s.height * 0.025 * v.eased,
      Paint()..color = const Color(0xFFB0413E),
    );
  }
}

// 3. Daniel continue de prier Dieu, comme avant. Les chefs l'épient par la fenêtre.
void _fidele(Canvas canvas, Size s, StageView v) {
  _room(canvas, s, v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.94),
    s.height * 0.46,
    _danielStyle,
    raisedBoth: true,
    wave: 0.2,
    blink: 1,
  );
  for (var i = 0; i < _spies.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _spies[i], 0.95 - 0.03 * t),
      s.height * 0.42,
      _officials[i],
      facingLeft: true,
      raisedBoth: t >= 1,
      wave: t * 0.3,
      blink: blinkAt(v.time, i * 1.1),
    );
  }
}

// 4. Daniel est jeté dans la fosse aux lions, et une pierre en ferme l'entrée.
void _fosse(Canvas canvas, Size s, StageView v) {
  _den(canvas, s);
  for (var i = 0; i < _lions.length; i++) {
    paintAnimal(
      canvas,
      Animal.lion,
      boxAt(s, _lions[i] + (i == 1 ? 0.14 : 0), 0.96, 0.34),
      facingLeft: _lions[i] > 0.5,
      blink: blinkAt(v.time, i.toDouble()),
    );
  }
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.92),
    s.height * 0.46,
    _danielStyle,
    raisedBoth: true,
    wave: 0.2,
    blink: blinkAt(v.time, 0.4),
  );
  // La pierre roule devant l'ouverture, en haut.
  final c = Offset(s.width * (0.12 + 0.38 * v.eased), s.height * 0.12);
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(v.eased * math.pi * 2);
  paintThing(
    canvas,
    'stone',
    Rect.fromCenter(center: Offset.zero, width: s.height * 0.26, height: s.height * 0.2),
  );
  canvas.restore();
}

// 5. Dieu envoie son ange : il ferme la gueule des lions, qui se couchent tranquillement.
void _ange(Canvas canvas, Size s, StageView v) {
  final calm = (v.shown(0) + v.shown(1) + v.shown(2)) / 3;
  _den(canvas, s, light: calm * 0.4);
  paintAngel(canvas, feetAt(s, 0.62, 0.84), s.height * 0.5, v.time, glow: 0.5 + 0.5 * calm, facingLeft: true);
  paintPerson(
    canvas,
    feetAt(s, 0.38, 0.92),
    s.height * 0.46,
    _danielStyle,
    raisedBoth: true,
    wave: 0.2,
    blink: blinkAt(v.time, 0.4),
  );
  for (var i = 0; i < _lions.length; i++) {
    final t = v.shown(i);
    final box = boxAt(s, _lions[i], 0.97 - 0.01 * t, 0.34 - 0.06 * t);
    paintAnimal(
      canvas,
      Animal.lion,
      box,
      facingLeft: _lions[i] > 0.5,
      blink: t >= 1 ? 1 : blinkAt(v.time, i.toDouble()),
    );
    if (t >= 1) {
      for (var k = 0; k < 2; k++) {
        final y = (v.time * 0.3 + k * 0.5) % 1;
        canvas.drawCircle(
          Offset(box.right - box.width * 0.1 + y * 10, box.top - y * s.height * 0.06),
          s.height * 0.008 * (1 + k),
          Paint()..color = Color.fromRGBO(255, 255, 255, 0.8 * (1 - y)),
        );
      }
    }
  }
}

// 6. Au matin, le roi court à la fosse : Daniel est vivant ! « Mon Dieu a envoyé son ange. »
void _matin(Canvas canvas, Size s, StageView v) {
  final t = v.eased;
  _den(canvas, s, light: 0.5 + 0.5 * t);
  paintHeavenlyLight(canvas, s, Offset(s.width * 0.5, -s.height * 0.05), v.time, intensity: 0.3 + 0.5 * t);
  paintPerson(
    canvas,
    feetAt(s, 0.86, 0.36),
    s.height * 0.32,
    _king,
    facingLeft: true,
    raisedBoth: t > 0.5,
    wave: 0.5,
    blink: blinkAt(v.time, 1.2),
  );
  for (var i = 0; i < 2; i++) {
    paintAnimal(canvas, Animal.lion, boxAt(s, 0.14 + i * 0.72, 0.97, 0.3), facingLeft: i == 1, blink: 1);
  }
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.92 - 0.04 * t),
    s.height * 0.46,
    _danielStyle,
    raisedBoth: t > 0,
    wave: 0.5,
    blink: blinkAt(v.time, 0.4),
  );
}

void _seekBackground(Canvas canvas, Size s) {
  _room(canvas, s, 0);
  for (final fx in [0.4, 0.88]) {
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(s.width * (fx - 0.1), s.height * 0.66, s.width * 0.2, s.height * 0.04)),
      const Color(0xFF7E4A2A),
      elevation: 3,
    );
  }
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'jar', boxAt(s, 0.34, 1.0, 0.14));
  paintThing(canvas, 'crate', boxAt(s, 0.7, 1.0, 0.12));
}

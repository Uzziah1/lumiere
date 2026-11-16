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
import '../ot/heroes.dart';
import '../registry.dart';

/// Les murs de Jéricho (Josué 6).
final jerichoPack = StoryPack.scripted(
  scripts: {
    'promesse': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.04, 0.62, 0.30)],
      sfx: Sfx.chime,
      paint: _promesse,
    ),
    'tour': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 6,
      targets: [Rect.fromLTRB(0.04, 0.50, 0.40, 0.84)],
      paint: _tour,
    ),
    'trompettes': StageScript(
      targets: [for (final x in _priests) Rect.fromLTRB(x - 0.06, 0.42, x + 0.06, 0.80)],
      sfx: Sfx.whoosh,
      paint: _trompettes,
    ),
    'septieme': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.08, 0.8),
      swipeTo: Offset(0.92, 0.8),
      paint: _septieme,
    ),
    'cri': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.6,
      targets: [Rect.fromLTRB(0.24, 0.30, 0.76, 0.70)],
      sfx: Sfx.knock,
      paint: _cri,
    ),
    'rahab': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.62, 0.20, 0.82, 0.50)],
      sfx: Sfx.chime,
      paint: _rahab,
    ),
  },
  stickerScene: 'cri',
  seekScene: PaintedSeekScene(
    spots: const {
      'horn': (Offset(0.30, 0.86), 0.09),
      'stone': (Offset(0.58, 0.92), 0.07),
      'jar': (Offset(0.88, 0.84), 0.12),
      'palm': (Offset(0.12, 0.52), 0.18),
      'bird': (Offset(0.70, 0.16), 0.08),
      'snail': (Offset(0.46, 0.70), 0.06),
      'tortoise': (Offset(0.16, 0.90), 0.1),
      'ladybug': (Offset(0.80, 0.58), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _priests = [0.22, 0.38, 0.54];

void _plain(Canvas canvas, Size s, double time, {List<Color> sky = Skies.desert}) {
  paintSkyGradient(canvas, s, sky);
  paintClouds(canvas, s, time, count: 2);
  paintHills(canvas, s, time, baselines: const [0.56, 0.62], colors: Lands.desert, seed: 301);
  paintThing(canvas, 'palm', boxAt(s, 0.08, 0.66, 0.3, aspect: 0.7));
  paintThing(canvas, 'palm', boxAt(s, 0.94, 0.66, 0.26, aspect: 0.7));
}

void _ground(Canvas canvas, Size s) {
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.7, s.width, s.height * 0.3)),
    const Color(0xFFE6CFA3),
    elevation: 2,
  );
}

// 1. Dieu dit à Josué : « Je livre Jéricho entre tes mains. »
void _promesse(Canvas canvas, Size s, StageView v) {
  _plain(canvas, s, v.time);
  paintHeavenlyLight(
    canvas,
    s,
    Offset(s.width * 0.5, -s.height * 0.05),
    v.time,
    intensity: 0.2 + 0.8 * v.eased,
  );
  paintWalledCity(canvas, s, v.time);
  _ground(canvas, s);
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.95),
    s.height * 0.44,
    Heroes.joshua,
    raisedBoth: v.eased > 0,
    wave: 0.4 * v.eased,
    blink: blinkAt(v.time, 0.4),
  );
  paintPeople(canvas, s, v.time, from: 0.06, to: 0.18, fy: 0.97, h: 0.34, count: 2);
}

// 2. Chaque jour, pendant six jours, le peuple fait une fois le tour de la ville, en silence.
void _tour(Canvas canvas, Size s, StageView v) {
  _plain(canvas, s, v.time);
  paintWalledCity(canvas, s, v.time);
  _ground(canvas, s);
  final days = (v.progress * 6).round();
  for (var d = 0; d < 6; d++) {
    canvas.drawCircle(
      Offset(s.width * (0.36 + d * 0.056), s.height * 0.08),
      s.height * 0.022,
      Paint()..color = d < days ? Palette.sun : const Color(0x66FFFFFF),
    );
  }
  final shift = (v.progress * 0.5) % 0.5;
  paintPeople(
    canvas,
    s,
    v.time,
    from: 0.06 + shift,
    to: 0.42 + shift,
    fy: 0.95,
    h: 0.32,
    count: 5,
    bob: v.progress < 1 ? 0.006 : 0,
  );
}

// 3. Sept prêtres sonnent de la trompette devant l'arche de l'alliance.
void _trompettes(Canvas canvas, Size s, StageView v) {
  _plain(canvas, s, v.time);
  paintWalledCity(canvas, s, v.time);
  _ground(canvas, s);
  paintCovenantArk(canvas, Offset(s.width * 0.76, s.height * 0.72), s.height * 0.2);
  for (final fx in [0.68, 0.84]) {
    paintPerson(
      canvas,
      feetAt(s, fx, 0.96),
      s.height * 0.38,
      Heroes.priest,
      facingLeft: true,
      blink: blinkAt(v.time, fx * 3),
    );
  }
  for (var i = 0; i < _priests.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _priests[i], 0.95),
      s.height * 0.4,
      Heroes.priest,
      wave: 0.5,
      blink: blinkAt(v.time, i * 1.2),
    );
    final horn = Offset(s.width * (_priests[i] + 0.035), s.height * 0.62);
    paintThing(
      canvas,
      'horn',
      Rect.fromCenter(center: horn, width: s.height * 0.1, height: s.height * 0.1),
      glow: t,
    );
    if (t > 0) {
      for (var k = 0; k < 3; k++) {
        final r = s.height * (0.04 + 0.03 * k + 0.02 * math.sin(v.time * 6));
        canvas.drawArc(
          Rect.fromCircle(center: horn + Offset(-s.height * 0.05, -s.height * 0.05), radius: r),
          -2.6,
          1.2,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = Color.fromRGBO(255, 246, 220, 0.8 * t),
        );
      }
    }
  }
}

// 4. Le septième jour, ils font sept fois le tour de la ville.
void _septieme(Canvas canvas, Size s, StageView v) {
  _plain(canvas, s, v.time, sky: Skies.dawn);
  paintWalledCity(canvas, s, v.time);
  _ground(canvas, s);
  final laps = (v.eased * 7).floor();
  for (var d = 0; d < 7; d++) {
    canvas.drawCircle(
      Offset(s.width * (0.33 + d * 0.056), s.height * 0.08),
      s.height * 0.022,
      Paint()..color = d < laps || v.done ? Palette.sun : const Color(0x66FFFFFF),
    );
  }
  final x = -0.3 + v.eased * 0.9;
  paintPeople(canvas, s, v.time, from: x, to: x + 0.36, fy: 0.95, h: 0.32, count: 5, bob: 0.006, offset: 2);
  paintCovenantArk(canvas, Offset(s.width * (x + 0.46), s.height * 0.76), s.height * 0.14);
}

// 5. Les trompettes sonnent, le peuple pousse un grand cri… et la muraille s'écroule !
void _cri(Canvas canvas, Size s, StageView v) {
  _plain(canvas, s, v.time, sky: Skies.dawn);
  paintWalledCity(canvas, s, v.time, fall: v.eased);
  _ground(canvas, s);
  if (v.eased > 0.4) {
    for (var k = 0; k < 8; k++) {
      final a = k / 8 * math.pi * 2 + v.time;
      final c = Offset(s.width * (0.5 + math.cos(a) * 0.3), s.height * (0.62 + math.sin(a) * 0.06));
      canvas.drawCircle(c, s.height * 0.03, Paint()..color = const Color(0x55E6CFA3));
    }
  }
  paintPeople(
    canvas,
    s,
    v.time,
    from: 0.06,
    to: 0.3,
    fy: 0.97,
    h: 0.32,
    count: 3,
    raised: v.eased > 0,
    wave: 0.6,
  );
  paintPeople(
    canvas,
    s,
    v.time,
    from: 0.72,
    to: 0.94,
    fy: 0.97,
    h: 0.32,
    count: 3,
    raised: v.eased > 0,
    wave: 0.6,
    offset: 3,
    facingLeft: true,
  );
}

// 6. Rahab, qui avait caché les espions, est sauvée avec toute sa famille.
void _rahab(Canvas canvas, Size s, StageView v) {
  _plain(canvas, s, v.time, sky: Skies.day);
  paintWalledCity(canvas, s, v.time, fall: 1);
  // La maison de Rahab, restée debout, avec le cordon rouge à la fenêtre.
  final house = Rect.fromLTWH(s.width * 0.62, s.height * 0.26, s.width * 0.18, s.height * 0.44);
  drawPaper(canvas, Path()..addRect(house), const Color(0xFFE6CFA3), elevation: 5);
  final window = Rect.fromLTWH(
    house.left + house.width * 0.36,
    house.top + house.height * 0.18,
    house.width * 0.28,
    house.height * 0.18,
  );
  canvas.drawRect(window, Paint()..color = const Color(0xFF4A3323));
  final cord = Path()
    ..moveTo(window.center.dx, window.bottom)
    ..quadraticBezierTo(
      window.center.dx + 8 * math.sin(v.time * 2),
      window.bottom + house.height * 0.3,
      window.center.dx,
      window.bottom + house.height * 0.5,
    );
  canvas.drawPath(
    cord,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.height * 0.012
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFC0392B),
  );
  _ground(canvas, s);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.26, 0.95),
    s.height * 0.44,
    Heroes.joshua,
    wave: 0.4,
    blink: blinkAt(v.time, 0.4),
  );
  for (var k = 0; k < 3; k++) {
    paintPerson(
      canvas,
      feetAt(s, 0.72 - t * (0.18 + k * 0.06), 0.96),
      s.height * (k == 2 ? 0.3 : 0.4),
      Heroes.people[k == 0 ? 1 : k + 2],
      facingLeft: true,
      raisedBoth: t >= 1,
      wave: t * 0.4,
      blink: blinkAt(v.time, k * 1.4),
    );
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _plain(canvas, s, 0);
  paintWalledCity(canvas, s, 0, fall: 1);
  _ground(canvas, s);
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'wall', boxAt(s, 0.36, 1.0, 0.16, aspect: 0.6), glow: 1);
  paintThing(canvas, 'wall', boxAt(s, 0.74, 1.0, 0.14, aspect: 0.6), glow: 1);
  paintAnimal(canvas, Animal.sheep, boxAt(s, 0.96, 1.0, 0.1), facingLeft: true);
}

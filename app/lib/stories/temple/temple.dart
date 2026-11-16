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

/// Jésus au Temple à douze ans (Luc 2.41-52).
final templePack = StoryPack.scripted(
  scripts: {
    'fete': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.04, 0.42, 0.40, 0.82)],
      paint: _fete,
    ),
    'retour': StageScript(
      targets: [for (var i = 0; i < 3; i++) Rect.fromLTRB(0.18 + i * 0.22, 0.44, 0.34 + i * 0.22, 0.82)],
      paint: _retour,
    ),
    'recherche': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.72, 0.04, 0.92, 0.32)],
      sfx: Sfx.chime,
      paint: _recherche,
    ),
    'docteurs': StageScript(
      targets: [for (final x in _teachers) Rect.fromLTRB(x - 0.07, 0.40, x + 0.07, 0.80)],
      paint: _docteurs,
    ),
    'retrouve': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.40, 0.36, 0.62, 0.80)],
      sfx: Sfx.chime,
      paint: _retrouve,
    ),
    'grandir': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.38, 0.30, 0.62, 0.80)],
      sfx: Sfx.chime,
      paint: _grandir,
    ),
  },
  stickerScene: 'docteurs',
  seekScene: PaintedSeekScene(
    spots: const {
      'scroll': (Offset(0.14, 0.62), 0.1),
      'dove': (Offset(0.62, 0.18), 0.1),
      'jar': (Offset(0.88, 0.84), 0.13),
      'coin': (Offset(0.46, 0.90), 0.05),
      'basket': (Offset(0.30, 0.86), 0.11),
      'bread': (Offset(0.72, 0.62), 0.07),
      'mouse': (Offset(0.06, 0.90), 0.07),
      'snail': (Offset(0.40, 0.48), 0.06),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

const _teachers = [0.18, 0.34, 0.84];

const _elders = [
  NT.elder,
  PersonStyle(
    skin: Color(0xFFA06A45),
    robe: Color(0xFF6E5A8A),
    headcloth: Color(0xFFF0E2C8),
    sash: Color(0xFFD9B27A),
    beard: Color(0xFFBDB5A8),
  ),
  PersonStyle(
    skin: Color(0xFF7D4A30),
    robe: Color(0xFF3A7CA5),
    headcloth: Color(0xFFF5EEE0),
    sash: Color(0xFFF2C14E),
    beard: Color(0xFFE6E0D6),
  ),
];

// Les colonnes de la cour du Temple.
void _columns(Canvas canvas, Size s, {Color color = const Color(0xFFF0E2C8)}) {
  canvas.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = Gradient.linear(Offset.zero, Offset(0, s.height), const [
        Color(0xFFF7E7C6),
        Color(0xFFE6CFA3),
      ]),
  );
  for (var k = 0; k < 6; k++) {
    final x = s.width * (0.04 + k * 0.19);
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(x, s.height * 0.08, s.width * 0.06, s.height * 0.72)),
      color,
      elevation: 4,
      light: 0.2,
    );
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(x - s.width * 0.012, s.height * 0.06, s.width * 0.084, s.height * 0.04)),
      const Color(0xFFD9B27A),
      elevation: 3,
    );
  }
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22)),
    const Color(0xFFC9A066),
    elevation: 2,
  );
}

// 1. Chaque année, la famille monte à Jérusalem pour la fête de la Pâque.
void _fete(Canvas canvas, Size s, StageView v) {
  paintJerusalem(canvas, s, v.time, horizon: 0.58);
  final go = v.eased * s.width * 0.4;
  final bob = v.progress < 1 ? (math.sin(v.time * 6)).abs() * s.height * 0.006 : 0.0;
  canvas.save();
  canvas.translate(go, 0);
  paintPerson(
    canvas,
    feetAt(s, 0.1, 0.94),
    s.height * 0.36,
    NT.joseph,
    bob: bob,
    blink: blinkAt(v.time, 0.3),
  );
  paintPerson(canvas, feetAt(s, 0.2, 0.95), s.height * 0.34, NT.mary, bob: bob, blink: blinkAt(v.time, 1));
  paintPerson(
    canvas,
    feetAt(s, 0.3, 0.95),
    s.height * 0.34,
    NT.childJesus,
    bob: bob,
    wave: v.pulse[0] * 0.6,
    blink: blinkAt(v.time, 2),
  );
  canvas.restore();
  paintCrowd(canvas, s, v.time, from: 0.66, to: 0.94, fy: 0.97, h: 0.3, count: 3, offset: 2);
}

// 2. Sur le chemin du retour, Marie et Joseph cherchent Jésus parmi les voyageurs.
void _retour(Canvas canvas, Size s, StageView v) {
  paintRoad(canvas, s, v.time, sky: Skies.dusk);
  paintThing(canvas, 'city', boxAt(s, 0.9, 0.7, 0.14, aspect: 1.6));
  for (var i = 0; i < 3; i++) {
    final x = 0.26 + i * 0.22;
    paintPerson(
      canvas,
      feetAt(s, x, 0.92),
      s.height * 0.34,
      NT.crowd[(i * 2) % NT.crowd.length],
      facingLeft: v.shown(i) > 0,
      wave: v.shown(i) * 0.3,
      blink: blinkAt(v.time, i * 1.4),
    );
    if (v.shown(i) > 0.5) {
      // Un petit « non » de la tête : un point d'interrogation doré.
      final c = Offset(s.width * x, s.height * 0.4);
      canvas.drawCircle(c, s.height * 0.035, Paint()..color = const Color(0xCCFFF6DC));
      for (var k = -1; k <= 1; k++) {
        canvas.drawCircle(
          c + Offset(k * s.height * 0.014, 0),
          s.height * 0.005,
          Paint()..color = const Color(0xFF7E4A2A),
        );
      }
    }
  }
  paintPerson(canvas, feetAt(s, 0.06, 0.95), s.height * 0.36, NT.joseph, blink: blinkAt(v.time, 0.3));
  paintPerson(canvas, feetAt(s, 0.13, 0.96), s.height * 0.34, NT.mary, blink: blinkAt(v.time, 1));
}

// 3. Ils retournent à Jérusalem et cherchent Jésus pendant trois jours.
void _recherche(Canvas canvas, Size s, StageView v) {
  final days = v.progress * 3;
  final night = (math.sin(days * math.pi * 2 - math.pi / 2) + 1) / 2 * (v.done ? 0 : 1);
  paintJerusalem(
    canvas,
    s,
    v.time,
    sky: [for (var i = 0; i < 3; i++) Color.lerp(Skies.desert[i], Skies.night[i], night * 0.7)!],
    horizon: 0.6,
  );
  paintSun(canvas, Offset(s.width * 0.82, s.height * 0.18), s.height * 0.07);
  for (var d = 0; d < 3; d++) {
    final lit = days > d + 0.5 || v.done;
    final c = Offset(s.width * (0.1 + d * 0.06), s.height * 0.1);
    canvas.drawCircle(c, s.height * 0.022, Paint()..color = lit ? Palette.sun : const Color(0x55FFFFFF));
  }
  paintPerson(canvas, feetAt(s, 0.36, 0.95), s.height * 0.36, NT.joseph, blink: blinkAt(v.time, 0.3));
  paintPerson(
    canvas,
    feetAt(s, 0.62, 0.95),
    s.height * 0.34,
    NT.mary,
    facingLeft: true,
    blink: blinkAt(v.time, 1),
  );
}

// 4. Jésus est assis au milieu des docteurs : il les écoute et leur pose des questions.
void _docteurs(Canvas canvas, Size s, StageView v) {
  _columns(canvas, s);
  paintThing(canvas, 'scroll', boxAt(s, 0.58, 0.9, 0.08, aspect: 1.6));
  paintPerson(
    canvas,
    feetAt(s, 0.56, 0.92),
    s.height * 0.38,
    NT.childJesus,
    wave: 0.3 + 0.2 * math.sin(v.time * 2),
    blink: blinkAt(v.time, 0.4),
  );
  for (var i = 0; i < _teachers.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _teachers[i], 0.94),
      s.height * 0.42,
      _elders[i],
      facingLeft: _teachers[i] > 0.56,
      raisedBoth: t > 0.5,
      wave: t * 0.4,
      blink: blinkAt(v.time, i * 1.7),
    );
    if (t > 0) {
      final c = Offset(s.width * _teachers[i], s.height * 0.36);
      canvas.drawCircle(
        c,
        s.height * 0.04 * t,
        Paint()
          ..color = Palette.sun.withValues(alpha: 0.6 * t)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.02),
      );
    }
  }
}

// 5. Marie et Joseph le retrouvent : « Je dois m'occuper des affaires de mon Père. »
void _retrouve(Canvas canvas, Size s, StageView v) {
  _columns(canvas, s);
  final t = v.eased;
  paintPerson(
    canvas,
    feetAt(s, 0.2 + 0.14 * t, 0.95),
    s.height * 0.42,
    NT.joseph,
    blink: blinkAt(v.time, 0.3),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.3 + 0.12 * t, 0.96),
    s.height * 0.4,
    NT.mary,
    raisedBoth: t > 0.6,
    wave: t * 0.5,
    blink: blinkAt(v.time, 1),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.52, 0.94),
    s.height * 0.38,
    NT.childJesus,
    facingLeft: true,
    wave: t * 0.4,
    blink: blinkAt(v.time, 2),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.82, 0.94),
    s.height * 0.42,
    NT.elder,
    facingLeft: true,
    blink: blinkAt(v.time, 2.5),
  );
  if (t > 0) {
    final c = Offset(s.width * 0.47, s.height * 0.42);
    canvas.drawCircle(
      c,
      s.height * 0.12 * t,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.35 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.05),
    );
  }
}

// 6. À Nazareth, Jésus grandit en sagesse, en taille et en grâce.
void _grandir(Canvas canvas, Size s, StageView v) {
  paintSkyGradient(canvas, s, Skies.day);
  paintSun(canvas, Offset(s.width * 0.84, s.height * 0.16), s.height * 0.07);
  paintClouds(canvas, s, v.time, count: 2);
  paintHills(canvas, s, v.time, baselines: const [0.64, 0.8], colors: Lands.green, seed: 171);
  for (final fx in [0.12, 0.24]) {
    paintThing(canvas, 'city', boxAt(s, fx, 0.8, 0.16, aspect: 1.3));
  }
  paintThing(canvas, 'tree', boxAt(s, 0.88, 0.86, 0.34));
  final grow = v.eased;
  final style = NT.childJesus.withScale(NT.childJesus.scale + (1 - NT.childJesus.scale) * grow);
  paintPerson(
    canvas,
    feetAt(s, 0.5, 0.94),
    s.height * 0.46,
    style,
    wave: v.done ? 0.5 : 0,
    blink: blinkAt(v.time, 0.7),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.68, 0.95),
    s.height * 0.42,
    NT.joseph,
    facingLeft: true,
    blink: blinkAt(v.time, 1.4),
  );
  paintPerson(canvas, feetAt(s, 0.34, 0.96), s.height * 0.4, NT.mary, blink: blinkAt(v.time, 2));
  paintThing(canvas, 'crate', boxAt(s, 0.6, 0.97, 0.08));
  paintAnimal(canvas, Animal.dove, boxAt(s, 0.2, 0.4, 0.08), blink: blinkAt(v.time, 3));
}

void _seekBackground(Canvas canvas, Size s) {
  _columns(canvas, s);
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.06, s.height * 0.66, s.width * 0.18, s.height * 0.04)),
    const Color(0xFF7E4A2A),
    elevation: 3,
  );
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(s.width * 0.64, s.height * 0.66, s.width * 0.18, s.height * 0.04)),
    const Color(0xFF7E4A2A),
    elevation: 3,
  );
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'jar', boxAt(s, 0.18, 1.0, 0.16));
  paintThing(canvas, 'crate', boxAt(s, 0.58, 1.0, 0.12));
  paintThing(canvas, 'altar', boxAt(s, 0.98, 1.0, 0.14));
}

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

/// Zachée (Luc 19.1-10).
final zacheePack = StoryPack.scripted(
  scripts: {
    'jericho': StageScript(
      targets: [for (final x in _coins) Rect.fromCenter(center: Offset(x, 0.66), width: 0.1, height: 0.16)],
      sfx: Sfx.tap,
      paint: _jericho,
    ),
    'foule': const StageScript(
      interaction: Interaction.tapRepeat,
      taps: 3,
      targets: [Rect.fromLTRB(0.06, 0.44, 0.26, 0.82)],
      paint: _foule,
    ),
    'arbre': const StageScript(
      interaction: Interaction.swipe,
      swipeFrom: Offset(0.7, 0.8),
      swipeTo: Offset(0.7, 0.3),
      paint: _arbre,
    ),
    'appel': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.4,
      targets: [Rect.fromLTRB(0.36, 0.40, 0.56, 0.82)],
      sfx: Sfx.chime,
      paint: _appel,
    ),
    'repas': const StageScript(
      interaction: Interaction.tapThenWait,
      wait: 2.2,
      targets: [Rect.fromLTRB(0.36, 0.30, 0.64, 0.70)],
      paint: _repas,
    ),
    'change': StageScript(
      targets: [for (final x in _poor) Rect.fromLTRB(x - 0.06, 0.46, x + 0.06, 0.82)],
      sfx: Sfx.chime,
      paint: _change,
    ),
  },
  stickerScene: 'arbre',
  seekScene: PaintedSeekScene(
    spots: const {
      'coin': (Offset(0.30, 0.88), 0.05),
      'bird': (Offset(0.56, 0.20), 0.08),
      'fruit': (Offset(0.72, 0.36), 0.06),
      'owl': (Offset(0.82, 0.48), 0.1),
      'jar': (Offset(0.12, 0.84), 0.12),
      'basket': (Offset(0.46, 0.84), 0.1),
      'snail': (Offset(0.66, 0.90), 0.06),
      'ladybug': (Offset(0.90, 0.30), 0.05),
    },
    background: _seekBackground,
    foreground: _seekForeground,
  ),
);

/// Zachée : petit, riche, habit violet.
const _zachee = PersonStyle(
  skin: Color(0xFFA06A45),
  robe: Color(0xFF7A4E9C),
  headcloth: Color(0xFFF2C14E),
  sash: Color(0xFFF2C14E),
  beard: Color(0xFF2E1E15),
  scale: 0.72,
);

const _coins = [0.42, 0.52, 0.62];
const _poor = [0.56, 0.7, 0.84];

// Le grand sycomore au bord du chemin.
void _sycamore(Canvas canvas, Size s, double fx, double fy, double h, double time) {
  final base = feetAt(s, fx, fy);
  final hh = s.height * h;
  final trunk = Path()
    ..moveTo(base.dx - hh * 0.07, base.dy)
    ..quadraticBezierTo(base.dx - hh * 0.04, base.dy - hh * 0.4, base.dx - hh * 0.16, base.dy - hh * 0.62)
    ..lineTo(base.dx - hh * 0.1, base.dy - hh * 0.66)
    ..quadraticBezierTo(base.dx, base.dy - hh * 0.5, base.dx + hh * 0.14, base.dy - hh * 0.64)
    ..lineTo(base.dx + hh * 0.18, base.dy - hh * 0.6)
    ..quadraticBezierTo(base.dx + hh * 0.05, base.dy - hh * 0.4, base.dx + hh * 0.07, base.dy)
    ..close();
  drawPaper(canvas, trunk, const Color(0xFF8A5A36), elevation: 4, light: 0.1);
  final sway = math.sin(time * 0.8) * hh * 0.01;
  final leaves = Path();
  for (final (dx, dy, r) in [
    (-0.2, -0.72, 0.18),
    (0.0, -0.84, 0.2),
    (0.22, -0.74, 0.18),
    (-0.08, -0.66, 0.16),
    (0.12, -0.64, 0.15),
  ]) {
    leaves.addOval(Rect.fromCircle(center: base + Offset(dx * hh + sway, dy * hh), radius: r * hh));
  }
  drawPaper(canvas, leaves, const Color(0xFF5E9B45), elevation: 6, light: 0.18);
}

// Jéricho : une rue de maisons claires sous le soleil.
void _street(Canvas canvas, Size s, double time) {
  paintSkyGradient(canvas, s, Skies.desert);
  paintSun(canvas, Offset(s.width * 0.12, s.height * 0.14), s.height * 0.06);
  paintHills(canvas, s, time, baselines: const [0.6, 0.66], colors: Lands.desert, seed: 211);
  for (final (fx, h) in [(0.18, 0.2), (0.36, 0.16), (0.9, 0.18)]) {
    paintThing(canvas, 'city', boxAt(s, fx, 0.68, h, aspect: 1.3));
  }
  paintThing(canvas, 'palm', boxAt(s, 0.5, 0.7, 0.3, aspect: 0.7));
  drawPaper(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, s.height * 0.7, s.width, s.height * 0.3)),
    const Color(0xFFE6CFA3),
    elevation: 2,
  );
}

// 1. À Jéricho vit Zachée, chef des collecteurs d'impôts, très riche.
void _jericho(Canvas canvas, Size s, StageView v) {
  _street(canvas, s, v.time);
  final table = Path()
    ..addRect(Rect.fromLTWH(s.width * 0.36, s.height * 0.74, s.width * 0.32, s.height * 0.05));
  drawPaper(canvas, table, const Color(0xFF7E4A2A), elevation: 3);
  for (final fx in [0.39, 0.65]) {
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(s.width * (fx - 0.01), s.height * 0.79, s.width * 0.02, s.height * 0.12)),
      const Color(0xFF6B4226),
      elevation: 2,
    );
  }
  paintPerson(
    canvas,
    feetAt(s, 0.28, 0.92),
    s.height * 0.46,
    _zachee,
    wave: 0.3,
    blink: blinkAt(v.time, 0.4),
  );
  for (var i = 0; i < _coins.length; i++) {
    final t = v.shown(i);
    final c = Offset(s.width * _coins[i], s.height * (0.7 - 0.08 * math.sin(t * math.pi)));
    paintThing(canvas, 'coin', Rect.fromCenter(center: c, width: s.height * 0.07, height: s.height * 0.07));
    paintThing(
      canvas,
      'coin',
      Rect.fromCenter(
        center: Offset(s.width * _coins[i], s.height * 0.72),
        width: s.height * 0.07,
        height: s.height * 0.07,
      ),
    );
  }
  paintCrowd(
    canvas,
    s,
    v.time,
    from: 0.78,
    to: 0.94,
    fy: 0.96,
    h: 0.34,
    count: 2,
    facingLeft: true,
    offset: 3,
  );
}

// 2. Jésus passe ! Mais Zachée est trop petit pour voir par-dessus la foule.
void _foule(Canvas canvas, Size s, StageView v) {
  _street(canvas, s, v.time);
  final hop = v.pulse[0] > 0 ? math.sin(v.pulse[0] * math.pi) * s.height * 0.08 : 0.0;
  paintPerson(
    canvas,
    feetAt(s, 0.16, 0.92),
    s.height * 0.46,
    _zachee,
    bob: hop,
    raisedBoth: hop > 0,
    blink: blinkAt(v.time, 0.4),
  );
  paintCrowd(canvas, s, v.time, from: 0.3, to: 0.66, fy: 0.95, h: 0.44, count: 5, wave: 0.4);
  paintPerson(
    canvas,
    feetAt(s, 0.84, 0.94),
    s.height * 0.44,
    NT.jesus,
    facingLeft: true,
    blink: blinkAt(v.time, 0.7),
  );
}

// 3. Zachée court devant et grimpe dans un sycomore.
void _arbre(Canvas canvas, Size s, StageView v) {
  _street(canvas, s, v.time);
  final t = v.eased;
  final climb = Offset.lerp(feetAt(s, 0.62, 0.94), feetAt(s, 0.66, 0.46), t)!;
  paintPerson(
    canvas,
    climb,
    s.height * 0.42,
    _zachee,
    raisedBoth: t > 0 && t < 1,
    wave: t >= 1 ? 0.5 : 0,
    blink: blinkAt(v.time, 0.4),
  );
  _sycamore(canvas, s, 0.72, 0.94, 0.86, v.time);
  if (t >= 1) {
    // Zachée regarde par une trouée du feuillage.
    paintPerson(canvas, climb, s.height * 0.42, _zachee, wave: 0.5, blink: blinkAt(v.time, 0.4));
  }
  paintCrowd(canvas, s, v.time, from: 0.08, to: 0.36, fy: 0.96, h: 0.4, count: 3, offset: 1);
}

// 4. Jésus s'arrête sous l'arbre : « Zachée, descends vite ! Aujourd'hui, je vais chez toi. »
void _appel(Canvas canvas, Size s, StageView v) {
  _street(canvas, s, v.time);
  final t = v.eased;
  _sycamore(canvas, s, 0.72, 0.94, 0.86, v.time);
  final z = Offset.lerp(feetAt(s, 0.66, 0.46), feetAt(s, 0.62, 0.95), t)!;
  paintPerson(canvas, z, s.height * 0.42, _zachee, raisedBoth: true, wave: 0.6, blink: blinkAt(v.time, 0.4));
  paintPerson(
    canvas,
    feetAt(s, 0.46, 0.94),
    s.height * 0.46,
    NT.jesus,
    raisedBoth: t > 0,
    wave: 0.5,
    blink: blinkAt(v.time, 0.7),
  );
  paintCrowd(canvas, s, v.time, from: 0.06, to: 0.3, fy: 0.96, h: 0.4, count: 3, offset: 2);
  if (t > 0) {
    canvas.drawCircle(
      Offset(s.width * 0.54, s.height * 0.6),
      s.height * 0.2 * t,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.2 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.height * 0.08),
    );
  }
}

// 5. Jésus mange chez Zachée, même si les gens ne sont pas contents.
void _repas(Canvas canvas, Size s, StageView v) {
  paintHouse(canvas, s, wall: const Color(0xFFE9D3A8), lamp: 0.5 + 0.5 * v.eased);
  final table = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.3, s.height * 0.7, s.width * 0.4, s.height * 0.08),
        Radius.circular(s.height * 0.02),
      ),
    );
  paintPerson(
    canvas,
    feetAt(s, 0.36, 0.94),
    s.height * 0.46,
    NT.jesus,
    blink: blinkAt(v.time, 0.7),
    wave: 0.3,
  );
  paintPerson(
    canvas,
    feetAt(s, 0.62, 0.94),
    s.height * 0.46,
    _zachee,
    facingLeft: true,
    raisedBoth: v.done,
    wave: 0.4,
    blink: blinkAt(v.time, 0.4),
  );
  drawPaper(canvas, table, const Color(0xFF7E4A2A), elevation: 4);
  if (v.eased > 0) {
    for (final (fx, id) in [(0.4, 'bread'), (0.5, 'fish'), (0.6, 'fruit')]) {
      paintThing(canvas, id, boxAt(s, fx, 0.71, 0.06 * v.eased, aspect: 1.3));
    }
  }
  // Par la fenêtre, des voisins qui murmurent.
  paintCrowd(
    canvas,
    s,
    v.time,
    from: 0.84,
    to: 0.96,
    fy: 0.98,
    h: 0.36,
    count: 2,
    facingLeft: true,
    offset: 4,
  );
}

// 6. Zachée change de vie : il donne la moitié de ses biens aux pauvres.
void _change(Canvas canvas, Size s, StageView v) {
  _street(canvas, s, v.time);
  paintPerson(
    canvas,
    feetAt(s, 0.16, 0.92),
    s.height * 0.46,
    NT.jesus,
    wave: 0.4,
    blink: blinkAt(v.time, 0.7),
  );
  paintPerson(
    canvas,
    feetAt(s, 0.36, 0.94),
    s.height * 0.46,
    _zachee,
    wave: 0.6,
    raisedBoth: v.done,
    blink: blinkAt(v.time, 0.4),
  );
  for (var i = 0; i < _poor.length; i++) {
    final t = v.shown(i);
    paintPerson(
      canvas,
      feetAt(s, _poor[i], 0.95),
      s.height * 0.4,
      NT.crowd[(i + 3) % NT.crowd.length],
      facingLeft: true,
      raisedBoth: t >= 1,
      wave: t * 0.5,
      blink: blinkAt(v.time, i * 1.5),
    );
    if (t > 0) {
      final from = Offset(s.width * 0.4, s.height * 0.68);
      final to = Offset(s.width * _poor[i], s.height * 0.52);
      final c = Offset.lerp(from, to, t)! + Offset(0, -math.sin(t * math.pi) * s.height * 0.12);
      paintThing(canvas, 'coin', Rect.fromCenter(center: c, width: s.height * 0.06, height: s.height * 0.06));
    }
  }
}

void _seekBackground(Canvas canvas, Size s) {
  _street(canvas, s, 0);
  _sycamore(canvas, s, 0.76, 0.86, 0.8, 0);
}

void _seekForeground(Canvas canvas, Size s) {
  paintThing(canvas, 'crate', boxAt(s, 0.24, 1.0, 0.12));
  paintThing(canvas, 'stone', boxAt(s, 0.58, 1.0, 0.08, aspect: 1.4));
  paintAnimal(canvas, Animal.sheep, boxAt(s, 0.94, 1.0, 0.12), facingLeft: true);
}

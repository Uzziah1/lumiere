import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'animals.dart';
import 'paper.dart';
import 'shapes.dart';

/// Objets et éléments de décor des histoires, en papier découpé.
///
/// Chacun est dessiné dans une boîte de 100 × 100 posée en bas, comme les
/// animaux. [paintThing] dessine aussi bien un objet qu'un animal : les
/// mini-jeux (memory, cache-cache) l'utilisent avec des identifiants simples.
void paintThing(Canvas canvas, String id, Rect box, {double time = 0, double glow = 0}) {
  if (box.isEmpty) return;
  for (final a in Animal.values) {
    if (a.name == id) {
      paintAnimal(canvas, a, box);
      return;
    }
  }
  final painter = _things[id];
  if (painter == null) throw ArgumentError('Objet inconnu : $id');
  canvas.save();
  fitBox(canvas, box, const Size(100, 100));
  painter(canvas, time, glow);
  canvas.restore();
}

/// Nom affiché ou annoncé d'un objet (« le soleil »).
String thingLabel(String id) {
  for (final a in Animal.values) {
    if (a.name == id) return a.label;
  }
  return _labels[id] ?? id;
}

/// Tous les objets connus (sans les animaux).
Iterable<String> get thingIds => _things.keys;

bool isThing(String id) => _things.containsKey(id) || Animal.values.any((a) => a.name == id);

const _labels = {
  'sun': 'le soleil',
  'moon': 'la lune',
  'star': 'l’étoile',
  'fish': 'le poisson',
  'flower': 'la fleur',
  'tree': 'l’arbre',
  'fruit': 'le fruit',
  'snake': 'le serpent',
  'camel': 'le chameau',
  'tent': 'la tente',
  'altar': 'l’autel',
  'well': 'le puits',
  'wheat': 'la gerbe de blé',
  'granary': 'le grenier',
  'coat': 'la tunique',
  'crown': 'la couronne',
  'basket': 'le panier',
  'staff': 'le bâton',
  'tambourine': 'le tambourin',
  'harp': 'la harpe',
  'stone': 'la pierre',
  'sling': 'la fronde',
  'boat': 'le bateau',
  'crate': 'la caisse',
  'plant': 'la plante',
  'frog': 'la grenouille',
  'jar': 'la jarre',
  'bush': 'le buisson',
  'flame': 'la flamme',
  'horn': 'la corne d’huile',
  'shell': 'le coquillage',
  'city': 'la ville',
  'reeds': 'les roseaux',
  'bird': 'l’oiseau',
  'bread': 'le pain',
  'donkey': 'l’âne',
  'scroll': 'le rouleau',
  'pig': 'le cochon',
  'coin': 'la pièce',
  'stable': 'l’étable',
  'manger': 'la crèche',
  'temple': 'le temple',
  'tomb': 'le tombeau',
  'cross': 'la croix',
  'ring': 'la bague',
  'palm': 'la palme',
  'torch': 'la torche',
  'lamp': 'la lampe',
  'raven': 'le corbeau',
  'wall': 'la muraille',
  'scepter': 'le sceptre',
  'grapes': 'le raisin',
};

typedef _ThingPainter = void Function(Canvas c, double t, double glow);

void _p(Canvas c, Path path, Color color, [double e = 2, double light = 0.14]) =>
    drawPaper(c, path, color, elevation: e, light: light);

Path _star(Offset at, double r, {int points = 5, double inner = 0.42}) {
  final path = Path();
  for (var k = 0; k < points * 2; k++) {
    final a = -math.pi / 2 + k * math.pi / points;
    final rr = k.isEven ? r : r * inner;
    final p = at + Offset(math.cos(a) * rr, math.sin(a) * rr);
    k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

Path _rrect(double l, double t, double r, double b, double radius) =>
    Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(l, t, r, b), Radius.circular(radius)));

final Map<String, _ThingPainter> _things = {
  'sun': (c, t, g) {
    final rays = Paint()
      ..color = const Color(0xFFF7B731)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var k = 0; k < 12; k++) {
      final a = k * math.pi / 6 + t * 0.3;
      c.drawLine(
        Offset(50 + math.cos(a) * 30, 52 + math.sin(a) * 30),
        Offset(50 + math.cos(a) * 44, 52 + math.sin(a) * 44),
        rays,
      );
    }
    _p(c, circle(const Offset(50, 52), 24), const Color(0xFFFFD45E), 2, 0.25);
    final eye = Paint()..color = const Color(0xFFB9772F);
    c.drawCircle(const Offset(42, 48), 2.5, eye);
    c.drawCircle(const Offset(58, 48), 2.5, eye);
    c.drawArc(
      Rect.fromCircle(center: const Offset(50, 54), radius: 9),
      0.3,
      math.pi - 0.6,
      false,
      Paint()
        ..color = const Color(0xFFB9772F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  },
  'moon': (c, t, g) {
    _p(
      c,
      Path.combine(
        PathOperation.difference,
        circle(const Offset(48, 54), 32),
        circle(const Offset(64, 44), 28),
      ),
      const Color(0xFFFFF0B3),
      2,
      0.2,
    );
    c.drawCircle(const Offset(34, 56), 2.5, Paint()..color = const Color(0xFFB9A35A));
  },
  'star': (c, t, g) => _p(c, _star(const Offset(50, 55), 36), const Color(0xFFF7C948), 2, 0.3),
  'fish': (c, t, g) {
    const body = Color(0xFFF29A45);
    _p(
      c,
      Path()
        ..moveTo(22, 60)
        ..lineTo(4, 42)
        ..lineTo(6, 78)
        ..close(),
      const Color(0xFFE07B2E),
      1.5,
    );
    _p(c, ellipse(const Offset(54, 60), 70, 40), body, 2);
    final stripe = Paint()
      ..color = const Color(0xFFFFF1D6)
      ..strokeWidth = 4;
    c.drawLine(const Offset(46, 44), const Offset(46, 76), stripe);
    c.drawLine(const Offset(62, 42), const Offset(62, 78), stripe);
    c.drawCircle(const Offset(76, 54), 4.5, Paint()..color = const Color(0xFFFFFFFF));
    c.drawCircle(const Offset(77, 54), 2.5, Paint()..color = const Color(0xFF2A1A12));
  },
  'flower': (c, t, g) {
    c.drawLine(
      const Offset(50, 98),
      const Offset(50, 54),
      Paint()
        ..color = const Color(0xFF5E8A3A)
        ..strokeWidth = 4,
    );
    _p(c, ellipse(const Offset(38, 80), 18, 8), const Color(0xFF7FA650), 1);
    for (var k = 0; k < 6; k++) {
      final a = k * math.pi / 3;
      _p(c, circle(Offset(50 + math.cos(a) * 13, 42 + math.sin(a) * 13), 10), const Color(0xFFF07FA0), 1.5);
    }
    _p(c, circle(const Offset(50, 42), 8), const Color(0xFFF7C948), 1);
  },
  'tree': (c, t, g) {
    _p(c, capsule(const Offset(50, 98), const Offset(50, 56), 7), const Color(0xFF8A5634));
    _p(
      c,
      unite([
        circle(const Offset(50, 38), 28),
        circle(const Offset(28, 52), 18),
        circle(const Offset(72, 52), 18),
      ]),
      const Color(0xFF6FA24C),
      3,
    );
    for (final o in const [Offset(40, 32), Offset(62, 28), Offset(70, 52), Offset(32, 56), Offset(52, 50)]) {
      _p(c, circle(o, 5), const Color(0xFFE5523F), 1, 0.3);
    }
  },
  'fruit': (c, t, g) {
    _p(
      c,
      unite([circle(const Offset(40, 64), 26), circle(const Offset(60, 64), 26)]),
      const Color(0xFFE5523F),
      2,
      0.3,
    );
    c.drawLine(
      const Offset(50, 40),
      const Offset(54, 26),
      Paint()
        ..color = const Color(0xFF6B4630)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    _p(c, ellipse(const Offset(64, 30), 20, 9), const Color(0xFF7FA650), 1);
  },
  'snake': (c, t, g) {
    final body = Path()
      ..moveTo(10, 88)
      ..cubicTo(30, 70, 50, 100, 66, 80)
      ..cubicTo(78, 64, 60, 50, 70, 38);
    c.drawPath(
      body,
      Paint()
        ..color = const Color(0x334A2A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    c.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF7DB548)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    c.drawPath(
      body,
      Paint()
        ..color = const Color(0xFFB8D96A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    _p(c, ellipse(const Offset(74, 32), 24, 17), const Color(0xFF7DB548), 1.5);
    c.drawCircle(const Offset(78, 29), 2.6, Paint()..color = const Color(0xFF2A1A12));
    c.drawLine(
      const Offset(86, 34),
      const Offset(94, 36),
      Paint()
        ..color = const Color(0xFFE5523F)
        ..strokeWidth = 1.6,
    );
  },
  'camel': (c, t, g) {
    const coat = Color(0xFFD9A55E);
    for (final x in [30.0, 38.0, 62.0, 70.0]) {
      _p(
        c,
        capsule(Offset(x, 66), Offset(x, 96), 3.6),
        x == 38 || x == 70 ? const Color(0xFFC08E4A) : coat,
        1,
      );
    }
    _p(
      c,
      unite([
        ellipse(const Offset(50, 60), 52, 26),
        circle(const Offset(42, 46), 12),
        circle(const Offset(58, 46), 12),
      ]),
      coat,
      2,
    );
    _p(
      c,
      Path()
        ..moveTo(70, 58)
        ..quadraticBezierTo(82, 46, 80, 28)
        ..lineTo(88, 26)
        ..quadraticBezierTo(92, 50, 76, 64)
        ..close(),
      coat,
      1.5,
    );
    _p(c, ellipse(const Offset(88, 26), 16, 10), coat, 1);
    c.drawCircle(const Offset(90, 23), 1.6, Paint()..color = const Color(0xFF2A1A12));
    _p(c, _rrect(38, 36, 62, 44, 3), const Color(0xFFC0504D), 1);
  },
  'tent': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(6, 96)
        ..lineTo(50, 30)
        ..lineTo(94, 96)
        ..close(),
      const Color(0xFFD9B27A),
      3,
    );
    _p(
      c,
      Path()
        ..moveTo(50, 30)
        ..lineTo(94, 96)
        ..lineTo(64, 96)
        ..close(),
      const Color(0xFFC79B60),
      0,
      0,
    );
    _p(
      c,
      Path()
        ..moveTo(40, 96)
        ..lineTo(50, 60)
        ..lineTo(60, 96)
        ..close(),
      const Color(0xFF6B4630),
      0,
      0,
    );
    final stripe = Paint()
      ..color = const Color(0xFFB0563A)
      ..strokeWidth = 3;
    c.drawLine(const Offset(26, 68), const Offset(74, 68), stripe);
  },
  'altar': (c, t, g) {
    for (final (x, y, w) in const [(20.0, 80.0, 60.0), (26.0, 64.0, 48.0), (32.0, 50.0, 36.0)]) {
      _p(c, _rrect(x, y, x + w, y + 16, 4), const Color(0xFFB8AFA0), 2, 0.15);
    }
    final flame = Path()
      ..moveTo(50, 50)
      ..cubicTo(36, 40, 44, 26, 50, 14 + math.sin(t * 6) * 2)
      ..cubicTo(56, 26, 64, 40, 50, 50)
      ..close();
    _p(c, flame, const Color(0xFFF29A45), 0, 0.3);
  },
  'well': (c, t, g) {
    _p(c, _rrect(20, 60, 80, 96, 6), const Color(0xFFB8AFA0), 3);
    _p(c, ellipse(const Offset(50, 60), 60, 14), const Color(0xFF3E5C76), 0, 0);
    c.drawLine(
      const Offset(24, 60),
      const Offset(24, 24),
      Paint()
        ..color = const Color(0xFF8A5634)
        ..strokeWidth = 5,
    );
    c.drawLine(
      const Offset(76, 60),
      const Offset(76, 24),
      Paint()
        ..color = const Color(0xFF8A5634)
        ..strokeWidth = 5,
    );
    c.drawLine(
      const Offset(20, 24),
      const Offset(80, 24),
      Paint()
        ..color = const Color(0xFF7E4A2A)
        ..strokeWidth = 6,
    );
    _p(c, _rrect(44, 36, 56, 48, 2), const Color(0xFF9A5E36), 1);
  },
  'wheat': (c, t, g) {
    for (final dx in [-12.0, -6.0, 0.0, 6.0, 12.0]) {
      c.drawLine(
        Offset(50 + dx * 0.4, 96),
        Offset(50 + dx * 1.6, 40),
        Paint()
          ..color = const Color(0xFFC79B35)
          ..strokeWidth = 2.5,
      );
      for (var k = 0; k < 4; k++) {
        _p(
          c,
          ellipse(Offset(50 + dx * 1.6 + (k.isEven ? -3 : 3), 22 + k * 7.0), 6, 10),
          const Color(0xFFE6C15A),
          0.8,
        );
      }
    }
    _p(c, _rrect(38, 70, 62, 76, 2), const Color(0xFFB0563A), 1);
  },
  'granary': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(22, 96)
        ..lineTo(22, 46)
        ..quadraticBezierTo(50, 4, 78, 46)
        ..lineTo(78, 96)
        ..close(),
      const Color(0xFFE2BC72),
      3,
    );
    _p(c, _rrect(42, 70, 58, 96, 6), const Color(0xFF8A5634), 0, 0);
    final band = Paint()
      ..color = const Color(0xFFC79B60)
      ..strokeWidth = 3;
    c.drawLine(const Offset(22, 52), const Offset(78, 52), band);
  },
  'coat': (c, t, g) {
    final coat = Path()
      ..moveTo(30, 24)
      ..lineTo(70, 24)
      ..lineTo(94, 46)
      ..lineTo(82, 56)
      ..lineTo(74, 48)
      ..lineTo(78, 96)
      ..lineTo(22, 96)
      ..lineTo(26, 48)
      ..lineTo(18, 56)
      ..lineTo(6, 46)
      ..close();
    c.save();
    c.drawPath(
      coat.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0x4D5A2412)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    c.clipPath(coat);
    const colors = [
      Color(0xFFE85A5A),
      Color(0xFFF29A45),
      Color(0xFFF5D04E),
      Color(0xFF7CC66B),
      Color(0xFF4FA8D8),
      Color(0xFFA77BCB),
    ];
    for (var i = 0; i < 12; i++) {
      c.drawRect(Rect.fromLTWH(0, 20 + i * 7.0, 100, 7), Paint()..color = colors[i % colors.length]);
    }
    c.restore();
    _p(
      c,
      Path()
        ..moveTo(40, 24)
        ..quadraticBezierTo(50, 34, 60, 24)
        ..close(),
      const Color(0xFF6B4630),
      0,
      0,
    );
  },
  'crown': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(12, 84)
        ..lineTo(10, 36)
        ..lineTo(30, 58)
        ..lineTo(50, 26)
        ..lineTo(70, 58)
        ..lineTo(90, 36)
        ..lineTo(88, 84)
        ..close(),
      const Color(0xFFF2C14E),
      3,
      0.3,
    );
    for (final (x, color) in const [
      (30.0, Color(0xFFE85A5A)),
      (50.0, Color(0xFF4FA8D8)),
      (70.0, Color(0xFF7CC66B)),
    ]) {
      _p(c, circle(Offset(x, 72), 5), color, 0.5, 0.3);
    }
  },
  'basket': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(6, 60)
        ..lineTo(94, 60)
        ..quadraticBezierTo(88, 92, 50, 92)
        ..quadraticBezierTo(12, 92, 6, 60)
        ..close(),
      const Color(0xFFC9A066),
      3,
    );
    final weave = Paint()
      ..color = const Color(0xFF9A7442)
      ..strokeWidth = 2;
    for (var x = 16.0; x < 90; x += 10) {
      c.drawLine(Offset(x, 62), Offset(x + 2, 88), weave);
    }
    _p(c, ellipse(const Offset(50, 60), 88, 14), const Color(0xFFDDBB80), 0, 0.1);
    _p(c, ellipse(const Offset(50, 56), 50, 14), const Color(0xFFF3E7D3), 1);
  },
  'staff': (c, t, g) {
    final staff = Path()
      ..moveTo(52, 98)
      ..lineTo(52, 30)
      ..quadraticBezierTo(52, 10, 68, 12)
      ..quadraticBezierTo(80, 16, 76, 30);
    c.drawPath(
      staff,
      Paint()
        ..color = const Color(0xFF7E4A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    if (g > 0) {
      c.drawCircle(
        const Offset(60, 20),
        22 * g,
        Paint()
          ..color = Color.fromRGBO(255, 240, 180, 0.5 * g)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  },
  'tambourine': (c, t, g) {
    _p(c, circle(const Offset(50, 56), 38), const Color(0xFFD9A55E), 3);
    _p(c, circle(const Offset(50, 56), 30), const Color(0xFFF6E7C8), 0, 0.1);
    for (var k = 0; k < 6; k++) {
      final a = k * math.pi / 3;
      _p(
        c,
        circle(Offset(50 + math.cos(a) * 34, 56 + math.sin(a) * 34), 5),
        const Color(0xFFF2C14E),
        0.5,
        0.3,
      );
    }
    final ribbon = Paint()
      ..color = const Color(0xFFE85A5A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    c.drawPath(
      Path()
        ..moveTo(80, 80)
        ..quadraticBezierTo(92, 90, 86, 99),
      ribbon,
    );
  },
  'harp': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(30, 96)
        ..lineTo(30, 30)
        ..quadraticBezierTo(30, 12, 46, 16)
        ..quadraticBezierTo(72, 24, 78, 50)
        ..quadraticBezierTo(82, 72, 70, 96)
        ..close(),
      const Color(0xFFE2A93B),
      3,
    );
    _p(
      c,
      Path()
        ..moveTo(38, 88)
        ..lineTo(38, 32)
        ..quadraticBezierTo(40, 24, 48, 26)
        ..quadraticBezierTo(66, 32, 70, 52)
        ..quadraticBezierTo(72, 70, 63, 88)
        ..close(),
      const Color(0xFFFDF1DE),
      0,
      0,
    );
    final string = Paint()
      ..color = const Color(0xFFB9772F)
      ..strokeWidth = 1.6;
    for (var x = 44.0; x <= 64; x += 4.5) {
      c.drawLine(Offset(x, 30 + (x - 44) * 0.7), Offset(x, 88), string);
    }
  },
  'stone': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(14, 90)
        ..quadraticBezierTo(8, 60, 36, 50)
        ..quadraticBezierTo(70, 40, 86, 62)
        ..quadraticBezierTo(96, 90, 60, 94)
        ..close(),
      const Color(0xFFB8B3AA),
      2,
      0.3,
    );
    c.drawArc(
      Rect.fromLTWH(30, 58, 30, 16),
      math.pi * 1.1,
      1.2,
      false,
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  },
  'sling': (c, t, g) {
    final cord = Paint()
      ..color = const Color(0xFF8A5634)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    c.drawPath(
      Path()
        ..moveTo(20, 20)
        ..quadraticBezierTo(30, 60, 46, 78),
      cord,
    );
    c.drawPath(
      Path()
        ..moveTo(80, 20)
        ..quadraticBezierTo(70, 60, 54, 78),
      cord,
    );
    _p(c, ellipse(const Offset(50, 80), 26, 14), const Color(0xFFA9714B), 1.5);
    _p(c, circle(const Offset(50, 76), 6), const Color(0xFFB8B3AA), 1);
  },
  'boat': (c, t, g) {
    c.drawLine(
      const Offset(50, 70),
      const Offset(50, 8),
      Paint()
        ..color = const Color(0xFF7E4A2A)
        ..strokeWidth = 4,
    );
    _p(
      c,
      Path()
        ..moveTo(53, 12)
        ..quadraticBezierTo(84, 34, 88, 64)
        ..lineTo(53, 64)
        ..close(),
      const Color(0xFFFFF7EA),
      2,
      0.1,
    );
    _p(
      c,
      Path()
        ..moveTo(47, 16)
        ..quadraticBezierTo(22, 40, 18, 64)
        ..lineTo(47, 64)
        ..close(),
      const Color(0xFFF2E6CF),
      2,
      0.1,
    );
    _p(
      c,
      Path()
        ..moveTo(4, 70)
        ..lineTo(96, 70)
        ..quadraticBezierTo(86, 96, 50, 96)
        ..quadraticBezierTo(14, 96, 4, 70)
        ..close(),
      const Color(0xFFA86A3E),
      3,
    );
    c.drawLine(
      const Offset(8, 78),
      const Offset(92, 78),
      Paint()
        ..color = const Color(0xFF7E4A2A)
        ..strokeWidth = 2,
    );
  },
  'crate': (c, t, g) {
    _p(c, _rrect(14, 40, 86, 96, 3), const Color(0xFFC68A55), 3);
    final slat = Paint()
      ..color = const Color(0xFFA86A3E)
      ..strokeWidth = 4;
    c.drawLine(const Offset(16, 42), const Offset(84, 94), slat);
    c.drawRect(const Rect.fromLTRB(16, 42, 84, 94), slat..style = PaintingStyle.stroke);
  },
  'plant': (c, t, g) {
    c.drawPath(
      Path()
        ..moveTo(50, 98)
        ..quadraticBezierTo(46, 60, 54, 30),
      Paint()
        ..color = const Color(0xFF5E8A3A)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (final (o, a) in const [
      (Offset(36, 34), -0.5),
      (Offset(66, 26), 0.5),
      (Offset(34, 60), -0.3),
      (Offset(66, 54), 0.4),
      (Offset(52, 16), 0.0),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      c.rotate(a);
      _p(
        c,
        Path()
          ..moveTo(-16, 0)
          ..quadraticBezierTo(0, -16, 16, 0)
          ..quadraticBezierTo(0, 16, -16, 0)
          ..close(),
        const Color(0xFF6FA24C),
        1.5,
      );
      c.restore();
    }
  },
  'frog': (c, t, g) {
    const skin = Color(0xFF7DB548);
    _p(c, ellipse(const Offset(50, 72), 64, 40), skin, 2);
    _p(c, ellipse(const Offset(50, 80), 40, 20), const Color(0xFFC6E08A), 0, 0.1);
    for (final x in [32.0, 68.0]) {
      _p(c, circle(Offset(x, 48), 12), skin, 1.5);
      c.drawCircle(Offset(x, 47), 7, Paint()..color = const Color(0xFFFFFFFF));
      c.drawCircle(Offset(x + 1, 47), 4, Paint()..color = const Color(0xFF2A1A12));
    }
    c.drawArc(
      const Rect.fromLTWH(36, 58, 28, 14),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF3E6B22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    for (final x in [20.0, 80.0]) {
      _p(c, ellipse(Offset(x, 92), 22, 8), skin, 1);
    }
  },
  'jar': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(36, 18)
        ..lineTo(64, 18)
        ..lineTo(62, 30)
        ..quadraticBezierTo(90, 46, 80, 80)
        ..quadraticBezierTo(70, 98, 50, 98)
        ..quadraticBezierTo(30, 98, 20, 80)
        ..quadraticBezierTo(10, 46, 38, 30)
        ..close(),
      const Color(0xFFC8744A),
      3,
    );
    final band = Paint()
      ..color = const Color(0xFF8E4F2E)
      ..strokeWidth = 3;
    c.drawLine(const Offset(22, 56), const Offset(78, 56), band);
  },
  'bush': (c, t, g) {
    _p(
      c,
      unite([
        circle(const Offset(30, 74), 20),
        circle(const Offset(50, 64), 26),
        circle(const Offset(72, 74), 20),
        _rrect(14, 74, 88, 96, 10),
      ]),
      const Color(0xFF6F8F50),
      3,
    );
    if (g > 0) {
      for (var k = 0; k < 5; k++) {
        final x = 26 + k * 12.0;
        final h = 34 + 14 * math.sin(t * 7 + k * 1.7);
        final flame = Path()
          ..moveTo(x - 9, 70)
          ..quadraticBezierTo(x - 10, 70 - h * 0.6, x, 70 - h * g)
          ..quadraticBezierTo(x + 10, 70 - h * 0.6, x + 9, 70)
          ..close();
        c.drawPath(flame, Paint()..color = Color.fromRGBO(242, 154, 69, 0.85 * g));
        c.drawPath(
          flame.transform(
            Float64List.fromList([0.55, 0, 0, 0, 0, 0.6, 0, 0, 0, 0, 1, 0, x * 0.45, 28, 0, 1]),
          ),
          Paint()..color = Color.fromRGBO(255, 230, 140, 0.9 * g),
        );
      }
    }
  },
  'flame': (c, t, g) {
    final flame = Path()
      ..moveTo(50, 96)
      ..cubicTo(14, 80, 30, 46, 50, 10 + math.sin(t * 6) * 3)
      ..cubicTo(70, 46, 86, 80, 50, 96)
      ..close();
    _p(c, flame, const Color(0xFFF29A45), 0, 0.3);
    _p(c, ellipse(const Offset(50, 76), 26, 34), const Color(0xFFFFE08A), 0, 0.2);
  },
  'horn': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(14, 30)
        ..quadraticBezierTo(30, 86, 84, 84)
        ..lineTo(86, 70)
        ..quadraticBezierTo(44, 66, 26, 24)
        ..close(),
      const Color(0xFFE8D2A8),
      2,
      0.2,
    );
    final ring = Paint()
      ..color = const Color(0xFFC9A066)
      ..strokeWidth = 3;
    c.drawLine(const Offset(40, 64), const Offset(48, 54), ring);
    if (g > 0) {
      c.drawCircle(const Offset(18, 26), 8 * g, Paint()..color = const Color(0xFFF2C14E));
    }
  },
  'shell': (c, t, g) {
    final shell = Path()..moveTo(50, 92);
    for (var k = 0; k <= 8; k++) {
      final a = math.pi + k * math.pi / 8;
      shell.lineTo(50 + math.cos(a) * 42, 80 + math.sin(a) * 52);
    }
    _p(c, shell..close(), const Color(0xFFF6B7A6), 2, 0.25);
    final rib = Paint()
      ..color = const Color(0xFFE08A7A)
      ..strokeWidth = 2;
    for (var k = 1; k < 8; k++) {
      final a = math.pi + k * math.pi / 8;
      c.drawLine(const Offset(50, 90), Offset(50 + math.cos(a) * 38, 80 + math.sin(a) * 46), rib);
    }
  },
  'city': (c, t, g) {
    for (final (x, w, h) in const [
      (4.0, 24.0, 44.0),
      (26.0, 22.0, 60.0),
      (46.0, 28.0, 50.0),
      (72.0, 24.0, 66.0),
    ]) {
      _p(c, _rrect(x, 96 - h, x + w, 96, 3), const Color(0xFFE6CFA3), 2);
      _p(c, _rrect(x + w * 0.35, 96 - h * 0.4, x + w * 0.65, 96, w * 0.15), const Color(0xFF8C5A3C), 0, 0);
    }
    _p(c, _rrect(0, 84, 100, 98, 2), const Color(0xFFC9A877), 2);
  },
  'reeds': (c, t, g) {
    final stem = Paint()
      ..color = const Color(0xFF6F8F50)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    for (var k = 0; k < 9; k++) {
      final x = 8 + k * 10.5;
      final top = 20 + (k * 37 % 30).toDouble();
      final sway = math.sin(t * 1.5 + k) * 3;
      c.drawLine(Offset(x, 98), Offset(x + sway, top), stem);
      _p(
        c,
        capsule(Offset(x + sway, top - 2), Offset(x + sway, top + 12), 3.4),
        const Color(0xFF8A5634),
        0.5,
      );
    }
  },
  'bird': (c, t, g) {
    final wing = Path()
      ..moveTo(10, 50)
      ..quadraticBezierTo(30, 30 + math.sin(t * 9) * 8, 50, 52)
      ..quadraticBezierTo(70, 30 + math.sin(t * 9) * 8, 90, 50)
      ..quadraticBezierTo(70, 44, 50, 62)
      ..quadraticBezierTo(30, 44, 10, 50)
      ..close();
    _p(c, wing, const Color(0xFF4F86C6), 1.5);
  },
  'bread': (c, t, g) {
    for (final (dx, dy) in const [(0.0, 0.0), (-20.0, 14.0), (20.0, 14.0)]) {
      _p(c, ellipse(Offset(50 + dx, 66 + dy), 46, 26), const Color(0xFFD9A55E), 2, 0.25);
      final score = Paint()
        ..color = const Color(0xFFB07A3A)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      c.drawLine(Offset(40 + dx, 60 + dy), Offset(46 + dx, 70 + dy), score);
      c.drawLine(Offset(52 + dx, 58 + dy), Offset(58 + dx, 68 + dy), score);
    }
  },
  'donkey': (c, t, g) {
    const fur = Color(0xFF9C948C);
    for (final x in [32.0, 40.0, 62.0, 70.0]) {
      _p(
        c,
        capsule(Offset(x, 66), Offset(x, 96), 3.6),
        x == 40 || x == 70 ? const Color(0xFF857D76) : fur,
        1,
      );
    }
    _p(c, ellipse(const Offset(50, 60), 56, 28), fur, 2);
    c.drawPath(
      Path()
        ..moveTo(22, 56)
        ..quadraticBezierTo(12, 62, 14, 76),
      Paint()
        ..color = fur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    _p(
      c,
      Path()
        ..moveTo(70, 56)
        ..quadraticBezierTo(76, 40, 80, 32)
        ..lineTo(92, 40)
        ..quadraticBezierTo(86, 54, 78, 64)
        ..close(),
      fur,
      1.5,
    );
    _p(c, ellipse(const Offset(88, 42), 18, 14), fur, 1);
    _p(c, ellipse(const Offset(94, 46), 8, 7), const Color(0xFFD8CFC6), 0.5);
    for (final (x, a) in const [(80.0, -0.3), (86.0, 0.2)]) {
      c.save();
      c.translate(x, 30);
      c.rotate(a);
      _p(c, ellipse(Offset.zero, 6, 18), fur, 1);
      c.restore();
    }
    c.drawCircle(const Offset(88, 39), 1.8, Paint()..color = const Color(0xFF2A1A12));
  },
  'scroll': (c, t, g) {
    _p(c, _rrect(22, 30, 78, 86, 2), const Color(0xFFF3E2C0), 2, 0.1);
    for (final y in [30.0, 86.0]) {
      _p(c, capsule(Offset(16, y), Offset(84, y), 6), const Color(0xFFC9A066), 1.5);
    }
    final line = Paint()
      ..color = const Color(0xFF9A7442)
      ..strokeWidth = 2;
    for (var y = 44.0; y < 80; y += 8) {
      c.drawLine(Offset(30, y), Offset(70, y), line);
    }
  },
  'pig': (c, t, g) {
    const skin = Color(0xFFF2B3B0);
    for (final x in [32.0, 40.0, 60.0, 68.0]) {
      _p(c, capsule(Offset(x, 74), Offset(x, 96), 4), const Color(0xFFE59C99), 1);
    }
    _p(c, ellipse(const Offset(50, 66), 60, 40), skin, 2);
    _p(c, circle(const Offset(76, 58), 16), skin, 1.5);
    _p(c, ellipse(const Offset(88, 62), 12, 10), const Color(0xFFE88F8C), 0.5);
    c.drawCircle(const Offset(86, 62), 1.5, Paint()..color = const Color(0xFF8A4A48));
    c.drawCircle(const Offset(90, 62), 1.5, Paint()..color = const Color(0xFF8A4A48));
    _p(
      c,
      Path()
        ..moveTo(70, 44)
        ..lineTo(66, 34)
        ..lineTo(78, 42)
        ..close(),
      const Color(0xFFE59C99),
      0.5,
    );
    c.drawCircle(const Offset(78, 52), 2.2, Paint()..color = const Color(0xFF2A1A12));
    c.drawPath(
      Path()
        ..moveTo(20, 62)
        ..cubicTo(12, 54, 22, 50, 16, 46),
      Paint()
        ..color = const Color(0xFFE59C99)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  },
  'coin': (c, t, g) {
    _p(c, circle(const Offset(50, 60), 30), const Color(0xFFF2C14E), 2, 0.35);
    c.drawCircle(
      const Offset(50, 60),
      22,
      Paint()
        ..color = const Color(0xFFD9A43A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _p(c, _star(const Offset(50, 60), 10), const Color(0xFFD9A43A), 0, 0);
  },
  'stable': (c, t, g) {
    _p(c, _rrect(14, 44, 86, 98, 3), const Color(0xFFB57B4E), 3);
    _p(
      c,
      Path()
        ..moveTo(6, 48)
        ..lineTo(50, 18)
        ..lineTo(94, 48)
        ..close(),
      const Color(0xFFD9B27A),
      3,
      0.2,
    );
    final straw = Paint()
      ..color = const Color(0xFFC79B35)
      ..strokeWidth = 2;
    for (var x = 14.0; x < 88; x += 7) {
      c.drawLine(Offset(x, 46), Offset(x + 4, 38 - (x - 50).abs() * 0.4), straw);
    }
    _p(c, _rrect(34, 62, 66, 98, 4), const Color(0xFF6B4630), 0, 0);
    if (g > 0) {
      c.drawCircle(
        const Offset(50, 80),
        18 * g,
        Paint()
          ..color = Color.fromRGBO(255, 230, 150, 0.7 * g)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  },
  'manger': (c, t, g) {
    final leg = Paint()
      ..color = const Color(0xFF7E4A2A)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(26, 98), const Offset(40, 60), leg);
    c.drawLine(const Offset(74, 98), const Offset(60, 60), leg);
    c.drawLine(const Offset(40, 98), const Offset(26, 60), leg);
    c.drawLine(const Offset(60, 98), const Offset(74, 60), leg);
    _p(
      c,
      Path()
        ..moveTo(14, 56)
        ..lineTo(86, 56)
        ..lineTo(76, 76)
        ..lineTo(24, 76)
        ..close(),
      const Color(0xFFA86A3E),
      2,
    );
    _p(c, ellipse(const Offset(50, 56), 70, 12), const Color(0xFFE6C15A), 1, 0.2);
  },
  'temple': (c, t, g) {
    _p(c, _rrect(8, 86, 92, 98, 2), const Color(0xFFE6D3A8), 2);
    _p(c, _rrect(14, 40, 86, 88, 2), const Color(0xFFF1E0B8), 3);
    for (var x = 20.0; x < 84; x += 13) {
      c.drawLine(
        Offset(x, 44),
        Offset(x, 86),
        Paint()
          ..color = const Color(0xFFD9C08A)
          ..strokeWidth = 4,
      );
    }
    _p(
      c,
      Path()
        ..moveTo(8, 42)
        ..lineTo(50, 18)
        ..lineTo(92, 42)
        ..close(),
      const Color(0xFFE2BC72),
      3,
      0.2,
    );
    _p(c, _rrect(42, 62, 58, 88, 8), const Color(0xFF8C5A3C), 0, 0);
  },
  'tomb': (c, t, g) {
    _p(
      c,
      Path()
        ..moveTo(4, 98)
        ..quadraticBezierTo(10, 26, 54, 24)
        ..quadraticBezierTo(96, 26, 96, 98)
        ..close(),
      const Color(0xFFA9A49A),
      3,
      0.15,
    );
    _p(c, Path()..addOval(Rect.fromLTWH(30, 50, 36, 48)), const Color(0xFF3A3530), 0, 0);
    if (g > 0) {
      c.drawCircle(
        const Offset(48, 76),
        20 * g,
        Paint()
          ..color = Color.fromRGBO(255, 246, 220, 0.8 * g)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    // La pierre roulée sur le côté (g = 1) ou devant l'entrée (g = 0).
    final x = 48 + 34 * g;
    _p(c, circle(Offset(x, 74), 24), const Color(0xFF8E897F), 3, 0.2);
  },
  'cross': (c, t, g) {
    _p(c, _rrect(44, 14, 56, 98, 2), const Color(0xFF7E4A2A), 2);
    _p(c, _rrect(22, 30, 78, 40, 2), const Color(0xFF7E4A2A), 2);
  },
  'ring': (c, t, g) {
    c.drawCircle(
      const Offset(50, 68),
      22,
      Paint()
        ..color = const Color(0xFFF2C14E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    _p(
      c,
      Path()
        ..moveTo(42, 46)
        ..lineTo(50, 34)
        ..lineTo(58, 46)
        ..lineTo(50, 52)
        ..close(),
      const Color(0xFF4FA8D8),
      1,
      0.4,
    );
  },
  'palm': (c, t, g) {
    c.save();
    c.translate(50, 96);
    c.rotate(-0.25 + math.sin(t * 3) * 0.08);
    c.drawLine(
      Offset.zero,
      const Offset(0, -80),
      Paint()
        ..color = const Color(0xFF5E8A3A)
        ..strokeWidth = 3,
    );
    for (var k = 0; k < 9; k++) {
      final y = -20.0 - k * 7;
      final len = 28 - k * 2.0;
      for (final side in [-1.0, 1.0]) {
        _p(
          c,
          Path()
            ..moveTo(0, y)
            ..quadraticBezierTo(side * len * 0.6, y - 10, side * len, y - 4)
            ..quadraticBezierTo(side * len * 0.5, y - 2, 0, y + 3)
            ..close(),
          const Color(0xFF6FA24C),
          0.5,
        );
      }
    }
    c.restore();
  },
  // Une cruche d'où sort une torche (Gédéon) ; [g] : la cruche est brisée.
  'torch': (c, t, g) {
    final flame = Path()
      ..moveTo(50, 48)
      ..cubicTo(30, 38, 38, 18, 50, 4 + math.sin(t * 7) * 3)
      ..cubicTo(62, 18, 70, 38, 50, 48)
      ..close();
    c.drawCircle(const Offset(50, 30), 26, Paint()..color = const Color(0x55FFD36B));
    _p(c, _rrect(45, 40, 55, 70, 3), const Color(0xFF8A5A36), 1);
    _p(c, flame, const Color(0xFFF29A45), 0, 0.3);
    _p(c, ellipse(const Offset(50, 36), 10, 18), const Color(0xFFFFE08A), 0, 0.2);
    if (g < 1) {
      _p(
        c,
        Path()
          ..moveTo(30, 58)
          ..lineTo(70, 58)
          ..quadraticBezierTo(86, 74, 74, 92)
          ..quadraticBezierTo(50, 102, 26, 92)
          ..quadraticBezierTo(14, 74, 30, 58)
          ..close(),
        const Color(0xFFC8744A),
        3,
      );
    } else {
      for (final (x, r) in [(28.0, 0.4), (72.0, -0.5)]) {
        c.save();
        c.translate(x, 90);
        c.rotate(r);
        _p(c, _rrect(-12, -6, 12, 6, 3), const Color(0xFFC8744A), 2);
        c.restore();
      }
    }
  },
  // La petite lampe à huile du temple (Samuel) ; [g] : flamme allumée.
  'lamp': (c, t, g) {
    final body = Path()
      ..moveTo(14, 70)
      ..quadraticBezierTo(40, 54, 72, 64)
      ..lineTo(90, 60)
      ..quadraticBezierTo(88, 70, 76, 76)
      ..quadraticBezierTo(44, 96, 14, 70)
      ..close();
    final flame = Path()
      ..moveTo(86, 58)
      ..cubicTo(76, 50, 82, 36, 86, 26 + math.sin(t * 6) * 2)
      ..cubicTo(92, 36, 96, 50, 86, 58)
      ..close();
    c.drawCircle(
      const Offset(86, 44),
      20 + 6 * g,
      Paint()..color = Color.fromRGBO(255, 211, 107, 0.25 + 0.3 * g),
    );
    _p(c, flame, const Color(0xFFF29A45), 0, 0.3);
    _p(c, body, const Color(0xFFC8744A), 3);
    c.drawCircle(const Offset(40, 66), 5, Paint()..color = const Color(0xFF8E4F2E));
  },
  'raven': (c, t, g) {
    final wing = math.sin(t * 8) * 6;
    _p(c, ellipse(const Offset(48, 62), 54, 30), const Color(0xFF2E2A33), 3, 0.1);
    _p(
      c,
      Path()
        ..moveTo(36, 56)
        ..quadraticBezierTo(50, 30 - wing, 74, 34 - wing)
        ..quadraticBezierTo(62, 52, 46, 64)
        ..close(),
      const Color(0xFF3F3A47),
      2,
      0.15,
    );
    _p(c, circle(const Offset(78, 52), 13), const Color(0xFF2E2A33), 2, 0.1);
    _p(
      c,
      Path()
        ..moveTo(88, 50)
        ..lineTo(100, 56)
        ..lineTo(88, 58)
        ..close(),
      const Color(0xFFE9B949),
      1,
    );
    c.drawCircle(const Offset(81, 49), 2.5, Paint()..color = const Color(0xFFFFFBF0));
    _p(
      c,
      Path()
        ..moveTo(22, 60)
        ..lineTo(4, 54)
        ..lineTo(8, 68)
        ..close(),
      const Color(0xFF2E2A33),
      1,
    );
    if (g > 0) _p(c, ellipse(const Offset(96, 64), 12, 8), const Color(0xFFE6C15A), 1);
  },
  // Un pan de muraille (Jéricho) ; [g] : elle s'écroule.
  'wall': (c, t, g) {
    const color = Color(0xFFE6CFA3);
    for (var row = 0; row < 4; row++) {
      for (var k = 0; k < 4; k++) {
        final x = 8.0 + k * 21 + (row.isOdd ? 10 : 0);
        if (x > 82) continue;
        final y = 76.0 - row * 18;
        final fall = g * (row + 1) * 6;
        c.save();
        c.translate(x + 10 + g * (k - 1.5) * 8, y + 8 + fall * (row / 3) * 3);
        c.rotate(g * (k.isEven ? 0.5 : -0.4) * (row / 3));
        _p(c, _rrect(-10, -8, 10, 8, 2), row.isEven ? color : const Color(0xFFD9BC88), 2);
        c.restore();
      }
    }
    if (g < 0.5) {
      for (var k = 0; k < 3; k++) {
        _p(c, _rrect(10.0 + k * 30, 14, 26.0 + k * 30, 24, 1), color, 1);
      }
    }
  },
  'scepter': (c, t, g) {
    c.drawCircle(
      const Offset(50, 20),
      18 + 8 * g,
      Paint()..color = Color.fromRGBO(255, 211, 107, 0.2 + 0.3 * g),
    );
    _p(c, _rrect(46, 26, 54, 96, 3), const Color(0xFFE9B949), 2, 0.25);
    _p(c, circle(const Offset(50, 20), 11), const Color(0xFFF2C14E), 2, 0.3);
    _p(c, circle(const Offset(50, 20), 5), const Color(0xFFB0413E), 1, 0.2);
  },
  'grapes': (c, t, g) {
    c.drawLine(
      const Offset(50, 22),
      const Offset(56, 8),
      Paint()
        ..color = const Color(0xFF6B4226)
        ..strokeWidth = 3,
    );
    _p(
      c,
      Path()
        ..moveTo(54, 18)
        ..quadraticBezierTo(74, 4, 86, 18)
        ..quadraticBezierTo(70, 26, 54, 18)
        ..close(),
      const Color(0xFF6FA24C),
      1,
    );
    for (final (x, y) in [
      (38.0, 32.0),
      (52.0, 30.0),
      (66.0, 32.0),
      (32.0, 46.0),
      (46.0, 46.0),
      (60.0, 46.0),
      (74.0, 46.0),
      (40.0, 60.0),
      (54.0, 60.0),
      (68.0, 60.0),
      (46.0, 74.0),
      (60.0, 74.0),
      (53.0, 88.0),
    ]) {
      _p(c, circle(Offset(x, y), 8), const Color(0xFF7A4E9C), 1.5, 0.25);
    }
  },
};

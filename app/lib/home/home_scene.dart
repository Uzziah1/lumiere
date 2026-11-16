import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../art/colombe.dart';
import '../art/landscape.dart';
import '../art/paper.dart';
import '../theme/palette.dart';

/// La scène animée de l'accueil : une aube sur les collines d'Orient,
/// des palmiers, un petit village, de la poussière dorée et Colombe qui vole.
///
/// Si l'appareil demande de réduire les animations, la scène reste immobile.
class HomeScene extends FlameGame {
  HomeScene({this.reducedMotion = false});

  final bool reducedMotion;

  late final ColombeComponent colombe;

  @override
  Color backgroundColor() => Palette.dawnHorizon;

  @override
  Future<void> onLoad() async {
    add(SkyComponent());
    add(SunComponent());
    for (final (i, speed) in const [(0, 9.0), (1, 6.0), (2, 12.0)]) {
      add(CloudComponent(index: i, speed: speed));
    }
    for (var depth = 0; depth < Palette.dawnHills.length; depth++) {
      add(HillLayer(depth: depth));
    }
    add(DustField());
    add(colombe = ColombeComponent());
    add(GrainOverlay());
  }

  @override
  void update(double dt) {
    // Réduire les animations = le temps de la scène s'arrête.
    super.update(reducedMotion ? 0 : dt);
  }
}

/// Le ciel : dégradé corail → pêche → crème jusqu'à l'horizon.
class SkyComponent extends Component with HasGameReference<HomeScene> {
  @override
  void render(Canvas canvas) {
    final size = game.size.toSize();
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          Offset(0, size.height * 0.72),
          const [Palette.dawnSkyTop, Palette.dawnSkyMid, Palette.dawnHorizon],
          const [0, 0.5, 1],
        ),
    );
  }
}

/// Le soleil qui se lève derrière les collines, avec son halo et ses rayons.
class SunComponent extends Component with HasGameReference<HomeScene> {
  double _time = 0;

  @override
  void update(double dt) => _time += dt;

  @override
  void render(Canvas canvas) {
    final size = game.size.toSize();
    final unit = math.min(size.width, size.height * 1.6);
    final center = Offset(size.width * 0.5, size.height * 0.60);

    // Rayons qui tournent très lentement.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_time * 0.04);
    final ray = Paint()..color = Palette.sun.withValues(alpha: 0.13);
    const rays = 14;
    final length = unit * 0.95;
    for (var i = 0; i < rays; i++) {
      final a = i * math.pi * 2 / rays;
      final spread = math.pi / rays * 0.45;
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..lineTo(math.cos(a - spread) * length, math.sin(a - spread) * length)
          ..lineTo(math.cos(a + spread) * length, math.sin(a + spread) * length)
          ..close(),
        ray,
      );
    }
    canvas.restore();

    final pulse = 1 + 0.03 * math.sin(_time * 1.2);
    final haloRadius = unit * 0.32 * pulse;
    canvas.drawCircle(
      center,
      haloRadius,
      Paint()
        ..shader = Gradient.radial(center, haloRadius, [
          Palette.sunHalo.withValues(alpha: 0.75),
          Palette.sunHalo.withValues(alpha: 0),
        ]),
    );
    final sun = Path()..addOval(Rect.fromCircle(center: center, radius: unit * 0.085));
    drawPaper(canvas, sun, Palette.sun, elevation: 0, light: 0);
  }
}

/// Un nuage de papier qui dérive et revient de l'autre côté.
class CloudComponent extends Component with HasGameReference<HomeScene> {
  CloudComponent({required this.index, required this.speed});

  final int index;
  final double speed;

  static const _starts = [0.12, 0.62, 0.86];
  static const _heights = [0.16, 0.10, 0.30];
  static const _widths = [0.15, 0.11, 0.09];

  double _x = 0;
  Path? _path;
  Size? _builtFor;

  double get x => _x;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_builtFor == null) _x = size.x * _starts[index];
  }

  @override
  void update(double dt) {
    final width = game.size.x;
    _x += speed * dt;
    final cloudWidth = width * _widths[index];
    if (_x - cloudWidth > width) _x = -cloudWidth;
  }

  @override
  void render(Canvas canvas) {
    final size = game.size.toSize();
    if (_builtFor != size) {
      final w = math.max(70.0, size.width * _widths[index]);
      _path = cloudPath(Offset.zero, w);
      _builtFor = size;
    }
    canvas.save();
    canvas.translate(_x, size.height * _heights[index]);
    drawPaper(canvas, _path!, Palette.cloud, elevation: 4, light: 0.3);
    canvas.restore();
  }
}

/// Un plan de collines, avec ses décors (palmiers, maisons), qui ondule
/// doucement : plus il est proche, plus il bouge (effet de profondeur).
class HillLayer extends Component with HasGameReference<HomeScene> {
  HillLayer({required this.depth});

  final int depth;

  static const _baselines = [0.60, 0.69, 0.80, 0.91];
  static const _amplitudes = [0.075, 0.055, 0.05, 0.035];
  static const _elevations = [3.0, 5.0, 7.0, 10.0];

  double _time = 0;
  Hill? hill;

  /// Décors posés sur la colline ; `flat` = ouverture sans ombre (porte, fenêtre).
  final _props = <(Path, Color, bool)>[];

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final s = size.toSize();
    if (s.isEmpty) return;
    final h = Hill(
      size: s,
      baseline: s.height * _baselines[depth],
      amplitude: s.height * _amplitudes[depth],
      seed: 11 + depth * 7,
      waves: 1.6 + depth * 0.45,
    );
    hill = h;
    _props
      ..clear()
      ..addAll(_buildProps(h, s));
  }

  List<(Path, Color, bool)> _buildProps(Hill h, Size s) {
    final color = Palette.dawnHills[depth];
    Offset on(double fx) => Offset(s.width * fx, h.heightAt(s.width * fx) + 4);
    switch (depth) {
      case 1:
        final tall = s.height * 0.17;
        return [
          (palmPath(on(0.13), tall, lean: 0.10), Color.lerp(color, Palette.ink, 0.12)!, false),
          (palmPath(on(0.17), tall * 0.72, lean: -0.08), Color.lerp(color, Palette.ink, 0.12)!, false),
          (palmPath(on(0.88), tall * 0.9, lean: -0.12), Color.lerp(color, Palette.ink, 0.12)!, false),
        ];
      case 2:
        final w = s.height * 0.075;
        final wall = Color.lerp(color, Palette.paper, 0.45)!;
        final hole = Color.lerp(color, Palette.ink, 0.35)!;
        final houses = <(Path, Color, bool)>[];
        for (final (fx, scale) in const [(0.70, 1.0), (0.745, 1.25), (0.79, 0.9)]) {
          final base = on(fx);
          houses
            ..add((housePath(base, w * scale, w * scale * 0.85), wall, false))
            ..add((houseOpenings(base, w * scale, w * scale * 0.85), hole, true));
        }
        return houses;
      default:
        return const [];
    }
  }

  @override
  void update(double dt) => _time += dt;

  @override
  void render(Canvas canvas) {
    final h = hill;
    if (h == null) return;
    final sway = math.sin(_time * 0.22 + depth * 1.3) * (2 + depth * 2.5);
    canvas.save();
    canvas.translate(sway, 0);
    for (final (path, color, flat) in _props) {
      drawPaper(canvas, path, color, elevation: flat ? 0 : _elevations[depth] * 0.6, light: flat ? 0 : 0.1);
    }
    drawPaper(canvas, h.path, Palette.dawnHills[depth], elevation: _elevations[depth], light: 0.1);
    canvas.restore();
  }
}

/// Poussière dorée qui monte lentement et scintille.
class DustField extends Component with HasGameReference<HomeScene> {
  DustField({this.count = 42, int seed = 3}) : _random = math.Random(seed);

  final int count;
  final math.Random _random;
  final _motes = <_Mote>[];

  int get moteCount => _motes.length;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_motes.isEmpty && !size.toSize().isEmpty) {
      for (var i = 0; i < count; i++) {
        _motes.add(
          _Mote(
            x: _random.nextDouble() * size.x,
            y: _random.nextDouble() * size.y,
            radius: 1.2 + _random.nextDouble() * 2.2,
            speed: 6 + _random.nextDouble() * 14,
            phase: _random.nextDouble() * math.pi * 2,
          ),
        );
      }
    }
  }

  @override
  void update(double dt) {
    final size = game.size;
    for (final m in _motes) {
      m.phase += dt;
      m.y -= m.speed * dt;
      m.x += math.sin(m.phase * 0.8) * 6 * dt;
      if (m.y < -10) {
        m.y = size.y + 10;
        m.x = _random.nextDouble() * size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final core = Paint();
    for (final m in _motes) {
      final twinkle = 0.45 + 0.55 * (0.5 + 0.5 * math.sin(m.phase * 2.2));
      glow.color = Palette.gold.withValues(alpha: 0.35 * twinkle);
      core.color = Palette.sun.withValues(alpha: 0.9 * twinkle);
      canvas.drawCircle(Offset(m.x, m.y), m.radius * 2.2, glow);
      canvas.drawCircle(Offset(m.x, m.y), m.radius * 0.7, core);
    }
  }
}

class _Mote {
  _Mote({required this.x, required this.y, required this.radius, required this.speed, required this.phase});

  double x;
  double y;
  final double radius;
  final double speed;
  double phase;
}

/// Colombe en vol stationnaire. Si on la touche, elle saute de joie
/// et lance des étincelles.
class ColombeComponent extends PositionComponent with HasGameReference<HomeScene>, TapCallbacks {
  ColombeComponent({int seed = 5}) : _random = math.Random(seed), super(anchor: Anchor.center);

  final math.Random _random;

  double _time = 0;
  double _flapPhase = 0;
  double _nextBlink = 2.5;
  double _blink = 0;
  double _joy = 0;
  int happyCount = 0;

  Vector2 _home = Vector2.zero();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final h = math.min(size.y * 0.24, size.x * 0.2);
    this.size = Vector2(h * Colombe.aspectRatio, h);
    _home = Vector2(size.x * 0.78, size.y * 0.30);
    position = _home.clone();
  }

  @override
  void update(double dt) {
    _time += dt;
    _joy = math.max(0, _joy - dt / 1.2);
    // Elle bat des ailes plus vite quand elle est contente.
    _flapPhase += dt * math.pi * 2 * (2.0 + 2.5 * _joy);

    _nextBlink -= dt;
    if (_nextBlink <= 0) {
      _blink += dt / 0.16;
      if (_blink >= 2) {
        _blink = 0;
        _nextBlink = 2.5 + _random.nextDouble() * 3;
      }
    }

    final g = game.size;
    final hop = math.sin(_joy * math.pi) * g.y * 0.05;
    position =
        _home + Vector2(math.sin(_time * 0.5) * g.x * 0.025, math.sin(_time * 1.6) * g.y * 0.018 - hop);
    angle = math.cos(_time * 1.6) * 0.06 - _joy * 0.12;
    scale = Vector2.all(1 + 0.12 * math.sin(_joy * math.pi));
  }

  @override
  void render(Canvas canvas) {
    Colombe.paint(
      canvas,
      size.toSize(),
      flap: 0.5 + 0.5 * math.sin(_flapPhase),
      blink: _blink <= 1 ? _blink : 2 - _blink,
      facingLeft: true,
      withBranch: true,
    );
  }

  @override
  void onTapDown(TapDownEvent event) => celebrate();

  /// Colombe saute de joie, bat des ailes plus vite et lance des étincelles.
  void celebrate() {
    happyCount++;
    _joy = 1;
    if (!game.reducedMotion) {
      game.add(SparkleBurst(origin: absoluteCenter.clone(), radius: size.y));
    }
  }
}

/// Une gerbe d'étoiles dorées qui s'éteint toute seule.
class SparkleBurst extends Component {
  SparkleBurst({required this.origin, required this.radius, int count = 12, int seed = 9}) {
    final random = math.Random(seed);
    for (var i = 0; i < count; i++) {
      final a = i * math.pi * 2 / count + random.nextDouble() * 0.4;
      final speed = radius * (1.4 + random.nextDouble() * 1.2);
      _sparks.add(_Spark(Vector2(math.cos(a), math.sin(a)) * speed, 0.6 + random.nextDouble() * 0.8));
    }
  }

  static const lifetime = 0.9;

  final Vector2 origin;
  final double radius;
  final _sparks = <_Spark>[];
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    for (final s in _sparks) {
      s.offset += s.velocity * dt;
      s.velocity *= math.pow(0.08, dt).toDouble();
    }
    if (_age >= lifetime) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / lifetime).clamp(0.0, 1.0);
    final paint = Paint()..color = Palette.gold.withValues(alpha: 1 - t);
    final light = Paint()..color = Palette.sun.withValues(alpha: 1 - t);
    for (final s in _sparks) {
      final c = Offset(origin.x + s.offset.x, origin.y + s.offset.y);
      final r = radius * 0.09 * s.size * (1 - t * 0.5);
      canvas.drawPath(_star(c, r), paint);
      canvas.drawCircle(c, r * 0.3, light);
    }
  }

  static Path _star(Offset c, double r) {
    final inner = r * 0.32;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + inner * 0.3, c.dy - inner * 0.3, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + inner * 0.3, c.dy + inner * 0.3, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - inner * 0.3, c.dy + inner * 0.3, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - inner * 0.3, c.dy - inner * 0.3, c.dx, c.dy - r)
      ..close();
  }
}

class _Spark {
  _Spark(this.velocity, this.size);

  Vector2 velocity;
  Vector2 offset = Vector2.zero();
  final double size;
}

/// Le grain de papier posé sur toute la scène.
class GrainOverlay extends Component with HasGameReference<HomeScene> {
  final _grain = PaperGrain();

  @override
  void render(Canvas canvas) => _grain.paint(canvas, game.size.toSize());

  @override
  void onRemove() {
    _grain.dispose();
    super.onRemove();
  }
}

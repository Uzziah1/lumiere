import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../art/landscape.dart';
import '../art/paper.dart';
import '../audio/audio.dart';
import '../theme/palette.dart';

typedef StageBuilder = StoryStage Function();

/// Le théâtre du récit : affiche un décor animé ([StoryStage]) à la fois.
class StoryGame extends FlameGame {
  StoryGame({required this.stages, this.reducedMotion = false, SoundEffects? sfx})
    : sfx = sfx ?? SilentSoundEffects();

  final Map<String, StageBuilder> stages;
  final bool reducedMotion;
  final SoundEffects sfx;

  /// Vrai quand l'enfant a fait l'action de la scène.
  final stageDone = ValueNotifier<bool>(false);

  StoryStage? stage;
  late final HintRing _hint = HintRing();
  final _grain = PaperGrain(opacity: 0.05);

  @override
  Color backgroundColor() => Palette.paper;

  @override
  Future<void> onLoad() async {
    add(_hint);
  }

  /// Remplace le décor par celui de [id].
  void showStage(String id) {
    final builder = stages[id];
    if (builder == null) throw ArgumentError('Décor inconnu : $id');
    stage?.removeFromParent();
    stageDone.value = false;
    _hint.target = null;
    final next = builder()..onDone = _onStageDone;
    stage = next;
    add(next);
  }

  void _onStageDone() {
    _hint.target = null;
    stageDone.value = true;
  }

  /// Montre (ou cache) l'anneau doré qui indique où toucher.
  set hintVisible(bool visible) {
    final s = stage;
    _hint.target = visible && s != null && !s.done ? s.hintTarget : null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _grain.paint(canvas, size.toSize());
  }

  @override
  void onRemove() {
    _grain.dispose();
    stageDone.dispose();
    super.onRemove();
  }
}

/// Un décor animé et interactif du récit.
///
/// Chaque décor dit où toucher ([hintTarget]) et appelle [complete] quand
/// l'enfant a fait l'action demandée. Le mouvement d'ambiance ([ambient]) s'arrête
/// si l'appareil demande de réduire les animations ; les transitions utiles,
/// elles, se terminent instantanément ([approach]).
abstract class StoryStage extends PositionComponent
    with HasGameReference<StoryGame>, TapCallbacks, DragCallbacks {
  StoryStage() : super(priority: 0);

  VoidCallback? onDone;
  bool _done = false;

  /// Temps d'ambiance (s'arrête avec « réduire les animations »).
  double ambient = 0;

  bool get done => _done;

  bool get reducedMotion => game.reducedMotion;

  /// Où l'enfant doit toucher, en coordonnées de l'écran.
  Vector2? get hintTarget;

  void complete() {
    if (_done) return;
    _done = true;
    game.sfx.play(Sfx.success);
    onDone?.call();
  }

  Size? _laidOut;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Flame rappelle onGameResize à chaque mise en page, même sans changement :
    // on ne recalcule (et ne remet à zéro) le décor que si la taille change.
    final s = size.toSize();
    if (s == _laidOut) return;
    _laidOut = s;
    this.size = size.clone();
    layout(s);
  }

  /// Recalcule les positions quand la taille de l'écran change.
  void layout(Size s) {}

  @override
  void update(double dt) {
    if (!reducedMotion) ambient += dt;
    tick(dt);
  }

  /// Animation propre au décor.
  void tick(double dt) {}

  /// Fait tendre [current] vers [target] à la vitesse [speed] par seconde
  /// (instantané avec « réduire les animations »).
  double approach(double current, double target, double dt, double speed) {
    if (reducedMotion) return target;
    final step = speed * dt;
    if ((target - current).abs() <= step) return target;
    return current + step * (target > current ? 1 : -1);
  }

  /// Ciel en dégradé vertical.
  void paintSky(Canvas canvas, List<Color> colors, {List<double>? stops}) {
    canvas.drawRect(
      Offset.zero & size.toSize(),
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          Offset(0, size.y),
          colors,
          stops ?? [for (var i = 0; i < colors.length; i++) i / (colors.length - 1)],
        ),
    );
  }

  /// Une rangée de collines en papier, qui ondule doucement.
  void paintHill(Canvas canvas, Hill hill, Color color, double depth) {
    canvas.save();
    canvas.translate(math.sin(ambient * 0.2 + depth) * (1 + depth * 1.5), 0);
    drawPaper(canvas, hill.path, color, elevation: 3 + depth * 2, light: 0.1);
    canvas.restore();
  }

  /// Vrai si [point] est dans le cercle ([center], [radius]).
  static bool hits(Vector2 point, Vector2 center, double radius) => point.distanceTo(center) <= radius;
}

/// Anneau doré qui pulse là où l'enfant doit toucher.
class HintRing extends Component with HasGameReference<StoryGame> {
  HintRing() : super(priority: 100);

  Vector2? target;
  double _time = 0;

  @override
  void update(double dt) => _time += dt;

  @override
  void render(Canvas canvas) {
    final t = target;
    if (t == null) return;
    final base = math.min(game.size.x, game.size.y) * 0.07;
    final pulse = game.reducedMotion ? 0.5 : (_time * 1.3) % 1;
    final center = Offset(t.x, t.y);
    canvas.drawCircle(
      center,
      base * (1 + pulse * 0.8),
      Paint()
        ..color = Palette.gold.withValues(alpha: 0.9 * (1 - pulse))
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.16,
    );
    canvas.drawCircle(
      center,
      base * 0.5,
      Paint()
        ..color = Palette.sun.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, base * 0.3),
    );
  }
}

/// Une gerbe d'étoiles dorées (réussite), qui s'efface seule.
class Sparkles extends Component {
  Sparkles({required this.origin, required this.radius, int count = 14, int seed = 2}) : super(priority: 50) {
    final random = math.Random(seed);
    for (var i = 0; i < count; i++) {
      final a = i * math.pi * 2 / count + random.nextDouble() * 0.5;
      _sparks.add((
        velocity: Vector2(math.cos(a), math.sin(a)) * radius * (1.5 + random.nextDouble()),
        size: 0.6 + random.nextDouble() * 0.8,
      ));
    }
  }

  static const lifetime = 1.0;

  final Vector2 origin;
  final double radius;
  final _sparks = <({Vector2 velocity, double size})>[];
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= lifetime) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / lifetime).clamp(0.0, 1.0);
    final travel = 1 - math.pow(1 - t, 3).toDouble();
    final paint = Paint()..color = Palette.gold.withValues(alpha: 1 - t);
    final core = Paint()..color = Palette.sun.withValues(alpha: 1 - t);
    for (final s in _sparks) {
      final c = Offset(origin.x + s.velocity.x * travel * 0.5, origin.y + s.velocity.y * travel * 0.5);
      final r = radius * 0.1 * s.size * (1 - t * 0.4);
      canvas.drawPath(star(c, r), paint);
      canvas.drawCircle(c, r * 0.3, core);
    }
  }

  static Path star(Offset c, double r) {
    final i = r * 0.1;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + i, c.dy - i, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + i, c.dy + i, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - i, c.dy + i, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - i, c.dy - i, c.dx, c.dy - r)
      ..close();
  }
}

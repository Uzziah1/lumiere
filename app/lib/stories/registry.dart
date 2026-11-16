import 'dart:math' as math;
import 'dart:ui';

import '../art/objects.dart';
import '../story/scripted_stage.dart';
import '../story/story_game.dart';
import '../theme/palette.dart';
import 'abraham/abraham.dart';
import 'creation/creation.dart';
import 'eden/eden.dart';
import 'joseph/joseph.dart';
import 'moise/moise.dart';
import 'noe/noe_art.dart';
import 'noe/noe_stages.dart';

/// Ce qu'une histoire apporte en code : ses décors animés, les vignettes de la
/// chronologie et la grande scène du cherche-et-trouve.
class StoryPack {
  const StoryPack({
    required this.stages,
    required this.paintThumb,
    required this.seekScene,
    required this.paintSticker,
    this.paintItem = paintThing,
  });

  /// Une histoire faite de scènes scénarisées ([StageScript]) : les vignettes
  /// de la chronologie et l'autocollant reprennent les scènes terminées.
  factory StoryPack.scripted({
    required Map<String, StageScript> scripts,
    required SeekScene seekScene,
    required String stickerScene,
  }) {
    void paintFinished(Canvas canvas, Size size, String id) {
      final script = scripts[id]!;
      script.paint(canvas, size, StageView.finished(script.viewTargets));
    }

    return StoryPack(
      stages: {for (final MapEntry(:key, :value) in scripts.entries) key: () => ScriptedStage(value)},
      paintThumb: paintFinished,
      seekScene: seekScene,
      paintSticker: (canvas, size) =>
          paintStickerFrame(canvas, size, (c, s) => paintFinished(c, s, stickerScene)),
    );
  }

  final Map<String, StageBuilder> stages;

  /// Dessine la vignette [id] de la chronologie dans [size].
  final void Function(Canvas canvas, Size size, String id) paintThumb;

  final SeekScene seekScene;

  /// Dessine l'autocollant gagné à la fin de l'histoire (dans un cercle).
  final void Function(Canvas canvas, Size size) paintSticker;

  /// Dessine un objet ou un animal des mini-jeux (memory, cache-cache).
  final void Function(Canvas canvas, String id, Rect box) paintItem;
}

/// Autocollant rond : bord blanc découpé, ombre, reflet ; [inner] dessine la scène.
void paintStickerFrame(Canvas canvas, Size s, void Function(Canvas canvas, Size size) inner) {
  final c = s.center(Offset.zero);
  final r = s.shortestSide / 2;
  canvas.drawCircle(
    c + Offset(0, r * 0.05),
    r * 0.98,
    Paint()
      ..color = Palette.shadow
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.06),
  );
  canvas.drawCircle(c, r * 0.98, Paint()..color = const Color(0xFFFFFFFF));
  canvas.save();
  canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.9)));
  // La scène est dessinée en 16:9, centrée dans le cercle.
  final h = r * 1.8;
  final w = h * 16 / 9;
  canvas.translate(c.dx - w / 2, c.dy - h / 2);
  inner(canvas, Size(w, h));
  canvas.restore();
  canvas.drawArc(
    Rect.fromCircle(center: c, radius: r * 0.82),
    math.pi * 1.1,
    math.pi * 0.35,
    false,
    Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round,
  );
}

/// Une scène de cache-cache faite de deux dessins (fond, premier plan).
class PaintedSeekScene implements SeekScene {
  const PaintedSeekScene({
    required this.spots,
    required this.background,
    required this.foreground,
    this.aspectRatio = 16 / 9,
  });

  @override
  final Map<String, (Offset, double)> spots;
  final void Function(Canvas canvas, Size size) background;
  final void Function(Canvas canvas, Size size) foreground;
  @override
  final double aspectRatio;

  @override
  void paintBackground(Canvas canvas, Size size) => background(canvas, size);

  @override
  void paintForeground(Canvas canvas, Size size) => foreground(canvas, size);

  @override
  void paintItem(Canvas canvas, String id, Rect box) => paintThing(canvas, id, box);
}

/// Une scène de cherche-et-trouve : décor dessiné en deux passes (fond, puis
/// premier plan qui cache à moitié les objets) et position des objets.
abstract class SeekScene {
  /// Rapport largeur / hauteur de la scène.
  double get aspectRatio;

  void paintBackground(Canvas canvas, Size size);

  void paintForeground(Canvas canvas, Size size);

  /// Centre (relatif, 0–1) et taille (relative à la hauteur) de chaque objet caché.
  Map<String, (Offset, double)> get spots;

  /// Dessine l'objet [id] dans [box].
  void paintItem(Canvas canvas, String id, Rect box);
}

final Map<String, StoryPack> storyPacks = {
  'creation': creationPack,
  'eden': edenPack,
  'abraham': abrahamPack,
  'joseph': josephPack,
  'moise': moisePack,
  'noe': StoryPack(
    stages: noeStages,
    paintThumb: paintNoeThumb,
    seekScene: ArkInterior(),
    paintSticker: paintNoeSticker,
  ),
};

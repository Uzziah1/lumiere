import 'dart:ui';

import '../story/story_game.dart';
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
  });

  final Map<String, StageBuilder> stages;

  /// Dessine la vignette [id] de la chronologie dans [size].
  final void Function(Canvas canvas, Size size, String id) paintThumb;

  final SeekScene seekScene;

  /// Dessine l'autocollant gagné à la fin de l'histoire (dans un cercle).
  final void Function(Canvas canvas, Size size) paintSticker;
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
  'noe': StoryPack(
    stages: noeStages,
    paintThumb: paintNoeThumb,
    seekScene: ArkInterior(),
    paintSticker: paintNoeSticker,
  ),
};

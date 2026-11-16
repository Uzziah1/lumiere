import 'dart:ui';

import '../save/save_data.dart';

/// Une île de la carte du monde : une histoire de la Bible.
class Island {
  const Island({
    required this.id,
    required this.title,
    required this.reference,
    required this.position,
    required this.landmark,
  });

  /// Identifiant de l'histoire (dossier `assets/stories/<id>/`).
  final String id;
  final String title;
  final String reference;

  /// Position relative sur la carte (0–1 en largeur et en hauteur).
  final Offset position;

  /// Le petit monument dessiné sur l'île (voir `landmarks.dart`).
  final Landmark landmark;
}

enum Landmark { creation, tree, ark, tent, pyramid, sea, harp, fish }

/// État d'une île pour un enfant.
enum IslandStatus {
  /// Jouable.
  open,

  /// L'histoire existe mais il faut des étoiles sur l'île d'avant.
  locked,

  /// L'histoire n'est pas encore construite.
  soon,
}

/// Le premier lot d'histoires, dans l'ordre du voyage (GDD § 9).
const lot1 = [
  Island(
    id: 'creation',
    title: 'La Création',
    reference: 'Genèse 1 à 2',
    position: Offset(0.07, 0.56),
    landmark: Landmark.creation,
  ),
  Island(
    id: 'eden',
    title: 'Adam et Ève',
    reference: 'Genèse 2 à 3',
    position: Offset(0.19, 0.30),
    landmark: Landmark.tree,
  ),
  Island(
    id: 'noe',
    title: 'Noé et l’arche',
    reference: 'Genèse 6 à 9',
    position: Offset(0.31, 0.60),
    landmark: Landmark.ark,
  ),
  Island(
    id: 'abraham',
    title: 'Abraham et les étoiles',
    reference: 'Genèse 12, 15 et 21',
    position: Offset(0.43, 0.30),
    landmark: Landmark.tent,
  ),
  Island(
    id: 'joseph',
    title: 'Joseph et ses frères',
    reference: 'Genèse 37 à 45',
    position: Offset(0.55, 0.62),
    landmark: Landmark.pyramid,
  ),
  Island(
    id: 'moise',
    title: 'Moïse et la mer',
    reference: 'Exode 2 à 14',
    position: Offset(0.67, 0.31),
    landmark: Landmark.sea,
  ),
  Island(
    id: 'david',
    title: 'David et Goliath',
    reference: '1 Samuel 17',
    position: Offset(0.79, 0.60),
    landmark: Landmark.harp,
  ),
  Island(
    id: 'jonas',
    title: 'Jonas et le grand poisson',
    reference: 'Jonas 1 à 4',
    position: Offset(0.91, 0.33),
    landmark: Landmark.fish,
  ),
];

/// Règles d'ouverture des îles.
///
/// Une île est ouverte si son histoire existe et si l'histoire existante qui la
/// précède a rapporté au moins [starsToUnlock] étoiles (sur 5) : assez souple
/// pour qu'aucun enfant ne reste bloqué. La première histoire existante est
/// toujours ouverte.
class World {
  const World({required this.islands, required this.available});

  final List<Island> islands;

  /// Histoires effectivement présentes dans le jeu.
  final Set<String> available;

  static const starsToUnlock = 3;

  IslandStatus status(Island island, StoryProgress Function(String storyId) progress) {
    if (!available.contains(island.id)) return IslandStatus.soon;
    final index = islands.indexOf(island);
    for (var i = index - 1; i >= 0; i--) {
      final previous = islands[i];
      if (!available.contains(previous.id)) continue;
      return progress(previous.id).stars >= starsToUnlock ? IslandStatus.open : IslandStatus.locked;
    }
    return IslandStatus.open;
  }

  /// L'île où se trouve l'enfant : la première ouverte sans autocollant, sinon la
  /// dernière ouverte.
  Island currentIsland(StoryProgress Function(String storyId) progress) {
    Island? lastOpen;
    for (final island in islands) {
      if (status(island, progress) != IslandStatus.open) continue;
      if (!progress(island.id).sticker) return island;
      lastOpen = island;
    }
    return lastOpen ?? islands.firstWhere((i) => available.contains(i.id), orElse: () => islands.first);
  }
}

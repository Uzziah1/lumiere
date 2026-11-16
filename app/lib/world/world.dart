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
    required this.treasure,
    this.lot = 1,
  });

  /// La même île, placée à l'abscisse relative [dx] (carte complète).
  Island at(double dx) => Island(
    id: id,
    title: title,
    reference: reference,
    position: Offset(dx, position.dy),
    landmark: landmark,
    treasure: treasure,
    lot: lot,
  );

  /// Identifiant de l'histoire (dossier `assets/stories/<id>/`).
  final String id;
  final String title;
  final String reference;

  /// Position relative sur la carte (0–1 en largeur et en hauteur).
  final Offset position;

  /// Le petit monument dessiné sur l'île (voir `landmarks.dart`).
  final Landmark landmark;

  /// L'animal (ou l'objet) qui rejoint l'arche-trésor quand l'histoire est
  /// terminée (identifiant de `paintThing`) : l'arche pour l'Ancien
  /// Testament, le jardin pour le Nouveau.
  final String treasure;

  /// 1 : Ancien Testament ; 2 : Nouveau Testament.
  final int lot;
}

enum Landmark {
  creation,
  tree,
  ark,
  tent,
  pyramid,
  sea,
  harp,
  fish,
  stable,
  temple,
  dove,
  storm,
  loaves,
  sycamore,
  donkey,
  homecoming,
  tomb,
  flames,
}

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
    treasure: 'giraffe',
  ),
  Island(
    id: 'eden',
    title: 'Adam et Ève',
    reference: 'Genèse 2 à 3',
    position: Offset(0.19, 0.30),
    landmark: Landmark.tree,
    treasure: 'rabbit',
  ),
  Island(
    id: 'noe',
    title: 'Noé et l’arche',
    reference: 'Genèse 6 à 9',
    position: Offset(0.31, 0.60),
    landmark: Landmark.ark,
    treasure: 'dove',
  ),
  Island(
    id: 'abraham',
    title: 'Abraham et les étoiles',
    reference: 'Genèse 12, 15 et 21',
    position: Offset(0.43, 0.30),
    landmark: Landmark.tent,
    treasure: 'sheep',
  ),
  Island(
    id: 'joseph',
    title: 'Joseph et ses frères',
    reference: 'Genèse 37 à 45',
    position: Offset(0.55, 0.62),
    landmark: Landmark.pyramid,
    treasure: 'camel',
  ),
  Island(
    id: 'moise',
    title: 'Moïse et la mer',
    reference: 'Exode 2 à 14',
    position: Offset(0.67, 0.31),
    landmark: Landmark.sea,
    treasure: 'frog',
  ),
  Island(
    id: 'david',
    title: 'David et Goliath',
    reference: '1 Samuel 17',
    position: Offset(0.79, 0.60),
    landmark: Landmark.harp,
    treasure: 'lion',
  ),
  Island(
    id: 'jonas',
    title: 'Jonas et le grand poisson',
    reference: 'Jonas 1 à 4',
    position: Offset(0.91, 0.33),
    landmark: Landmark.fish,
    treasure: 'fish',
  ),
];

/// Le deuxième lot : le Nouveau Testament (GDD § 9).
const lot2 = [
  Island(
    id: 'naissance',
    title: 'La naissance de Jésus',
    reference: 'Luc 1 et 2 ; Matthieu 2',
    position: Offset(0, 0.58),
    landmark: Landmark.stable,
    treasure: 'star',
    lot: 2,
  ),
  Island(
    id: 'temple',
    title: 'Jésus enfant au temple',
    reference: 'Luc 2.41-52',
    position: Offset(0, 0.30),
    landmark: Landmark.temple,
    treasure: 'scroll',
    lot: 2,
  ),
  Island(
    id: 'bapteme',
    title: 'Le baptême de Jésus',
    reference: 'Matthieu 3 et 4',
    position: Offset(0, 0.60),
    landmark: Landmark.dove,
    treasure: 'bird',
    lot: 2,
  ),
  Island(
    id: 'tempete',
    title: 'Jésus calme la tempête',
    reference: 'Marc 4.35-41',
    position: Offset(0, 0.32),
    landmark: Landmark.storm,
    treasure: 'boat',
    lot: 2,
  ),
  Island(
    id: 'pains',
    title: 'Les pains et les poissons',
    reference: 'Jean 6.1-14',
    position: Offset(0, 0.62),
    landmark: Landmark.loaves,
    treasure: 'bread',
    lot: 2,
  ),
  Island(
    id: 'zachee',
    title: 'Zachée',
    reference: 'Luc 19.1-10',
    position: Offset(0, 0.30),
    landmark: Landmark.sycamore,
    treasure: 'tree',
    lot: 2,
  ),
  Island(
    id: 'samaritain',
    title: 'Le bon Samaritain',
    reference: 'Luc 10.25-37',
    position: Offset(0, 0.60),
    landmark: Landmark.donkey,
    treasure: 'donkey',
    lot: 2,
  ),
  Island(
    id: 'prodigue',
    title: 'Le fils prodigue',
    reference: 'Luc 15.11-32',
    position: Offset(0, 0.32),
    landmark: Landmark.homecoming,
    treasure: 'pig',
    lot: 2,
  ),
  Island(
    id: 'paques',
    title: 'Pâques : Jésus est vivant',
    reference: 'Luc 19 à 24',
    position: Offset(0, 0.60),
    landmark: Landmark.tomb,
    treasure: 'flower',
    lot: 2,
  ),
  Island(
    id: 'pentecote',
    title: 'La Pentecôte',
    reference: 'Actes 1 et 2',
    position: Offset(0, 0.34),
    landmark: Landmark.flames,
    treasure: 'flame',
    lot: 2,
  ),
];

/// Toutes les îles de la carte, dans l'ordre du voyage, réparties sur la largeur.
final allIslands = [
  for (final (i, island) in [...lot1, ...lot2].indexed) island.at((i + 0.5) / (lot1.length + lot2.length)),
];

/// Règles d'ouverture des îles.
///
/// Une île est ouverte si son histoire existe et si l'histoire existante qui la
/// précède, dans le même lot (Ancien ou Nouveau Testament), a rapporté au moins
/// [starsToUnlock] étoiles (sur 5) : assez souple pour qu'aucun enfant ne reste
/// bloqué. La première histoire existante de chaque lot est toujours ouverte.
class World {
  const World({required this.islands, required this.available});

  final List<Island> islands;

  /// Histoires effectivement présentes dans le jeu. Une île déjà commencée
  /// reste toujours ouverte.
  final Set<String> available;

  static const starsToUnlock = 3;

  IslandStatus status(Island island, StoryProgress Function(String storyId) progress) {
    if (!available.contains(island.id)) return IslandStatus.soon;
    // Une île déjà commencée reste ouverte (même si l'ordre des histoires change).
    if (progress(island.id).stars > 0) return IslandStatus.open;
    final index = islands.indexOf(island);
    for (var i = index - 1; i >= 0; i--) {
      final previous = islands[i];
      if (previous.lot != island.lot) break;
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

/// L'île d'une histoire, s'il y en a une.
Island? islandFor(String storyId) {
  for (final island in allIslands) {
    if (island.id == storyId) return island;
  }
  return null;
}

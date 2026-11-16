/// Les étapes d'une histoire qui rapportent une étoile.
enum StoryPart {
  recit,
  chronology,
  seek,
  memory,
  verse,
  puzzle,
  quiz;

  /// Les mini-jeux qu'une histoire peut proposer (trois par histoire, voir
  /// `Story.lineup`).
  static const games = [chronology, seek, memory, puzzle, quiz];

  static StoryPart? byName(String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

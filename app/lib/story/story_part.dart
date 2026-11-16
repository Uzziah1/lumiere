/// Les étapes d'une histoire qui rapportent une étoile.
enum StoryPart {
  recit,
  chronology,
  seek,
  memory,
  verse;

  static StoryPart? byName(String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

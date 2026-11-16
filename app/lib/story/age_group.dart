/// Les trois âges du jeu (voir le GDD, § 3).
enum AgeGroup {
  agneaux(label: 'Agneaux', ages: '4 à 6 ans'),
  bergers(label: 'Bergers', ages: '7 à 9 ans'),
  explorateurs(label: 'Explorateurs', ages: '10 à 12 ans');

  const AgeGroup({required this.label, required this.ages});

  final String label;
  final String ages;

  /// Les Agneaux ne lisent pas encore : pas de sous-titres, tout est narré.
  bool get showsSubtitles => this != agneaux;

  static AgeGroup? byName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

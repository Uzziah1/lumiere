import 'age_group.dart';

/// Une phrase dite par la narratrice, qui peut changer selon l'âge.
///
/// Dans les données : soit une chaîne (même texte pour tous), soit un objet
/// `{"all": …, "agneaux": …, "bergers": …, "explorateurs": …}` où chaque âge
/// absent reprend `all`.
class NarratedText {
  const NarratedText(this.variants);

  factory NarratedText.fromJson(Object? json) {
    if (json is String) return NarratedText({'all': json});
    if (json is Map) {
      final variants = <String, String>{};
      for (final entry in json.entries) {
        final key = entry.key as String;
        if (key != 'all' && AgeGroup.byName(key) == null) {
          throw FormatException('Âge inconnu « $key » dans un texte narré.');
        }
        variants[key] = entry.value as String;
      }
      return NarratedText(variants);
    }
    throw const FormatException('Texte narré attendu (chaîne ou objet par âge).');
  }

  /// Clés : `all` ou le nom d'un âge.
  final Map<String, String> variants;

  /// Le nom de la variante utilisée pour [age] (`all` ou le nom de l'âge).
  String variantFor(AgeGroup age) {
    if (variants.containsKey(age.name)) return age.name;
    if (variants.containsKey('all')) return 'all';
    throw StateError('Aucun texte pour ${age.name}.');
  }

  String textFor(AgeGroup age) => variants[variantFor(age)]!;

  /// Toutes les variantes réellement présentes (pour générer la narration).
  Iterable<MapEntry<String, String>> get entries => variants.entries;
}

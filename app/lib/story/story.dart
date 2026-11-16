import 'dart:convert';

import 'age_group.dart';
import 'narrated_text.dart';

/// Une histoire de la Bible, décrite entièrement par des données
/// (`assets/stories/<id>/story.json`) : ajouter une histoire = ajouter un dossier.
class Story {
  Story({
    required this.id,
    required this.title,
    required this.reference,
    required this.intro,
    required this.scenes,
    required this.chronology,
    required this.seek,
    required this.memory,
    required this.verse,
    required this.sticker,
    required this.lines,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final lines = <String, NarratedText>{};
    NarratedText line(String key, Object? value) {
      final text = NarratedText.fromJson(value);
      lines[key] = text;
      return text;
    }

    final scenes = <StoryScene>[];
    for (final raw in (json['scenes'] as List).cast<Map<String, dynamic>>()) {
      final sceneId = raw['id'] as String;
      scenes.add(
        StoryScene(
          id: sceneId,
          stage: raw['stage'] as String,
          reference: raw['reference'] as String,
          text: line('scene.$sceneId', raw['text']),
          action: line('scene.$sceneId.action', raw['action']),
          after: raw['after'] == null ? null : line('scene.$sceneId.after', raw['after']),
        ),
      );
    }

    final games = json['games'] as Map<String, dynamic>;
    final chronology = games['chronology'] as Map<String, dynamic>;
    final seek = games['seek'] as Map<String, dynamic>;
    final memory = games['memory'] as Map<String, dynamic>;
    final verse = json['verse'] as Map<String, dynamic>;
    final sticker = json['sticker'] as Map<String, dynamic>;

    final story = Story(
      id: id,
      title: json['title'] as String,
      reference: json['reference'] as String,
      intro: line('intro', json['intro']),
      scenes: scenes,
      chronology: ChronologyConfig(
        cards: [
          for (final c in (chronology['cards'] as List).cast<Map<String, dynamic>>())
            ChronologyCard(id: c['id'] as String, label: c['label'] as String),
        ],
        counts: _counts(chronology['counts']),
        instructions: line('game.chronology', chronology['instructions']),
      ),
      seek: SeekConfig(
        items: [
          for (final i in (seek['items'] as List).cast<Map<String, dynamic>>())
            SeekItem(id: i['id'] as String, label: i['label'] as String),
        ],
        counts: _counts(seek['counts']),
        instructions: line('game.seek', seek['instructions']),
      ),
      memory: MemoryConfig(
        pairs: (memory['pairs'] as List).cast<String>(),
        counts: _counts(memory['counts']),
        instructions: line('game.memory', memory['instructions']),
      ),
      verse: Verse(
        text: verse['text'] as String,
        reference: verse['reference'] as String,
        chunks: {
          for (final e in (verse['chunks'] as Map<String, dynamic>).entries)
            AgeGroup.byName(e.key)!: (e.value as List).cast<String>(),
        },
        referenceChoices: (verse['referenceChoices'] as List).cast<String>(),
        reading: line('verse.reading', verse['spoken']),
        instructions: line('game.verse', verse['instructions']),
      ),
      sticker: Sticker(id: sticker['id'] as String, title: sticker['title'] as String),
      lines: lines,
    );
    line('reward', json['reward']);
    return story;
  }

  static Story parse(String source) => Story.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static Map<AgeGroup, int> _counts(Object? json) => {
    for (final e in (json as Map<String, dynamic>).entries) AgeGroup.byName(e.key)!: e.value as int,
  };

  final String id;
  final String title;

  /// Référence biblique affichée, ex. « Genèse 6 à 9 ».
  final String reference;
  final NarratedText intro;
  final List<StoryScene> scenes;
  final ChronologyConfig chronology;
  final SeekConfig seek;
  final MemoryConfig memory;
  final Verse verse;
  final Sticker sticker;

  /// Toutes les phrases narrées de l'histoire, par clé (`scene.village`, `game.seek`…).
  final Map<String, NarratedText> lines;

  /// Nombre d'étoiles à gagner : le récit, les trois jeux et le verset.
  static const maxStars = 5;

  /// Chemin (dans les assets) du fichier audio d'une phrase pour un âge.
  String audioPath(String key, AgeGroup age) => storyAudioPath(id, key, lines[key]!.variantFor(age));
}

/// Chemin du fichier audio d'une phrase d'histoire (utilisé aussi par le
/// script de génération de la narration).
String storyAudioPath(String storyId, String key, String variant) =>
    'stories/$storyId/audio/$key.$variant.mp3';

class StoryScene {
  StoryScene({
    required this.id,
    required this.stage,
    required this.reference,
    required this.text,
    required this.action,
    this.after,
  });

  final String id;

  /// Le décor animé à afficher (voir `lib/stories/`).
  final String stage;

  /// Référence biblique de la scène, ex. « Genèse 7.16 ».
  final String reference;

  /// Ce que raconte la narratrice.
  final NarratedText text;

  /// Ce que l'enfant doit faire pour continuer.
  final NarratedText action;

  /// Raconté une fois l'action faite (facultatif).
  final NarratedText? after;
}

class ChronologyCard {
  const ChronologyCard({required this.id, required this.label});

  final String id;
  final String label;
}

class ChronologyConfig {
  const ChronologyConfig({required this.cards, required this.counts, required this.instructions});

  /// Toutes les images, dans l'ordre de l'histoire.
  final List<ChronologyCard> cards;
  final Map<AgeGroup, int> counts;
  final NarratedText instructions;

  /// Les images à remettre en ordre pour [age], réparties sur toute l'histoire
  /// (toujours la première et la dernière).
  List<ChronologyCard> cardsFor(AgeGroup age) {
    final n = counts[age]!.clamp(2, cards.length);
    if (n == cards.length) return cards;
    return [for (var i = 0; i < n; i++) cards[(i * (cards.length - 1) / (n - 1)).round()]];
  }
}

class SeekItem {
  const SeekItem({required this.id, required this.label});

  final String id;
  final String label;
}

class SeekConfig {
  const SeekConfig({required this.items, required this.counts, required this.instructions});

  final List<SeekItem> items;
  final Map<AgeGroup, int> counts;
  final NarratedText instructions;

  List<SeekItem> itemsFor(AgeGroup age) => items.take(counts[age]!).toList();
}

class MemoryConfig {
  const MemoryConfig({required this.pairs, required this.counts, required this.instructions});

  final List<String> pairs;
  final Map<AgeGroup, int> counts;
  final NarratedText instructions;

  List<String> pairsFor(AgeGroup age) => pairs.take(counts[age]!).toList();
}

class Verse {
  const Verse({
    required this.text,
    required this.reference,
    required this.chunks,
    required this.referenceChoices,
    required this.reading,
    required this.instructions,
  });

  /// Texte exact, Louis Segond 1910.
  final String text;
  final String reference;

  /// Morceaux à remettre en ordre, par âge (absent pour les Agneaux).
  final Map<AgeGroup, List<String>> chunks;

  /// Références proposées aux Explorateurs (la bonne en premier dans les données).
  final List<String> referenceChoices;
  final NarratedText reading;
  final NarratedText instructions;
}

class Sticker {
  const Sticker({required this.id, required this.title});

  final String id;
  final String title;
}

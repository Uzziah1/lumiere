import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/art/objects.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/stories/registry.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/story/narrated_text.dart';
import 'package:lumiere/story/story.dart';
import 'package:lumiere/story/story_part.dart';

import '../helpers.dart';

/// Vérifie les données de chaque histoire : rien ne doit manquer au moment de jouer.
void main() {
  for (final id in storyPacks.keys) {
    group('Histoire « $id »', () {
      final story = loadStory(id);
      final pack = storyPacks[id]!;

      test('a un titre, une référence et des scènes avec un décor existant', () {
        expect(story.title, isNotEmpty);
        expect(story.reference, isNotEmpty);
        expect(story.scenes, isNotEmpty);
        for (final scene in story.scenes) {
          expect(pack.stages, contains(scene.stage), reason: 'décor manquant pour ${scene.id}');
          expect(scene.reference, matches(RegExp(r'^[A-ZÉ1-3].* \d+\.\d+')));
        }
      });

      test('chaque phrase existe pour les trois âges, avec son fichier audio', () {
        for (final MapEntry(:key, :value) in story.lines.entries) {
          for (final age in AgeGroup.values) {
            expect(value.textFor(age), isNotEmpty, reason: '$key / ${age.name}');
            final path = story.audioPath(key, age);
            expect(File('assets/$path').existsSync(), isTrue, reason: 'audio manquant : $path');
          }
        }
      });

      test('les morceaux du verset reforment exactement le verset', () {
        for (final MapEntry(key: age, value: chunks) in story.verse.chunks.entries) {
          expect(chunks.join(' '), story.verse.text, reason: age.name);
        }
        expect(story.verse.chunks.keys, containsAll([AgeGroup.bergers, AgeGroup.explorateurs]));
        expect(story.verse.referenceChoices.first, story.verse.reference);
        expect(story.verse.referenceChoices.toSet(), hasLength(story.verse.referenceChoices.length));
      });

      test('les jeux ont assez de contenu pour chaque âge, et chaque objet a sa place', () {
        for (final age in AgeGroup.values) {
          expect(story.chronology.cardsFor(age).length, story.chronology.counts[age]);
          expect(story.seek.itemsFor(age).length, story.seek.counts[age]);
          expect(story.memory.pairsFor(age).length, story.memory.counts[age]);
        }
        for (final item in story.seek.items) {
          expect(pack.seekScene.spots, contains(item.id));
        }
      });

      test('trois jeux différents, et un quiz complet s’il est proposé', () {
        expect(story.lineup, hasLength(3));
        expect(story.lineup.toSet(), hasLength(3));
        expect(story.lineup, everyElement(isIn(StoryPart.games)));
        final quiz = story.quiz;
        expect(quiz != null, story.lineup.contains(StoryPart.quiz));
        if (quiz == null) return;
        for (final age in AgeGroup.values) {
          expect(quiz.questionsFor(age).length, quiz.counts[age]);
          expect(quiz.counts[age], greaterThanOrEqualTo(2));
        }
        for (final q in quiz.questions) {
          expect(q.choices, hasLength(3), reason: q.key);
          expect(q.choices.toSet(), hasLength(3), reason: q.key);
          for (final id in q.choices) {
            expect(isThing(id), isTrue, reason: '${q.key} : $id');
          }
          expect(
            q.text.textFor(AgeGroup.agneaux),
            anyOf(endsWith('?'), endsWith('…'), endsWith('»')),
            reason: q.key,
          );
        }
      });

      test('la chronologie garde toujours la première et la dernière image, dans l’ordre', () {
        final all = story.chronology.cards;
        for (final age in AgeGroup.values) {
          final cards = story.chronology.cardsFor(age);
          expect(cards.first, all.first);
          expect(cards.last, all.last);
          final positions = cards.map(all.indexOf).toList();
          expect(positions, orderedEquals([...positions]..sort()));
        }
      });
    });
  }

  test('les phrases communes et les bruitages ont leurs fichiers audio', () {
    final common = loadCommon();
    for (final key in common.lines.keys) {
      for (final age in AgeGroup.values) {
        expect(File('assets/${common.audioPath(key, age)}').existsSync(), isTrue, reason: key);
      }
    }
    for (final effect in Sfx.values) {
      expect(File('assets/audio/sfx/${effect.name}.mp3').existsSync(), isTrue, reason: effect.name);
    }
  });

  group('NarratedText', () {
    test('une chaîne vaut pour tous les âges', () {
      final t = NarratedText.fromJson('Bonjour');
      expect(t.textFor(AgeGroup.agneaux), 'Bonjour');
      expect(t.variantFor(AgeGroup.explorateurs), 'all');
    });

    test('un âge absent reprend « all »', () {
      final t = NarratedText.fromJson({'all': 'A', 'agneaux': 'B'});
      expect(t.textFor(AgeGroup.agneaux), 'B');
      expect(t.textFor(AgeGroup.bergers), 'A');
    });

    test('un âge inconnu est refusé', () {
      expect(() => NarratedText.fromJson({'bebes': 'A'}), throwsFormatException);
    });
  });

  test('les Agneaux n’ont pas de sous-titres', () {
    expect(AgeGroup.agneaux.showsSubtitles, isFalse);
    expect(AgeGroup.bergers.showsSubtitles, isTrue);
    expect(Story.maxStars, 5);
  });
}

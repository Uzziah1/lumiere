import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/games/chronology_game.dart';
import 'package:lumiere/games/memory_game.dart';
import 'package:lumiere/games/puzzle_game.dart';
import 'package:lumiere/games/quiz_game.dart';
import 'package:lumiere/games/seek_game.dart';
import 'package:lumiere/games/verse_game.dart';
import 'package:lumiere/stories/registry.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

void main() {
  Future<void> big(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('Chronologie', () {
    testWidgets('les bonnes images, dans l’ordre, terminent le jeu ; une erreur ne place rien', (
      tester,
    ) async {
      await big(tester);
      var done = 0;
      final said = <String>[];
      final sfx = SilentSoundEffects();
      await tester.pumpWidget(
        inSession(
          ChronologyGame(complete: () => done++, say: said.add, seed: 1),
          sfx: sfx,
        ),
      );
      final story = loadStory('noe');
      final cards = story.chronology.cardsFor(AgeGroup.bergers);

      // Une mauvaise image d'abord : elle tremble, Colombe aide.
      await tester.tap(find.byKey(ValueKey('chrono-${cards.last.id}')));
      await tester.pump(const Duration(milliseconds: 500));
      final state = tester.state<ChronologyGameState>(find.byType(ChronologyGame));
      expect(state.placed, isEmpty);
      expect(said, contains('before'));
      expect(sfx.played, contains(Sfx.wrong));

      for (final card in cards) {
        await tester.tap(find.byKey(ValueKey('chrono-${card.id}')));
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(state.placed.map((c) => c.id), cards.map((c) => c.id));
      expect(done, 1);
    });

    testWidgets('les Agneaux ont 3 images, les Explorateurs 5', (tester) async {
      await big(tester);
      await tester.pumpWidget(
        inSession(
          ChronologyGame(complete: () {}, say: (_) {}, seed: 2),
          age: AgeGroup.agneaux,
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w.key is ValueKey && '${(w.key as ValueKey).value}'.startsWith('chrono-'),
        ),
        findsNWidgets(3),
      );
      await tester.pumpWidget(
        inSession(
          ChronologyGame(complete: () {}, say: (_) {}, seed: 2),
          age: AgeGroup.explorateurs,
        ),
      );
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (w) => w.key is ValueKey && '${(w.key as ValueKey).value}'.startsWith('chrono-'),
        ),
        findsNWidgets(5),
      );
    });
  });

  group('Cherche et trouve', () {
    testWidgets('toucher chaque animal caché termine le jeu', (tester) async {
      await big(tester);
      var done = 0;
      await tester.pumpWidget(
        inSession(
          SeekGame(complete: () => done++, say: (_) {}),
          age: AgeGroup.agneaux,
        ),
      );
      await tester.pump();
      final state = tester.state<SeekGameState>(find.byType(SeekGame));
      final scene = storyPacks['noe']!.seekScene;
      final box = tester.getRect(find.byKey(const ValueKey('seek-scene')));

      // Toucher à côté ne trouve rien.
      await tester.tapAt(box.topLeft + const Offset(4, 4));
      await tester.pump();
      expect(state.found, isEmpty);

      for (final item in state.items) {
        final (c, _) = scene.spots[item.id]!;
        await tester.tapAt(Offset(box.left + c.dx * box.width, box.top + c.dy * box.height));
        await tester.pump();
      }
      expect(state.found, hasLength(state.items.length));
      expect(done, 1);
    });

    testWidgets('après 15 secondes sans trouver, Colombe montre un animal', (tester) async {
      await big(tester);
      final said = <String>[];
      await tester.pumpWidget(inSession(SeekGame(complete: () {}, say: said.add)));
      await tester.pump(const Duration(seconds: 16));
      expect(said, contains('look'));
    });

    test('les cachettes ne se chevauchent pas trop', () {
      final spots = storyPacks['noe']!.seekScene.spots.values.toList();
      for (var i = 0; i < spots.length; i++) {
        for (var j = i + 1; j < spots.length; j++) {
          final d = (spots[i].$1 - spots[j].$1).distance;
          expect(d, greaterThan(0.08));
        }
      }
    });
  });

  group('Memory', () {
    testWidgets('retrouver toutes les paires termine le jeu', (tester) async {
      await big(tester);
      var done = 0;
      await tester.pumpWidget(
        inSession(
          MemoryGame(complete: () => done++, say: (_) {}, seed: 3),
          age: AgeGroup.explorateurs,
        ),
      );
      await tester.pump();
      final state = tester.state<MemoryGameState>(find.byType(MemoryGame));
      expect(state.cards, hasLength(12));
      expect(state.preview, isFalse);

      // Deux cartes différentes se retournent puis se recachent.
      final first = 0;
      final other = state.cards.indexWhere((a) => a != state.cards[first]);
      await tester.tap(find.byKey(const ValueKey('memory-0')));
      await tester.tap(find.byKey(ValueKey('memory-$other')));
      await tester.pump(const Duration(milliseconds: 1100));
      expect(state.revealed, isEmpty);
      expect(state.matched, isEmpty);

      final pending = List.generate(state.cards.length, (i) => i);
      while (pending.isNotEmpty) {
        final a = pending.removeAt(0);
        final b = pending.firstWhere((i) => state.cards[i] == state.cards[a]);
        pending.remove(b);
        await tester.tap(find.byKey(ValueKey('memory-$a')));
        await tester.tap(find.byKey(ValueKey('memory-$b')));
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(state.matched, hasLength(12));
      expect(done, 1);
    });

    testWidgets('les Agneaux voient d’abord toutes les cartes', (tester) async {
      await big(tester);
      await tester.pumpWidget(
        inSession(
          MemoryGame(complete: () {}, say: (_) {}, seed: 3),
          age: AgeGroup.agneaux,
        ),
      );
      final state = tester.state<MemoryGameState>(find.byType(MemoryGame));
      expect(state.cards, hasLength(6));
      expect(state.preview, isTrue);
      await tester.tap(find.byKey(const ValueKey('memory-0')));
      expect(state.revealed, isEmpty, reason: 'pendant l’aperçu, on ne joue pas encore');
      await tester.pump(const Duration(seconds: 3));
      expect(state.preview, isFalse);
    });
  });

  group('Verset', () {
    testWidgets('Agneaux : colorier les 7 bandes puis écouter le verset', (tester) async {
      await big(tester);
      var done = 0;
      final narrator = SilentNarrator(instant: true);
      await tester.pumpWidget(
        inSession(
          VerseGame(complete: () => done++, say: (_) {}),
          age: AgeGroup.agneaux,
          narrator: narrator,
        ),
      );
      for (var i = 0; i < VerseGameState.bandCount; i++) {
        await tester.tap(find.byKey(const ValueKey('verse-rainbow')));
        await tester.pump();
      }
      await tester.pump();
      expect(narrator.played.last, contains('verse.reading'));
      expect(done, 1);
    });

    testWidgets('Bergers : les morceaux dans l’ordre ; une erreur ne place rien', (tester) async {
      await big(tester);
      var done = 0;
      final said = <String>[];
      await tester.pumpWidget(inSession(VerseGame(complete: () => done++, say: said.add, seed: 4)));
      final chunks = loadStory('noe').verse.chunks[AgeGroup.bergers]!;
      await tester.tap(find.byKey(const ValueKey('chunk-2')));
      await tester.pump(const Duration(milliseconds: 500));
      final state = tester.state<VerseGameState>(find.byType(VerseGame));
      expect(state.placed, isEmpty);
      expect(said, contains('again'));
      for (var i = 0; i < chunks.length; i++) {
        await tester.tap(find.byKey(ValueKey('chunk-$i')));
        await tester.pump(const Duration(milliseconds: 250));
      }
      await tester.pump();
      expect(state.step, VerseStep.done);
      expect(done, 1);
    });

    testWidgets('Explorateurs : le verset, puis la bonne référence', (tester) async {
      await big(tester);
      var done = 0;
      await tester.pumpWidget(
        inSession(
          VerseGame(complete: () => done++, say: (_) {}, seed: 5),
          age: AgeGroup.explorateurs,
        ),
      );
      final story = loadStory('noe');
      final chunks = story.verse.chunks[AgeGroup.explorateurs]!;
      for (var i = 0; i < chunks.length; i++) {
        await tester.tap(find.byKey(ValueKey('chunk-$i')));
        await tester.pump(const Duration(milliseconds: 250));
      }
      await tester.pump();
      final state = tester.state<VerseGameState>(find.byType(VerseGame));
      expect(state.step, VerseStep.reference);
      await tester.tap(find.byKey(ValueKey('ref-${story.verse.referenceChoices[1]}')));
      await tester.pump();
      expect(done, 0);
      await tester.tap(find.byKey(ValueKey('ref-${story.verse.reference}')));
      await tester.pump();
      expect(done, 1);
    });
  });

  group('Puzzle', () {
    testWidgets('échanger les pièces jusqu’à l’image complète termine le jeu', (tester) async {
      await big(tester);
      var done = 0;
      await tester.pumpWidget(inSession(PuzzleGame(complete: () => done++, say: (_) {}, seed: 3)));
      await tester.pump(const Duration(milliseconds: 100));
      final s = tester.state<PuzzleGameState>(find.byType(PuzzleGame));
      expect(s.slots, hasLength(6));
      expect(s.solved, isFalse);
      for (var i = 0; i < s.slots.length; i++) {
        if (s.slots[i] == i) continue;
        await tester.tap(find.byKey(ValueKey('puzzle-${s.slots.indexOf(i)}')));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.byKey(ValueKey('puzzle-$i')));
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(s.solved, isTrue);
      expect(done, 1);
    });

    testWidgets('4 pièces pour les Agneaux, 9 pour les Explorateurs ; une pièce bien placée ne bouge plus', (
      tester,
    ) async {
      await big(tester);
      await tester.pumpWidget(
        inSession(
          PuzzleGame(complete: () {}, say: (_) {}, seed: 1),
          age: AgeGroup.agneaux,
        ),
      );
      expect(tester.state<PuzzleGameState>(find.byType(PuzzleGame)).slots, hasLength(4));
      await tester.pumpWidget(
        inSession(
          PuzzleGame(key: const ValueKey('grand'), complete: () {}, say: (_) {}, seed: 2),
          age: AgeGroup.explorateurs,
        ),
      );
      final s = tester.state<PuzzleGameState>(find.byType(PuzzleGame));
      expect(s.slots, hasLength(9));
      final placed = [
        for (var i = 0; i < 9; i++)
          if (s.slots[i] == i) i,
      ];
      if (placed.isNotEmpty) {
        s.tap(placed.first);
        expect(s.selected, isNull);
      }
    });
  });

  group('Quiz', () {
    testWidgets('la bonne image fait avancer ; une erreur efface l’image et Colombe encourage', (
      tester,
    ) async {
      await big(tester);
      var done = 0;
      final said = <String>[];
      await tester.pumpWidget(
        inSession(
          QuizGame(complete: () => done++, say: said.add, seed: 1),
          storyId: 'david',
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final s = tester.state<QuizGameState>(find.byType(QuizGame));
      expect(s.questions, hasLength(3));
      final wrong = s.question.choices.last;
      await tester.tap(find.byKey(ValueKey('quiz-$wrong')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(s.wrong, contains(wrong));
      expect(s.index, 0);
      expect(said, contains('again'));
      for (var q = 0; q < 3; q++) {
        await tester.tap(find.byKey(ValueKey('quiz-${s.question.answer}')));
        await tester.pump(const Duration(milliseconds: 1700));
      }
      expect(done, 1);
      expect(said, containsAll(['super', 'quiz.2', 'quiz.3']));
    });
  });

  testWidgets('chaque jeu tient sur un petit téléphone, pour chaque âge', (tester) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final age in AgeGroup.values) {
      for (final game in <Widget>[
        ChronologyGame(complete: () {}, say: (_) {}, seed: 1),
        SeekGame(complete: () {}, say: (_) {}),
        MemoryGame(complete: () {}, say: (_) {}, seed: 1),
        VerseGame(complete: () {}, say: (_) {}, seed: 1),
        PuzzleGame(complete: () {}, say: (_) {}, seed: 1),
        QuizGame(complete: () {}, say: (_) {}, seed: 1),
      ]) {
        await tester.pumpWidget(inSession(game, age: age, storyId: game is QuizGame ? 'david' : 'noe'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: '${game.runtimeType} / ${age.name}');
      }
    }
    await tester.pump(const Duration(seconds: 20));
  });
}

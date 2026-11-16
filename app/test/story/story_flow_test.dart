import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiere/app.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/games/chronology_game.dart';
import 'package:lumiere/games/puzzle_game.dart';
import 'package:lumiere/games/seek_game.dart';
import 'package:lumiere/games/verse_game.dart';
import 'package:lumiere/story/recit_view.dart';
import 'package:lumiere/story/story_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Attend que l'histoire soit chargée (lecture réelle des fichiers).
Future<void> waitForStory(WidgetTester tester) async {
  for (var i = 0; i < 40 && find.byKey(const ValueKey('age-bergers')).evaluate().isEmpty; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> frames(WidgetTester tester, [int count = 20]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  // Le cache des assets garde des Futures nés dans la « fausse horloge » d'un
  // test précédent : on le vide pour que chaque test relise les fichiers.
  setUp(rootBundle.clear);

  testWidgets('Noé de bout en bout : âge, récit, quatre jeux, récompense à 5 étoiles', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final narrator = SilentNarrator(instant: true);
    final sfx = SilentSoundEffects();
    await tester.pumpWidget(LumiereApp(trackPlaytime: false, narrator: narrator, sfx: sfx));
    await frames(tester);

    // Sans profil, l'histoire s'ouvre par le choix de l'âge.
    GoRouter.of(tester.element(find.text('Jouer'))).push('/histoire/noe');
    await waitForStory(tester);
    await frames(tester);
    expect(find.text('Noé et l\'arche'), findsWidgets);

    // Choix de l'âge.
    await tester.tap(find.byKey(const ValueKey('age-bergers')));
    await frames(tester);
    expect(find.byType(RecitView), findsOneWidget);

    // Les huit scènes : on fait l'action, puis « Suite ».
    final recit = tester.state<RecitViewState>(find.byType(RecitView));
    for (var i = 0; i < 8; i++) {
      await frames(tester, 4);
      expect(recit.index, i);
      expect(recit.canContinue, isFalse, reason: 'pas de « Suite » avant l’action');
      recit.game.stage!.complete();
      await frames(tester, 4);
      expect(recit.canContinue, isTrue);
      await tester.tap(find.text('Suite'));
      await frames(tester, 12);
    }
    expect(narrator.played.first, 'stories/noe/audio/scene.village.bergers.mp3');
    expect(narrator.played, contains('stories/noe/audio/scene.colombe.after.bergers.mp3'));

    // Le menu des jeux : déjà une étoile pour le récit.
    final screen = tester.state<StoryScreenState>(find.byType(StoryScreen));
    expect(screen.phase, StoryPhase.hub);
    expect(screen.stars, hasLength(1));

    Future<void> play(String hubKey, void Function() win) async {
      await tester.tap(find.byKey(ValueKey(hubKey)));
      await frames(tester, 12);
      win();
      await frames(tester, 12);
      await tester.tap(find.text('Suite'));
      await frames(tester, 12);
    }

    await play('hub-chronology', () {
      final s = tester.state<ChronologyGameState>(find.byType(ChronologyGame));
      for (final card in [...s.debugCards]) {
        s.pick(card);
      }
    });
    await play('hub-seek', () {
      final s = tester.state<SeekGameState>(find.byType(SeekGame));
      for (final item in [...s.items]) {
        s.find(item.id);
      }
    });
    await play('hub-puzzle', () {
      final s = tester.state<PuzzleGameState>(find.byType(PuzzleGame));
      for (var i = 0; i < s.slots.length; i++) {
        if (s.slots[i] == i) continue;
        s.tap(s.slots.indexOf(i));
        s.tap(i);
      }
      expect(s.solved, isTrue);
    });
    await tester.tap(find.byKey(const ValueKey('hub-verse')));
    await frames(tester, 12);
    final verse = tester.state<VerseGameState>(find.byType(VerseGame));
    for (var i = 0; i < 4; i++) {
      verse.pickChunk(i);
    }
    await frames(tester, 12);
    await tester.tap(find.text('Suite'));
    await frames(tester, 12);
    expect(screen.stars, hasLength(5));

    // Terminer : l'autocollant et les étoiles.
    await tester.tap(find.text('Terminer'));
    await frames(tester, 40);
    expect(find.text('Bravo !'), findsOneWidget);
    expect(find.bySemanticsLabel('5 étoiles sur 5'), findsOneWidget);
    expect(narrator.played.last, contains('reward'));

    await tester.tap(find.text('Accueil'));
    await frames(tester, 20);
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('le récit tient sur un petit téléphone, avec les longs sous-titres des Explorateurs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      LumiereApp(trackPlaytime: false, narrator: SilentNarrator(instant: true), sfx: SilentSoundEffects()),
    );
    await frames(tester);
    GoRouter.of(tester.element(find.text('Jouer'))).push('/histoire/noe');
    await waitForStory(tester);
    await frames(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('age-explorateurs')));
    await frames(tester);
    final recit = tester.state<RecitViewState>(find.byType(RecitView));
    for (var i = 0; i < 8; i++) {
      await frames(tester, 4);
      expect(tester.takeException(), isNull, reason: 'scène ${i + 1}');
      recit.game.stage!.complete();
      await frames(tester, 4);
      await tester.tap(find.text('Suite'));
      await frames(tester, 10);
    }
    expect(tester.takeException(), isNull);
  });
}

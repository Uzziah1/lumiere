import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiere/app.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/save/game_state.dart';
import 'package:lumiere/save/save_data.dart';
import 'package:lumiere/save/save_store.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/story/recit_view.dart';
import 'package:lumiere/story/story_part.dart';
import 'package:lumiere/story/story_screen.dart';
import 'package:lumiere/world/world.dart';
import 'package:material_ui/material_ui.dart';

Future<void> frames(WidgetTester tester, [int count = 30]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(rootBundle.clear);

  group('Règles des îles', () {
    final progress = <String, StoryProgress>{};
    StoryProgress of(String id) => progress[id] ?? StoryProgress.empty;
    const world = World(islands: lot1, available: {'noe', 'abraham'});
    Island island(String id) => lot1.firstWhere((i) => i.id == id);

    setUp(progress.clear);

    test('la première histoire existante est ouverte ; celles qui n’existent pas sont « bientôt »', () {
      expect(world.status(island('creation'), of), IslandStatus.soon);
      expect(world.status(island('noe'), of), IslandStatus.open);
      expect(world.status(island('jonas'), of), IslandStatus.soon);
    });

    test('l’île suivante s’ouvre avec 3 étoiles sur la précédente', () {
      expect(world.status(island('abraham'), of), IslandStatus.locked);
      progress['noe'] = const StoryProgress(parts: {StoryPart.recit, StoryPart.seek});
      expect(world.status(island('abraham'), of), IslandStatus.locked);
      progress['noe'] = const StoryProgress(parts: {StoryPart.recit, StoryPart.seek, StoryPart.verse});
      expect(world.status(island('abraham'), of), IslandStatus.open);
    });

    test('l’enfant se trouve sur la première île ouverte pas encore terminée', () {
      expect(world.currentIsland(of).id, 'noe');
      progress['noe'] = StoryProgress(parts: StoryPart.values.toSet(), sticker: true);
      expect(world.currentIsland(of).id, 'abraham');
      progress['abraham'] = const StoryProgress(sticker: true);
      expect(world.currentIsland(of).id, 'abraham', reason: 'tout est fini : la dernière île ouverte');
    });

    test('les îles sont dans l’ordre du voyage, bien réparties sur la carte', () {
      for (var i = 1; i < lot1.length; i++) {
        expect(lot1[i].position.dx, greaterThan(lot1[i - 1].position.dx));
      }
      for (final i in lot1) {
        expect(i.position.dy, inInclusiveRange(0.2, 0.7));
      }
    });
  });

  Future<GameState> openMap(
    WidgetTester tester, {
    Size size = const Size(1280, 720),
    void Function(GameState)? setup,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = GameState(MemorySaveStore());
    state.addProfile(name: 'Awa', age: AgeGroup.agneaux, avatar: 'sheep');
    setup?.call(state);
    await tester.pumpWidget(
      LumiereApp(narrator: SilentNarrator(instant: true), sfx: SilentSoundEffects(), gameState: state),
    );
    await frames(tester);
    await tester.tap(find.text('Jouer'));
    await frames(tester, 20);
    await tester.tap(find.text('Awa'));
    await frames(tester, 30);
    return state;
  }

  testWidgets('la carte montre les 8 îles ; une île « bientôt » le dit', (tester) async {
    await openMap(tester);
    for (final island in lot1) {
      expect(find.byKey(ValueKey('island-${island.id}')), findsOneWidget);
    }
    expect(find.bySemanticsLabel('Noé et l’arche, 0 étoiles sur 5'), findsOneWidget);
    expect(find.bySemanticsLabel('Abraham et les étoiles, bientôt'), findsOneWidget);

    final scroll = tester.widget<SingleChildScrollView>(find.byKey(const ValueKey('world-scroll')));
    scroll.controller!.jumpTo(scroll.controller!.position.maxScrollExtent);
    await frames(tester, 4);
    await tester.tap(find.byKey(const ValueKey('island-jonas')));
    await frames(tester, 4);
    expect(find.textContaining(RegExp('Jonas et le grand poisson.*arrive bientôt')), findsOneWidget);
    expect(find.byKey(const ValueKey('island-card')), findsNothing);
  });

  testWidgets('Noé depuis la carte : l’âge du profil, pas de choix ; les étoiles sont sauvegardées', (
    tester,
  ) async {
    final state = await openMap(tester);
    await tester.tap(find.byKey(const ValueKey('island-noe')));
    await frames(tester, 6);
    expect(find.byKey(const ValueKey('island-card')), findsOneWidget);
    await tester.tap(find.text('Jouer').last);
    for (var i = 0; i < 40 && find.byType(RecitView).evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const ValueKey('age-bergers')), findsNothing);
    final recit = tester.state<RecitViewState>(find.byType(RecitView));
    for (var i = 0; i < 8; i++) {
      await frames(tester, 4);
      recit.game.stage!.complete();
      await frames(tester, 4);
      await tester.tap(find.text('Suite'));
      await frames(tester, 12);
    }
    expect(tester.state<StoryScreenState>(find.byType(StoryScreen)).phase, StoryPhase.hub);
    expect(state.progress('noe').parts, {StoryPart.recit});

    // Terminer : autocollant gagné, retour à la carte.
    await tester.tap(find.text('Terminer'));
    await frames(tester, 40);
    expect(state.progress('noe').sticker, isTrue);
    await tester.tap(find.text('La carte'));
    await frames(tester, 30);
    expect(find.bySemanticsLabel('Noé et l’arche, 1 étoiles sur 5'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Awa, 1 étoiles')), findsOneWidget);
  });

  testWidgets('reprendre Noé : les étoiles déjà gagnées sont là dans le menu des jeux', (tester) async {
    await openMap(
      tester,
      setup: (s) {
        s.recordPart('noe', StoryPart.recit);
        s.recordPart('noe', StoryPart.memory);
      },
    );
    await tester.tap(find.byKey(const ValueKey('island-noe')));
    await frames(tester, 6);
    expect(find.text('Rejouer'), findsOneWidget);
  });

  testWidgets('sans joueur choisi, la carte renvoie vers la création d’un joueur', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(LumiereApp(narrator: SilentNarrator(instant: true), sfx: SilentSoundEffects()));
    await frames(tester);
    GoRouter.of(tester.element(find.text('Jouer'))).go('/carte');
    await frames(tester, 40);
    expect(find.text('Nouveau joueur'), findsOneWidget);
  });

  testWidgets('la carte tient sur un petit téléphone', (tester) async {
    await openMap(tester, size: const Size(640, 360));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('island-noe')));
    await frames(tester, 6);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('island-card')), findsOneWidget);
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiere/app.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/save/game_state.dart';
import 'package:lumiere/save/save_store.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/story/story_part.dart';
import 'package:lumiere/world/world.dart';
import 'package:material_ui/material_ui.dart';

Future<void> frames(WidgetTester tester, [int count = 30]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(rootBundle.clear);

  Future<GameState> open(WidgetTester tester, String route, {Size size = const Size(1280, 720)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = GameState(MemorySaveStore());
    state.addProfile(name: 'Awa', age: AgeGroup.bergers, avatar: 'lion');
    state.recordPart('noe', StoryPart.recit);
    state.earnSticker('noe');
    state.earnSticker('jonas');
    await tester.pumpWidget(
      LumiereApp(narrator: SilentNarrator(instant: true), sfx: SilentSoundEffects(), gameState: state),
    );
    await frames(tester, 10);
    GoRouter.of(tester.element(find.text('Jouer'))).go(route);
    await frames(tester);
    return state;
  }

  test('chaque île a un ami pour l’arche, tous différents', () {
    final friends = lot1.map((i) => i.treasure).toList();
    expect(friends.toSet(), hasLength(lot1.length));
    expect(islandFor('noe')!.treasure, 'dove');
    expect(islandFor('inconnue'), isNull);
  });

  testWidgets('l’album montre les autocollants gagnés et les places à gagner', (tester) async {
    await open(tester, '/album');
    expect(find.text('L’album de Awa'), findsOneWidget);
    expect(find.textContaining('2 autocollants sur 8'), findsOneWidget);
    expect(find.bySemanticsLabel('Autocollant : Noé et l’arche'), findsOneWidget);
    expect(find.bySemanticsLabel('La Création, autocollant à gagner'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('album-noe')));
    await frames(tester, 10);
    expect(find.text('Genèse 6 à 9'), findsOneWidget);
  });

  testWidgets('l’arche-trésor : les amis gagnés sautent, les cabines vides expliquent', (tester) async {
    await open(tester, '/tresor');
    expect(find.text('Mon arche'), findsOneWidget);
    expect(find.textContaining('2 amis sur 8'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('la colombe, Noé')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('friend-noe')));
    await frames(tester, 12);
    expect(find.textContaining('Voici la colombe'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('friend-david')));
    await frames(tester, 4);
    expect(find.textContaining(RegExp('Termine l’histoire .*David et Goliath')), findsOneWidget);
  });

  testWidgets('album et arche tiennent sur un petit téléphone, et ramènent à la carte', (tester) async {
    await open(tester, '/tresor', size: const Size(640, 360));
    expect(tester.takeException(), isNull);
    GoRouter.of(tester.element(find.text('Mon arche'))).go('/album');
    await frames(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.bySemanticsLabel('Retour à la carte'));
    await frames(tester);
    expect(find.byKey(const ValueKey('world-scroll')), findsOneWidget);
  });

  testWidgets('passer directement d’une histoire à l’autre ouvre bien la nouvelle', (tester) async {
    await open(tester, '/histoire/creation');
    for (var i = 0; i < 40 && find.text('Genèse 1.1-5').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Genèse 1.1-5'), findsOneWidget);
    GoRouter.of(tester.element(find.text('Genèse 1.1-5'))).go('/histoire/jonas');
    for (var i = 0; i < 40 && find.text('Jonas 1.1-3').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Jonas 1.1-3'), findsOneWidget);
    await frames(tester, 20);
  });
}

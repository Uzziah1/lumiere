import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/app.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/save/game_state.dart';
import 'package:lumiere/save/save_store.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/widgets/parental_gate.dart';
import 'package:material_ui/material_ui.dart';

Future<void> frames(WidgetTester tester, [int count = 30]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(rootBundle.clear);

  Future<GameState> openApp(WidgetTester tester, {void Function(GameState state)? setup}) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = GameState(MemorySaveStore());
    await state.load();
    setup?.call(state);
    await tester.pumpWidget(
      LumiereApp(narrator: SilentNarrator(instant: true), sfx: SilentSoundEffects(), gameState: state),
    );
    await frames(tester);
    return state;
  }

  testWidgets('premier lancement : créer son profil puis arriver sur la carte', (tester) async {
    final state = await openApp(tester);
    await tester.tap(find.text('Jouer'));
    await frames(tester, 40);
    expect(find.text('Nouveau joueur'), findsOneWidget);

    // Sans prénom ni âge : on le dit gentiment, rien n'est créé.
    await tester.tap(find.text('C’est parti !'));
    await frames(tester, 6);
    expect(find.text('Écris ton prénom (un adulte peut t’aider)'), findsOneWidget);
    expect(state.profiles, isEmpty);

    await tester.enterText(find.byKey(const ValueKey('profile-name')), '  Awa ');
    await tester.tap(find.byKey(const ValueKey('profile-age-agneaux')));
    await tester.tap(find.byKey(const ValueKey('profile-avatar-lion')));
    await frames(tester, 4);
    await tester.tap(find.text('C’est parti !'));
    await frames(tester, 40);

    expect(state.profiles.single.name, 'Awa');
    expect(state.current!.age, AgeGroup.agneaux);
    expect(state.current!.avatar, 'lion');
    expect(find.bySemanticsLabel(RegExp('Awa, 0 étoiles')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Noé et l’arche')), findsOneWidget);
  });

  testWidgets('« Qui joue ? » : toucher un médaillon choisit ce joueur', (tester) async {
    late String ibrahim;
    final state = await openApp(
      tester,
      setup: (s) {
        s.addProfile(name: 'Awa', age: AgeGroup.agneaux, avatar: 'sheep');
        ibrahim = s.addProfile(name: 'Ibrahim', age: AgeGroup.explorateurs, avatar: 'owl').id;
        s.select(s.profiles.first.id);
      },
    );
    await tester.tap(find.text('Jouer'));
    await frames(tester, 30);
    expect(find.text('Awa'), findsOneWidget);
    expect(find.text('Ibrahim'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-new')), findsOneWidget);

    await tester.tap(find.text('Ibrahim'));
    await frames(tester, 30);
    expect(state.current!.id, ibrahim);
    expect(find.bySemanticsLabel(RegExp('Ibrahim, 0 étoiles')), findsOneWidget);
  });

  testWidgets('quatre joueurs : plus de case « Nouveau »', (tester) async {
    await openApp(
      tester,
      setup: (s) {
        for (var i = 0; i < 4; i++) {
          s.addProfile(name: 'Enfant $i', age: AgeGroup.bergers, avatar: 'rabbit');
        }
      },
    );
    await tester.tap(find.text('Jouer'));
    await frames(tester, 30);
    expect(find.byKey(const ValueKey('profile-new')), findsNothing);
  });

  testWidgets('gérer les profils : barrière parentale, modifier, supprimer', (tester) async {
    final state = await openApp(
      tester,
      setup: (s) => s.addProfile(name: 'Awa', age: AgeGroup.agneaux, avatar: 'sheep'),
    );
    await tester.tap(find.text('Jouer'));
    await frames(tester, 30);

    await tester.tap(find.bySemanticsLabel('Gérer les profils (parents)'));
    await frames(tester, 10);
    final gate = tester.state<ParentalGateState>(find.byType(ParentalGate));
    expect(gate.question, startsWith('Combien font '));

    // Mauvaise réponse : nouvelle question, on reste dehors.
    await tester.tap(find.byKey(const ValueKey('gate-1')));
    await frames(tester, 2);
    await tester.tap(find.text('Valider'));
    await frames(tester, 4);
    expect(find.text('Ce n’est pas ça. Demande à un adulte !'), findsOneWidget);

    for (final digit in '${gate.a * gate.b}'.split('')) {
      await tester.tap(find.byKey(ValueKey('gate-$digit')));
      await frames(tester, 1);
    }
    await tester.tap(find.text('Valider'));
    await frames(tester, 10);
    expect(find.byType(ParentalGate), findsNothing);
    expect(find.textContaining('Quel profil veux-tu modifier'), findsOneWidget);

    await tester.tap(find.text('Awa'));
    await frames(tester, 30);
    expect(find.text('Modifier le profil'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('profile-name')), 'Awa B.');
    await tester.tap(find.byKey(const ValueKey('profile-age-bergers')));
    await frames(tester, 2);
    await tester.tap(find.text('Enregistrer'));
    await frames(tester, 30);
    expect(state.current!.name, 'Awa B.');
    expect(state.current!.age, AgeGroup.bergers);

    await tester.tap(find.text('Awa B.'));
    await frames(tester, 30);
    await tester.tap(find.text('Supprimer'));
    await frames(tester, 10);
    await tester.tap(find.byKey(const ValueKey('confirm-delete')));
    await frames(tester, 40);
    expect(state.profiles, isEmpty);
  });

  testWidgets('la question de la barrière est écrite en lettres', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(onPressed: () => showParentalGate(context), child: const Text('ouvrir'));
          },
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pump(const Duration(milliseconds: 300));
    final gate = tester.state<ParentalGateState>(find.byType(ParentalGate));
    expect(gate.question, isNot(contains(RegExp(r'\d'))));
    expect(gate.a, inInclusiveRange(3, 9));
    expect(gate.b, inInclusiveRange(3, 9));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ParentalGate), findsNothing);
  });

  testWidgets('les écrans de profil tiennent sur un petit téléphone', (tester) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = GameState(MemorySaveStore());
    for (var i = 0; i < 4; i++) {
      state.addProfile(name: 'Enfant numéro $i', age: AgeGroup.bergers, avatar: 'giraffe');
    }
    await tester.pumpWidget(
      LumiereApp(narrator: SilentNarrator(instant: true), sfx: SilentSoundEffects(), gameState: state),
    );
    await frames(tester);
    await tester.tap(find.text('Jouer'));
    await frames(tester, 30);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Enfant numéro 0'));
    await frames(tester, 30);
    expect(tester.takeException(), isNull);
  });
}

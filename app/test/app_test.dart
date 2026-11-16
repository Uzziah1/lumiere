import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/app.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiere/widgets/paper_button.dart';
import 'package:material_ui/material_ui.dart';

/// L'accueil tourne en continu (scène Flame, titre qui flotte) : on avance
/// donc le temps à la main plutôt qu'avec pumpAndSettle.
Future<void> settle(WidgetTester tester, [int frames = 30]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  // Le cache des assets garde des Futures nés dans la « fausse horloge » d'un
  // test précédent : on le vide pour que chaque test relise les fichiers.
  setUp(rootBundle.clear);

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> openApp(WidgetTester tester, {Size size = const Size(1280, 720)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      LumiereApp(trackPlaytime: false, narrator: SilentNarrator(instant: true), sfx: SilentSoundEffects()),
    );
    await settle(tester);
  }

  testWidgets("l'accueil affiche le titre, le sous-titre et les boutons", (tester) async {
    await openApp(tester);

    expect(find.bySemanticsLabel('Lumière'), findsOneWidget);
    expect(find.text('La Bible en jeux'), findsOneWidget);
    expect(find.widgetWithText(PaperButton, 'Jouer'), findsOneWidget);
    expect(find.widgetWithText(PaperButton, 'Parents'), findsOneWidget);
  });

  testWidgets('« Jouer » sans profil ouvre la création d’un joueur', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('Jouer'));
    await settle(tester, 40);
    expect(find.text('Nouveau joueur'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Retour'));
    await settle(tester);
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('la carte (bientôt) reste accessible par son adresse', (tester) async {
    await openApp(tester);
    final router = GoRouter.of(tester.element(find.text('Jouer')));
    router.push('/bientot/carte');
    await settle(tester);
    expect(find.text('Ton voyage se prépare !'), findsOneWidget);
    await tester.tap(find.text('Retour'));
    await settle(tester);
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('« Parents » ouvre la barrière parentale', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('Parents'));
    await settle(tester);
    expect(find.text('Pour les parents'), findsOneWidget);
  });

  testWidgets("l'accueil tient sur un petit téléphone, à l'horizontale comme à la verticale", (tester) async {
    await openApp(tester, size: const Size(640, 360));
    expect(tester.takeException(), isNull);
    expect(find.text('Jouer'), findsOneWidget);

    await openApp(tester, size: const Size(360, 740));
    expect(tester.takeException(), isNull);
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('avec « réduire les animations », tout est visible tout de suite', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: LumiereApp(
          trackPlaytime: false,
          narrator: SilentNarrator(instant: true),
          sfx: SilentSoundEffects(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('Jouer').hitTestable(), findsOneWidget);
  });
}

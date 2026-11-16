import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/app.dart';
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
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> openApp(WidgetTester tester, {Size size = const Size(1280, 720)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const LumiereApp());
    await settle(tester);
  }

  testWidgets("l'accueil affiche le titre, le sous-titre et les boutons", (tester) async {
    await openApp(tester);

    expect(find.bySemanticsLabel('Lumière'), findsOneWidget);
    expect(find.text('La Bible en jeux'), findsOneWidget);
    expect(find.widgetWithText(PaperButton, 'Jouer'), findsOneWidget);
    expect(find.widgetWithText(PaperButton, 'Parents'), findsOneWidget);
  });

  testWidgets('« Jouer » mène à la carte (bientôt), « Retour » ramène à l’accueil', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('Jouer'));
    await settle(tester);
    expect(find.text('Ton voyage se prépare !'), findsOneWidget);

    await tester.tap(find.text('Retour'));
    await settle(tester);
    expect(find.text('Ton voyage se prépare !'), findsNothing);
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('« Parents » mène à l’espace parents (bientôt)', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('Parents'));
    await settle(tester);
    expect(find.text('Espace parents'), findsOneWidget);
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
      const MediaQuery(data: MediaQueryData(disableAnimations: true), child: LumiereApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('Jouer').hitTestable(), findsOneWidget);
  });
}

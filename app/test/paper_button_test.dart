import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/widgets/paper_button.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('le bouton réagit au toucher et prend la taille de son contenu', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PaperButton(label: 'Jouer', onPressed: () => taps++)));

    await tester.tap(find.text('Jouer'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(taps, 1);

    final size = tester.getSize(find.byType(PaperButton));
    expect(size.width, lessThan(400));
    expect(size.height, PaperButtonSize.large.height + PaperButtonSize.large.depth);
  });

  testWidgets('assez grand pour de petits doigts (au moins 48 px)', (tester) async {
    await tester.pumpWidget(wrap(PaperButton.secondary(label: 'Parents', onPressed: () {})));
    expect(tester.getSize(find.byType(PaperButton)).height, greaterThanOrEqualTo(48));
  });

  testWidgets('désactivé : ne réagit pas et est annoncé comme tel', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(const PaperButton(label: 'Jouer', onPressed: null)));
    await tester.tap(find.text('Jouer'), warnIfMissed: false);
    await tester.pump();

    expect(
      tester.getSemantics(find.byType(PaperButton)),
      matchesSemantics(label: 'Jouer', isButton: true, hasEnabledState: true, isEnabled: false),
    );
    handle.dispose();
  });
}

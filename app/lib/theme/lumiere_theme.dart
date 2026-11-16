import 'package:material_ui/material_ui.dart';

import 'palette.dart';

/// Styles de texte de Lumière.
///
/// Fredoka (titres, ronde et chaleureuse) est une police variable : on règle
/// sa graisse avec `FontVariation`. Andika (texte) est conçue pour les jeunes lecteurs.
abstract final class LumiereText {
  static const display = 'Fredoka';
  static const body = 'Andika';

  static TextStyle title(double size, {int weight = 600, Color color = Palette.ink}) {
    return TextStyle(
      fontFamily: display,
      fontSize: size,
      height: 1.05,
      color: color,
      fontWeight: _weight(weight),
      fontVariations: [FontVariation('wght', weight.toDouble())],
    );
  }

  static TextStyle text(double size, {bool bold = false, Color color = Palette.ink}) {
    return TextStyle(
      fontFamily: body,
      fontSize: size,
      height: 1.35,
      color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
  }

  static FontWeight _weight(int weight) {
    final index = ((weight / 100).round() - 1).clamp(0, FontWeight.values.length - 1);
    return FontWeight.values[index];
  }
}

/// Typographie française : espace insécable avant « ! ? ; : » et à l'intérieur
/// des guillemets, pour qu'un signe ne parte jamais seul à la ligne.
String frenchSpacing(String text) =>
    text.replaceAllMapped(RegExp(r' ([!?;:»])'), (m) => '\u00A0${m[1]}').replaceAll('« ', '«\u00A0');

ThemeData buildLumiereTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Palette.lagoon,
    primary: Palette.lagoon,
    secondary: Palette.gold,
    surface: Palette.paper,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.paper,
    fontFamily: LumiereText.body,
    textTheme: TextTheme(
      displayLarge: LumiereText.title(72),
      headlineMedium: LumiereText.title(32),
      titleLarge: LumiereText.title(24, weight: 500),
      bodyLarge: LumiereText.text(20),
      bodyMedium: LumiereText.text(17),
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

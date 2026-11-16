import 'dart:ui';

/// Couleurs de Lumière : aube chaude, papier crème, encre brune et lagon.
///
/// Chaque histoire aura sa palette dominante ; celle-ci est la palette « Aube »
/// de l'accueil, et les couleurs d'interface communes.
abstract final class Palette {
  // Interface
  static const ink = Color(0xFF3B2418);
  static const inkSoft = Color(0xFF7A3F25);
  static const cream = Color(0xFFFFF8EC);
  static const paper = Color(0xFFFDF1DE);
  static const gold = Color(0xFFF2B544);
  static const goldDeep = Color(0xFFD9922B);
  static const lagoon = Color(0xFF1FA4A0);
  static const lagoonDeep = Color(0xFF137A77);
  static const ember = Color(0xFFE9894F);
  static const blush = Color(0xFFF59A9A);
  static const shadow = Color(0x4D5A2412);

  // Aube
  static const dawnSkyTop = Color(0xFFFF9C7A);
  static const dawnSkyMid = Color(0xFFFFC498);
  static const dawnHorizon = Color(0xFFFFE6BE);
  static const sun = Color(0xFFFFF6DC);
  static const sunHalo = Color(0xFFFFD67E);
  static const cloud = Color(0xFFFFF1E2);

  /// Collines de l'aube, du plan le plus lointain au plus proche.
  static const dawnHills = <Color>[
    Color(0xFFEDB48E),
    Color(0xFFDB8F67),
    Color(0xFFC06E49),
    Color(0xFF9A5238),
  ];

  // Colombe
  static const dove = Color(0xFFFFFFFF);
  static const doveShade = Color(0xFFEDE5F6);
  static const doveWingBack = Color(0xFFDCD1EA);
  static const doveFeather = Color(0xFFD9CDE8);
  static const beak = Color(0xFFF4A340);
  static const olive = Color(0xFF7FA650);
  static const oliveDeep = Color(0xFF5E8A3A);
}

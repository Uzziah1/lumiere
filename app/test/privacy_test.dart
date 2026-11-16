import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/parents/privacy.dart';

/// La politique de confidentialité existe en trois endroits (jeu, page web,
/// docs) : ils doivent dire exactement la même chose.
void main() {
  String unescape(String s) => s
      .replaceAll('&#x27;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  test('la page web et le document reprennent chaque section du jeu', () {
    final web = unescape(File('web/confidentialite.html').readAsStringSync());
    final doc = File('../docs/confidentialite.md').readAsStringSync();
    for (final (title, body) in privacySections) {
      expect(web, contains(title));
      expect(web, contains(body), reason: title);
      expect(doc, contains(body), reason: title);
    }
  });

  test('la politique ne promet rien que le jeu ne fasse pas : aucune autorisation Android', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, isNot(contains('uses-permission')));
  });
}

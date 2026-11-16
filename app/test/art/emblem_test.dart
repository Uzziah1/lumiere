import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/art/emblem.dart';

void main() {
  test('l’emblème se dessine à toutes les tailles d’icône', () {
    for (final side in [48.0, 108.0, 512.0]) {
      final recorder = PictureRecorder();
      Emblem.paintIcon(Canvas(recorder), Size(side, side), inset: 0.2);
      expect(recorder.endRecording(), isNotNull);
    }
  });
}

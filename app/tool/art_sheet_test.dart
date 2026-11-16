// Planche de tous les dessins (personnages, animaux, arche, météo), pour
// vérifier le style d'un coup d'œil.
//
// Lancer depuis app/ :  flutter test tool/art_sheet_test.dart
// Résultat : build/art_sheet.png
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/art/animals.dart';
import 'package:lumiere/art/ark.dart';
import 'package:lumiere/art/people.dart';
import 'package:lumiere/art/weather.dart';
import 'package:lumiere/theme/palette.dart';

void main() {
  test('planche', () async {
    const size = Size(1600, 1200);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Offset.zero & size, Paint()..color = Palette.paper);

    // Famille de Noé.
    for (var i = 0; i < NoahFamily.all.length; i++) {
      paintPerson(
        canvas,
        Offset(90 + i * 120.0, 300),
        220,
        NoahFamily.all[i],
        wave: i == 0 ? 1 : 0,
        blink: i == 3 ? 1 : 0,
      );
    }

    // Animaux.
    for (var i = 0; i < Animal.values.length; i++) {
      final x = 20 + (i % 6) * 190.0;
      final y = 340 + (i ~/ 6) * 190.0;
      paintAnimal(canvas, Animal.values[i], Rect.fromLTWH(x, y, 170, 170));
    }

    // Arche à chaque étape.
    for (var s = 0; s <= Ark.buildSteps; s++) {
      Ark.paint(canvas, Rect.fromLTWH(20 + s * 260.0, 740, 240, 144), build: s / Ark.buildSteps);
    }
    Ark.paint(canvas, const Rect.fromLTWH(20, 920, 400, 240), door: 1, window: 1);

    // Météo.
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(460, 900, 1100, 280));
    canvas.translate(460, 900);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1100, 280), Paint()..color = const Color(0xFFBFD8E6));
    paintRainbow(canvas, const Offset(300, 280), 240, 90, progress: 0.85);
    paintHeavenlyLight(canvas, const Size(400, 280), const Offset(820, 0), 1);
    paintWaves(canvas, const Size(1100, 280), 200, 0.5);
    canvas.restore();

    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    File('build/art_sheet.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

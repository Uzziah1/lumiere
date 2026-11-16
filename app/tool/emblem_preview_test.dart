// Aperçu de l'emblème à plusieurs tailles : build/emblem_preview.png
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/art/emblem.dart';

void main() {
  test('aperçu', () async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1000, 560), Paint()..color = const Color(0xFFEDEDED));
    var x = 20.0;
    for (final s in [512.0, 192.0, 96.0, 48.0]) {
      canvas.save();
      canvas.translate(x, 20);
      canvas.clipRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), Radius.circular(s * 0.22)));
      Emblem.paintIcon(canvas, Size(s, s));
      canvas.restore();
      x += s + 20;
    }
    final image = await recorder.endRecording().toImage(1000, 560);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    File('build/emblem_preview.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

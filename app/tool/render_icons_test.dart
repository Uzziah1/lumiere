// Génère les icônes de l'application (Android, iOS, web) à partir du dessin
// de Colombe, pour qu'elles restent identiques au jeu.
//
// Lancer depuis app/ :  flutter test tool/render_icons_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/art/colombe.dart';
import 'package:lumiere/art/paper.dart';
import 'package:lumiere/theme/palette.dart';

/// [inset] : part du côté laissée libre autour de Colombe (plus grande pour
/// les icônes « maskable » qu'Android découpe en cercle).
Future<void> renderIcon(String path, int size, {double inset = 0.14, bool rounded = false}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();
  final rect = Rect.fromLTWH(0, 0, s, s);

  if (rounded) {
    canvas.clipRRect(RRect.fromRectAndRadius(rect, Radius.circular(s * 0.22)));
  }
  canvas.drawRect(
    rect,
    Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(0, s),
        const [Palette.dawnSkyTop, Palette.dawnSkyMid, Palette.dawnHorizon],
        const [0, 0.55, 1],
      ),
  );
  final sunCenter = Offset(s * 0.5, s * 0.56);
  canvas.drawCircle(
    sunCenter,
    s * 0.46,
    Paint()
      ..shader = Gradient.radial(sunCenter, s * 0.46, [
        Palette.sunHalo.withValues(alpha: 0.9),
        Palette.sunHalo.withValues(alpha: 0),
      ]),
  );
  drawPaper(
    canvas,
    Path()..addOval(Rect.fromCircle(center: sunCenter, radius: s * 0.24)),
    Palette.sun,
    elevation: 0,
    light: 0,
  );

  final doveWidth = s * (1 - inset * 2);
  canvas.save();
  canvas.translate(s * inset, s * 0.5 - doveWidth / Colombe.aspectRatio / 2);
  Colombe.paint(canvas, Size(doveWidth, doveWidth / Colombe.aspectRatio), flap: 0.85, withBranch: true);
  canvas.restore();

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('icônes', () async {
    // Web
    await renderIcon('web/favicon.png', 64, inset: 0.06);
    await renderIcon('web/icons/Icon-192.png', 192);
    await renderIcon('web/icons/Icon-512.png', 512);
    await renderIcon('web/icons/Icon-maskable-192.png', 192, inset: 0.22);
    await renderIcon('web/icons/Icon-maskable-512.png', 512, inset: 0.22);

    // Android
    const android = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192};
    for (final MapEntry(key: density, value: size) in android.entries) {
      await renderIcon(
        'android/app/src/main/res/mipmap-$density/ic_launcher.png',
        size,
        inset: 0.1,
        rounded: true,
      );
    }

    // iOS : les tailles sont lues dans Contents.json.
    const iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final contents = jsonDecode(File('$iosDir/Contents.json').readAsStringSync()) as Map<String, dynamic>;
    for (final entry in (contents['images'] as List).cast<Map<String, dynamic>>()) {
      final file = entry['filename'] as String?;
      if (file == null) continue;
      final points = double.parse((entry['size'] as String).split('x').first);
      final scale = int.parse((entry['scale'] as String).replaceAll('x', ''));
      await renderIcon('$iosDir/$file', (points * scale).round(), inset: 0.1);
    }
  });
}

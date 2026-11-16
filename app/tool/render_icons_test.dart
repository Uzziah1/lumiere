// Génère les icônes de l'application (Android, iOS, web) à partir de l'emblème
// (lib/art/emblem.dart) : colombe blanche, rameau d'olivier, disque doré, ciel de nuit.
//
// Lancer depuis app/ :  flutter test tool/render_icons_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/art/emblem.dart';

/// [inset] : part du côté laissée libre autour de la colombe (plus grande pour
/// les icônes « maskable » qu'Android découpe en cercle).
Future<void> renderIcon(String path, int size, {double inset = 0.1, bool rounded = false}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();
  if (rounded) {
    canvas.clipRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), Radius.circular(s * 0.22)));
  }
  Emblem.paintIcon(canvas, Size(s, s), inset: inset);

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('icônes', () async {
    // Web
    await renderIcon('web/favicon.png', 64, inset: 0.04);
    await renderIcon('web/icons/Icon-192.png', 192);
    await renderIcon('web/icons/Icon-512.png', 512);
    await renderIcon('web/icons/Icon-maskable-192.png', 192, inset: 0.18);
    await renderIcon('web/icons/Icon-maskable-512.png', 512, inset: 0.18);

    // Android
    const android = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192};
    for (final MapEntry(key: density, value: size) in android.entries) {
      await renderIcon(
        'android/app/src/main/res/mipmap-$density/ic_launcher.png',
        size,
        inset: 0.08,
        rounded: true,
      );
    }

    // Android 8 et plus : premier plan de l'icône adaptative (108 dp, la colombe
    // dans la zone sûre centrale de 66 dp).
    const adaptive = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432};
    for (final MapEntry(key: density, value: size) in adaptive.entries) {
      await renderIcon(
        'android/app/src/main/res/mipmap-$density/ic_launcher_foreground.png',
        size,
        inset: 0.22,
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
      await renderIcon('$iosDir/$file', (points * scale).round(), inset: 0.08);
    }
  });
}

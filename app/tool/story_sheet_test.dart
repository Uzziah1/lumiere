// Planche des scènes d'une histoire scénarisée : chaque scène au début (en
// haut) et terminée (en bas), plus la scène de cache-cache et l'autocollant.
//
// Depuis app/ :  flutter test tool/story_sheet_test.dart --dart-define=STORY=creation
// Résultat : build/story_<id>.png
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/stories/registry.dart';
import 'package:lumiere/story/scripted_stage.dart';

import '../test/helpers.dart';

void main() {
  const id = String.fromEnvironment('STORY', defaultValue: 'creation');
  // --dart-define=TARGETS=false pour une planche sans les zones à toucher.
  const showTargets = bool.fromEnvironment('TARGETS', defaultValue: true);
  test('planche $id', () async {
    final pack = storyPacks[id]!;
    final story = loadStory(id);
    const cell = Size(480, 270);
    final scenes = story.scenes;
    final size = Size(cell.width * scenes.length, cell.height * 3);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    for (var i = 0; i < scenes.length; i++) {
      final stage = pack.stages[scenes[i].stage]!() as ScriptedStage;
      final start = StageView(stage.script.viewTargets)..time = 0.7;
      for (final (row, view) in [(0, start), (1, StageView.finished(stage.script.viewTargets))]) {
        canvas.save();
        canvas.translate(i * cell.width, row * cell.height);
        canvas.clipRect(Offset.zero & cell);
        stage.script.paint(canvas, cell, view);
        // Zones à toucher.
        for (final t in showTargets ? stage.script.targets : const <Rect>[]) {
          canvas.drawRect(
            Rect.fromLTRB(
              t.left * cell.width,
              t.top * cell.height,
              t.right * cell.width,
              t.bottom * cell.height,
            ),
            Paint()
              ..color = const Color(0x88FF00FF)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
        canvas.restore();
      }
    }
    canvas.save();
    canvas.translate(0, cell.height * 2);
    final seek = pack.seekScene;
    final seekSize = Size(cell.height * seek.aspectRatio, cell.height);
    canvas.clipRect(Offset.zero & seekSize);
    seek.paintBackground(canvas, seekSize);
    for (final MapEntry(key: item, value: (c, s)) in seek.spots.entries) {
      final side = s * seekSize.height;
      seek.paintItem(
        canvas,
        item,
        Rect.fromCenter(
          center: Offset(c.dx * seekSize.width, c.dy * seekSize.height),
          width: side,
          height: side,
        ),
      );
    }
    seek.paintForeground(canvas, seekSize);
    canvas.restore();
    canvas.save();
    canvas.translate(seekSize.width + 20, cell.height * 2);
    pack.paintSticker(canvas, Size(cell.height, cell.height));
    canvas.translate(cell.height + 20, 0);
    for (var k = 0; k < story.memory.pairs.length; k++) {
      pack.paintItem(
        canvas,
        story.memory.pairs[k],
        Rect.fromLTWH((k % 3) * 120.0, (k ~/ 3) * 130.0, 110, 120),
      );
    }
    canvas.restore();
    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    File('build/story_$id.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

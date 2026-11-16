// Captures des mini-jeux avec les vraies polices.
// Depuis app/ :  flutter test tool/games_screens_test.dart  → build/screens/jeu-*.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/games/game_frame.dart';
import 'package:lumiere/games/puzzle_game.dart';
import 'package:lumiere/games/quiz_game.dart';
import 'package:lumiere/stories/registry.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/story/story_hub.dart';
import 'package:lumiere/story/story_part.dart';
import 'package:lumiere/story/story_session.dart';
import 'package:lumiere/theme/lumiere_theme.dart';
import 'package:material_ui/material_ui.dart';

import '../test/helpers.dart';

Future<void> loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    await loadFont('Fredoka', ['assets/fonts/Fredoka.ttf']);
    await loadFont('Andika', ['assets/fonts/Andika-Regular.ttf', 'assets/fonts/Andika-Bold.ttf']);
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/sdk/flutter';
    await loadFont('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  });

  Future<void> capture(
    WidgetTester tester,
    String storyId,
    String name,
    String title,
    String key,
    Widget Function(VoidCallback, void Function(String)) game, {
    void Function(WidgetTester tester)? act,
  }) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLumiereTheme(),
        home: RepaintBoundary(
          key: boundary,
          child: StorySession(
            story: loadStory(storyId),
            common: loadCommon(),
            age: AgeGroup.bergers,
            pack: storyPacks[storyId]!,
            narrator: SilentNarrator(instant: true),
            sfx: SilentSoundEffects(),
            child: GameFrame(
              title: title,
              instructionKey: key,
              onExit: () {},
              onDone: () {},
              builder: (context, complete, say) => game(complete, say),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    act?.call(tester);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(() async {
      final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/screens/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  testWidgets('puzzle', (tester) async {
    await capture(
      tester,
      'jonas',
      'jeu-puzzle',
      'Le puzzle',
      'puzzle_help',
      (c, s) => PuzzleGame(complete: c, say: s, seed: 4),
      act: (tester) {
        final st = tester.state<PuzzleGameState>(find.byType(PuzzleGame));
        st.tap(st.slots.indexWhere((p) => p != st.slots.indexOf(p)));
      },
    );
  });

  testWidgets('quiz', (tester) async {
    await capture(
      tester,
      'daniel',
      'jeu-quiz',
      'Le quiz',
      'quiz.1',
      (c, s) => QuizGame(complete: c, say: s, seed: 2),
    );
  });

  testWidgets('menu des jeux', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLumiereTheme(),
        home: RepaintBoundary(
          key: boundary,
          child: Scaffold(
            backgroundColor: const Color(0xFFFFF6E8),
            body: StorySession(
              story: loadStory('david'),
              common: loadCommon(),
              age: AgeGroup.bergers,
              pack: storyPacks['david']!,
              narrator: SilentNarrator(instant: true),
              sfx: SilentSoundEffects(),
              child: StoryHub(
                stars: const {StoryPart.recit, StoryPart.quiz},
                onOpen: (_) {},
                onFinish: () {},
                onExit: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(() async {
      final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/screens/jeu-menu.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}

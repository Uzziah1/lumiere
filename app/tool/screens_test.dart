// Captures d'écrans de menus avec les vraies polices (espace parents, « À demain »).
// Depuis app/ :  flutter test tool/screens_test.dart  → build/screens/*.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/parents/parents_screen.dart';
import 'package:lumiere/parents/play_time.dart';
import 'package:lumiere/save/game_state.dart';
import 'package:lumiere/save/save_store.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/story/story_part.dart';
import 'package:lumiere/theme/lumiere_theme.dart';
import 'package:lumiere/world/album_screen.dart';
import 'package:lumiere/world/treasure_screen.dart';
import 'package:lumiere/world/world_map_screen.dart';
import 'package:material_ui/material_ui.dart';

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

  Future<void> capture(WidgetTester tester, Widget screen, String name, {GameState? state}) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    final game = state ?? GameState(MemorySaveStore());
    await tester.pumpWidget(
      GameScope(
        state: game,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildLumiereTheme(),
          home: AudioScope(
            narrator: SilentNarrator(instant: true),
            sfx: SilentSoundEffects(),
            musicOverride: ValueNotifier(null),
            child: RepaintBoundary(key: key, child: screen),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/screens/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  GameState sample() {
    final s = GameState(MemorySaveStore(), clock: () => DateTime(2026, 11, 16, 17));
    s.addProfile(name: 'Awa', age: AgeGroup.bergers, avatar: 'lion');
    for (final id in ['creation', 'eden', 'noe']) {
      for (final p in StoryPart.values) {
        s.recordPart(id, p);
      }
      s.earnSticker(id);
    }
    for (final id in ['naissance', 'bapteme', 'tempete', 'paques']) {
      s.recordPart(id, StoryPart.recit);
      s.earnSticker(id);
    }
    s.recordPart('abraham', StoryPart.recit);
    s.addPlaytime(25 * 60);
    s.addProfile(name: 'Ibrahim', age: AgeGroup.agneaux, avatar: 'sheep');
    s.recordPart('creation', StoryPart.recit);
    s.addPlaytime(12 * 60);
    s.updateSettings(s.settings.copyWith(dailyLimit: 45));
    return s;
  }

  GameState awa() {
    final s = sample();
    s.select(s.profiles.first.id);
    return s;
  }

  testWidgets(
    'enfants',
    (tester) async =>
        capture(tester, const ParentsScreen(skipGate: true), 'parents-enfants', state: sample()),
  );

  testWidgets('réglages', (tester) async {
    await capture(
      tester,
      const ParentsScreen(skipGate: true, initialTab: ParentsTab.settings),
      'parents-reglages',
      state: sample(),
    );
  });

  testWidgets('à demain', (tester) async {
    await capture(tester, TimeUpScreen(onHome: () {}, onExtra: (_) {}), 'a-demain');
  });

  testWidgets('jardin', (tester) async {
    await capture(tester, const TreasureScreen(garden: true), 'jardin', state: awa());
  });

  testWidgets('album', (tester) async {
    await capture(tester, const AlbumScreen(), 'album', state: awa());
  });

  testWidgets('carte', (tester) async {
    await capture(tester, const WorldMapScreen(), 'carte', state: awa());
  });
}

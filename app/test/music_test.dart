import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiere/app.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/audio/music_director.dart';
import 'package:lumiere/save/game_state.dart';
import 'package:lumiere/save/save_store.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:material_ui/material_ui.dart';

Future<void> frames(WidgetTester tester, [int count = 20]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(rootBundle.clear);

  test('chaque morceau existe', () {
    for (final track in MusicTrack.values) {
      final file = File('assets/audio/music/${track.name}.mp3');
      expect(file.existsSync(), isTrue, reason: track.name);
      expect(file.lengthSync(), lessThan(600 * 1024), reason: 'morceau léger');
    }
  });

  test('le morceau de chaque écran', () {
    expect(trackFor('/'), MusicTrack.home);
    expect(trackFor('/carte'), MusicTrack.map);
    expect(trackFor('/profils'), MusicTrack.map);
    expect(trackFor('/histoire/noe'), MusicTrack.story);
    expect(trackFor('/histoire/noe', override: MusicTrack.games), MusicTrack.games);
    expect(trackFor('/carte', timeUp: true), isNull, reason: 'silence quand le temps est écoulé');
    expect(trackFor('/', timeUp: true), MusicTrack.home);
  });

  test('la musique baisse pendant la narration, puis remonte', () async {
    final music = SilentMusicPlayer();
    final narrator = DuckingNarrator(SilentNarrator(instant: true), music);
    final playing = narrator.play('a.mp3', text: 'bonjour');
    expect(music.ducked, isTrue);
    await playing;
    expect(music.ducked, isFalse);
  });

  test('musique coupée par les parents : silence', () {
    var on = false;
    final inner = SilentMusicPlayer();
    final music = GatedMusicPlayer(inner, () => on);
    music.play(MusicTrack.map);
    expect(inner.current, isNull);
    on = true;
    music.play(MusicTrack.map);
    expect(inner.current, MusicTrack.map);
  });

  testWidgets('la musique suit les écrans : accueil, carte, histoire', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final music = SilentMusicPlayer();
    final state = GameState(MemorySaveStore());
    state.addProfile(name: 'Awa', age: AgeGroup.bergers, avatar: 'lion');
    await tester.pumpWidget(
      LumiereApp(
        trackPlaytime: false,
        narrator: SilentNarrator(instant: true),
        sfx: SilentSoundEffects(),
        music: music,
        gameState: state,
      ),
    );
    await frames(tester);
    expect(music.current, MusicTrack.home);

    GoRouter.of(tester.element(find.text('Jouer'))).go('/carte');
    await frames(tester);
    expect(music.current, MusicTrack.map);

    state.updateSettings(state.settings.copyWith(music: false));
    GoRouter.of(tester.element(find.byKey(const ValueKey('world-scroll')))).go('/histoire/creation');
    await frames(tester);
    expect(music.current, isNull, reason: 'musique coupée dans les réglages');
  });
}

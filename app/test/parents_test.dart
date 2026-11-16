import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiere/app.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/parents/play_time.dart';
import 'package:lumiere/save/game_state.dart';
import 'package:lumiere/save/save_data.dart';
import 'package:lumiere/save/save_store.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/story/story_part.dart';
import 'package:lumiere/widgets/parental_gate.dart';
import 'package:material_ui/material_ui.dart';

Future<void> frames(WidgetTester tester, [int count = 30]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Répond correctement à la barrière parentale affichée.
Future<void> passGate(WidgetTester tester) async {
  final gate = tester.state<ParentalGateState>(find.byType(ParentalGate));
  for (final digit in '${gate.a * gate.b}'.split('')) {
    await tester.tap(find.byKey(ValueKey('gate-$digit')));
    await tester.pump();
  }
  await tester.tap(find.text('Valider'));
  await frames(tester, 10);
}

void main() {
  setUp(rootBundle.clear);

  group('Réglages et temps de jeu (sauvegarde)', () {
    test('les réglages sont sauvegardés et relus', () async {
      final store = MemorySaveStore();
      final state = GameState(store);
      await state.load();
      state.updateSettings(
        state.settings.copyWith(narration: false, dailyLimit: 30, subtitles: SubtitleMode.never),
      );
      await Future<void>.delayed(Duration.zero);
      final again = GameState(MemorySaveStore(store.data));
      await again.load();
      expect(again.settings.narration, isFalse);
      expect(again.settings.dailyLimit, 30);
      expect(again.settings.subtitles, SubtitleMode.never);
    });

    test('une limite inconnue dans la sauvegarde est ignorée', () {
      expect(Settings.fromJson({'dailyLimit': 7}).dailyLimit, 0);
      expect(Settings.fromJson('n’importe quoi').narration, isTrue);
    });

    test('sous-titres : selon l’âge, toujours, jamais — et toujours sans la voix', () {
      const auto = Settings();
      expect(auto.subtitlesFor(AgeGroup.agneaux), isFalse);
      expect(auto.subtitlesFor(AgeGroup.bergers), isTrue);
      expect(const Settings(subtitles: SubtitleMode.always).subtitlesFor(AgeGroup.agneaux), isTrue);
      expect(const Settings(subtitles: SubtitleMode.never).subtitlesFor(AgeGroup.explorateurs), isFalse);
      expect(
        const Settings(subtitles: SubtitleMode.never, narration: false).subtitlesFor(AgeGroup.agneaux),
        isTrue,
      );
    });

    test('temps de jeu par jour, sur 7 jours, limite et temps offert', () async {
      var now = DateTime(2026, 11, 16, 10);
      final state = GameState(MemorySaveStore(), clock: () => now);
      await state.load();
      final awa = state.addProfile(name: 'Awa', age: AgeGroup.bergers, avatar: 'lion');
      expect(state.remainingToday, isNull, reason: 'pas de limite');

      state.addPlaytime(600);
      now = DateTime(2026, 11, 15, 18);
      state.addPlaytime(300);
      now = DateTime(2026, 11, 16, 11);
      expect(state.playtimeToday(awa.id), const Duration(minutes: 10));
      expect(state.playtimeWeek(awa.id), const Duration(minutes: 15));

      state.updateSettings(state.settings.copyWith(dailyLimit: 15));
      expect(state.remainingToday, const Duration(minutes: 5));
      state.addPlaytime(400);
      expect(state.timeIsUp, isTrue);
      state.grantExtraTime(15);
      expect(state.remainingToday, isNot(Duration.zero));

      // Le lendemain, tout recommence.
      now = DateTime(2026, 11, 17, 9);
      expect(state.playtimeToday(awa.id), Duration.zero);
      expect(state.remainingToday, const Duration(minutes: 15));
    });

    test('on ne garde que 14 jours de temps de jeu', () async {
      var now = DateTime(2026, 10, 1);
      final state = GameState(MemorySaveStore(), clock: () => now);
      state.addProfile(name: 'Awa', age: AgeGroup.bergers, avatar: 'lion');
      state.addPlaytime(60);
      now = DateTime(2026, 11, 16);
      state.addPlaytime(60);
      final json = state.toString();
      expect(json, isNotNull);
      expect(state.playtimeWeek(state.current!.id), const Duration(minutes: 1));
    });
  });

  group('Son coupé par les parents', () {
    test('narration et bruitages se taisent quand on les coupe', () async {
      var on = true;
      final inner = SilentNarrator(instant: true);
      final narrator = GatedNarrator(inner, () => on);
      await narrator.play('a.mp3', text: 'un');
      on = false;
      final silent = narrator.play('b.mp3', text: 'deux');
      await narrator.stop();
      await silent;
      expect(inner.played, ['a.mp3']);

      final sfxInner = SilentSoundEffects();
      final sfx = GatedSoundEffects(sfxInner, () => on);
      sfx.play(Sfx.pop);
      on = true;
      sfx.play(Sfx.star);
      expect(sfxInner.played, [Sfx.star]);
    });
  });

  Future<GameState> openApp(
    WidgetTester tester, {
    void Function(GameState)? setup,
    Size size = const Size(1280, 720),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = GameState(MemorySaveStore());
    state.addProfile(name: 'Awa', age: AgeGroup.bergers, avatar: 'lion');
    setup?.call(state);
    await tester.pumpWidget(
      LumiereApp(
        trackPlaytime: false,
        narrator: SilentNarrator(instant: true),
        sfx: SilentSoundEffects(),
        gameState: state,
      ),
    );
    await frames(tester, 10);
    return state;
  }

  testWidgets('espace parents : barrière, enfants, réglages, à propos', (tester) async {
    final state = await openApp(tester, setup: (s) => s.recordPart('creation', StoryPart.recit));
    await tester.tap(find.text('Parents'));
    await frames(tester, 20);
    expect(find.byType(ParentalGate), findsOneWidget);
    await passGate(tester);

    // Enfants : progression.
    expect(find.text('Les enfants'), findsOneWidget);
    expect(find.text('Awa'), findsOneWidget);
    expect(find.text('1 étoiles sur 40'), findsOneWidget);
    expect(find.bySemanticsLabel('La Création : 1 étoiles'), findsOneWidget);

    // Réglages.
    await tester.tap(find.byKey(const ValueKey('tab-settings')));
    await frames(tester, 6);
    await tester.tap(find.byKey(const ValueKey('set-narration')));
    await tester.tap(find.byKey(const ValueKey('choice-Temps de jeu par jour et par enfant-30')));
    await frames(tester, 4);
    expect(state.settings.narration, isFalse);
    expect(state.settings.dailyLimit, 30);

    // À propos : confidentialité.
    await tester.tap(find.byKey(const ValueKey('tab-about')));
    await frames(tester, 6);
    expect(find.text('Politique de confidentialité'), findsOneWidget);
    expect(find.textContaining('Lumière ne collecte aucune donnée'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Quitter l’espace parents'));
    await frames(tester, 20);
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('une mauvaise réponse ou la croix referment l’espace parents', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Parents'));
    await frames(tester, 20);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await frames(tester, 20);
    expect(find.text('Les enfants'), findsNothing);
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('l’espace parents tient sur un petit téléphone', (tester) async {
    await openApp(tester, size: const Size(640, 360));
    GoRouter.of(tester.element(find.text('Jouer'))).push('/parents');
    await frames(tester, 20);
    await passGate(tester);
    for (final tab in ['children', 'settings', 'about']) {
      await tester.tap(find.byKey(ValueKey('tab-$tab')));
      await frames(tester, 6);
      expect(tester.takeException(), isNull, reason: tab);
    }
  });

  testWidgets('textes plus grands et animations réduites passent par les réglages', (tester) async {
    late MediaQueryData media;
    final state = await openApp(
      tester,
      setup: (s) => s.updateSettings(s.settings.copyWith(largeText: true, reduceMotion: true)),
    );
    media = MediaQuery.of(tester.element(find.text('Jouer')));
    expect(media.disableAnimations, isTrue);
    expect(media.textScaler.scale(10), closeTo(12, 0.01));
    expect(state.settings.largeText, isTrue);
  });

  testWidgets('limite de temps : on compte sur la carte, pas à l’accueil ; « À demain » puis temps offert', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = GameState(MemorySaveStore());
    state.addProfile(name: 'Awa', age: AgeGroup.bergers, avatar: 'lion');
    state.updateSettings(state.settings.copyWith(dailyLimit: 15));
    await tester.pumpWidget(
      LumiereApp(
        trackPlaytime: false,
        narrator: SilentNarrator(instant: true),
        sfx: SilentSoundEffects(),
        gameState: state,
      ),
    );
    await frames(tester, 10);
    final keeper = tester.state<PlayTimeKeeperState>(find.byType(PlayTimeKeeper));

    // À l'accueil, le temps ne compte pas.
    keeper.onTick();
    expect(state.playtimeToday(state.current!.id), Duration.zero);

    GoRouter.of(tester.element(find.text('Jouer'))).go('/carte');
    await frames(tester, 20);
    for (var i = 0; i < 53; i++) {
      keeper.onTick();
    }
    await frames(tester, 4);
    expect(find.byKey(const ValueKey('time-soon')), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      keeper.onTick();
    }
    await frames(tester, 6);
    expect(state.timeIsUp, isTrue);
    expect(find.text('C’est l’heure de se reposer !'), findsOneWidget);

    // Un parent ajoute 15 minutes.
    await tester.tap(find.text('Parents').last);
    await frames(tester, 6);
    await passGate(tester);
    await tester.tap(find.byKey(const ValueKey('extra-15')));
    await frames(tester, 6);
    expect(state.timeIsUp, isFalse);
    expect(find.text('C’est l’heure de se reposer !'), findsNothing);
  });

  test('chemins comptés comme du jeu', () {
    expect(countsAsPlay('/carte'), isTrue);
    expect(countsAsPlay('/histoire/noe'), isTrue);
    expect(countsAsPlay('/'), isFalse);
    expect(countsAsPlay('/parents'), isFalse);
    expect(countsAsPlay('/profils'), isFalse);
  });
}

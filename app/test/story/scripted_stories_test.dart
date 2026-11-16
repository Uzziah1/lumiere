import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/stories/registry.dart';
import 'package:lumiere/story/scripted_stage.dart';
import 'package:lumiere/story/story_game.dart';

import '../helpers.dart';

/// Toutes les histoires faites de scènes scénarisées : chaque scène s'affiche,
/// montre où toucher (au-dessus des sous-titres) et se termine quand l'enfant
/// fait l'action.
void main() {
  final size = Vector2(1280, 720);

  for (final MapEntry(key: id, value: pack) in storyPacks.entries) {
    final story = loadStory(id);
    final scripted = story.scenes.where((s) => pack.stages[s.stage]!() is ScriptedStage).toList();
    if (scripted.isEmpty) continue;

    group('Histoire « $id »', () {
      for (final scene in scripted) {
        testWithGame<StoryGame>(
          'scène « ${scene.id} »',
          () => StoryGame(stages: pack.stages, sfx: SilentSoundEffects()),
          (game) async {
            game.onGameResize(size);
            await game.ready();
            game.showStage(scene.stage);
            await game.ready();
            for (var i = 0; i < 15; i++) {
              game.update(1 / 30);
            }
            final stage = game.stage! as ScriptedStage;
            for (final t in stage.script.targets) {
              expect(t.left, greaterThanOrEqualTo(0));
              expect(t.right, lessThanOrEqualTo(1));
              expect(t.bottom, lessThanOrEqualTo(0.85), reason: 'cible sous les sous-titres');
            }
            final hint = stage.hintTarget!;
            expect(hint.y, lessThanOrEqualTo(size.y * 0.85));
            expect(game.stageDone.value, isFalse);
            stage.autoplay();
            for (var i = 0; i < 90; i++) {
              game.update(1 / 30);
            }
            expect(game.stageDone.value, isTrue);
          },
        );
      }

      testWithGame<StoryGame>(
        'avec « réduire les animations », les scènes se terminent aussi',
        () => StoryGame(stages: pack.stages, reducedMotion: true, sfx: SilentSoundEffects()),
        (game) async {
          game.onGameResize(size);
          await game.ready();
          for (final scene in scripted) {
            game.showStage(scene.stage);
            await game.ready();
            game.update(0.1);
            (game.stage! as ScriptedStage).autoplay();
            game.update(0.1);
            expect(game.stageDone.value, isTrue, reason: scene.id);
          }
        },
      );
    });
  }

  testWithGame<StoryGame>(
    'toucher les cibles une à une, puis glisser',
    () {
      return StoryGame(
        stages: {
          'tap': () => ScriptedStage(
            StageScript(
              paint: (_, _, _) {},
              targets: const [Rect.fromLTRB(0, 0, 0.2, 0.2), Rect.fromLTRB(0.5, 0.5, 0.7, 0.7)],
            ),
          ),
          'swipe': () => ScriptedStage(StageScript(paint: (_, _, _) {}, interaction: Interaction.swipe)),
          'repeat': () => ScriptedStage(
            StageScript(
              paint: (_, _, _) {},
              interaction: Interaction.tapRepeat,
              taps: 3,
              targets: const [Rect.fromLTRB(0.4, 0.4, 0.6, 0.6)],
            ),
          ),
        },
        sfx: SilentSoundEffects(),
      );
    },
    (game) async {
      game.onGameResize(size);
      await game.ready();
      game.showStage('tap');
      await game.ready();
      final tap = game.stage! as ScriptedStage;
      expect(tap.hintTarget, Vector2(0.1 * size.x, 0.1 * size.y));
      tap.tapTarget(0);
      tap.tapTarget(0);
      expect(game.stageDone.value, isFalse);
      expect(tap.hintTarget, Vector2(0.6 * size.x, 0.6 * size.y));
      tap.tapTarget(1);
      expect(game.stageDone.value, isTrue);

      game.showStage('swipe');
      await game.ready();
      final swipe = game.stage! as ScriptedStage;
      swipe.advanceSwipe(0.5);
      expect(game.stageDone.value, isFalse);
      swipe.advanceSwipe(0.6);
      expect(game.stageDone.value, isTrue);

      game.showStage('repeat');
      await game.ready();
      final repeat = game.stage! as ScriptedStage;
      repeat.tapTarget(0);
      repeat.tapTarget(0);
      expect(game.stageDone.value, isFalse);
      repeat.tapTarget(0);
      expect(game.stageDone.value, isTrue);
    },
  );
}

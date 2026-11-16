import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/stories/noe/noe_stages.dart';
import 'package:lumiere/story/story_game.dart';

void main() {
  final size = Vector2(1280, 720);

  StoryGame newGame({bool reducedMotion = false}) =>
      StoryGame(stages: noeStages, reducedMotion: reducedMotion, sfx: SilentSoundEffects());

  Future<T> show<T extends StoryStage>(StoryGame game, String id) async {
    game.onGameResize(size);
    await game.ready();
    game.showStage(id);
    await game.ready();
    game.update(0.016);
    return game.stage! as T;
  }

  /// Fait avancer le temps de [seconds] secondes, image par image.
  void run(StoryGame game, double seconds) {
    for (var t = 0.0; t < seconds; t += 1 / 30) {
      game.update(1 / 30);
    }
  }

  testWithGame<StoryGame>('chaque décor s’affiche et propose un endroit où toucher', newGame, (game) async {
    game.onGameResize(size);
    await game.ready();
    for (final id in noeStages.keys) {
      game.showStage(id);
      await game.ready();
      run(game, 0.5);
      expect(game.stage!.hintTarget, isNotNull, reason: id);
      expect(game.stageDone.value, isFalse, reason: id);
      final hint = game.stage!.hintTarget!;
      expect(hint.x, inInclusiveRange(0, size.x), reason: id);
      expect(
        hint.y,
        inInclusiveRange(0, size.y * 0.85),
        reason: '$id : la cible doit rester au-dessus des sous-titres',
      );
    }
  });

  testWithGame<StoryGame>('1. saluer Noé termine la scène', newGame, (game) async {
    final stage = await show<VillageStage>(game, 'noah_village');
    stage.greetNoah();
    expect(game.stageDone.value, isTrue);
  });

  testWithGame<StoryGame>('2. toucher la lumière termine la scène', newGame, (game) async {
    final stage = await show<GodSpeaksStage>(game, 'god_speaks');
    stage.touchLight();
    expect(game.stageDone.value, isTrue);
  });

  testWithGame<StoryGame>('3. il faut cinq coups de marteau pour finir l’arche', newGame, (game) async {
    final stage = await show<BuildingStage>(game, 'building');
    for (var i = 0; i < 4; i++) {
      stage.hammer();
    }
    expect(game.stageDone.value, isFalse);
    stage.hammer();
    expect(stage.step, 5);
    expect(game.stageDone.value, isTrue);
  });

  testWithGame<StoryGame>('4. la scène se termine quand les quatre couples sont entrés', newGame, (
    game,
  ) async {
    final stage = await show<AnimalsStage>(game, 'animals');
    for (var i = 0; i < 3; i++) {
      stage.sendPair(i);
    }
    run(game, 4);
    expect(game.stageDone.value, isFalse);
    stage.sendPair(3);
    run(game, 4);
    expect(stage.pairs.every((p) => p.state == 2), isTrue);
    expect(game.stageDone.value, isTrue);
  });

  testWithGame<StoryGame>('5. bercer trois fois l’arche', newGame, (game) async {
    final stage = await show<RainStage>(game, 'rain');
    stage.rock();
    stage.rock();
    expect(game.stageDone.value, isFalse);
    stage.rock();
    expect(game.stageDone.value, isTrue);
  });

  testWithGame<StoryGame>('6. la colombe part puis revient avec le rameau', newGame, (game) async {
    final stage = await show<DoveStage>(game, 'dove');
    stage.openWindow();
    run(game, 2);
    expect(game.stageDone.value, isFalse);
    run(game, 5);
    expect(stage.phase, 4);
    expect(game.stageDone.value, isTrue);
  });

  testWithGame<StoryGame>(
    '6 bis. avec « réduire les animations », la colombe revient tout de suite',
    () => newGame(reducedMotion: true),
    (game) async {
      final stage = await show<DoveStage>(game, 'dove');
      stage.openWindow();
      run(game, 0.2);
      expect(game.stageDone.value, isTrue);
    },
  );

  testWithGame<StoryGame>('7. ouvrir la porte : tout le monde sort et s’éloigne de l’arche', newGame, (
    game,
  ) async {
    final stage = await show<ExitStage>(game, 'exit');
    stage.openDoor();
    expect(game.stageDone.value, isTrue);
    run(game, 3);
    // Une nouvelle mise en page à la même taille ne doit rien remettre à zéro.
    game.onGameResize(size);
    run(game, 10);
    for (final w in stage.walkers) {
      expect(w.x, closeTo(size.x * w.target, 1));
    }
  });

  testWithGame<StoryGame>('8. dessiner l’arc-en-ciel du doigt (ou en touchant)', newGame, (game) async {
    final stage = await show<RainbowStage>(game, 'rainbow');
    stage.addRainbow(0.5);
    expect(game.stageDone.value, isFalse);
    for (var i = 0; i < 3; i++) {
      stage.addRainbow(0.2);
    }
    expect(stage.progress, 1);
    expect(game.stageDone.value, isTrue);
  });

  testWithGame<StoryGame>('l’indice doré s’affiche puis disparaît quand la scène est réussie', newGame, (
    game,
  ) async {
    final stage = await show<VillageStage>(game, 'noah_village');
    game.hintVisible = true;
    final ring = game.children.whereType<HintRing>().single;
    expect(ring.target, isNotNull);
    stage.greetNoah();
    expect(ring.target, isNull);
  });

  testWithGame<StoryGame>('un décor inconnu est refusé', newGame, (game) async {
    game.onGameResize(size);
    await game.ready();
    expect(() => game.showStage('inconnu'), throwsArgumentError);
  });
}

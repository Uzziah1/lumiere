import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/home/home_scene.dart';

void main() {
  final size = Vector2(1280, 720);

  testWithGame<HomeScene>(
    'la scène contient le ciel, le soleil, 3 nuages, 4 collines, la poussière et Colombe',
    HomeScene.new,
    (game) async {
      game.onGameResize(size);
      await game.ready();

      expect(game.children.whereType<SkyComponent>(), hasLength(1));
      expect(game.children.whereType<SunComponent>(), hasLength(1));
      expect(game.children.whereType<CloudComponent>(), hasLength(3));
      expect(game.children.whereType<HillLayer>(), hasLength(4));
      expect(game.children.whereType<DustField>().single.moteCount, 42);
      expect(game.children.whereType<GrainOverlay>(), hasLength(1));
      expect(game.colombe.isMounted, isTrue);
    },
  );

  testWithGame<HomeScene>('Colombe vole et les nuages dérivent', HomeScene.new, (game) async {
    game.onGameResize(size);
    await game.ready();
    final start = game.colombe.position.clone();
    final cloud = game.children.whereType<CloudComponent>().first;
    final cloudStart = cloud.x;

    game.update(1.0);

    expect(game.colombe.position, isNot(start));
    expect(cloud.x, greaterThan(cloudStart));
  });

  testWithGame<HomeScene>('un nuage sorti à droite revient par la gauche', HomeScene.new, (game) async {
    game.onGameResize(size);
    await game.ready();
    final cloud = game.children.whereType<CloudComponent>().first;
    for (var i = 0; i < 400; i++) {
      game.update(0.5);
    }
    expect(cloud.x, lessThan(size.x * 1.2));
  });

  testWithGame<HomeScene>(
    'avec « réduire les animations », la scène reste immobile',
    () => HomeScene(reducedMotion: true),
    (game) async {
      game.onGameResize(size);
      await game.ready();
      final start = game.colombe.position.clone();

      game.update(1.0);

      expect(game.colombe.position, start);
    },
  );

  testWithGame<HomeScene>('Colombe heureuse : elle saute et lance des étincelles', HomeScene.new, (
    game,
  ) async {
    game.onGameResize(size);
    await game.ready();

    game.colombe.celebrate();
    await game.ready();

    expect(game.colombe.happyCount, 1);
    expect(game.children.whereType<SparkleBurst>(), hasLength(1));

    // Les étincelles disparaissent seules.
    game.update(SparkleBurst.lifetime + 0.1);
    game.update(0);
    await game.ready();
    expect(game.children.whereType<SparkleBurst>(), isEmpty);
  });

  testWithGame<HomeScene>('la scène suit le changement de taille de l’écran', HomeScene.new, (game) async {
    game.onGameResize(size);
    await game.ready();
    game.onGameResize(Vector2(400, 800));
    game.update(0.016);

    final hill = game.children.whereType<HillLayer>().first.hill!;
    expect(hill.size.width, 400);
    expect(game.colombe.size.y, lessThanOrEqualTo(800 * 0.24));
  });

  testWidgets("toucher Colombe à l'écran la rend heureuse", (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final game = HomeScene();
    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final c = game.colombe.absoluteCenter;
    await tester.tapAt(Offset(c.x, c.y));
    await tester.pump(const Duration(milliseconds: 16));

    expect(game.colombe.happyCount, 1);
    // Laisse expirer le minuteur d'appui long du gestionnaire de touchers.
    await tester.pump(const Duration(seconds: 1));
  });
}

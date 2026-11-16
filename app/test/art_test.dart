import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/art/colombe.dart';
import 'package:lumiere/art/landscape.dart';
import 'package:lumiere/art/paper.dart';

void main() {
  Canvas newCanvas() => Canvas(PictureRecorder());

  group('Colombe', () {
    test('se dessine à toutes les étapes du battement et du clignement', () {
      for (final flap in [0.0, 0.25, 0.5, 1.0]) {
        for (final blink in [0.0, 0.5, 1.0]) {
          Colombe.paint(newCanvas(), const Size(125, 100), flap: flap, blink: blink, withBranch: true);
          Colombe.paint(newCanvas(), const Size(125, 100), flap: flap, blink: blink, facingLeft: true);
        }
      }
    });

    test('ne dessine rien dans une taille vide', () {
      Colombe.paint(newCanvas(), Size.zero);
    });

    test('le peintre ne redessine que si ses réglages changent', () {
      final a = ColombePainter(withBranch: true);
      expect(a.shouldRepaint(ColombePainter(withBranch: true)), isFalse);
      expect(a.shouldRepaint(ColombePainter(withBranch: false)), isTrue);
      expect(a.shouldRepaint(ColombePainter(withBranch: true, facingLeft: true)), isTrue);
    });
  });

  group('Paysage', () {
    test('une colline est déterministe : même graine, même crête', () {
      const size = Size(800, 400);
      final a = Hill(size: size, baseline: 280, amplitude: 30, seed: 4);
      final b = Hill(size: size, baseline: 280, amplitude: 30, seed: 4);
      final c = Hill(size: size, baseline: 280, amplitude: 30, seed: 5);
      expect(a.heightAt(123), b.heightAt(123));
      expect(a.heightAt(123), isNot(c.heightAt(123)));
    });

    test("la crête reste dans l'amplitude prévue et la colline couvre tout l'écran", () {
      const size = Size(800, 400);
      final hill = Hill(size: size, baseline: 280, amplitude: 30, seed: 4);
      for (var x = 0.0; x <= size.width; x += 10) {
        expect(hill.heightAt(x), inInclusiveRange(250, 310));
      }
      final bounds = hill.path.getBounds();
      expect(bounds.left, lessThanOrEqualTo(0));
      expect(bounds.right, greaterThanOrEqualTo(size.width));
      expect(bounds.bottom, greaterThanOrEqualTo(size.height));
    });

    test('palmier, maison et nuage ont la taille demandée', () {
      final palm = palmPath(const Offset(100, 300), 120).getBounds();
      expect(palm.bottom, closeTo(300, 1));
      expect(palm.height, inInclusiveRange(110, 150));

      final house = housePath(const Offset(200, 300), 40, 34).getBounds();
      expect(house.width, closeTo(40, 0.01));
      expect(house.top, closeTo(266, 0.01));

      final cloud = cloudPath(Offset.zero, 100).getBounds();
      expect(cloud.width, inInclusiveRange(95, 110));
    });
  });

  test('le grain de papier se dessine et se libère', () {
    final grain = PaperGrain();
    grain.paint(newCanvas(), const Size(200, 100));
    grain.paint(newCanvas(), const Size(300, 100));
    grain.paint(newCanvas(), Size.zero);
    grain.dispose();
  });
}

import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../art/animals.dart';
import '../art/colombe.dart';
import '../audio/audio.dart';
import '../story/age_group.dart';
import '../story/story_session.dart';
import '../theme/palette.dart';

/// Memory : retrouver les couples d'animaux. Les plus petits voient d'abord
/// toutes les cartes quelques secondes.
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key, required this.complete, required this.say, this.seed});

  final VoidCallback complete;
  final void Function(String key) say;
  final int? seed;

  @override
  State<MemoryGame> createState() => MemoryGameState();
}

class MemoryGameState extends State<MemoryGame> {
  late List<Animal> cards;
  final matched = <int>{};
  final revealed = <int>[];
  bool preview = true;
  bool _busy = false;
  Timer? _timer;

  static const _previewTime = {
    AgeGroup.agneaux: Duration(milliseconds: 2500),
    AgeGroup.bergers: Duration(milliseconds: 1300),
    AgeGroup.explorateurs: Duration.zero,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timer != null || matched.isNotEmpty) return;
    final session = StorySession.of(context);
    final pairs = session.story.memory.pairsFor(session.age).map(Animal.byName);
    cards = [...pairs, ...pairs]..shuffle(math.Random(widget.seed));
    final wait = _previewTime[session.age]!;
    if (wait == Duration.zero) {
      preview = false;
      _timer = Timer(Duration.zero, () {});
    } else {
      _timer = Timer(wait, () {
        if (mounted) setState(() => preview = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool isFaceUp(int i) => preview || matched.contains(i) || revealed.contains(i);

  void flip(int i) {
    if (preview || _busy || isFaceUp(i)) return;
    final session = StorySession.of(context);
    session.sfx.play(Sfx.flip);
    setState(() => revealed.add(i));
    if (revealed.length < 2) return;
    final a = revealed[0];
    final b = revealed[1];
    if (cards[a] == cards[b]) {
      session.sfx.play(Sfx.chime);
      setState(() {
        matched.addAll([a, b]);
        revealed.clear();
      });
      if (matched.length == cards.length) {
        widget.complete();
      } else {
        widget.say('pair');
      }
    } else {
      _busy = true;
      _timer = Timer(const Duration(milliseconds: 950), () {
        if (!mounted) return;
        setState(() {
          revealed.clear();
          _busy = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = cards.length;
        // Le nombre de colonnes qui donne les plus grandes cartes.
        var best = (cols: n, side: 0.0);
        for (var cols = 2; cols <= n; cols++) {
          final rows = (n / cols).ceil();
          final side = math.min(
            (constraints.maxWidth - 12 * cols) / cols,
            (constraints.maxHeight - 12 * rows) / rows / 1.2,
          );
          if (side > best.side) best = (cols: cols, side: side);
        }
        final w = best.side;
        final h = w * 1.2;
        return Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < n; i++)
                SizedBox(
                  width: w,
                  height: h,
                  child: Semantics(
                    button: true,
                    label: isFaceUp(i) ? cards[i].label : 'Carte cachée',
                    child: GestureDetector(
                      key: ValueKey('memory-$i'),
                      onTap: () => flip(i),
                      child: _FlipCard(faceUp: isFaceUp(i), matched: matched.contains(i), animal: cards[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.faceUp, required this.matched, required this.animal});

  final bool faceUp;
  final bool matched;
  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: faceUp ? 1 : 0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        final showFront = t >= 0.5;
        final angle = t * math.pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(showFront ? angle - math.pi : angle),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                const BoxShadow(color: Palette.shadow, blurRadius: 10, offset: Offset(0, 5)),
                if (matched)
                  BoxShadow(color: Palette.gold.withValues(alpha: 0.8), blurRadius: 14, spreadRadius: 2),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: showFront ? _FrontPainter(animal) : _BackPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FrontPainter extends CustomPainter {
  _FrontPainter(this.animal);

  final Animal animal;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.cream, Color(0xFFF6E3C4)],
        ).createShader(Offset.zero & size),
    );
    final pad = size.width * 0.12;
    paintAnimal(canvas, animal, Rect.fromLTRB(pad, pad, size.width - pad, size.height - pad));
  }

  @override
  bool shouldRepaint(_FrontPainter oldDelegate) => oldDelegate.animal != animal;
}

class _BackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Palette.lagoon, Palette.lagoonDeep],
        ).createShader(Offset.zero & size),
    );
    final dot = Paint()..color = const Color(0x22FFFFFF);
    for (var y = size.width * 0.1; y < size.height; y += size.width * 0.2) {
      for (var x = size.width * 0.1; x < size.width; x += size.width * 0.2) {
        canvas.drawCircle(Offset(x, y), size.width * 0.03, dot);
      }
    }
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.3, Paint()..color = const Color(0x33FFF6DC));
    final h = size.width * 0.42;
    canvas.save();
    canvas.translate(size.width / 2 - h * Colombe.aspectRatio / 2, size.height / 2 - h / 2);
    Colombe.paint(canvas, Size(h * Colombe.aspectRatio, h), flap: 0.8);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BackPainter oldDelegate) => false;
}

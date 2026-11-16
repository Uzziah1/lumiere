import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../audio/audio.dart';
import '../story/story.dart';
import '../story/story_session.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import 'game_frame.dart';

/// Remettre les images de l'histoire dans l'ordre : on touche les images, la
/// bonne file à sa place. Une erreur fait trembler l'image et Colombe aide.
class ChronologyGame extends StatefulWidget {
  const ChronologyGame({super.key, required this.complete, required this.say, this.seed});

  final VoidCallback complete;
  final void Function(String key) say;

  /// Graine du mélange (pour les tests).
  final int? seed;

  @override
  State<ChronologyGame> createState() => ChronologyGameState();
}

class ChronologyGameState extends State<ChronologyGame> with TickerProviderStateMixin {
  late List<ChronologyCard> _order;
  late List<ChronologyCard> _shuffled;
  final placed = <ChronologyCard>[];
  int _mistakes = 0;
  String? _shaking;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = StorySession.of(context);
    _order = session.story.chronology.cardsFor(session.age);
    _shuffled = [..._order]..shuffle(math.Random(widget.seed));
    // Jamais déjà dans l'ordre.
    if (_shuffled.length > 1 &&
        List.generate(_order.length, (i) => _order[i] == _shuffled[i]).every((e) => e)) {
      _shuffled = [..._shuffled.skip(1), _shuffled.first];
    }
  }

  /// Les images à placer, dans l'ordre de l'histoire (pour les tests).
  @visibleForTesting
  List<ChronologyCard> get debugCards => _order;

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void pick(ChronologyCard card) {
    if (placed.contains(card) || placed.length == _order.length) return;
    final sfx = StorySession.of(context).sfx;
    if (card == _order[placed.length]) {
      sfx.play(Sfx.pop);
      setState(() {
        placed.add(card);
        _mistakes = 0;
      });
      if (placed.length == _order.length) {
        widget.complete();
      } else if (placed.length == 1) {
        widget.say('super');
      }
    } else {
      sfx.play(Sfx.wrong);
      setState(() {
        _mistakes++;
        _shaking = card.id;
      });
      _shake.forward(from: 0);
      widget.say(_mistakes >= 2 ? 'look' : 'before');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = StorySession.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = _order.length;
        final gap = 14.0;
        final cardW = math.min(
          (constraints.maxWidth - gap * (n + 1)) / n,
          constraints.maxHeight * 0.36 * 4 / 3,
        );
        final cardH = cardW * 3 / 4;
        final label = math.max(12.0, cardW * 0.085);
        final hint = _mistakes >= 2 ? _order[placed.length] : null;

        Widget thumb(ChronologyCard card) => SizedBox(
          width: cardW,
          height: cardH,
          child: CustomPaint(painter: _ThumbPainter(session, card.id)),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Les cases numérotées, dans l'ordre de l'histoire.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < n; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gap / 2),
                    child: Column(
                      children: [
                        SizedBox(
                          width: cardW,
                          height: cardH,
                          child: i < placed.length
                              ? PaperCard(child: thumb(placed[i]))
                              : DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0x22B07A4F),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0x66B07A4F), width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: LumiereText.title(cardH * 0.4, color: const Color(0x88B07A4F)),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: cardW,
                          child: Text(
                            i < placed.length ? placed[i].label : ' ',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LumiereText.text(label, bold: true, color: Palette.inkSoft),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // Les images à placer.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final card in _shuffled)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gap / 2),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: placed.contains(card) ? 0 : 1,
                      child: Semantics(
                        button: true,
                        label: card.label,
                        child: GestureDetector(
                          key: ValueKey('chrono-${card.id}'),
                          onTap: () => pick(card),
                          child: Shake(
                            animation: _shaking == card.id ? _shake : const AlwaysStoppedAnimation(0),
                            child: PaperCard(glow: hint == card, child: thumb(card)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter(this.session, this.id);

  final StorySession session;
  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    session.pack.paintThumb(canvas, size, id);
  }

  @override
  bool shouldRepaint(_ThumbPainter oldDelegate) => oldDelegate.id != id;
}

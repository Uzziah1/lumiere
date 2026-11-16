import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../audio/audio.dart';
import '../story/age_group.dart';
import '../story/story_session.dart';
import '../theme/palette.dart';

/// Le puzzle : une scène de l'histoire découpée en pièces mélangées. On touche
/// deux pièces pour les échanger, jusqu'à retrouver l'image.
class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key, required this.complete, required this.say, this.seed});

  final VoidCallback complete;
  final void Function(String key) say;
  final int? seed;

  /// Colonnes et lignes selon l'âge : 4, 6 ou 9 pièces.
  static (int, int) gridFor(AgeGroup age) => switch (age) {
    AgeGroup.agneaux => (2, 2),
    AgeGroup.bergers => (3, 2),
    AgeGroup.explorateurs => (3, 3),
  };

  @override
  State<PuzzleGame> createState() => PuzzleGameState();
}

class PuzzleGameState extends State<PuzzleGame> {
  /// `slots[i]` : la pièce posée à la place `i` (la pièce `i` va à la place `i`).
  late List<int> slots;
  int? selected;
  bool _done = false;
  int cols = 2;
  int rows = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final (c, r) = PuzzleGame.gridFor(StorySession.of(context).age);
    cols = c;
    rows = r;
    final random = math.Random(widget.seed);
    final n = cols * rows;
    do {
      slots = List.generate(n, (i) => i)..shuffle(random);
      // Au moins la moitié des pièces sont mal placées, jamais déjà résolu.
    } while (_correct() > n ~/ 2);
  }

  bool _initialized = false;

  int _correct() => [for (var i = 0; i < slots.length; i++) slots[i] == i].where((ok) => ok).length;

  bool get solved => _correct() == slots.length;

  void tap(int slot) {
    if (_done) return;
    final session = StorySession.of(context);
    if (slots[slot] == slot) {
      // Pièce déjà bien placée : elle ne bouge plus.
      session.sfx.play(Sfx.tap);
      return;
    }
    if (selected == null) {
      session.sfx.play(Sfx.tap);
      setState(() => selected = slot);
      return;
    }
    if (selected == slot) {
      setState(() => selected = null);
      return;
    }
    final a = selected!;
    final before = _correct();
    setState(() {
      final piece = slots[a];
      slots[a] = slots[slot];
      slots[slot] = piece;
      selected = null;
    });
    final gained = _correct() > before;
    session.sfx.play(gained ? Sfx.chime : Sfx.pop);
    if (solved) {
      _done = true;
      widget.complete();
    } else if (gained && _correct() == slots.length - 2) {
      widget.say('super');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = StorySession.of(context);
    final scene = session.pack.puzzleScene ?? session.story.chronology.cards.last.id;
    final animate = !MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Le modèle à gauche (petit), le plateau au format 16:9 de la scène.
        final modelW = constraints.maxWidth * 0.2;
        final w = math.min(constraints.maxWidth - modelW - 16, constraints.maxHeight * 16 / 9);
        final h = w * 9 / 16;
        final cw = w / cols;
        final ch = h / rows;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Le modèle',
              excludeSemantics: true,
              child: Container(
                width: modelW,
                height: modelW * 9 / 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Palette.cream, width: 3),
                  boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 8, offset: Offset(0, 3))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: _PiecePainter(0, 1, 1, Size(modelW, modelW * 9 / 16), (canvas, size) {
                      session.pack.paintThumb(canvas, size, scene);
                    }),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2C9A6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  for (var slot = 0; slot < slots.length; slot++)
                    AnimatedPositioned(
                      key: ValueKey('piece-${slots[slot]}'),
                      duration: animate ? const Duration(milliseconds: 260) : Duration.zero,
                      curve: Curves.easeOutBack,
                      left: (slot % cols) * cw,
                      top: (slot ~/ cols) * ch,
                      width: cw,
                      height: ch,
                      child: Semantics(
                        button: true,
                        label: slots[slot] == slot
                            ? 'Pièce ${slot + 1}, bien placée'
                            : 'Pièce ${slot + 1}${selected == slot ? ', choisie' : ''}',
                        excludeSemantics: true,
                        child: GestureDetector(
                          key: ValueKey('puzzle-$slot'),
                          onTap: () => tap(slot),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: _Piece(
                              piece: slots[slot],
                              cols: cols,
                              rows: rows,
                              board: Size(w, h),
                              selected: selected == slot,
                              placed: slots[slot] == slot,
                              paint: (canvas, size) => session.pack.paintThumb(canvas, size, scene),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Piece extends StatelessWidget {
  const _Piece({
    required this.piece,
    required this.cols,
    required this.rows,
    required this.board,
    required this.selected,
    required this.placed,
    required this.paint,
  });

  final int piece;
  final int cols;
  final int rows;
  final Size board;
  final bool selected;
  final bool placed;
  final void Function(Canvas canvas, Size size) paint;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 0.92 : 1,
      duration: const Duration(milliseconds: 150),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Palette.gold
                : placed
                ? const Color(0xAAFFFFFF)
                : const Color(0x66FFFFFF),
            width: selected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(color: Palette.shadow, blurRadius: selected ? 14 : 6, offset: const Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CustomPaint(
            painter: _PiecePainter(piece, cols, rows, board, paint),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  _PiecePainter(this.piece, this.cols, this.rows, this.board, this.paintScene);

  final int piece;
  final int cols;
  final int rows;
  final Size board;
  final void Function(Canvas canvas, Size size) paintScene;

  @override
  void paint(Canvas canvas, Size size) {
    // On dessine toute la scène, décalée pour ne montrer que le morceau de cette pièce.
    final sx = size.width / (board.width / cols);
    final sy = size.height / (board.height / rows);
    canvas.save();
    canvas.scale(sx, sy);
    canvas.translate(-(piece % cols) * board.width / cols, -(piece ~/ cols) * board.height / rows);
    paintScene(canvas, board);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PiecePainter oldDelegate) => oldDelegate.piece != piece || oldDelegate.board != board;
}

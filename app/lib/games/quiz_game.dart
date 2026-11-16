import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../art/objects.dart';
import '../audio/audio.dart';
import '../story/story.dart';
import '../story/story_session.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';

/// Le quiz illustré : Colombe pose une question, l'enfant touche la bonne image.
/// Une erreur n'enlève rien : l'image s'efface et on essaie encore.
class QuizGame extends StatefulWidget {
  const QuizGame({super.key, required this.complete, required this.say, this.seed});

  final VoidCallback complete;
  final void Function(String key) say;
  final int? seed;

  @override
  State<QuizGame> createState() => QuizGameState();
}

class QuizGameState extends State<QuizGame> {
  late List<QuizQuestion> questions;
  late List<List<String>> choices;
  int index = 0;
  final wrong = <String>{};
  bool answered = false;
  Timer? _next;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final session = StorySession.of(context);
    questions = session.story.quiz!.questionsFor(session.age);
    final random = math.Random(widget.seed);
    choices = [
      for (final q in questions) [...q.choices]..shuffle(random),
    ];
  }

  @override
  void dispose() {
    _next?.cancel();
    super.dispose();
  }

  QuizQuestion get question => questions[index];

  void choose(String id) {
    if (answered || wrong.contains(id)) return;
    final session = StorySession.of(context);
    if (id != question.answer) {
      session.sfx.play(Sfx.wrong);
      setState(() => wrong.add(id));
      widget.say('again');
      return;
    }
    session.sfx.play(Sfx.chime);
    setState(() => answered = true);
    if (index == questions.length - 1) {
      widget.complete();
      return;
    }
    widget.say('super');
    _next = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        index++;
        wrong.clear();
        answered = false;
      });
      widget.say(question.key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = StorySession.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 300;
        final options = choices[index];
        final side = math.min(
          (constraints.maxWidth - 24 * (options.length + 1)) / options.length,
          constraints.maxHeight * (compact ? 0.62 : 0.66),
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Question ${index + 1} sur ${questions.length}',
              excludeSemantics: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < questions.length; i++)
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < index || (i == index && answered) ? Palette.gold : const Color(0xFFE8D9C6),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: compact ? 8 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final id in options)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Semantics(
                      button: true,
                      label: thingLabel(id),
                      excludeSemantics: true,
                      child: GestureDetector(
                        key: ValueKey('quiz-$id'),
                        onTap: () => choose(id),
                        child: AnimatedOpacity(
                          opacity: wrong.contains(id) ? 0.3 : 1,
                          duration: const Duration(milliseconds: 250),
                          child: _Choice(
                            id: id,
                            side: side,
                            good: answered && id == question.answer,
                            paintItem: session.pack.paintItem,
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

class _Choice extends StatelessWidget {
  const _Choice({required this.id, required this.side, required this.good, required this.paintItem});

  final String id;
  final double side;
  final bool good;
  final void Function(Canvas canvas, String id, Rect box) paintItem;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: good ? 1.08 : 1,
      duration: const Duration(milliseconds: 250),
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          color: Palette.cream,
          borderRadius: BorderRadius.circular(22),
          border: const Border(bottom: BorderSide(color: Color(0xFFE2C9A6), width: 5)),
          boxShadow: [
            const BoxShadow(color: Palette.shadow, blurRadius: 10, offset: Offset(0, 5)),
            if (good) BoxShadow(color: Palette.gold.withValues(alpha: 0.8), blurRadius: 18, spreadRadius: 3),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(side * 0.1),
                child: CustomPaint(painter: _ItemPainter(id, paintItem), child: const SizedBox.expand()),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: side * 0.06),
              child: Text(
                thingLabel(id),
                style: LumiereText.title(math.max(13, side * 0.1)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPainter extends CustomPainter {
  _ItemPainter(this.id, this.paintItem);

  final String id;
  final void Function(Canvas canvas, String id, Rect box) paintItem;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    paintItem(canvas, id, Rect.fromCenter(center: size.center(Offset.zero), width: s, height: s));
  }

  @override
  bool shouldRepaint(_ItemPainter oldDelegate) => oldDelegate.id != id;
}

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../art/weather.dart';
import '../audio/audio.dart';
import '../story/age_group.dart';
import '../story/story_session.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import 'game_frame.dart';

/// Le verset à retenir.
///
/// Agneaux : on touche les couleurs de l'arc-en-ciel, puis on écoute le verset.
/// Bergers : on remet les morceaux du verset dans l'ordre.
/// Explorateurs : pareil, puis on retrouve la référence dans la Bible.
class VerseGame extends StatefulWidget {
  const VerseGame({super.key, required this.complete, required this.say, this.seed});

  final VoidCallback complete;
  final void Function(String key) say;
  final int? seed;

  @override
  State<VerseGame> createState() => VerseGameState();
}

enum VerseStep { build, reading, reference, done }

class VerseGameState extends State<VerseGame> with SingleTickerProviderStateMixin {
  late AgeGroup _age;
  late List<String> _chunks;
  late List<int> _shuffled;
  final placed = <int>[];
  int bands = 0;
  VerseStep step = VerseStep.build;
  late List<String> _choices;
  int? _shaking;
  String? _wrongChoice;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  static const bandCount = 7;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (placed.isNotEmpty || bands > 0) return;
    final session = StorySession.of(context);
    _age = session.age;
    _chunks = session.story.verse.chunks[_age] ?? const [];
    final random = math.Random(widget.seed);
    _shuffled = List.generate(_chunks.length, (i) => i)..shuffle(random);
    if (_shuffled.length > 1 && List.generate(_shuffled.length, (i) => _shuffled[i] == i).every((e) => e)) {
      _shuffled = [..._shuffled.skip(1), _shuffled.first];
    }
    _choices = [...session.story.verse.referenceChoices]..shuffle(random);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  /// Agneaux : colorie la bande suivante de l'arc-en-ciel.
  void colorBand() {
    if (step != VerseStep.build || _age != AgeGroup.agneaux) return;
    StorySession.of(context).sfx.play(Sfx.pop);
    setState(() => bands++);
    if (bands >= bandCount) _read();
  }

  void pickChunk(int index) {
    if (step != VerseStep.build || placed.contains(index)) return;
    final sfx = StorySession.of(context).sfx;
    if (index == placed.length) {
      sfx.play(Sfx.pop);
      setState(() => placed.add(index));
      if (placed.length == _chunks.length) _read();
    } else {
      sfx.play(Sfx.wrong);
      setState(() => _shaking = index);
      _shake.forward(from: 0);
      widget.say('again');
    }
  }

  Future<void> _read() async {
    setState(() => step = VerseStep.reading);
    final session = StorySession.of(context);
    await session.say('verse.reading');
    if (!mounted) return;
    if (_age == AgeGroup.explorateurs) {
      setState(() => step = VerseStep.reference);
      widget.say('reference');
    } else {
      _finish();
    }
  }

  void chooseReference(String reference) {
    if (step != VerseStep.reference) return;
    final session = StorySession.of(context);
    if (reference == session.story.verse.reference) {
      session.sfx.play(Sfx.chime);
      _finish();
    } else {
      session.sfx.play(Sfx.wrong);
      setState(() => _wrongChoice = reference);
      widget.say('again');
    }
  }

  void _finish() {
    setState(() => step = VerseStep.done);
    widget.complete();
  }

  @override
  Widget build(BuildContext context) {
    final verse = StorySession.of(context).story.verse;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 300;
        final showVerse = step != VerseStep.build;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_age == AgeGroup.agneaux)
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('verse-rainbow'),
                  behavior: HitTestBehavior.opaque,
                  onTap: colorBand,
                  child: Semantics(
                    button: true,
                    label: 'Arc-en-ciel à colorier',
                    child: CustomPaint(painter: _RainbowPainter(bands), child: const SizedBox.expand()),
                  ),
                ),
              )
            else
              _VerseLine(chunks: _chunks, placed: placed, compact: compact),
            if (showVerse || _age == AgeGroup.agneaux)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: showVerse ? 1 : 0,
                child: _VerseCard(
                  text: verse.text,
                  reference: step == VerseStep.reference ? '?' : verse.reference,
                ),
              ),
            if (_age != AgeGroup.agneaux && step == VerseStep.build)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final i in _shuffled)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: placed.contains(i) ? 0.0 : 1,
                      child: Shake(
                        animation: _shaking == i ? _shake : const AlwaysStoppedAnimation(0),
                        child: _Chunk(
                          key: ValueKey('chunk-$i'),
                          text: _chunks[i],
                          compact: compact,
                          onTap: () => pickChunk(i),
                        ),
                      ),
                    ),
                ],
              ),
            if (step == VerseStep.reference)
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final c in _choices)
                    _Chunk(
                      key: ValueKey('ref-$c'),
                      text: c,
                      compact: compact,
                      color: c == _wrongChoice ? const Color(0xFFE8D9C6) : Palette.gold,
                      onTap: () => chooseReference(c),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _VerseLine extends StatelessWidget {
  const _VerseLine({required this.chunks, required this.placed, required this.compact});

  final List<String> chunks;
  final List<int> placed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < chunks.length; i++)
          i < placed.length
              ? Text(chunks[i], style: LumiereText.title(compact ? 18 : 24, weight: 500))
              : Container(
                  width: (compact ? 7.0 : 9.0) * chunks[i].length.clamp(4, 22),
                  height: compact ? 26 : 34,
                  decoration: BoxDecoration(
                    border: const Border(bottom: BorderSide(color: Color(0x88B07A4F), width: 3)),
                    color: const Color(0x14B07A4F),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
      ],
    );
  }
}

class _Chunk extends StatelessWidget {
  const _Chunk({
    super.key,
    required this.text,
    required this.onTap,
    required this.compact,
    this.color = Palette.cream,
  });

  final String text;
  final VoidCallback onTap;
  final bool compact;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: text,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 8 : 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: const Border(bottom: BorderSide(color: Color(0xFFE2C9A6), width: 4)),
            boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Text(text, style: LumiereText.title(compact ? 16 : 20, weight: 500)),
        ),
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({required this.text, required this.reference});

  final String text;
  final String reference;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: PaperCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('« $text »', textAlign: TextAlign.center, style: LumiereText.text(19)),
              const SizedBox(height: 6),
              Text(reference, style: LumiereText.title(18, color: Palette.lagoonDeep)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RainbowPainter extends CustomPainter {
  _RainbowPainter(this.bands);

  final int bands;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width * 0.42, size.height * 0.92);
    paintRainbow(canvas, Offset(size.width / 2, size.height * 0.98), r, r * 0.42, progress: 1, bands: bands);
  }

  @override
  bool shouldRepaint(_RainbowPainter oldDelegate) => oldDelegate.bands != bands;
}

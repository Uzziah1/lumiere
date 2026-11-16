import 'package:material_ui/material_ui.dart';

import '../art/animals.dart';
import '../art/people.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/colombe_bubble.dart';
import '../widgets/round_button.dart';
import 'age_group.dart';
import 'story.dart';

/// Début d'une histoire : titre, référence et choix de l'âge.
///
/// (Avec les profils, à l'étape L2, l'âge viendra du profil de l'enfant.)
class StoryIntro extends StatelessWidget {
  const StoryIntro({
    super.key,
    required this.story,
    required this.paintSticker,
    required this.onStart,
    required this.onExit,
  });

  final Story story;
  final void Function(Canvas canvas, Size size) paintSticker;
  final void Function(AgeGroup age) onStart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 420;
          final cardW = ((constraints.maxWidth - 80) / 3).clamp(120.0, 220.0);
          return Stack(
            children: [
              Positioned(
                left: 12,
                top: 8,
                child: RoundPaperButton(
                  icon: Icons.close_rounded,
                  label: 'Retour à l’accueil',
                  size: compact ? 44 : 54,
                  onPressed: onExit,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: compact ? 70 : 110,
                            height: compact ? 70 : 110,
                            child: CustomPaint(painter: _StickerPainter(paintSticker)),
                          ),
                          const SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(story.title, style: LumiereText.title(compact ? 32 : 46)),
                              Text(
                                story.reference,
                                style: LumiereText.title(
                                  compact ? 17 : 22,
                                  weight: 500,
                                  color: Palette.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 8 : 20),
                      ColombeBubble(
                        text: 'Bonjour ! Je suis Colombe. Quel âge as-tu ?',
                        size: compact ? 36 : 50,
                      ),
                      SizedBox(height: compact ? 10 : 22),
                      Wrap(
                        spacing: 18,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final age in AgeGroup.values)
                            _AgeCard(age: age, width: cardW, compact: compact, onTap: () => onStart(age)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StickerPainter extends CustomPainter {
  _StickerPainter(this.paintSticker);

  final void Function(Canvas canvas, Size size) paintSticker;

  @override
  void paint(Canvas canvas, Size size) => paintSticker(canvas, size);

  @override
  bool shouldRepaint(_StickerPainter oldDelegate) => false;
}

class _AgeCard extends StatefulWidget {
  const _AgeCard({required this.age, required this.width, required this.compact, required this.onTap});

  final AgeGroup age;
  final double width;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_AgeCard> createState() => _AgeCardState();
}

class _AgeCardState extends State<_AgeCard> {
  bool _pressed = false;

  static const _colors = {
    AgeGroup.agneaux: Color(0xFFFFE3D3),
    AgeGroup.bergers: Color(0xFFDDEFD9),
    AgeGroup.explorateurs: Color(0xFFDCE7F5),
  };

  @override
  Widget build(BuildContext context) {
    final h = widget.compact ? widget.width * 0.82 : widget.width * 1.05;
    return Semantics(
      button: true,
      label: '${widget.age.label}, ${widget.age.ages}',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('age-${widget.age.name}'),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            width: widget.width,
            height: h,
            decoration: BoxDecoration(
              color: _colors[widget.age],
              borderRadius: BorderRadius.circular(24),
              border: const Border(bottom: BorderSide(color: Color(0x33000000), width: 5)),
              boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(painter: _AgeIcon(widget.age), child: const SizedBox.expand()),
                ),
                Text(widget.age.label, style: LumiereText.title(widget.compact ? 19 : 24)),
                Text(
                  widget.age.ages,
                  style: LumiereText.text(widget.compact ? 13 : 16, color: Palette.inkSoft),
                ),
                SizedBox(height: widget.compact ? 6 : 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeIcon extends CustomPainter {
  _AgeIcon(this.age);

  final AgeGroup age;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromCenter(
      center: size.center(Offset(0, size.height * 0.04)),
      width: size.height * 0.8,
      height: size.height * 0.8,
    );
    switch (age) {
      case AgeGroup.agneaux:
        paintAnimal(canvas, Animal.sheep, box);
      case AgeGroup.bergers:
        paintPerson(canvas, Offset(box.center.dx, box.bottom), box.height, NoahFamily.shem, wave: 0.6);
      case AgeGroup.explorateurs:
        paintAnimal(canvas, Animal.owl, box);
    }
  }

  @override
  bool shouldRepaint(_AgeIcon oldDelegate) => oldDelegate.age != age;
}

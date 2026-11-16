import 'package:material_ui/material_ui.dart';

import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/age_card.dart';
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
                            AgeCard(age: age, width: cardW, compact: compact, onTap: () => onStart(age)),
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

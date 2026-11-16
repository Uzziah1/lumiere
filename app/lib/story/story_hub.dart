import 'package:material_ui/material_ui.dart';

import '../art/animals.dart';
import '../art/weather.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/colombe_bubble.dart';
import '../widgets/paper_button.dart';
import '../widgets/round_button.dart';
import 'story_session.dart';

/// Les étapes d'une histoire qui rapportent une étoile.
enum StoryPart { recit, chronology, seek, memory, verse }

/// Le menu des jeux, après le récit.
class StoryHub extends StatelessWidget {
  const StoryHub({
    super.key,
    required this.stars,
    required this.onOpen,
    required this.onFinish,
    required this.onExit,
  });

  final Set<StoryPart> stars;
  final void Function(StoryPart part) onOpen;
  final VoidCallback onFinish;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final session = StorySession.of(context);
    final games = [
      (StoryPart.chronology, 'Dans l’ordre', _HubIcon.thumb),
      (StoryPart.seek, 'Cache-cache', _HubIcon.seek),
      (StoryPart.memory, 'Les paires', _HubIcon.memory),
      (StoryPart.verse, 'Le verset', _HubIcon.verse),
    ];
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 420;
          final cardW = ((constraints.maxWidth - 100) / 4).clamp(110.0, 210.0);
          return Stack(
            children: [
              Positioned(
                left: 12,
                top: 8,
                child: RoundPaperButton(
                  icon: Icons.home_rounded,
                  label: 'Accueil',
                  size: compact ? 44 : 54,
                  onPressed: onExit,
                ),
              ),
              Positioned(right: 16, top: 12, child: _StarCount(count: stars.length)),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(session.story.title, style: LumiereText.title(compact ? 26 : 38)),
                      SizedBox(height: compact ? 6 : 12),
                      ColombeBubble(text: session.text('games'), size: compact ? 34 : 46),
                      SizedBox(height: compact ? 12 : 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final (part, label, icon) in games)
                            _GameCard(
                              key: ValueKey('hub-${part.name}'),
                              label: label,
                              width: cardW,
                              compact: compact,
                              done: stars.contains(part),
                              painter: _HubIcon(icon, session),
                              onTap: () => onOpen(part),
                            ),
                        ],
                      ),
                      SizedBox(height: compact ? 12 : 24),
                      PaperButton(
                        label: 'Terminer',
                        icon: Icons.emoji_events_rounded,
                        size: compact ? PaperButtonSize.small : PaperButtonSize.large,
                        face: Palette.gold,
                        edge: Palette.goldDeep,
                        foreground: Palette.ink,
                        onPressed: onFinish,
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

class _StarCount extends StatelessWidget {
  const _StarCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count étoiles sur 5',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Palette.cream,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 5; i++)
                Icon(Icons.star_rounded, size: 24, color: i < count ? Palette.gold : const Color(0xFFE8D9C6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    super.key,
    required this.label,
    required this.width,
    required this.compact,
    required this.done,
    required this.painter,
    required this.onTap,
  });

  final String label;
  final double width;
  final bool compact;
  final bool done;
  final CustomPainter painter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = compact ? width * 0.8 : width;
    return Semantics(
      button: true,
      label: done ? '$label, réussi' : label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: h,
          decoration: BoxDecoration(
            color: Palette.cream,
            borderRadius: BorderRadius.circular(22),
            border: const Border(bottom: BorderSide(color: Color(0xFFE2C9A6), width: 5)),
            boxShadow: [
              const BoxShadow(color: Palette.shadow, blurRadius: 12, offset: Offset(0, 6)),
              if (done)
                BoxShadow(color: Palette.gold.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 1),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CustomPaint(painter: painter, child: const SizedBox.expand()),
                      ),
                    ),
                  ),
                  Text(label, style: LumiereText.title(compact ? 16 : 20)),
                  SizedBox(height: compact ? 6 : 10),
                ],
              ),
              if (done)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: Icon(Icons.star_rounded, color: Palette.gold, size: 36),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubIcon extends CustomPainter {
  _HubIcon(this.kind, this.session);

  static const thumb = 0;
  static const seek = 1;
  static const memory = 2;
  static const verse = 3;

  final int kind;
  final StorySession session;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case thumb:
        session.pack.paintThumb(canvas, size, session.story.chronology.cards.first.id);
      case seek:
        final scene = session.pack.seekScene;
        scene.paintBackground(canvas, Size(size.height * scene.aspectRatio, size.height));
        canvas.drawCircle(
          size.center(Offset.zero),
          size.shortestSide * 0.32,
          Paint()..color = const Color(0x55FFF6DC),
        );
        paintAnimal(
          canvas,
          Animal.rabbit,
          Rect.fromCenter(
            center: size.center(Offset.zero),
            width: size.shortestSide * 0.6,
            height: size.shortestSide * 0.6,
          ),
        );
      case memory:
        canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFDDEFD9));
        final w = size.width * 0.36;
        for (final (i, a) in [Animal.lion, Animal.lion].indexed) {
          final r = Rect.fromLTWH(
            size.width * 0.1 + i * size.width * 0.44,
            size.height * 0.15,
            w,
            size.height * 0.7,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(r, Radius.circular(w * 0.15)),
            Paint()..color = Palette.cream,
          );
          paintAnimal(canvas, a, r.deflate(w * 0.12));
        }
      case verse:
        canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFDCE7F5));
        paintRainbow(
          canvas,
          Offset(size.width / 2, size.height * 0.95),
          size.width * 0.42,
          size.width * 0.18,
        );
    }
  }

  @override
  bool shouldRepaint(_HubIcon oldDelegate) => false;
}

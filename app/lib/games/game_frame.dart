import 'package:material_ui/material_ui.dart';

import '../art/paper.dart';
import '../audio/audio.dart';
import '../story/story_session.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/colombe_bubble.dart';
import '../widgets/paper_button.dart';
import '../widgets/round_button.dart';

/// Cadre commun des mini-jeux : bouton retour, consigne de Colombe (dite à voix
/// haute), le jeu, puis « Bravo ! » et la flèche « Suite » une fois réussi.
class GameFrame extends StatefulWidget {
  const GameFrame({
    super.key,
    required this.title,
    required this.instructionKey,
    required this.onExit,
    required this.onDone,
    required this.builder,
  });

  final String title;
  final String instructionKey;
  final VoidCallback onExit;

  /// Appelé quand l'enfant touche « Suite » après avoir réussi.
  final VoidCallback onDone;

  /// Construit le jeu ; il appelle `complete` quand c'est réussi et peut faire
  /// parler Colombe avec `say` (clé d'une phrase commune ou de l'histoire).
  final Widget Function(BuildContext context, VoidCallback complete, void Function(String key) say) builder;

  @override
  State<GameFrame> createState() => _GameFrameState();
}

class _GameFrameState extends State<GameFrame> {
  bool _complete = false;
  late String _bubbleKey = widget.instructionKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bubbleKey == widget.instructionKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) StorySession.of(context).say(widget.instructionKey);
      });
    }
  }

  void _say(String key) {
    if (!mounted) return;
    setState(() => _bubbleKey = key);
    StorySession.of(context).say(key);
  }

  void _completeGame() {
    if (_complete) return;
    final session = StorySession.of(context);
    session.sfx.play(Sfx.star);
    setState(() {
      _complete = true;
      _bubbleKey = 'bravo';
    });
    session.say('bravo');
  }

  @override
  Widget build(BuildContext context) {
    final session = StorySession.of(context);
    return Scaffold(
      backgroundColor: Palette.paper,
      body: CustomPaint(
        painter: _PaperBackdrop(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 420;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Row(
                      children: [
                        RoundPaperButton(
                          icon: Icons.arrow_back_rounded,
                          label: 'Retour aux jeux',
                          size: compact ? 44 : 54,
                          onPressed: () {
                            session.narrator.stop();
                            widget.onExit();
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ColombeBubble(text: session.text(_bubbleKey), size: compact ? 38 : 52),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.title,
                          style: LumiereText.title(compact ? 18 : 24, color: Palette.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                            child: widget.builder(context, _completeGame, _say),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 12,
                          child: AnimatedScale(
                            scale: _complete ? 1 : 0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                            child: PaperButton(
                              label: 'Suite',
                              icon: Icons.arrow_forward_rounded,
                              size: compact ? PaperButtonSize.small : PaperButtonSize.large,
                              face: Palette.gold,
                              edge: Palette.goldDeep,
                              foreground: Palette.ink,
                              onPressed: _complete
                                  ? () {
                                      session.narrator.stop();
                                      widget.onDone();
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaperBackdrop extends CustomPainter {
  final _grain = PaperGrain(opacity: 0.07);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Palette.cream, Palette.paper, Color(0xFFF3D9B5)],
          stops: [0, 0.65, 1],
        ).createShader(Offset.zero & size),
    );
    _grain.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_PaperBackdrop oldDelegate) => false;
}

/// Petite secousse « non, pas celle-là » (sans punition).
class Shake extends StatelessWidget {
  const Shake({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        final dx = t == 0 ? 0.0 : (1 - t) * 10 * (((t * 8).floor()).isEven ? 1 : -1);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

/// Une carte en papier avec une ombre douce et des coins arrondis.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.color = Palette.cream,
    this.glow = false,
    this.radius = 18,
  });

  final Widget child;
  final Color color;
  final bool glow;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          const BoxShadow(color: Palette.shadow, blurRadius: 10, offset: Offset(0, 5)),
          if (glow) BoxShadow(color: Palette.gold.withValues(alpha: 0.9), blurRadius: 18, spreadRadius: 3),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
    );
  }
}

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../art/colombe.dart';
import '../art/paper.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/paper_button.dart';

/// Les rubriques pas encore construites.
enum Upcoming {
  carte(
    title: 'Ton voyage se prépare !',
    message: 'Colombe dessine la carte du monde de la Bible.\nReviens très bientôt pour partir avec elle.',
  ),
  parents(title: 'Espace parents', message: 'Les profils, la progression et les réglages\narrivent bientôt.');

  const Upcoming({required this.title, required this.message});

  final String title;
  final String message;

  static Upcoming? byName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// Écran d'attente, sur papier crème, avec Colombe qui vole.
class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key, required this.section});

  final Upcoming section;

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _flap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _flap.stop();
    } else if (!_flap.isAnimating) {
      _flap.repeat();
    }
  }

  @override
  void dispose() {
    _flap.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    return Scaffold(
      backgroundColor: Palette.paper,
      body: CustomPaint(
        painter: _PaperBackground(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final doveHeight = (constraints.maxHeight * 0.30).clamp(80.0, 200.0);
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: SizedBox(
                          height: doveHeight,
                          width: doveHeight * Colombe.aspectRatio,
                          child: CustomPaint(painter: ColombePainter(animation: _flap, withBranch: true)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(section.title, textAlign: TextAlign.center, style: LumiereText.title(34)),
                      const SizedBox(height: 10),
                      Text(
                        section.message,
                        textAlign: TextAlign.center,
                        style: LumiereText.text(19, color: Palette.inkSoft),
                      ),
                      const SizedBox(height: 28),
                      PaperButton(
                        label: 'Retour',
                        icon: Icons.arrow_back_rounded,
                        size: PaperButtonSize.small,
                        face: Palette.gold,
                        edge: Palette.goldDeep,
                        foreground: Palette.ink,
                        onPressed: _back,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaperBackground extends CustomPainter {
  final _grain = PaperGrain(opacity: 0.08);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: const [Palette.cream, Palette.paper, Color(0xFFF6DFC0)],
          stops: const [0, 0.6, 1],
        ).createShader(Offset.zero & size),
    );
    _grain.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_PaperBackground oldDelegate) => false;
}

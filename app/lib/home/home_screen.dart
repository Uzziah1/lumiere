import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/lumiere_title.dart';
import '../widgets/paper_button.dart';
import 'home_scene.dart';

/// L'accueil : la scène de l'aube en fond, le titre, et le bouton « Jouer ».
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  HomeScene? _scene;
  late bool _reducedMotion;

  /// Entrée du titre et des boutons, puis respiration du bouton « Jouer ».
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (_scene == null || reduced != _reducedMotion) {
      _reducedMotion = reduced;
      _scene = HomeScene(reducedMotion: reduced);
      if (reduced) {
        _intro.value = 1;
      } else if (!_intro.isAnimating && _intro.value == 0) {
        _intro.forward();
      }
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _scene!)),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  final w = constraints.maxWidth;
                  final titleSize = math.min(h * 0.17, w * 0.15).clamp(42.0, 132.0);
                  return Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: h * 0.08,
                        child: _Appear(
                          animation: _intro,
                          interval: const Interval(0, 0.6, curve: Curves.easeOutBack),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: LumiereTitle(fontSize: titleSize, animate: !_reducedMotion),
                                ),
                              ),
                              SizedBox(height: titleSize * 0.12),
                              Text(
                                'La Bible en jeux',
                                style: LumiereText.title(
                                  titleSize * 0.26,
                                  weight: 500,
                                  color: Palette.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: h * 0.56,
                        child: Center(
                          child: _Appear(
                            animation: _intro,
                            interval: const Interval(0.35, 1, curve: Curves.elasticOut),
                            child: _Breathing(
                              enabled: !_reducedMotion,
                              child: PaperButton(
                                label: 'Jouer',
                                icon: Icons.play_arrow_rounded,
                                // Qui joue ? puis la carte du monde.
                                onPressed: () => context.push('/profils'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 16,
                        child: _Appear(
                          animation: _intro,
                          interval: const Interval(0.6, 1, curve: Curves.easeOut),
                          child: PaperButton.secondary(
                            label: 'Parents',
                            icon: Icons.lock_rounded,
                            onPressed: () => context.push('/parents'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fait apparaître un élément (fondu + petit saut) sur une partie de l'animation.
class _Appear extends StatelessWidget {
  const _Appear({required this.animation, required this.interval, required this.child});

  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: interval);
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        final t = curved.value;
        return Opacity(
          opacity: animation.value <= interval.begin ? 0 : 1,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 30),
            child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
          ),
        );
      },
    );
  }
}

/// Le bouton « Jouer » respire doucement pour attirer le regard.
class _Breathing extends StatefulWidget {
  const _Breathing({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<_Breathing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) =>
          Transform.scale(scale: 1 + 0.04 * math.sin(_controller.value * math.pi * 2), child: child),
    );
  }
}

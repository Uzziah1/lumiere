import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../art/colombe.dart';
import '../art/landscape.dart';
import '../art/paper.dart';
import '../audio/audio.dart';
import '../save/game_state.dart';
import '../save/save_data.dart';
import '../stories/registry.dart';
import '../story/common_lines.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/colombe_bubble.dart';
import '../widgets/paper_button.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/round_button.dart';
import 'landmarks.dart';
import 'world.dart';

/// La carte du monde de la Bible : une mer et ses îles, une par histoire.
/// On la fait défiler du doigt ; l'avatar de l'enfant attend sur son île.
class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key, this.world});

  /// Remplaçable dans les tests.
  final World? world;

  @override
  State<WorldMapScreen> createState() => WorldMapScreenState();
}

class WorldMapScreenState extends State<WorldMapScreen> with SingleTickerProviderStateMixin {
  final scroll = ScrollController();
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  Island? selected;
  String _bubble = 'Touche une île pour commencer une histoire !';
  bool _scrolled = false;

  World get world => widget.world ?? World(islands: lot1, available: storyPacks.keys.toSet());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameScope.read(context).current == null) {
        context.go('/profils');
        return;
      }
      _say('map', _bubble);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    scroll.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _say(String key, String text) {
    setState(() => _bubble = text);
    AudioScope.of(context).narrator.play(commonAudioPath(key, 'all'), text: text);
  }

  /// L'enfant touche une île.
  void tapIsland(Island island) {
    final state = GameScope.read(context);
    AudioScope.of(context).sfx.play(Sfx.tap);
    switch (world.status(island, state.progress)) {
      case IslandStatus.open:
        AudioScope.of(context).narrator.stop();
        setState(() => selected = island);
      case IslandStatus.locked:
        setState(() => selected = null);
        _say('locked', 'Gagne au moins trois étoiles sur l’île d’avant pour ouvrir celle-ci !');
      case IslandStatus.soon:
        setState(() => selected = null);
        _say('soon', '« ${island.title} » arrive bientôt ! Je la prépare pour toi.');
    }
  }

  void _play(Island island) {
    AudioScope.of(context).narrator.stop();
    setState(() => selected = null);
    context.push('/histoire/${island.id}');
  }

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final profile = state.current;
    if (profile == null) return const Scaffold(backgroundColor: Color(0xFF3E9CC2));
    final w = world;
    StoryProgress progress(String id) => state.progress(id);
    final statuses = {for (final i in w.islands) i.id: w.status(i, progress)};
    final here = w.currentIsland(progress);

    return Scaffold(
      backgroundColor: const Color(0xFF3E9CC2),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final width = math.max(constraints.maxWidth * 2.2, h * 3.2);
          final compact = h < 420;
          if (!_scrolled) {
            _scrolled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scroll.hasClients) {
                scroll.jumpTo(
                  (here.position.dx * width - constraints.maxWidth / 2).clamp(
                    0,
                    scroll.position.maxScrollExtent,
                  ),
                );
              }
            });
          }
          Offset at(Island i) => Offset(i.position.dx * width, i.position.dy * h);
          final islandSize = h * 0.3;

          return Stack(
            children: [
              Positioned.fill(
                // La carte se fait glisser au doigt, mais aussi à la souris sur le web.
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(dragDevices: ui.PointerDeviceKind.values.toSet()),
                  child: SingleChildScrollView(
                    key: const ValueKey('world-scroll'),
                    controller: scroll,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      height: h,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: RepaintBoundary(child: CustomPaint(painter: _MapPainter(w, statuses))),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _ambient,
                                builder: (context, _) => CustomPaint(painter: _SeaGlints(_ambient.value)),
                              ),
                            ),
                          ),
                          for (final island in w.islands)
                            Positioned(
                              left: at(island).dx - islandSize / 2,
                              top: at(island).dy - islandSize / 2,
                              width: islandSize,
                              height: islandSize + 34,
                              child: _IslandSpot(
                                key: ValueKey('island-${island.id}'),
                                island: island,
                                status: statuses[island.id]!,
                                progress: progress(island.id),
                                selected: selected == island,
                                onTap: () => tapIsland(island),
                              ),
                            ),
                          // L'avatar de l'enfant sur son île.
                          AnimatedBuilder(
                            animation: _ambient,
                            builder: (context, child) => Positioned(
                              left: at(here).dx - islandSize * 0.48,
                              top:
                                  at(here).dy -
                                  islandSize * 0.62 +
                                  math.sin(_ambient.value * math.pi * 8) * 4,
                              child: child!,
                            ),
                            child: IgnorePointer(
                              child: ProfileAvatar(avatar: profile.avatar, size: h * 0.12, selected: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Barre du haut, fixe.
              Positioned(
                left: 12,
                top: 8,
                child: SafeArea(
                  child: Row(
                    children: [
                      RoundPaperButton(
                        icon: Icons.home_rounded,
                        label: 'Accueil',
                        size: compact ? 44 : 54,
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(width: 10),
                      _ProfileChip(
                        profile: profile,
                        stars: state.totalStars(profile.id),
                        compact: compact,
                        onTap: () => context.go('/profils'),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 8,
                child: SafeArea(
                  child: Row(
                    children: [
                      RoundPaperButton(
                        icon: Icons.auto_stories_rounded,
                        label: 'Mon album d’autocollants',
                        size: compact ? 44 : 54,
                        face: Palette.gold,
                        edge: Palette.goldDeep,
                        foreground: Palette.ink,
                        onPressed: () => context.go('/album'),
                      ),
                      const SizedBox(width: 10),
                      RoundPaperButton(
                        icon: Icons.sailing_rounded,
                        label: 'Mon arche',
                        size: compact ? 44 : 54,
                        face: Palette.lagoon,
                        edge: Palette.lagoonDeep,
                        foreground: Palette.cream,
                        onPressed: () => context.go('/tresor'),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 10,
                right: selected == null ? 12 : null,
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ColombeBubble(text: _bubble, size: compact ? 34 : 46, maxWidth: 420),
                  ),
                ),
              ),
              if (selected != null)
                Positioned(
                  right: 16,
                  bottom: 12,
                  child: SafeArea(
                    child: _IslandCard(
                      island: selected!,
                      progress: progress(selected!.id),
                      compact: compact,
                      onPlay: () => _play(selected!),
                      onClose: () => setState(() => selected = null),
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

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.profile,
    required this.stars,
    required this.compact,
    required this.onTap,
  });

  final Profile profile;
  final int stars;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${profile.name}, $stars étoiles. Changer de joueur',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
          decoration: BoxDecoration(
            color: Palette.cream,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(avatar: profile.avatar, size: compact ? 36 : 44),
              const SizedBox(width: 8),
              Text(profile.name, style: LumiereText.title(compact ? 16 : 19)),
              const SizedBox(width: 10),
              const Icon(Icons.star_rounded, color: Palette.gold, size: 22),
              Text('$stars', style: LumiereText.title(compact ? 16 : 19, color: Palette.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IslandSpot extends StatelessWidget {
  const _IslandSpot({
    super.key,
    required this.island,
    required this.status,
    required this.progress,
    required this.selected,
    required this.onTap,
  });

  final Island island;
  final IslandStatus status;
  final StoryProgress progress;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      IslandStatus.open => '${island.title}, ${progress.stars} étoiles sur 5',
      IslandStatus.locked => '${island.title}, fermée',
      IslandStatus.soon => '${island.title}, bientôt',
    };
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: const Duration(milliseconds: 200),
                child: const SizedBox.expand(),
              ),
            ),
            _Badge(status: status, progress: progress),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.status, required this.progress});

  final IslandStatus status;
  final StoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final Widget content = switch (status) {
      IslandStatus.open => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Icon(
              Icons.star_rounded,
              size: 18,
              color: i < progress.stars ? Palette.gold : const Color(0xFFE8D9C6),
            ),
          if (progress.sticker) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified_rounded, size: 18, color: Palette.lagoon),
          ],
        ],
      ),
      IslandStatus.locked => const Icon(Icons.lock_rounded, size: 18, color: Palette.inkSoft),
      IslandStatus.soon => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_top_rounded, size: 16, color: Palette.inkSoft),
          const SizedBox(width: 4),
          Text('Bientôt', style: LumiereText.title(14, weight: 500, color: Palette.inkSoft)),
        ],
      ),
    };
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Palette.cream.withValues(alpha: status == IslandStatus.soon ? 0.75 : 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: content),
    );
  }
}

class _IslandCard extends StatelessWidget {
  const _IslandCard({
    required this.island,
    required this.progress,
    required this.compact,
    required this.onPlay,
    required this.onClose,
  });

  final Island island;
  final StoryProgress progress;
  final bool compact;
  final VoidCallback onPlay;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('island-card'),
      width: compact ? 280 : 340,
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: BoxDecoration(
        color: Palette.paper,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(island.title, style: LumiereText.title(compact ? 20 : 26)),
                    Text(
                      island.reference,
                      style: LumiereText.title(compact ? 14 : 16, weight: 500, color: Palette.inkSoft),
                    ),
                  ],
                ),
              ),
              RoundPaperButton(icon: Icons.close_rounded, label: 'Fermer', size: 40, onPressed: onClose),
            ],
          ),
          SizedBox(height: compact ? 6 : 10),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Icon(
                  Icons.star_rounded,
                  size: compact ? 26 : 32,
                  color: i < progress.stars ? Palette.gold : const Color(0xFFE8D9C6),
                ),
              const Spacer(),
              if (progress.sticker)
                Text('Autocollant gagné', style: LumiereText.text(14, bold: true, color: Palette.lagoonDeep)),
            ],
          ),
          SizedBox(height: compact ? 8 : 14),
          Center(
            child: PaperButton(
              label: progress.stars == 0 ? 'Jouer' : 'Rejouer',
              icon: Icons.play_arrow_rounded,
              size: compact ? PaperButtonSize.small : PaperButtonSize.large,
              onPressed: onPlay,
            ),
          ),
        ],
      ),
    );
  }
}

/// La mer, le chemin de sable et les îles (dessin fixe, mis en cache).
class _MapPainter extends CustomPainter {
  _MapPainter(this.world, this.statuses);

  final World world;
  final Map<String, IslandStatus> statuses;
  final _grain = PaperGrain(opacity: 0.05);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          const [Color(0xFF86CDE0), Color(0xFF4FA8CB), Color(0xFF2E7DA6)],
          const [0, 0.5, 1],
        ),
    );
    // Petites vagues dessinées.
    final wave = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, h * 0.004)
      ..strokeCap = StrokeCap.round;
    final random = math.Random(21);
    for (var i = 0; i < (size.width / 40).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * h;
      final r = h * (0.012 + random.nextDouble() * 0.012);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x, y), radius: r),
        math.pi * 1.15,
        math.pi * 0.7,
        false,
        wave,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x + r * 1.6, y), radius: r),
        math.pi * 1.15,
        math.pi * 0.7,
        false,
        wave,
      );
    }
    // Îlots décoratifs avec un palmier.
    for (final (fx, fy) in const [
      (0.13, 0.84),
      (0.37, 0.14),
      (0.49, 0.86),
      (0.73, 0.84),
      (0.86, 0.12),
      (0.97, 0.78),
    ]) {
      final c = Offset(fx * size.width, fy * h);
      drawPaper(
        canvas,
        Path()..addOval(Rect.fromCenter(center: c, width: h * 0.12, height: h * 0.04)),
        const Color(0xFFF2D9A0),
        elevation: 3,
      );
      drawPaper(
        canvas,
        palmPath(c, h * 0.1, lean: fx > 0.5 ? -0.1 : 0.1),
        const Color(0xFF5E8A3A),
        elevation: 3,
      );
    }
    _path(canvas, size);
    for (final island in world.islands) {
      _island(canvas, size, island, statuses[island.id]!);
    }
    _grain.paint(canvas, size);
  }

  void _path(Canvas canvas, Size size) {
    final points = [
      for (final i in world.islands)
        Offset(i.position.dx * size.width, i.position.dy * size.height + size.height * 0.07),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final mid = Offset.lerp(a, b, 0.5)!;
      path.quadraticBezierTo(mid.dx, a.dy, mid.dx, mid.dy);
      path.quadraticBezierTo(mid.dx, b.dy, b.dx, b.dy);
    }
    final dot = Paint()..color = const Color(0xFFF6E3B4);
    final shadow = Paint()
      ..color = const Color(0x33124A66)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.004);
    final step = size.height * 0.035;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += step) {
        final p = metric.getTangentForOffset(d)!.position;
        canvas.drawCircle(p + Offset(0, size.height * 0.004), size.height * 0.008, shadow);
        canvas.drawCircle(p, size.height * 0.008, dot);
      }
    }
  }

  void _island(Canvas canvas, Size size, Island island, IslandStatus status) {
    final h = size.height;
    final c = Offset(island.position.dx * size.width, island.position.dy * h);
    final dim = status == IslandStatus.soon;
    if (dim) {
      canvas.saveLayer(
        Rect.fromCircle(center: c, radius: h * 0.25),
        Paint()..colorFilter = const ColorFilter.matrix(_softGrey),
      );
    }
    final base = c + Offset(0, h * 0.07);
    // Halo d'eau claire autour de l'île.
    canvas.drawOval(
      Rect.fromCenter(center: base, width: h * 0.34, height: h * 0.13),
      Paint()..color = const Color(0x5594E0EA),
    );
    drawPaper(
      canvas,
      Path()..addOval(Rect.fromCenter(center: base, width: h * 0.28, height: h * 0.1)),
      const Color(0xFFF2D9A0),
      elevation: 5,
      light: 0.15,
    );
    final grass = Path()
      ..addOval(Rect.fromCenter(center: base - Offset(0, h * 0.012), width: h * 0.22, height: h * 0.07))
      ..addOval(Rect.fromCenter(center: base - Offset(h * 0.05, h * 0.02), width: h * 0.1, height: h * 0.05))
      ..addOval(
        Rect.fromCenter(center: base + Offset(h * 0.05, -h * 0.02), width: h * 0.1, height: h * 0.05),
      );
    drawPaper(canvas, grass, const Color(0xFF9CC271), elevation: 2, light: 0.15);
    final box = Rect.fromCenter(center: c - Offset(0, h * 0.035), width: h * 0.19, height: h * 0.19);
    paintLandmark(canvas, island.landmark, box);
    if (dim) {
      // Un petit nuage posé sur l'île en préparation.
      canvas.restore();
      drawPaper(
        canvas,
        cloudPath(c + Offset(h * 0.07, -h * 0.07), h * 0.12),
        const Color(0xEEFFFFFF),
        elevation: 3,
        light: 0.2,
      );
    }
  }

  static const _softGrey = <double>[
    0.55, 0.3, 0.15, 0, 30, //
    0.25, 0.6, 0.15, 0, 30, //
    0.25, 0.3, 0.45, 0, 30, //
    0, 0, 0, 0.85, 0,
  ];

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      oldDelegate.statuses.toString() != statuses.toString() || oldDelegate.world != world;
}

/// Reflets du soleil qui scintillent sur la mer, et Colombe qui survole la carte.
class _SeaGlints extends CustomPainter {
  _SeaGlints(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(5);
    final paint = Paint()
      ..strokeWidth = math.max(2, size.height * 0.005)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < (size.width / 60).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final phase = random.nextDouble();
      final a = (math.sin((t * 6 + phase) * math.pi * 2) + 1) / 2;
      paint.color = Color.fromRGBO(255, 255, 255, 0.5 * a);
      final len = size.height * 0.02 * (0.5 + a);
      canvas.drawLine(Offset(x - len / 2, y), Offset(x + len / 2, y), paint);
    }
    // Colombe fait de grands tours au-dessus de la mer.
    final h = size.height * 0.08;
    final x = (t * size.width * 0.6 + size.width * 0.1) % size.width;
    final y = size.height * (0.16 + 0.04 * math.sin(t * math.pi * 6));
    canvas.save();
    canvas.translate(x - h * Colombe.aspectRatio / 2, y);
    Colombe.paint(canvas, Size(h * Colombe.aspectRatio, h), flap: 0.5 + 0.5 * math.sin(t * math.pi * 2 * 30));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SeaGlints oldDelegate) => oldDelegate.t != t;
}

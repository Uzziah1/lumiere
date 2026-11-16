import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../art/ark.dart';
import '../art/objects.dart';
import '../art/paper.dart';
import '../audio/audio.dart';
import '../save/game_state.dart';
import '../story/common_lines.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/colombe_bubble.dart';
import '../widgets/round_button.dart';
import 'world.dart';

/// L'arche-trésor (Ancien Testament) et le jardin (Nouveau Testament) : chaque
/// histoire terminée y fait venir un nouvel ami.
class TreasureScreen extends StatefulWidget {
  const TreasureScreen({super.key, this.garden = false});

  /// Le jardin du Nouveau Testament plutôt que l'arche.
  final bool garden;

  @override
  State<TreasureScreen> createState() => TreasureScreenState();
}

class TreasureScreenState extends State<TreasureScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  String? _bubble;
  String? _hopping;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameScope.read(context).current == null) {
        context.go('/profils');
        return;
      }
      AudioScope.of(context).narrator.play(
        commonAudioPath(widget.garden ? 'garden' : 'treasure', 'all'),
        text: widget.garden
            ? 'Voici ton jardin ! Chaque histoire de Jésus terminée y fait venir un nouvel ami.'
            : 'Voici ton arche ! Chaque histoire terminée y fait entrer un nouvel ami.',
      );
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
    _ambient.dispose();
    super.dispose();
  }

  void tapFriend(Island island, bool earned) {
    final audio = AudioScope.of(context);
    if (earned) {
      audio.sfx.play(Sfx.pop);
      setState(() {
        _hopping = island.id;
        _bubble = 'Voici ${thingLabel(island.treasure)}, de l’histoire « ${island.title} » !';
      });
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _hopping == island.id) setState(() => _hopping = null);
      });
    } else {
      audio.sfx.play(Sfx.tap);
      setState(() => _bubble = 'Termine l’histoire « ${island.title} » pour faire entrer un nouvel ami !');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    if (state.current == null) return const Scaffold(backgroundColor: Palette.paper);
    final garden = widget.garden;
    final islands = garden ? lot2 : lot1;
    final earned = {for (final i in islands) i.id: state.progress(i.id).sticker};
    final count = earned.values.where((e) => e).length;
    final place = garden ? 'ton jardin' : 'ton arche';
    return Scaffold(
      backgroundColor: const Color(0xFF8CCFE6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final compact = size.height < 420;
          // L'arche coupée en deux : on voit l'intérieur, avec deux étages de cabines.
          final arkW = math.min(size.width * 0.9, size.height * 1.5);
          final arkH = arkW / Ark.aspectRatio;
          final ark = Rect.fromLTWH((size.width - arkW) / 2, size.height * 0.94 - arkH, arkW, arkH);
          final cells = garden ? _gardenCells(size, compact) : _cells(ark);
          return Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: garden ? _Garden(cells) : _ArkInside(ark))),
              for (var i = 0; i < islands.length; i++)
                Positioned.fromRect(
                  rect: cells[i],
                  child: AnimatedBuilder(
                    animation: _ambient,
                    builder: (context, _) => _Friend(
                      key: ValueKey('friend-${islands[i].id}'),
                      island: islands[i],
                      earned: earned[islands[i].id]!,
                      hop: _hopping == islands[i].id,
                      bob: math.sin(_ambient.value * math.pi * 2 + i) * 2,
                      onTap: () => tapFriend(islands[i], earned[islands[i].id]!),
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                top: 8,
                child: SafeArea(
                  child: RoundPaperButton(
                    icon: Icons.map_rounded,
                    label: 'Retour à la carte',
                    size: compact ? 44 : 54,
                    onPressed: () => context.go('/carte'),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 8,
                child: SafeArea(
                  child: RoundPaperButton(
                    key: const ValueKey('treasure-switch'),
                    icon: garden ? Icons.sailing_rounded : Icons.local_florist_rounded,
                    label: garden ? 'Mon arche' : 'Mon jardin',
                    size: compact ? 44 : 54,
                    onPressed: () => context.go(garden ? '/tresor' : '/jardin'),
                  ),
                ),
              ),
              Positioned(
                left: 80,
                right: 80,
                top: 10,
                child: SafeArea(
                  child: Column(
                    children: [
                      Text(
                        garden ? 'Mon jardin' : 'Mon arche',
                        style: LumiereText.title(compact ? 24 : 34, color: Palette.ink),
                      ),
                      const SizedBox(height: 4),
                      ColombeBubble(
                        text:
                            _bubble ?? '$count ami${count > 1 ? 's' : ''} sur ${islands.length} dans $place',
                        size: compact ? 30 : 40,
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

  /// Dix massifs : deux rangées de cinq, sous le titre.
  static List<Rect> _gardenCells(Size size, bool compact) {
    final cell = math.min(size.width / 7, size.height * (compact ? 0.24 : 0.22));
    final gap = (size.width - cell * 5) / 6;
    final rows = [size.height * 0.5, size.height * 0.78];
    return [
      for (final y in rows)
        for (var k = 0; k < 5; k++) Rect.fromLTWH(gap + k * (cell + gap), y - cell / 2, cell, cell),
    ];
  }

  /// Huit cabines : deux étages de quatre, dans la coque et la cabine de l'arche.
  static List<Rect> _cells(Rect ark) {
    final sx = ark.width / 200;
    final sy = ark.height / 120;
    Rect r(double l, double t, double w, double h) =>
        Rect.fromLTWH(ark.left + l * sx, ark.top + t * sy, w * sx, h * sy);
    return [
      for (var k = 0; k < 4; k++) r(48 + k * 27, 22, 25, 27),
      for (var k = 0; k < 4; k++) r(30 + k * 36, 58, 32, 32),
    ];
  }
}

class _Friend extends StatelessWidget {
  const _Friend({
    super.key,
    required this.island,
    required this.earned,
    required this.hop,
    required this.bob,
    required this.onTap,
  });

  final Island island;
  final bool earned;
  final bool hop;
  final double bob;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: earned ? '${thingLabel(island.treasure)}, ${island.title}' : 'Cabine vide : ${island.title}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedSlide(
          offset: Offset(0, hop ? -0.25 : 0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Transform.translate(
            offset: Offset(0, earned ? bob : 0),
            child: CustomPaint(painter: _FriendPainter(island.treasure, earned)),
          ),
        ),
      ),
    );
  }
}

class _FriendPainter extends CustomPainter {
  _FriendPainter(this.id, this.earned);

  final String id;
  final bool earned;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromLTWH(size.width * 0.08, size.height * 0.08, size.width * 0.84, size.height * 0.84);
    if (earned) {
      paintThing(canvas, id, box);
      return;
    }
    // Silhouette à deviner.
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..colorFilter = const ColorFilter.mode(Color(0x55603C28), BlendMode.srcIn),
    );
    paintThing(canvas, id, box);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FriendPainter oldDelegate) => oldDelegate.id != id || oldDelegate.earned != earned;
}

/// Le jardin : ciel du matin, collines, allée et un massif sous chaque ami.
class _Garden extends CustomPainter {
  _Garden(this.cells);

  final List<Rect> cells;
  final _grain = PaperGrain(opacity: 0.05);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD9A8), Color(0xFFCDE8EE), Color(0xFFBFE3B4)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.18),
      size.height * 0.08,
      Paint()..color = Palette.sun,
    );
    for (final (top, color) in [(0.3, const Color(0xFF9BCB7A)), (0.38, const Color(0xFF7DB860))]) {
      drawPaper(
        canvas,
        Path()
          ..moveTo(0, size.height)
          ..lineTo(0, size.height * (top + 0.06))
          ..quadraticBezierTo(
            size.width * 0.3,
            size.height * (top - 0.06),
            size.width * 0.6,
            size.height * top,
          )
          ..quadraticBezierTo(size.width * 0.85, size.height * (top + 0.05), size.width, size.height * top)
          ..lineTo(size.width, size.height)
          ..close(),
        color,
        elevation: 4,
      );
    }
    // L'allée de sable entre les deux rangées.
    drawPaper(
      canvas,
      Path()..addRect(Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.05)),
      const Color(0xFFEBD3A0),
      elevation: 2,
    );
    for (final fx in [0.03, 0.97]) {
      paintThing(
        canvas,
        fx < 0.5 ? 'palm' : 'tree',
        Rect.fromCenter(
          center: Offset(size.width * fx, size.height * 0.46),
          width: size.height * 0.24,
          height: size.height * 0.34,
        ),
      );
    }
    // Un massif de terre fleurie sous chaque ami.
    for (final c in cells) {
      final bed = Rect.fromCenter(
        center: Offset(c.center.dx, c.bottom - c.height * 0.06),
        width: c.width * 1.1,
        height: c.height * 0.3,
      );
      drawPaper(canvas, Path()..addOval(bed), const Color(0xFF8A5A36), elevation: 3);
      drawPaper(
        canvas,
        Path()..addOval(bed.deflate(bed.height * 0.12)),
        const Color(0xFF5E9B45),
        elevation: 1,
      );
      for (final dx in [-0.42, 0.42]) {
        canvas.drawCircle(
          Offset(bed.center.dx + bed.width * dx, bed.center.dy),
          bed.height * 0.14,
          Paint()..color = const Color(0xFFF28FB0),
        );
      }
    }
    _grain.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_Garden oldDelegate) => oldDelegate.cells != cells;
}

class _ArkInside extends CustomPainter {
  _ArkInside(this.ark);

  final Rect ark;
  final _grain = PaperGrain(opacity: 0.05);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8CCFE6), Color(0xFFCDE8EE), Color(0xFFFFF1D6)],
        ).createShader(Offset.zero & size),
    );
    // Le mont Ararat derrière l'arche.
    drawPaper(
      canvas,
      Path()
        ..moveTo(size.width * 0.1, size.height)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.1, size.width * 0.9, size.height)
        ..close(),
      const Color(0xFF9AA8B8),
      elevation: 4,
    );
    Ark.paint(canvas, ark, door: 1, window: 1);
    // Intérieur visible : les murs de planches des cabines.
    final sx = ark.width / 200;
    final sy = ark.height / 120;
    Rect r(double l, double t, double w, double h) =>
        Rect.fromLTWH(ark.left + l * sx, ark.top + t * sy, w * sx, h * sy);
    final inside = Paint()..color = const Color(0xFF8A5634);
    canvas.drawRRect(RRect.fromRectAndRadius(r(44, 20, 114, 30), Radius.circular(4 * sx)), inside);
    canvas.drawRRect(RRect.fromRectAndRadius(r(26, 56, 148, 36), Radius.circular(4 * sx)), inside);
    final wall = Paint()
      ..color = const Color(0xFF6B3E22)
      ..strokeWidth = 2 * sx;
    for (var k = 1; k < 4; k++) {
      canvas.drawLine(r(46 + k * 27, 20, 0, 30).topLeft, r(46 + k * 27, 20, 0, 30).bottomLeft, wall);
      canvas.drawLine(r(28 + k * 36, 56, 0, 36).topLeft, r(28 + k * 36, 56, 0, 36).bottomLeft, wall);
    }
    // Paille au fond des cabines.
    final straw = Paint()..color = const Color(0xFFE6C15A);
    canvas.drawRect(r(44, 46, 114, 4), straw);
    canvas.drawRect(r(26, 88, 148, 4), straw);
    _grain.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_ArkInside oldDelegate) => oldDelegate.ark != ark;
}

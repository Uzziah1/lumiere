import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../audio/audio.dart';
import '../stories/registry.dart';
import '../story/story.dart';
import '../story/story_session.dart';
import '../theme/palette.dart';
import 'game_frame.dart';

/// Cherche et trouve : des animaux sont cachés dans une grande scène.
/// En bas, leurs silhouettes ; si l'enfant cherche longtemps, Colombe aide.
class SeekGame extends StatefulWidget {
  const SeekGame({super.key, required this.complete, required this.say});

  final VoidCallback complete;
  final void Function(String key) say;

  @override
  State<SeekGame> createState() => SeekGameState();
}

class SeekGameState extends State<SeekGame> with SingleTickerProviderStateMixin {
  late List<SeekItem> items;
  final found = <String>{};
  String? _hinted;
  Timer? _idle;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = StorySession.of(context);
    items = session.story.seek.itemsFor(session.age);
    _restartIdle();
    if (!MediaQuery.disableAnimationsOf(context)) _pulse.repeat();
  }

  @override
  void dispose() {
    _idle?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _restartIdle() {
    _idle?.cancel();
    _idle = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      final next = items.where((i) => !found.contains(i.id)).firstOrNull;
      if (next == null) return;
      setState(() => _hinted = next.id);
      widget.say('look');
    });
  }

  /// L'enfant touche [relative] (0–1 dans la scène).
  void tapAt(Offset relative, SeekScene scene) {
    for (final item in items) {
      if (found.contains(item.id)) continue;
      final (center, size) = scene.spots[item.id]!;
      final dx = (relative.dx - center.dx) * scene.aspectRatio;
      final dy = relative.dy - center.dy;
      if (math.sqrt(dx * dx + dy * dy) <= size * 0.65) {
        find(item.id);
        return;
      }
    }
  }

  void find(String id) {
    if (found.contains(id)) return;
    StorySession.of(context).sfx.play(Sfx.chime);
    setState(() {
      found.add(id);
      if (_hinted == id) _hinted = null;
    });
    if (found.length == items.length) {
      _idle?.cancel();
      widget.complete();
    } else {
      widget.say('found');
      _restartIdle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = StorySession.of(context).pack.seekScene;
    return LayoutBuilder(
      builder: (context, constraints) {
        final trayH = math.min(
          math.min(76.0, constraints.maxHeight * 0.2),
          (constraints.maxWidth - 10.0 * items.length) / items.length,
        );
        final availH = constraints.maxHeight - trayH - 10;
        var w = constraints.maxWidth;
        var h = w / scene.aspectRatio;
        if (h > availH) {
          h = availH;
          w = h * scene.aspectRatio;
        }
        return Column(
          children: [
            SizedBox(
              width: w,
              height: h,
              child: PaperCard(
                radius: 22,
                child: GestureDetector(
                  key: const ValueKey('seek-scene'),
                  onTapUp: (d) => tapAt(Offset(d.localPosition.dx / w, d.localPosition.dy / h), scene),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) => CustomPaint(
                      size: Size(w, h),
                      painter: _SeekPainter(scene, items, found, _hinted, _pulse.value),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: trayH,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Semantics(
                        label: found.contains(item.id) ? '${item.label}, trouvé' : '${item.label}, à trouver',
                        child: _TrayItem(
                          scene: scene,
                          id: item.id,
                          found: found.contains(item.id),
                          size: trayH,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrayItem extends StatelessWidget {
  const _TrayItem({required this.scene, required this.id, required this.found, required this.size});

  final SeekScene scene;
  final String id;
  final bool found;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: found ? Palette.cream : const Color(0x22B07A4F),
        shape: BoxShape.circle,
        border: Border.all(color: found ? Palette.gold : const Color(0x55B07A4F), width: 3),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(size * 0.16),
              child: ColorFiltered(
                colorFilter: found
                    ? const ColorFilter.mode(Color(0x00000000), BlendMode.dst)
                    : const ColorFilter.mode(Color(0x99603C28), BlendMode.srcIn),
                child: CustomPaint(painter: _ItemPainter(scene, id)),
              ),
            ),
          ),
          if (found)
            const Positioned(
              right: 0,
              bottom: 0,
              child: Icon(Icons.check_circle_rounded, color: Palette.lagoon, size: 22),
            ),
        ],
      ),
    );
  }
}

class _ItemPainter extends CustomPainter {
  _ItemPainter(this.scene, this.id);

  final SeekScene scene;
  final String id;

  @override
  void paint(Canvas canvas, Size size) => scene.paintItem(canvas, id, Offset.zero & size);

  @override
  bool shouldRepaint(_ItemPainter oldDelegate) => oldDelegate.id != id;
}

class _SeekPainter extends CustomPainter {
  _SeekPainter(this.scene, this.items, this.found, this.hinted, this.pulse);

  final SeekScene scene;
  final List<SeekItem> items;
  final Set<String> found;
  final String? hinted;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    scene.paintBackground(canvas, size);
    for (final item in items) {
      final (c, s) = scene.spots[item.id]!;
      final side = s * size.height;
      final center = Offset(c.dx * size.width, c.dy * size.height);
      if (found.contains(item.id)) {
        canvas.drawCircle(
          center,
          side * 0.7,
          Paint()
            ..color = Palette.sun.withValues(alpha: 0.55)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.25),
        );
      }
      scene.paintItem(canvas, item.id, Rect.fromCenter(center: center, width: side, height: side));
    }
    scene.paintForeground(canvas, size);
    for (final item in items) {
      final (c, s) = scene.spots[item.id]!;
      final side = s * size.height;
      final center = Offset(c.dx * size.width, c.dy * size.height);
      if (found.contains(item.id)) {
        canvas.drawCircle(
          center,
          side * 0.62,
          Paint()
            ..color = Palette.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(3, side * 0.06),
        );
      } else if (item.id == hinted) {
        canvas.drawCircle(
          center,
          side * (0.7 + pulse * 0.4),
          Paint()
            ..color = Palette.gold.withValues(alpha: 1 - pulse)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(3, side * 0.08),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SeekPainter oldDelegate) => true;
}

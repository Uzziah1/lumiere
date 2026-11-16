import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../audio/audio.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/paper_button.dart';
import 'story.dart';
import 'story_session.dart';

/// La fin de l'histoire : les étoiles gagnées et l'autocollant pour l'album.
class StoryReward extends StatefulWidget {
  const StoryReward({
    super.key,
    required this.stars,
    required this.onReplay,
    required this.onHome,
    this.homeLabel = 'Accueil',
  });

  final int stars;

  /// « La carte » quand on vient de la carte du monde.
  final String homeLabel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  @override
  State<StoryReward> createState() => _StoryRewardState();
}

class _StoryRewardState extends State<StoryReward> with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reveal.status == AnimationStatus.dismissed) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _reveal.value = 1;
      } else {
        _reveal.forward();
      }
      final session = StorySession.of(context);
      session.sfx.play(Sfx.star);
      session.say('reward');
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = StorySession.of(context);
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 420;
          final sticker = math.min(constraints.maxHeight * 0.42, 260.0);
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _reveal,
                builder: (context, _) {
                  final t = Curves.elasticOut.transform((_reveal.value / 0.6).clamp(0.0, 1.0));
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bravo !', style: LumiereText.title(compact ? 34 : 52)),
                      SizedBox(height: compact ? 6 : 12),
                      Transform.rotate(
                        angle: (1 - t) * -0.6,
                        child: Transform.scale(
                          scale: t,
                          child: Semantics(
                            label: 'Autocollant : ${session.story.sticker.title}',
                            child: SizedBox(
                              width: sticker,
                              height: sticker,
                              child: CustomPaint(painter: _Sticker(session.pack.paintSticker)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 8),
                      Text(
                        session.story.sticker.title,
                        style: LumiereText.title(compact ? 20 : 26, color: Palette.inkSoft),
                      ),
                      SizedBox(height: compact ? 6 : 12),
                      Semantics(
                        label: '${widget.stars} étoiles sur ${Story.maxStars}',
                        excludeSemantics: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < Story.maxStars; i++)
                              Transform.scale(
                                scale: Curves.easeOutBack.transform(
                                  ((_reveal.value - 0.45 - i * 0.08) / 0.2).clamp(0.0, 1.0),
                                ),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: compact ? 40 : 56,
                                  color: i < widget.stars ? Palette.gold : const Color(0xFFE8D9C6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          PaperButton.secondary(
                            label: 'Rejouer',
                            icon: Icons.replay_rounded,
                            onPressed: widget.onReplay,
                          ),
                          PaperButton(
                            label: widget.homeLabel,
                            icon: widget.homeLabel == 'Accueil' ? Icons.home_rounded : Icons.map_rounded,
                            size: PaperButtonSize.small,
                            onPressed: widget.onHome,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Sticker extends CustomPainter {
  _Sticker(this.paintSticker);

  final void Function(Canvas canvas, Size size) paintSticker;

  @override
  void paint(Canvas canvas, Size size) => paintSticker(canvas, size);

  @override
  bool shouldRepaint(_Sticker oldDelegate) => false;
}

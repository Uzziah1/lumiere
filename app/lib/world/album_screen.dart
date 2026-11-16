import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../audio/audio.dart';
import '../save/game_state.dart';
import '../stories/registry.dart';
import '../story/common_lines.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/colombe_bubble.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/round_button.dart';
import 'world.dart';

/// L'album d'autocollants de l'enfant : un emplacement par histoire.
class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameScope.read(context).current == null) {
        context.go('/profils');
        return;
      }
      AudioScope.of(context).narrator
          .play(commonAudioPath('album', 'all'), text: 'Voici ton album d’autocollants !');
    });
  }

  void _show(Island island) {
    final pack = storyPacks[island.id]!;
    AudioScope.of(context).sfx.play(Sfx.star);
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x993B2418),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 260,
                height: 260,
                child: CustomPaint(painter: _StickerPainter(pack.paintSticker)),
              ),
              const SizedBox(height: 12),
              Text(island.title, style: LumiereText.title(26, color: Palette.cream)),
              Text(island.reference, style: LumiereText.text(17, color: Palette.cream)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final profile = state.current;
    if (profile == null) return const Scaffold(backgroundColor: Palette.paper);
    final earned = allIslands.where((i) => state.progress(i.id).sticker).length;
    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 420;
              final cell = math
                  .min(
                    (constraints.maxWidth - 120) / 4,
                    (constraints.maxHeight - (compact ? 110 : 160)) / 2 - 30,
                  )
                  .clamp(70.0, 200.0);
              return Stack(
                children: [
                  Positioned(
                    left: 12,
                    top: 8,
                    child: RoundPaperButton(
                      icon: Icons.map_rounded,
                      label: 'Retour à la carte',
                      size: compact ? 44 : 54,
                      onPressed: () => context.go('/carte'),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('L’album de ${profile.name}', style: LumiereText.title(compact ? 24 : 34)),
                          SizedBox(height: compact ? 4 : 8),
                          ColombeBubble(
                            text: '$earned autocollant${earned > 1 ? 's' : ''} sur ${allIslands.length}',
                            size: compact ? 30 : 40,
                          ),
                          SizedBox(height: compact ? 8 : 18),
                          Wrap(
                            spacing: 18,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final island in allIslands)
                                _Slot(
                                  key: ValueKey('album-${island.id}'),
                                  island: island,
                                  size: cell,
                                  earned: state.progress(island.id).sticker,
                                  onTap: () => _show(island),
                                ),
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
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    super.key,
    required this.island,
    required this.size,
    required this.earned,
    required this.onTap,
  });

  final Island island;
  final double size;
  final bool earned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pack = storyPacks[island.id];
    return Semantics(
      button: earned,
      label: earned ? 'Autocollant : ${island.title}' : '${island.title}, autocollant à gagner',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: earned ? onTap : null,
        child: SizedBox(
          width: size + 20,
          child: Column(
            children: [
              SizedBox(
                width: size,
                height: size,
                child: earned && pack != null
                    ? CustomPaint(painter: _StickerPainter(pack.paintSticker))
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x22B07A4F),
                          border: Border.all(color: const Color(0x66B07A4F), width: 3),
                        ),
                        child: Center(
                          child: Text(
                            '?',
                            style: LumiereText.title(size * 0.4, color: const Color(0x88B07A4F)),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                island.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: LumiereText.text(
                  13,
                  bold: true,
                  color: earned ? Palette.ink : const Color(0x997A3F25),
                ),
              ),
            ],
          ),
        ),
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

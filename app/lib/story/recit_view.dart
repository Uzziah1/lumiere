import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

import '../audio/audio.dart';
import '../save/game_state.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/paper_button.dart';
import '../widgets/round_button.dart';
import 'story.dart';
import 'story_game.dart';
import 'story_session.dart';

/// Le récit animé : une scène après l'autre, racontée par la narratrice.
///
/// Pour chaque scène : la narratrice raconte, puis dit ce qu'il faut faire.
/// Quand l'enfant a fait l'action (et que la narration est finie), la flèche
/// « Suite » apparaît. Si rien ne se passe, un anneau doré montre où toucher.
class RecitView extends StatefulWidget {
  const RecitView({super.key, required this.onFinished, required this.onExit});

  final VoidCallback onFinished;
  final VoidCallback onExit;

  @override
  State<RecitView> createState() => RecitViewState();
}

class RecitViewState extends State<RecitView> {
  StoryGame? _game;
  int index = 0;
  bool _narrating = false;
  bool _afterPending = false;
  int _speech = 0;
  Timer? _hintTimer;
  late StorySession _session;

  StoryGame get game => _game!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _session = StorySession.of(context);
    if (_game == null) {
      _game = StoryGame(
        stages: _session.pack.stages,
        reducedMotion: MediaQuery.disableAnimationsOf(context),
        sfx: _session.sfx,
      );
      _game!.stageDone.addListener(_onStageDone);
      // Le décor est posé dès que le jeu est prêt.
      WidgetsBinding.instance.addPostFrameCallback((_) => _enter(0));
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _speech++;
    _session.narrator.stop();
    _game?.stageDone.removeListener(_onStageDone);
    super.dispose();
  }

  Future<void> _enter(int i) async {
    if (!mounted) return;
    final scene = _session.story.scenes[i];
    await game.loaded;
    if (!mounted) return;
    setState(() {
      index = i;
      _afterPending = false;
    });
    game.showStage(scene.stage);
    await _say(['scene.${scene.id}', 'scene.${scene.id}.action']);
  }

  /// Dit les phrases [keys] à la suite ; une nouvelle demande annule la précédente.
  Future<void> _say(List<String> keys) async {
    final token = ++_speech;
    _hintTimer?.cancel();
    game.hintVisible = false;
    setState(() => _narrating = true);
    for (final key in keys) {
      await _session.say(key);
      if (token != _speech || !mounted) return;
    }
    setState(() => _narrating = false);
    if (_afterPending) {
      _afterPending = false;
      await _say(['scene.${_scene.id}.after']);
      return;
    }
    if (!game.stageDone.value) {
      _hintTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && !game.stageDone.value) game.hintVisible = true;
      });
    }
  }

  void _onStageDone() {
    if (!game.stageDone.value) return;
    _hintTimer?.cancel();
    setState(() {});
    if (_scene.after == null) return;
    if (_narrating) {
      _afterPending = true;
    } else {
      _say(['scene.${_scene.id}.after']);
    }
  }

  void replay() {
    _afterPending = false;
    final keys = ['scene.${_scene.id}', 'scene.${_scene.id}.action'];
    if (game.stageDone.value && _scene.after != null) keys.add('scene.${_scene.id}.after');
    _say(keys);
  }

  void next() {
    _session.sfx.play(Sfx.tap);
    if (index + 1 >= _session.story.scenes.length) {
      _speech++;
      _session.narrator.stop();
      widget.onFinished();
    } else {
      _enter(index + 1);
    }
  }

  StoryScene get _scene => _session.story.scenes[index];

  bool get canContinue => (_game?.stageDone.value ?? false) && !_narrating;

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final scene = session.story.scenes[index];
    final scenes = session.story.scenes.length;
    return Stack(
      children: [
        Positioned.fill(child: GameWidget(game: game)),
        Positioned.fill(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 420;
                final buttonSize = compact ? 48.0 : 56.0;
                return Stack(
                  children: [
                    Positioned(
                      left: 12,
                      top: 8,
                      child: RoundPaperButton(
                        icon: Icons.close_rounded,
                        label: 'Quitter l’histoire',
                        size: buttonSize,
                        onPressed: widget.onExit,
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _ProgressDots(count: scenes, current: index),
                      ),
                    ),
                    Positioned(right: 12, top: 10, child: _Chip(text: scene.reference)),
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: RoundPaperButton(
                        icon: Icons.volume_up_rounded,
                        label: 'Réécouter',
                        size: buttonSize,
                        onPressed: replay,
                      ),
                    ),
                    if (GameScope.maybeOf(context)?.settings.subtitlesFor(session.age) ??
                        session.age.showsSubtitles)
                      Positioned(
                        left: buttonSize + 24,
                        right: buttonSize * 2.6 + 24,
                        bottom: 10,
                        child: _Subtitle(
                          text: session.text(
                            game.stageDone.value && scene.after != null
                                ? 'scene.${scene.id}.after'
                                : 'scene.${scene.id}',
                          ),
                          action: game.stageDone.value ? null : session.text('scene.${scene.id}.action'),
                          compact: compact,
                        ),
                      ),
                    Positioned(
                      right: 12,
                      bottom: 10,
                      child: AnimatedScale(
                        scale: canContinue ? 1 : 0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutBack,
                        child: PaperButton(
                          label: 'Suite',
                          icon: Icons.arrow_forward_rounded,
                          size: compact ? PaperButtonSize.small : PaperButtonSize.large,
                          face: Palette.gold,
                          edge: Palette.goldDeep,
                          foreground: Palette.ink,
                          onPressed: canContinue ? next : null,
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
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Scène ${current + 1} sur $count',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: const Color(0x55FFF8EC), borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == current ? 22 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i <= current ? Palette.gold : Palette.cream,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Palette.cream.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, size: 18, color: Palette.inkSoft),
            const SizedBox(width: 6),
            Text(text, style: LumiereText.title(15, weight: 500, color: Palette.inkSoft)),
          ],
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.text, required this.action, required this.compact});

  final String text;
  final String? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 14.5 : 18.0;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: math.max(60, MediaQuery.sizeOf(context).height * 0.34),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Palette.cream.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 14, offset: Offset(0, 6))],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: compact ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(frenchSpacing(text), style: LumiereText.text(size)),
                if (action != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    frenchSpacing(action!),
                    style: LumiereText.text(size, bold: true, color: Palette.lagoonDeep),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

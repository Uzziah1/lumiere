import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../art/paper.dart';
import '../audio/audio.dart';
import '../games/chronology_game.dart';
import '../games/game_frame.dart';
import '../games/memory_game.dart';
import '../games/seek_game.dart';
import '../games/verse_game.dart';
import '../save/game_state.dart';
import '../world/world.dart';
import '../stories/registry.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import 'age_group.dart';
import 'common_lines.dart';
import 'recit_view.dart';
import 'story.dart';
import 'story_hub.dart';
import 'story_part.dart';
import 'story_intro.dart';
import 'story_repository.dart';
import 'story_reward.dart';
import 'story_session.dart';

/// Une histoire de bout en bout : choix de l'âge, récit animé, jeux, verset,
/// récompense.
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.storyId, this.repository});

  final String storyId;
  final StoryRepository? repository;

  @override
  State<StoryScreen> createState() => StoryScreenState();
}

enum StoryPhase { intro, recit, hub, game, reward }

class StoryScreenState extends State<StoryScreen> {
  late final StoryRepository _repository = widget.repository ?? StoryRepository();
  late final Future<(Story, CommonLines)> _loading = _load();

  StoryPhase phase = StoryPhase.intro;
  StoryPart? game;
  AgeGroup? age;
  final stars = <StoryPart>{};

  Future<(Story, CommonLines)> _load() async =>
      (await _repository.story(widget.storyId), await _repository.common());

  bool _fromProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (age != null || _fromProfile) return;
    // Avec un profil, l'âge est connu et les étoiles déjà gagnées sont reprises.
    final state = GameScope.read(context);
    final profile = state.current;
    if (profile != null) {
      _fromProfile = true;
      age = profile.age;
      phase = StoryPhase.recit;
      stars.addAll(state.progress(widget.storyId).parts);
    }
  }

  void _save(StoryPart part) => GameScope.read(context).recordPart(widget.storyId, part);

  void _go(StoryPhase next, {StoryPart? part}) {
    if (next == StoryPhase.reward) GameScope.read(context).earnSticker(widget.storyId);
    setState(() {
      phase = next;
      game = part;
    });
  }

  void _earn(StoryPart part) {
    _save(part);
    setState(() => stars.add(part));
    _go(StoryPhase.hub);
  }

  void _home() {
    AudioScope.of(context).narrator.stop();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pack = storyPacks[widget.storyId]!;
    final audio = AudioScope.of(context);
    return Scaffold(
      backgroundColor: Palette.paper,
      body: FutureBuilder<(Story, CommonLines)>(
        future: _loading,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Cette histoire n’a pas pu s’ouvrir.', style: LumiereText.title(24)));
          }
          if (!snapshot.hasData) return const _Loading();
          final (story, common) = snapshot.data!;
          if (age == null) {
            return CustomPaint(
              painter: _Backdrop(),
              child: StoryIntro(
                story: story,
                paintSticker: pack.paintSticker,
                onExit: _home,
                onStart: (chosen) {
                  audio.sfx.play(Sfx.tap);
                  setState(() {
                    age = chosen;
                    phase = StoryPhase.recit;
                  });
                },
              ),
            );
          }
          return StorySession(
            story: story,
            common: common,
            age: age!,
            pack: pack,
            narrator: audio.narrator,
            sfx: audio.sfx,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: KeyedSubtree(key: ValueKey('$phase-$game'), child: _phase(context)),
            ),
          );
        },
      ),
    );
  }

  Widget _phase(BuildContext context) {
    switch (phase) {
      case StoryPhase.intro:
      case StoryPhase.recit:
        return RecitView(
          onExit: _home,
          onFinished: () {
            _save(StoryPart.recit);
            stars.add(StoryPart.recit);
            _go(StoryPhase.hub);
          },
        );
      case StoryPhase.hub:
        return CustomPaint(
          painter: _Backdrop(),
          child: StoryHub(
            stars: stars,
            onExit: _home,
            onOpen: (part) => _go(StoryPhase.game, part: part),
            onFinish: () => _go(StoryPhase.reward),
          ),
        );
      case StoryPhase.game:
        final part = game!;
        final (title, key) = switch (part) {
          StoryPart.chronology => ('Dans l’ordre', 'game.chronology'),
          StoryPart.seek => ('Cache-cache', 'game.seek'),
          StoryPart.memory => ('Les paires', 'game.memory'),
          _ => ('Le verset', 'game.verse'),
        };
        return GameFrame(
          title: title,
          instructionKey: key,
          onExit: () => _go(StoryPhase.hub),
          onDone: () => _earn(part),
          builder: (context, complete, say) => switch (part) {
            StoryPart.chronology => ChronologyGame(complete: complete, say: say),
            StoryPart.seek => SeekGame(complete: complete, say: say),
            StoryPart.memory => MemoryGame(complete: complete, say: say),
            _ => VerseGame(complete: complete, say: say),
          },
        );
      case StoryPhase.reward:
        return CustomPaint(
          painter: _Backdrop(),
          child: StoryReward(
            stars: stars.length,
            homeLabel: _fromProfile ? 'La carte' : 'Accueil',
            friend: _fromProfile ? islandFor(widget.storyId)?.treasure : null,
            onHome: _home,
            onReplay: () => _go(StoryPhase.hub),
          ),
        );
    }
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chargement…',
      child: CustomPaint(painter: _Backdrop(), child: const SizedBox.expand()),
    );
  }
}

class _Backdrop extends CustomPainter {
  final _grain = PaperGrain(opacity: 0.07);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE3F0), Palette.cream, Palette.paper],
          stops: [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );
    _grain.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_Backdrop oldDelegate) => false;
}

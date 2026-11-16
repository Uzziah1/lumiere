import 'dart:async';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../art/colombe.dart';
import '../audio/audio.dart';
import '../save/game_state.dart';
import '../story/common_lines.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/paper_button.dart';
import '../widgets/parental_gate.dart';

/// Les écrans où l'on compte le temps de jeu (pas l'accueil ni l'espace parents).
bool countsAsPlay(String path) =>
    path == '/carte' ||
    path == '/album' ||
    path == '/tresor' ||
    path == '/jardin' ||
    path.startsWith('/histoire/');

/// Compte le temps de jeu de l'enfant actif et, si les parents ont fixé une
/// limite, prévient deux minutes avant puis affiche « À demain ! ».
class PlayTimeKeeper extends StatefulWidget {
  const PlayTimeKeeper({
    super.key,
    required this.router,
    required this.state,
    required this.child,
    this.tick = const Duration(seconds: 15),
    this.enabled = true,
  });

  final GoRouter router;
  final GameState state;
  final Widget child;

  /// Pas du compteur.
  final Duration tick;

  /// Faux dans la plupart des tests (pas de minuterie qui tourne).
  final bool enabled;

  @override
  State<PlayTimeKeeper> createState() => PlayTimeKeeperState();
}

class PlayTimeKeeperState extends State<PlayTimeKeeper> with WidgetsBindingObserver {
  Timer? _timer;
  bool _foreground = true;
  bool _warned = false;

  String get _path => widget.router.routerDelegate.currentConfiguration.uri.path;

  bool get _playing => _foreground && countsAsPlay(_path) && widget.state.current != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.router.routerDelegate.addListener(_refresh);
    widget.state.addListener(_refresh);
    if (widget.enabled) _timer = Timer.periodic(widget.tick, (_) => onTick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    widget.router.routerDelegate.removeListener(_refresh);
    widget.state.removeListener(_refresh);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
  }

  bool _refreshScheduled = false;

  /// La navigation peut prévenir en pleine construction : on redessine juste après.
  void _refresh() {
    if (_refreshScheduled || !mounted) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Un pas de compteur (appelé par la minuterie, ou directement dans les tests).
  void onTick() {
    if (!_playing || widget.state.timeIsUp) return;
    widget.state.addPlaytime(widget.tick.inSeconds);
    final left = widget.state.remainingToday;
    if (left == null) return;
    if (left > const Duration(minutes: 2)) {
      _warned = false;
    } else if (!_warned && left > Duration.zero) {
      _warned = true;
      _say('time_soon', 'Encore deux minutes, et on fera une pause !');
    }
    if (left == Duration.zero) _say('time_up', 'C’est l’heure de se reposer. On se retrouve demain !');
  }

  void _say(String key, String text) {
    context.findAncestorWidgetOfExactType<AudioScope>()?.narrator.play(
      commonAudioPath(key, 'all'),
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocked = countsAsPlay(_path) && widget.state.current != null && widget.state.timeIsUp;
    final left = widget.state.remainingToday;
    final soon =
        countsAsPlay(_path) && left != null && left > Duration.zero && left <= const Duration(minutes: 2);
    return Stack(
      children: [
        widget.child,
        if (soon)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  key: const ValueKey('time-soon'),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Palette.cream,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Text(
                    'Encore ${math.max(1, left.inMinutes)} min avant la pause',
                    style: LumiereText.text(15, bold: true, color: Palette.inkSoft),
                  ),
                ),
              ),
            ),
          ),
        if (blocked)
          Positioned.fill(
            child: TimeUpScreen(
              onHome: () => widget.router.go('/'),
              onExtra: (minutes) => widget.state.grantExtraTime(minutes),
            ),
          ),
      ],
    );
  }
}

/// « À demain ! » : Colombe s'est endormie sous la lune. Un parent peut
/// ajouter du temps après la barrière parentale (affichée dans l'écran même,
/// car cet écran recouvre la navigation).
class TimeUpScreen extends StatefulWidget {
  const TimeUpScreen({super.key, required this.onHome, required this.onExtra, this.random});

  final VoidCallback onHome;
  final void Function(int minutes) onExtra;
  final math.Random? random;

  @override
  State<TimeUpScreen> createState() => _TimeUpScreenState();
}

enum _Step { rest, gate, choose }

class _TimeUpScreenState extends State<TimeUpScreen> {
  _Step step = _Step.rest;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B2539),
      child: CustomPaint(
        painter: _NightSky(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: switch (step) {
                _Step.rest => _rest(),
                _Step.gate => ParentalGate(
                  random: widget.random ?? math.Random(),
                  onResult: (ok) => setState(() => step = ok ? _Step.choose : _Step.rest),
                ),
                _Step.choose => _choose(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _rest() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(width: 150, height: 120, child: CustomPaint(painter: _SleepingDove())),
      const SizedBox(height: 12),
      Text(
        'C’est l’heure de se reposer !',
        textAlign: TextAlign.center,
        style: LumiereText.title(32, color: Palette.cream),
      ),
      const SizedBox(height: 8),
      Text(
        frenchSpacing('Tu as bien joué aujourd’hui. Colombe s’est endormie : on se retrouve demain !'),
        textAlign: TextAlign.center,
        style: LumiereText.text(19, color: Palette.cream),
      ),
      const SizedBox(height: 22),
      Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          PaperButton(
            label: 'Accueil',
            icon: Icons.home_rounded,
            size: PaperButtonSize.small,
            onPressed: widget.onHome,
          ),
          PaperButton.secondary(
            label: 'Parents',
            icon: Icons.lock_rounded,
            onPressed: () => setState(() => step = _Step.gate),
          ),
        ],
      ),
    ],
  );

  Widget _choose() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Ajouter du temps aujourd’hui', style: LumiereText.title(26, color: Palette.cream)),
      const SizedBox(height: 16),
      Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          for (final m in const [15, 30])
            PaperButton(
              key: ValueKey('extra-$m'),
              label: '+ $m min',
              size: PaperButtonSize.small,
              onPressed: () {
                widget.onExtra(m);
                setState(() => step = _Step.rest);
              },
            ),
          PaperButton.secondary(label: 'Annuler', onPressed: () => setState(() => step = _Step.rest)),
        ],
      ),
    ],
  );
}

class _NightSky extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF141C3A), Color(0xFF26335E), Color(0xFF3F4E80)],
        ).createShader(Offset.zero & size),
    );
    final random = math.Random(12);
    final star = Paint()..color = const Color(0xCCFFF6DC);
    for (var i = 0; i < 60; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        1 + random.nextDouble() * 1.5,
        star,
      );
    }
    final moon = Offset(size.width * 0.82, size.height * 0.18);
    canvas.drawCircle(moon, 34, Paint()..color = const Color(0xFFFFF0B3));
    canvas.drawCircle(moon + const Offset(14, -8), 30, Paint()..color = const Color(0xFF1E2848));
  }

  @override
  bool shouldRepaint(_NightSky oldDelegate) => false;
}

class _SleepingDove extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Colombe.paint(canvas, size, flap: 0, blink: 1);
    final z = TextPainter(
      text: TextSpan(
        text: 'z z',
        style: LumiereText.title(22, color: Palette.cream),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    z.paint(canvas, Offset(size.width * 0.7, 0));
  }

  @override
  bool shouldRepaint(_SleepingDove oldDelegate) => false;
}

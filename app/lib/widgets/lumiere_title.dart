import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';

/// Le titre « Lumière » en lettres de papier : chaque lettre, crème bordée de
/// braise, flotte doucement avec un petit décalage, comme une vague.
class LumiereTitle extends StatefulWidget {
  const LumiereTitle({super.key, this.text = 'Lumière', required this.fontSize, this.animate = true});

  final String text;
  final double fontSize;
  final bool animate;

  @override
  State<LumiereTitle> createState() => _LumiereTitleState();
}

class _LumiereTitleState extends State<LumiereTitle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(LumiereTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letters = widget.text.characters.toList();
    final fill = LumiereText.title(widget.fontSize, color: Palette.cream).copyWith(
      shadows: const [Shadow(color: Color(0x40000000), offset: Offset(0, 2))],
    );
    final stroke = LumiereText.title(widget.fontSize).copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = widget.fontSize * 0.11
        ..strokeJoin = StrokeJoin.round
        ..color = Palette.ember,
      shadows: [
        Shadow(
          color: Palette.shadow,
          offset: Offset(0, widget.fontSize * 0.08),
          blurRadius: widget.fontSize * 0.12,
        ),
      ],
    );

    return Semantics(
      header: true,
      label: widget.text,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < letters.length; i++)
              Transform.translate(
                offset: Offset(
                  0,
                  math.sin((_controller.value - i * 0.09) * math.pi * 2) * widget.fontSize * 0.045,
                ),
                child: Stack(
                  children: [
                    Text(letters[i], style: stroke),
                    Text(letters[i], style: fill),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

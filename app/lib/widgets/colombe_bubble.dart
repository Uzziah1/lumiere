import 'package:material_ui/material_ui.dart';

import '../art/colombe.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';

/// Colombe qui parle : elle bat des ailes à côté d'une bulle de papier.
class ColombeBubble extends StatefulWidget {
  const ColombeBubble({super.key, required this.text, this.size = 64, this.maxWidth = 520});

  final String text;
  final double size;
  final double maxWidth;

  @override
  State<ColombeBubble> createState() => _ColombeBubbleState();
}

class _ColombeBubbleState extends State<ColombeBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _flap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _flap.stop();
    } else if (!_flap.isAnimating) {
      _flap.repeat();
    }
  }

  @override
  void dispose() {
    _flap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExcludeSemantics(
          child: SizedBox(
            width: widget.size * Colombe.aspectRatio,
            height: widget.size,
            child: CustomPaint(painter: ColombePainter(animation: _flap)),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: DecoratedBox(
                key: ValueKey(widget.text),
                decoration: BoxDecoration(
                  color: Palette.cream,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 12, offset: Offset(0, 5))],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Text(frenchSpacing(widget.text), style: LumiereText.text(18, color: Palette.ink)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

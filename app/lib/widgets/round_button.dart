import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/palette.dart';

/// Bouton rond en papier épais, pour les icônes (fermer, réécouter…).
class RoundPaperButton extends StatefulWidget {
  const RoundPaperButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 56,
    this.face = Palette.cream,
    this.edge = const Color(0xFFE2C9A6),
    this.foreground = Palette.inkSoft,
  });

  final IconData icon;

  /// Annoncé par les lecteurs d'écran.
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final Color face;
  final Color edge;
  final Color foreground;

  @override
  State<RoundPaperButton> createState() => _RoundPaperButtonState();
}

class _RoundPaperButtonState extends State<RoundPaperButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final depth = widget.size * 0.09;
    final sink = _pressed ? depth * 0.75 : 0.0;
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.selectionClick();
          widget.onPressed?.call();
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size + depth,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: widget.size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.edge,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Palette.shadow, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                left: 0,
                right: 0,
                top: sink,
                height: widget.size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.lerp(widget.face, Colors.white, 0.2)!, widget.face],
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.foreground, size: widget.size * 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

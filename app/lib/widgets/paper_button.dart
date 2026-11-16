import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';

/// Gros bouton en papier épais : une face colorée posée sur sa tranche plus
/// sombre. Quand on appuie, la face s'enfonce. Taille pensée pour les petits doigts.
class PaperButton extends StatefulWidget {
  const PaperButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.face = Palette.lagoon,
    this.edge = Palette.lagoonDeep,
    this.foreground = Palette.cream,
    this.size = PaperButtonSize.large,
  });

  /// Bouton secondaire, crème et encre.
  const PaperButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = PaperButtonSize.small,
  }) : face = Palette.cream,
       edge = const Color(0xFFE2C9A6),
       foreground = Palette.inkSoft;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color face;
  final Color edge;
  final Color foreground;
  final PaperButtonSize size;

  @override
  State<PaperButton> createState() => _PaperButtonState();
}

enum PaperButtonSize {
  small(height: 52, depth: 5, fontSize: 19, padding: 22),
  large(height: 72, depth: 8, fontSize: 30, padding: 38);

  const PaperButtonSize({
    required this.height,
    required this.depth,
    required this.fontSize,
    required this.padding,
  });

  final double height;
  final double depth;
  final double fontSize;
  final double padding;
}

class _PaperButtonState extends State<PaperButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final enabled = widget.onPressed != null;
    final sink = _pressed ? s.depth * 0.75 : 0.0;
    final radius = BorderRadius.circular(s.height / 2);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapCancel: () => _setPressed(false),
        onTapUp: enabled
            ? (_) {
                _setPressed(false);
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Stack(
            children: [
              // Tranche du papier, avec l'ombre sur le décor.
              Positioned.fill(
                top: s.depth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.edge,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: Palette.shadow,
                        blurRadius: _pressed ? 6 : 14,
                        offset: Offset(0, _pressed ? 3 : 7),
                      ),
                    ],
                  ),
                ),
              ),
              // Face du bouton : c'est elle qui donne sa taille au bouton.
              AnimatedPadding(
                duration: const Duration(milliseconds: 70),
                padding: EdgeInsets.only(top: sink, bottom: s.depth - sink),
                child: Container(
                  height: s.height,
                  padding: EdgeInsets.symmetric(horizontal: s.padding),
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.lerp(widget.face, Colors.white, 0.18)!, widget.face],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.foreground, size: s.fontSize * 1.25),
                        SizedBox(width: s.fontSize * 0.35),
                      ],
                      Text(widget.label, style: LumiereText.title(s.fontSize, color: widget.foreground)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

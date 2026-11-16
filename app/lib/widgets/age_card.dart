import 'package:material_ui/material_ui.dart';

import '../art/animals.dart';
import '../art/people.dart';
import '../story/age_group.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';

/// Carte d'un âge (Agneaux, Bergers, Explorateurs) avec son petit dessin.
class AgeCard extends StatefulWidget {
  const AgeCard({
    super.key,
    required this.age,
    required this.width,
    required this.compact,
    required this.onTap,
    this.selected = false,
  });

  final AgeGroup age;
  final double width;
  final bool compact;
  final VoidCallback onTap;

  /// Carte choisie (formulaire de profil) : bord doré.
  final bool selected;

  @override
  State<AgeCard> createState() => _AgeCardState();
}

class _AgeCardState extends State<AgeCard> {
  bool _pressed = false;

  static const _colors = {
    AgeGroup.agneaux: Color(0xFFFFE3D3),
    AgeGroup.bergers: Color(0xFFDDEFD9),
    AgeGroup.explorateurs: Color(0xFFDCE7F5),
  };

  @override
  Widget build(BuildContext context) {
    final h = widget.compact ? widget.width * 0.82 : widget.width * 1.05;
    return Semantics(
      button: true,
      label: '${widget.age.label}, ${widget.age.ages}',
      selected: widget.selected,
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('age-${widget.age.name}'),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            width: widget.width,
            height: h,
            decoration: BoxDecoration(
              color: _colors[widget.age],
              borderRadius: BorderRadius.circular(24),
              border: widget.selected
                  ? Border.all(color: Palette.gold, width: 4)
                  : const Border(bottom: BorderSide(color: Color(0x33000000), width: 5)),
              boxShadow: [
                const BoxShadow(color: Palette.shadow, blurRadius: 12, offset: Offset(0, 6)),
                if (widget.selected)
                  BoxShadow(color: Palette.gold.withValues(alpha: 0.6), blurRadius: 16, spreadRadius: 2),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(painter: _AgeIcon(widget.age), child: const SizedBox.expand()),
                ),
                Text(widget.age.label, style: LumiereText.title(widget.compact ? 19 : 24)),
                Text(
                  widget.age.ages,
                  style: LumiereText.text(widget.compact ? 13 : 16, color: Palette.inkSoft),
                ),
                SizedBox(height: widget.compact ? 6 : 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeIcon extends CustomPainter {
  _AgeIcon(this.age);

  final AgeGroup age;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromCenter(
      center: size.center(Offset(0, size.height * 0.04)),
      width: size.height * 0.8,
      height: size.height * 0.8,
    );
    switch (age) {
      case AgeGroup.agneaux:
        paintAnimal(canvas, Animal.sheep, box);
      case AgeGroup.bergers:
        paintPerson(canvas, Offset(box.center.dx, box.bottom), box.height, NoahFamily.shem, wave: 0.6);
      case AgeGroup.explorateurs:
        paintAnimal(canvas, Animal.owl, box);
    }
  }

  @override
  bool shouldRepaint(_AgeIcon oldDelegate) => oldDelegate.age != age;
}

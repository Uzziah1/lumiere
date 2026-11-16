import 'package:material_ui/material_ui.dart';

import '../art/animals.dart';
import '../theme/palette.dart';

/// L'avatar d'un enfant : son animal dans un médaillon de papier.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.avatar, this.size = 72, this.selected = false});

  final String avatar;
  final double size;
  final bool selected;

  static const _backgrounds = {
    'sheep': Color(0xFFFFE3D3),
    'lion': Color(0xFFFFE9B8),
    'owl': Color(0xFFDCE7F5),
    'rabbit': Color(0xFFF3E0EC),
    'giraffe': Color(0xFFFFF0C9),
    'elephant': Color(0xFFDDE3EE),
    'tortoise': Color(0xFFDDEFD9),
    'dove': Color(0xFFE6F2F8),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgrounds[avatar] ?? Palette.cream,
        border: Border.all(color: selected ? Palette.gold : Palette.cream, width: size * 0.06),
        boxShadow: [
          const BoxShadow(color: Palette.shadow, blurRadius: 10, offset: Offset(0, 4)),
          if (selected)
            BoxShadow(color: Palette.gold.withValues(alpha: 0.6), blurRadius: 14, spreadRadius: 2),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.14),
        child: CustomPaint(painter: _AnimalPainter(Animal.byName(avatar))),
      ),
    );
  }
}

class _AnimalPainter extends CustomPainter {
  _AnimalPainter(this.animal);

  final Animal animal;

  @override
  void paint(Canvas canvas, Size size) => paintAnimal(canvas, animal, Offset.zero & size);

  @override
  bool shouldRepaint(_AnimalPainter oldDelegate) => oldDelegate.animal != animal;
}

import 'package:material_ui/material_ui.dart';

import '../art/paper.dart';
import '../theme/palette.dart';

/// Fond des écrans de menu : ciel clair vers papier crème, avec le grain.
class PaperBackdrop extends StatelessWidget {
  const PaperBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BackdropPainter(), child: child);
}

class _BackdropPainter extends CustomPainter {
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
  bool shouldRepaint(_BackdropPainter oldDelegate) => false;
}

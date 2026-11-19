import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Brand mark: a viewfinder frame with a spark, drawn in code so it scales
/// crisply and follows the theme.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Snaptiq logo',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: size * 0.3,
              offset: Offset(0, size * 0.1),
            ),
          ],
        ),
        child: CustomPaint(painter: _LogoPainter()),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round;

    final inset = s * 0.24;
    final arm = s * 0.16;
    final corners = <(Offset, Offset, Offset)>[
      (
        Offset(inset, inset + arm),
        Offset(inset, inset),
        Offset(inset + arm, inset),
      ),
      (
        Offset(s - inset - arm, inset),
        Offset(s - inset, inset),
        Offset(s - inset, inset + arm),
      ),
      (
        Offset(inset, s - inset - arm),
        Offset(inset, s - inset),
        Offset(inset + arm, s - inset),
      ),
      (
        Offset(s - inset - arm, s - inset),
        Offset(s - inset, s - inset),
        Offset(s - inset, s - inset - arm),
      ),
    ];
    for (final (a, b, c) in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy),
        stroke,
      );
    }

    final bolt = Path()
      ..moveTo(s * 0.54, s * 0.34)
      ..lineTo(s * 0.42, s * 0.52)
      ..lineTo(s * 0.5, s * 0.52)
      ..lineTo(s * 0.46, s * 0.66)
      ..lineTo(s * 0.58, s * 0.47)
      ..lineTo(s * 0.5, s * 0.47)
      ..close();
    canvas.drawPath(bolt, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

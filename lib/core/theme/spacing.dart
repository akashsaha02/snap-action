import 'package:material_ui/material_ui.dart';

/// 8-point spacing scale.
abstract final class Spacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Acid Pop shape scale (assets/icons/developer/snaptiq_tokens.json).
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;

  /// Ink outline widths.
  static const double outlineThin = 1.5;
  static const double outline = 2;
  static const double outlineBold = 3;

  /// Offset of the hard (unblurred) brand shadow.
  static const double shadowOffset = 4;
  static const double shadowOffsetLarge = 6;

  static const double minTouchTarget = 48;

  static const pagePadding = EdgeInsets.symmetric(horizontal: md);
}

class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}

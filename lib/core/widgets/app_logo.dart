import 'package:material_ui/material_ui.dart';

/// Brand mark: the Snaptiq app icon from the brand kit. Picks the lime
/// variant in light mode and the ink variant in dark mode.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      dark
          ? 'assets/images/brand/logo_dark.png'
          : 'assets/images/brand/logo_light.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Snaptiq logo',
    );
  }
}

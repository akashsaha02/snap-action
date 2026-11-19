import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/spacing.dart';

/// The brand's hard, unblurred offset shadow ("Acid Pop"): ink on light,
/// acid lime on dark. Wrap a card, button or FAB with the same [shape].
class PopShadow extends StatelessWidget {
  const PopShadow({
    required this.child,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(Spacing.radiusMd)),
    ),
    this.offset = Spacing.shadowOffset,
    super.key,
  });

  /// A pill-shaped shadow for buttons and extended FABs.
  const PopShadow.pill({required this.child, super.key})
    : shape = const StadiumBorder(),
      offset = Spacing.shadowOffset;

  final Widget child;
  final ShapeBorder shape;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keep the shadow inside the widget's own bounds.
      padding: EdgeInsets.only(right: offset, bottom: offset),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          shadows: [
            BoxShadow(
              color: context.statusColors.shadowHard,
              offset: Offset(offset, offset),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Tiq, the mascot, in the situations the app shows him
/// (assets/images/illustrations, from the brand kit in assets/icons).
enum BrandArt {
  onboardingWelcome('onboarding_welcome'),
  onboardingPrivacy('onboarding_privacy'),
  onboardingActions('onboarding_actions'),
  emptyLibrary('empty_library'),
  noResults('no_results'),
  noReminders('no_reminders'),
  allDone('all_done'),
  error('error'),
  importing('importing');

  const BrandArt(this.file);

  final String file;

  String get asset => 'assets/images/illustrations/$file.png';
}

/// A brand illustration at a fixed logical size. Decorative: hidden from
/// screen readers, because the text next to it says the same thing.
class BrandIllustration extends StatelessWidget {
  const BrandIllustration(this.art, {this.size = 180, super.key});

  final BrandArt art;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        art.asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        // Shown before the first frame decodes, so layout never jumps.
        frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
          opacity: sync || frame != null ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
        errorBuilder: (context, _, _) => SizedBox(width: size, height: size),
      ),
    );
  }
}

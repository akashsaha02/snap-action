import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/states.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Shown while the database and settings load. Navigation away is driven by
/// the router redirect once [appBootstrapProvider] has a value.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(appBootstrapProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: boot.hasError
          ? ErrorState(
              message: l10n.splashLoadError,
              retryLabel: l10n.retry,
              onRetry: () => ref.invalidate(appBootstrapProvider),
            )
          : Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) => Opacity(
                  opacity: ((value - 0.85) / 0.15).clamp(0, 1),
                  child: Transform.scale(scale: value, child: child),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(size: 88),
                    const Gap(Spacing.lg),
                    Text(l10n.appName, style: theme.textTheme.headlineMedium),
                  ],
                ),
              ),
            ),
    );
  }
}

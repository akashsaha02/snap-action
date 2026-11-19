import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../core/services/settings_repository.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/app_logo.dart';
import '../application/app_lock.dart';

/// Covers the whole app, including dialogs, while the app lock is engaged,
/// and applies the "hide in recent apps" preference.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        lock.onBackground();
      case AppLifecycleState.resumed:
        lock.onForeground();
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appBootstrapProvider, (_, next) {
      final services = next.value;
      if (services == null) return;
      final secure = services.settings.getBool(SettingsKeys.secureWindow);
      if (secure) {
        unawaited(ref.read(platformServiceProvider).setSecure(secure: true));
      }
    });
    final locked = ref.watch(appLockProvider.select((s) => s.locked));
    return Stack(
      children: [
        // Keeps the app's semantics hidden from screen readers while locked.
        ExcludeSemantics(excluding: locked, child: widget.child),
        if (locked) const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(appLockProvider.notifier).unlock());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = ref.watch(appLockProvider.select((s) => s.message));
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(size: 72),
              const Gap(Spacing.lg),
              Text(
                'Snaptiq is locked',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const Gap(Spacing.xs),
              Text(
                'Use your fingerprint, face or screen lock to continue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const Gap(Spacing.md),
                Text(
                  message,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const Gap(Spacing.lg),
              FilledButton.icon(
                key: const Key('unlock_button'),
                onPressed: () => ref.read(appLockProvider.notifier).unlock(),
                icon: const Icon(Icons.lock_open),
                label: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

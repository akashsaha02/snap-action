import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/reminders/presentation/notification_coordinator.dart';
import '../features/screenshot_import/presentation/import_feedback.dart';
import '../l10n/generated/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      // Back from a non-home tab returns to Home before leaving the app.
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onTap(0);
      },
      child: Scaffold(
        body: NotificationCoordinator(
          child: ImportCoordinator(child: navigationShell),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: l10n.navCollections,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search_rounded),
              label: l10n.navSearch,
            ),
            NavigationDestination(
              icon: const Icon(Icons.alarm_outlined),
              selectedIcon: const Icon(Icons.alarm_rounded),
              label: l10n.navReminders,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}

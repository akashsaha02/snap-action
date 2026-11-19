import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/routes.dart';
import '../../../services/notifications/notification_service.dart';
import 'reminders_screen.dart';

/// Initializes notifications once the app is ready, re-registers scheduled
/// reminders and opens the screen a tapped notification points to.
class NotificationCoordinator extends ConsumerStatefulWidget {
  const NotificationCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationCoordinator> createState() =>
      _NotificationCoordinatorState();
}

class _NotificationCoordinatorState
    extends ConsumerState<NotificationCoordinator> {
  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final notifications = ref.read(notificationServiceProvider);
    try {
      await notifications.initialize(onOpen: _open);
      await ref.read(reminderServiceProvider).resyncAll();
      final launch = await notifications.launchRoute();
      if (launch != null) _open(launch);
    } on Object catch (e) {
      debugPrint('Notification setup failed: $e');
    }
  }

  void _open(String route) {
    if (!mounted) return;
    final router = ref.read(routerProvider);
    if (route.startsWith(NotificationService.actionPath)) {
      unawaited(_handleAction(Uri.parse(route)));
    } else if (route == Routes.reminders) {
      // The reminder has just become due: show the tab it is now on.
      router.go(RemindersScreen.location(tab: ReminderTab.overdue));
    } else if (route.startsWith('/screenshot/')) {
      unawaited(router.push(route));
    }
  }

  /// "Done" / "Snooze 1 hour" pressed on a reminder notification.
  Future<void> _handleAction(Uri uri) async {
    final service = ref.read(reminderServiceProvider);
    final id = int.tryParse(uri.queryParameters['id'] ?? '');
    final reminder = id == null ? null : await service.byNotificationId(id);
    if (reminder == null || !mounted) return;
    final snooze = uri.queryParameters['action'] == 'snooze';
    if (snooze) {
      await service.snooze(reminder.id, const Duration(hours: 1));
    } else {
      await service.complete(reminder.id);
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(
      rootNavigatorKey.currentContext ?? context,
    );
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          snooze
              ? '"${reminder.title}" snoozed for 1 hour'
              : '"${reminder.title}" marked as done',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

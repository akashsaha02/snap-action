import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/database/enums.dart';

/// Local notifications for reminders. Scheduling is inexact on Android so no
/// exact-alarm permission is needed; delivery may be delayed by the OS.
abstract interface class NotificationService {
  /// Route for a notification button ("Done", "Snooze"); the query carries
  /// `action` and the notification `id`.
  static const actionPath = '/reminder-action';

  /// [onOpen] receives the payload (an app route) when a notification is
  /// tapped while the app runs.
  Future<void> initialize({required void Function(String route) onOpen});

  /// Route of the notification that launched the app, if any.
  Future<String?> launchRoute();

  Future<bool> areEnabled();

  Future<bool> requestPermission();

  Future<void> schedule({
    required int id,
    required String title,
    required DateTime at,
    required String route,
    String? body,
    RepeatRule repeat = RepeatRule.none,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();

  String get timezone;
}

class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  String _timezone = 'UTC';

  static const _channel = AndroidNotificationDetails(
    'reminders',
    'Reminders',
    channelDescription: 'Reminders you created from your screenshots',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
    icon: smallIcon,
    color: Color(0xFF635BFF),
    // Both open the app briefly, which then updates the reminder; nothing
    // runs in the background.
    actions: [
      AndroidNotificationAction(
        actionDone,
        'Done',
        showsUserInterface: true,
        cancelNotification: true,
      ),
      AndroidNotificationAction(
        actionSnooze,
        'Snooze 1 hour',
        showsUserInterface: true,
        cancelNotification: true,
      ),
    ],
  );

  /// White silhouette of the logo (res/drawable-*/ic_stat_snapaction.png).
  static const smallIcon = 'ic_stat_snapaction';
  static const actionDone = 'done';
  static const actionSnooze = 'snooze';

  /// Route used when a notification button was pressed.
  static String actionRoute(String action, int? notificationId) =>
      '${NotificationService.actionPath}?action=$action&id=${notificationId ?? -1}';

  static String? _routeFor(NotificationResponse? response) {
    if (response == null) return null;
    final action = response.actionId;
    if (action == actionDone || action == actionSnooze) {
      return actionRoute(action!, response.id);
    }
    final route = response.payload;
    return route != null && route.startsWith('/') ? route : null;
  }

  @override
  String get timezone => _timezone;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize({required void Function(String route) onOpen}) async {
    if (_initialized) return;
    _initialized = true;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      _timezone = info.identifier;
      tz.setLocalLocation(tz.getLocation(_timezone));
    } on Object catch (e) {
      // Unknown zone identifiers fall back to UTC; times are still correct
      // because schedules are built from absolute instants.
      debugPrint('Timezone lookup failed: $e');
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/$smallIcon'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final route = _routeFor(response);
        if (route != null) onOpen(route);
      },
    );
  }

  @override
  Future<String?> launchRoute() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return _routeFor(details!.notificationResponse);
    }
    return null;
  }

  @override
  Future<bool> areEnabled() async {
    final android = _android;
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _android;
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime at,
    required String route,
    String? body,
    RepeatRule repeat = RepeatRule.none,
  }) async {
    final when = tz.TZDateTime.from(at, tz.local);
    if (repeat == RepeatRule.none &&
        !when.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: _channel,
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: route,
        matchDateTimeComponents: switch (repeat) {
          RepeatRule.none => null,
          RepeatRule.daily => DateTimeComponents.time,
          RepeatRule.weekly => DateTimeComponents.dayOfWeekAndTime,
          RepeatRule.monthly => DateTimeComponents.dayOfMonthAndTime,
        },
      );
    } on PlatformException catch (e) {
      debugPrint('Scheduling notification $id failed: ${e.message}');
    }
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}

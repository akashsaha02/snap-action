import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/reminder_defaults.dart';
import '../application/reminder_service.dart';
import 'reminder_editor.dart';

enum ReminderTab { today, upcoming, overdue, completed }

/// Splits active reminders into today, upcoming and overdue relative to [now].
Map<ReminderTab, List<ReminderItem>> groupReminders(
  List<ReminderItem> active,
  DateTime now,
) {
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final out = {for (final t in ReminderTab.values) t: <ReminderItem>[]};
  for (final r in active) {
    final at = r.reminder.scheduledAt;
    final tab = at.isBefore(now)
        ? ReminderTab.overdue
        : at.isBefore(tomorrow)
        ? ReminderTab.today
        : ReminderTab.upcoming;
    out[tab]!.add(r);
  }
  return out;
}

/// The tab to open with: the first one with reminders, overdue first, or
/// Today when nothing is scheduled.
ReminderTab defaultReminderTab(Map<ReminderTab, List<ReminderItem>> groups) {
  for (final t in const [
    ReminderTab.overdue,
    ReminderTab.today,
    ReminderTab.upcoming,
  ]) {
    if (groups[t]?.isNotEmpty ?? false) return t;
  }
  return ReminderTab.today;
}

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  /// Query parameter naming the tab to show (a [ReminderTab] name).
  static const tabParam = 'tab';

  /// Location of the Reminders tab, optionally opened on [tab]. A fresh
  /// token makes repeated taps switch the tab again even when the screen
  /// is already open.
  static String location({ReminderTab? tab}) => tab == null
      ? Routes.reminders
      : '${Routes.reminders}?$tabParam=${tab.name}'
            '&t=${DateTime.now().microsecondsSinceEpoch}';

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  /// Chosen by the user or the route; until then the first non-empty tab.
  ReminderTab? _tab;
  Uri? _handledUri;
  Timer? _ticker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Uri? uri;
    try {
      uri = GoRouterState.of(context).uri;
    } on GoError {
      uri = null;
    }
    if (uri == null || uri == _handledUri) return;
    _handledUri = uri;
    final tab = ReminderTab.values.asNameMap()[uri
        .queryParameters[RemindersScreen.tabParam]];
    if (tab != null) _tab = tab;
  }

  @override
  void initState() {
    super.initState();
    // Moves reminders between Today and Overdue while the screen is open.
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(remindersProvider(false));
    final completed = ref.watch(remindersProvider(true));
    final groups = groupReminders(active.value ?? const [], DateTime.now());
    if (_tab == null && active.hasValue) _tab = defaultReminderTab(groups);
    final tab = _tab ?? ReminderTab.today;
    final counts = {
      for (final t in ReminderTab.values)
        t: t == ReminderTab.completed
            ? (completed.value?.length ?? 0)
            : groups[t]!.length,
    };
    final items = tab == ReminderTab.completed
        ? completed
        : active.whenData((_) => groups[tab]!);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReminders)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new_reminder'),
        onPressed: () => showReminderEditor(context),
        icon: const Icon(Icons.add_alarm),
        label: const Text('New reminder'),
      ),
      body: Column(
        children: [
          const _PermissionBanner(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: Spacing.pagePadding,
            child: Row(
              children: [
                for (final t in ReminderTab.values)
                  Padding(
                    padding: const EdgeInsets.only(right: Spacing.xs),
                    child: ChoiceChip(
                      label: Text('${_label(t)} · ${counts[t]}'),
                      selected: tab == t,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _tab = t),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.when(
              loading: () => const SkeletonList(),
              error: (e, _) =>
                  ErrorState(message: 'Could not load reminders.', details: e),
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: tab == ReminderTab.completed
                          ? Icons.task_alt
                          : Icons.alarm_rounded,
                      title: switch (tab) {
                        ReminderTab.today => 'Nothing due today',
                        ReminderTab.upcoming => 'No upcoming reminders',
                        ReminderTab.overdue => 'Nothing overdue',
                        ReminderTab.completed => 'No completed reminders',
                      },
                      message: l10n.emptyRemindersBody,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.md,
                        Spacing.sm,
                        Spacing.md,
                        96,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Gap(Spacing.xs),
                      itemBuilder: (context, i) => _ReminderTile(item: list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static String _label(ReminderTab t) => switch (t) {
    ReminderTab.today => 'Today',
    ReminderTab.upcoming => 'Upcoming',
    ReminderTab.overdue => 'Overdue',
    ReminderTab.completed => 'Completed',
  };
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.item});

  final ReminderItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = item.reminder;
    final service = ref.read(reminderServiceProvider);
    final done = r.status == ReminderStatus.completed;
    final repeat = switch (r.repeatRule) {
      RepeatRule.none => null,
      RepeatRule.daily => 'Repeats daily',
      RepeatRule.weekly => 'Repeats weekly',
      RepeatRule.monthly => 'Repeats monthly',
    };
    return ReminderCard(
      key: ValueKey('reminder_${r.id}'),
      title: r.title,
      subtitle: [
        ?repeat,
        if (!r.notify) 'No notification',
        ?r.description,
      ].join(' · '),
      dueAt: r.scheduledAt,
      completed: done,
      overdue: !done && r.scheduledAt.isBefore(DateTime.now()),
      thumbnailPath: item.thumbnailPath,
      onToggleComplete: () async {
        if (done) {
          await service.reopen(r.id);
        } else {
          await service.complete(r.id);
          if (context.mounted) {
            context.showSnack(
              r.repeatRule == RepeatRule.none
                  ? 'Marked as done'
                  : 'Moved to the next occurrence',
            );
          }
        }
      },
      onTap: () => showReminderEditor(context, existing: r),
      trailing: PopupMenuButton<String>(
        tooltip: 'More',
        onSelected: (v) async {
          switch (v) {
            case 'snooze1h':
              await service.snooze(r.id, const Duration(hours: 1));
              if (context.mounted) context.showSnack('Snoozed for 1 hour');
            case 'snoozeTomorrow':
              final now = DateTime.now();
              final time = defaultReminderTime(
                ref.read(settingsRepositoryProvider),
              );
              final target = DateTime(
                now.year,
                now.month,
                now.day + 1,
                time.hour,
                time.minute,
              );
              await service.snooze(r.id, target.difference(now));
              if (context.mounted) {
                context.showSnack(
                  'Snoozed until tomorrow ${time.format(context)}',
                );
              }
            case 'open':
              if (context.mounted) {
                unawaited(context.push(Routes.screenshot(r.screenshotId!)));
              }
            case 'delete':
              final ok = await showConfirmationDialog(
                context,
                title: 'Delete reminder?',
                message: '"${r.title}" and its notification will be removed.',
                confirmLabel: 'Delete',
                destructive: true,
              );
              if (ok) await service.delete(r.id);
          }
        },
        itemBuilder: (_) => [
          if (!done) ...[
            const PopupMenuItem(
              value: 'snooze1h',
              child: Text('Snooze 1 hour'),
            ),
            const PopupMenuItem(
              value: 'snoozeTomorrow',
              child: Text('Snooze until tomorrow'),
            ),
          ],
          if (r.screenshotId != null)
            const PopupMenuItem(value: 'open', child: Text('Open screenshot')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

class _PermissionBanner extends ConsumerWidget {
  const _PermissionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsEnabledProvider).value ?? true;
    if (enabled) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Card.filled(
      color: scheme.tertiaryContainer,
      margin: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Row(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: scheme.onTertiaryContainer,
            ),
            const Gap(Spacing.sm),
            Expanded(
              child: Text(
                'Notifications are off. Reminders still appear here, but you will not be alerted.',
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
            TextButton(
              onPressed: () async {
                final granted = await ref
                    .read(notificationServiceProvider)
                    .requestPermission();
                ref.invalidate(notificationsEnabledProvider);
                if (granted) {
                  await ref.read(reminderServiceProvider).resyncAll();
                } else if (context.mounted) {
                  context.showSnack(
                    'You can turn notifications on in Android settings.',
                  );
                }
              },
              child: const Text('Turn on'),
            ),
          ],
        ),
      ),
    );
  }
}

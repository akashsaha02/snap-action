import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/constants/action_meta.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/settings_repository.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../application/action_executor.dart';
import '../application/action_repository.dart';

enum ActionGroup {
  dates('Events and deadlines', Icons.event_outlined, {
    ActionType.createReminder,
    ActionType.addCalendarEvent,
  }),
  payments('Payments', Icons.receipt_long_outlined, {
    ActionType.saveTransaction,
  }),
  shopping('Shopping', Icons.shopping_bag_outlined, {ActionType.addToWishlist}),
  travel('Travel', Icons.luggage_outlined, {ActionType.saveTravel}),
  places('Places', Icons.place_outlined, {ActionType.openMap}),
  links('Links', Icons.link, {ActionType.openUrl}),
  contacts('Contacts', Icons.contacts_outlined, {
    ActionType.callPhone,
    ActionType.sendEmail,
    ActionType.saveContact,
  }),
  other('Notes, codes and Wi-Fi', Icons.more_horiz, {
    ActionType.saveNotes,
    ActionType.copyCode,
    ActionType.copyWifi,
  });

  const ActionGroup(this.label, this.icon, this.types);

  final String label;
  final IconData icon;
  final Set<ActionType> types;

  static ActionGroup of(ActionType t) =>
      values.firstWhere((g) => g.types.contains(t));
}

/// The payload field the user may correct before accepting, if any.
const _editableField = <ActionType, (String, String)>{
  ActionType.createReminder: ('title', 'Reminder title'),
  ActionType.addCalendarEvent: ('title', 'Event title'),
  ActionType.openUrl: ('url', 'Link'),
  ActionType.callPhone: ('phone', 'Phone number'),
  ActionType.sendEmail: ('email', 'Email address'),
  ActionType.openMap: ('address', 'Address'),
  ActionType.saveTravel: ('flight', 'Flight'),
  ActionType.copyCode: ('code', 'Code'),
};

class ActionCenterScreen extends ConsumerStatefulWidget {
  const ActionCenterScreen({super.key});

  @override
  ConsumerState<ActionCenterScreen> createState() => _ActionCenterScreenState();
}

class _ActionCenterScreenState extends ConsumerState<ActionCenterScreen> {
  ActionGroup? _group;

  Future<void> _markAllChecked(List<int> ids) async {
    final ok = await showConfirmationDialog(
      context,
      title: 'Mark all as checked?',
      message:
          'The detected dates, amounts and categories of ${ids.length} '
          '${ids.length == 1 ? 'screenshot are' : 'screenshots are'} kept as '
          'they are. You can still change them on each screenshot.',
      confirmLabel: 'Mark as checked',
    );
    if (!ok) return;
    await ref.read(actionRepositoryProvider).confirmAll(ids);
    if (mounted) context.showSnack('Marked as checked');
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingActionsProvider);
    final confirm = ref.watch(needsConfirmationProvider).value ?? const [];
    final hideSensitive = ref
        .watch(settingsRepositoryProvider)
        .getBool(SettingsKeys.hideSensitivePreviews, fallback: true);
    return Scaffold(
      appBar: AppBar(title: const Text('Action center')),
      body: pending.when(
        loading: () => const SkeletonList(),
        error: (e, _) =>
            ErrorState(message: 'Could not load suggestions.', details: e),
        data: (items) {
          final present = {
            for (final i in items) ActionGroup.of(i.action.actionType),
          };
          final group = present.contains(_group) ? _group : null;
          final visible = group == null
              ? items
              : [
                  for (final i in items)
                    if (group.types.contains(i.action.actionType)) i,
                ];
          // One card per screenshot, in the order of its most urgent
          // suggestion (the list arrives sorted for review).
          final byScreenshot = <int, List<ActionItem>>{};
          for (final i in visible) {
            (byScreenshot[i.action.screenshotId] ??= []).add(i);
          }
          if (items.isEmpty && confirm.isEmpty) {
            return const EmptyState(
              art: BrandArt.allDone,
              icon: Icons.task_alt,
              title: 'All caught up',
              message: 'Suggestions such as reminders, links and payments appear here after screenshots are processed.',
            );
          }
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.only(bottom: Spacing.xl),
            children: [
              if (confirm.isNotEmpty) ...[
                Padding(
                  padding: Spacing.pagePadding,
                  child: SectionHeader(
                    title: 'Needs your confirmation (${confirm.length})',
                  ),
                ),
                Padding(
                  padding: Spacing.pagePadding,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Open a screenshot to check its dates, amounts or '
                          'category.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        key: const Key('confirm_all'),
                        onPressed: () =>
                            _markAllChecked([for (final s in confirm) s.id]),
                        child: const Text('Mark all as checked'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: Spacing.pagePadding,
                    itemCount: confirm.length,
                    separatorBuilder: (_, _) => const Gap(Spacing.sm),
                    itemBuilder: (context, i) => SizedBox(
                      width: 128,
                      child: ScreenshotCard(
                        screenshot: confirm[i],
                        hideSensitive: hideSensitive,
                        onTap: () =>
                            context.push(Routes.screenshot(confirm[i].id)),
                      ),
                    ),
                  ),
                ),
              ],
              if (items.isNotEmpty) ...[
                Padding(
                  padding: Spacing.pagePadding,
                  child: SectionHeader(title: 'Suggestions (${items.length})'),
                ),
                FilterChipBar<ActionGroup?>(
                  options: [
                    const FilterOption(null, 'All'),
                    for (final g in ActionGroup.values)
                      if (present.contains(g))
                        FilterOption(g, g.label, icon: g.icon),
                  ],
                  selected: group,
                  onSelected: (g) => setState(() => _group = g),
                ),
                const Gap(Spacing.sm),
                for (final entry in byScreenshot.entries)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.md,
                      0,
                      Spacing.md,
                      Spacing.sm,
                    ),
                    child: ScreenshotActionsCard(
                      key: ValueKey('actions_for_${entry.key}'),
                      items: entry.value,
                      hideSensitive: hideSensitive,
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// A screenshot with the suggestions made from it.
class ScreenshotActionsCard extends StatelessWidget {
  const ScreenshotActionsCard({
    required this.items,
    required this.hideSensitive,
    super.key,
  });

  final List<ActionItem> items;
  final bool hideSensitive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = items.first;
    final title = first.screenshotTitle?.trim();
    return PopShadow(
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () =>
                  context.push(Routes.screenshot(first.action.screenshotId)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.sm,
                  Spacing.sm,
                  Spacing.xs,
                  Spacing.xs,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      child: SizedBox(
                        width: 36,
                        height: 48,
                        child: ScreenshotThumbnail(
                          path: first.thumbnailPath,
                          blur: hideSensitive && first.isSensitive,
                        ),
                      ),
                    ),
                    const Gap(Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title == null || title.isEmpty
                                ? 'Screenshot'
                                : title,
                            style: theme.textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            items.length == 1
                                ? '1 suggestion'
                                : '${items.length} suggestions',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                      semanticLabel: 'Open screenshot',
                    ),
                  ],
                ),
              ),
            ),
            for (final (i, item) in items.indexed) ...[
              if (i > 0) const Divider(height: 1, indent: Spacing.sm),
              ActionTile(item: item),
            ],
          ],
        ),
      ),
    );
  }
}

enum _ActionMenu { edit, tomorrow, nextWeek, dismiss }

/// One suggestion: what it does, a button to do it and a menu for the rest.
class ActionTile extends ConsumerWidget {
  const ActionTile({required this.item, super.key});

  final ActionItem item;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final a = item.action;
    final field = _editableField[a.actionType];
    if (field == null) {
      await context.push(Routes.screenshot(a.screenshotId));
      return;
    }
    final value = await showTextInputDialog(
      context,
      title: 'Edit ${field.$2.toLowerCase()}',
      initialValue: item.payload[field.$1] as String?,
      maxLines: field.$1 == 'code' ? 6 : 1,
    );
    if (value == null || value.isEmpty) return;
    await ref.read(actionRepositoryProvider).updatePayload(a.id, {
      ...item.payload,
      field.$1: value,
    });
  }

  Future<void> _postpone(
    WidgetRef ref,
    BuildContext context,
    Duration by,
    String label,
  ) async {
    final now = DateTime.now();
    final until = DateTime(now.year, now.month, now.day).add(by);
    final repo = ref.read(actionRepositoryProvider);
    final id = item.action.id;
    await repo.setStatus(id, ActionStatus.postponed, postponedUntil: until);
    if (context.mounted) {
      context.showSnack(
        'Postponed until $label',
        actionLabel: 'Undo',
        onAction: () => unawaited(repo.setStatus(id, ActionStatus.suggested)),
      );
    }
  }

  Future<void> _dismiss(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(actionRepositoryProvider);
    final id = item.action.id;
    await repo.setStatus(id, ActionStatus.dismissed);
    if (context.mounted) {
      context.showSnack(
        'Suggestion dismissed',
        actionLabel: 'Undo',
        onAction: () => unawaited(repo.setStatus(id, ActionStatus.suggested)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final a = item.action;
    final detail = describeAction(a).trim();
    final source = item.screenshotTitle?.trim().toLowerCase();
    // The card header already names the screenshot; don't repeat it.
    // Nor repeat what the suggestion title already says
    // ("Email jobs@acme.example" over "jobs@acme.example").
    final showDetail =
        detail.isNotEmpty &&
        !a.title.toLowerCase().contains(detail.toLowerCase()) &&
        detail.toLowerCase() != source;
    return Padding(
      key: ValueKey('action_${a.id}'),
      padding: const EdgeInsets.fromLTRB(Spacing.sm, Spacing.xs, 0, Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                a.actionType.icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const Gap(Spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showDetail)
                      Text(
                        detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              PopupMenuButton<_ActionMenu>(
                key: ValueKey('menu_${a.id}'),
                tooltip: 'More options',
                onSelected: (choice) => switch (choice) {
                  _ActionMenu.edit => _edit(context, ref),
                  _ActionMenu.tomorrow => _postpone(
                    ref,
                    context,
                    const Duration(days: 1),
                    'tomorrow',
                  ),
                  _ActionMenu.nextWeek => _postpone(
                    ref,
                    context,
                    const Duration(days: 7),
                    'next week',
                  ),
                  _ActionMenu.dismiss => _dismiss(context, ref),
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _ActionMenu.edit,
                    child: Text(
                      _editableField.containsKey(a.actionType)
                          ? 'Edit'
                          : 'Open screenshot',
                    ),
                  ),
                  const PopupMenuItem(
                    value: _ActionMenu.tomorrow,
                    child: Text('Postpone until tomorrow'),
                  ),
                  const PopupMenuItem(
                    value: _ActionMenu.nextWeek,
                    child: Text('Postpone for a week'),
                  ),
                  PopupMenuItem(
                    key: ValueKey('dismiss_${a.id}'),
                    value: _ActionMenu.dismiss,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20 + Spacing.xs),
            child: FilledButton(
              key: ValueKey('accept_${a.id}'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => ActionExecutor.run(context, ref, a),
              child: Text(a.actionType.label),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact list of an individual screenshot's suggestions, used on the
/// details screen.
class SuggestedActionsSection extends ConsumerWidget {
  const SuggestedActionsSection({required this.actions, super.key});

  final List<SuggestedActionRow> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = [
      for (final a in actions)
        if (a.status == ActionStatus.suggested) a,
    ];
    final accepted = [
      for (final a in actions)
        if (a.status == ActionStatus.accepted) a,
    ];
    if (pending.isEmpty && accepted.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Suggested actions'),
        Text(
          'Nothing happens until you tap a suggestion and confirm.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Gap(Spacing.xs),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            for (final a in pending)
              GestureDetector(
                onLongPress: () async {
                  final repo = ref.read(actionRepositoryProvider);
                  final ok = await showConfirmationDialog(
                    context,
                    title: 'Dismiss suggestion?',
                    message: a.title,
                    confirmLabel: 'Dismiss',
                  );
                  if (ok) await repo.setStatus(a.id, ActionStatus.dismissed);
                },
                child: SmartActionChip.forAction(
                  a.actionType,
                  key: ValueKey('suggested_${a.id}'),
                  label: a.title,
                  onPressed: () => ActionExecutor.run(context, ref, a),
                ),
              ),
            for (final a in accepted)
              SmartActionChip(
                label: a.title,
                icon: Icons.check,
                tooltip: 'Done. Tap to run again.',
                onPressed: () => ActionExecutor.run(context, ref, a),
              ),
          ],
        ),
      ],
    );
  }
}

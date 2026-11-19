import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/repositories/screenshot_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../reminders/presentation/reminders_screen.dart';
import '../application/upcoming.dart';

/// One row of tappable counts. Processing and failed only appear while
/// non-zero; every tile has the same height, so the row never jumps.
class HomeCountStrip extends StatelessWidget {
  const HomeCountStrip({required this.stats, super.key});

  final LibraryStats? stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = context.statusColors;
    final s = stats ?? const LibraryStats();
    final tiles = <Widget>[
      CountTile(
        key: const Key('home_count_review'),
        icon: Icons.inbox_outlined,
        color: scheme.primary,
        count: s.needsReview,
        label: 'To review',
        semanticLabel: '${s.needsReview} to review',
        onTap: () => context.push(Routes.inbox),
      ),
      if (s.queued > 0)
        CountTile(
          key: const Key('home_count_processing'),
          icon: Icons.autorenew,
          color: scheme.secondary,
          count: s.queued,
          label: 'Processing',
          semanticLabel: '${s.queued} processing',
          onTap: () => context.push('${Routes.inbox}?filter=processing'),
        ),
      if (s.failed > 0)
        CountTile(
          key: const Key('home_count_failed'),
          icon: Icons.error_outline,
          color: scheme.error,
          count: s.failed,
          label: 'Failed',
          semanticLabel: '${s.failed} failed',
          onTap: () => context.push('${Routes.inbox}?filter=failed'),
        ),
      CountTile(
        key: const Key('home_count_favorites'),
        icon: Icons.star_outline_rounded,
        color: status.favorite,
        count: s.favorites,
        label: 'Favourites',
        semanticLabel: '${s.favorites} favourites',
        onTap: () => context.push('${Routes.inbox}?filter=favorites'),
      ),
      CountTile(
        key: const Key('home_similar'),
        icon: Icons.compare_outlined,
        color: scheme.onSurfaceVariant,
        label: 'Similar',
        semanticLabel: 'Similar screenshots',
        onTap: () => context.push(Routes.duplicates),
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: Spacing.pagePadding,
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const Gap(Spacing.xs),
            tiles[i],
          ],
        ],
      ),
    );
  }
}

class CountTile extends StatelessWidget {
  const CountTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.count,
    super.key,
  });

  final IconData icon;
  final Color color;
  final int? count;
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Spacing.radiusMd),
      side: BorderSide(color: context.statusColors.border),
    );
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: Spacing.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: color),
                  const Gap(Spacing.xs),
                  if (count != null) ...[
                    Text(
                      '$count',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(Spacing.xxs + 2),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Entry to the action center with the number of pending suggestions.
class ActionCenterBanner extends StatelessWidget {
  const ActionCenterBanner({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final active = count > 0;
    final background = active ? scheme.primaryContainer : null;
    final foreground = active
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final title = active
        ? '$count suggestion${count == 1 ? '' : 's'} to review'
        : 'No new suggestions';
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Spacing.radiusMd),
      side: active
          ? BorderSide.none
          : BorderSide(color: context.statusColors.border),
    );
    return Semantics(
      button: true,
      label: 'Action center: $title',
      excludeSemantics: true,
      child: Material(
        key: const Key('action_center_card'),
        color: background ?? scheme.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.actions),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, color: active ? foreground : scheme.primary),
                const Gap(Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: active ? foreground : scheme.onSurface,
                        ),
                      ),
                      Text(
                        'Action center',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The next dated items: reminders plus dates and deadlines found in
/// screenshots. Hidden when there is nothing coming up.
class ComingUpSection extends StatelessWidget {
  const ComingUpSection({
    required this.items,
    this.overdue = 0,
    this.now,
    super.key,
  });

  final List<UpcomingItem> items;
  final int overdue;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && overdue == 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      key: const Key('home_coming_up'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Spacing.lg, bottom: Spacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text('Coming up', style: theme.textTheme.titleLarge),
                ),
              ),
              if (overdue > 0)
                TextButton.icon(
                  key: const Key('home_overdue'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: () => context.go(
                    RemindersScreen.location(tab: ReminderTab.overdue),
                  ),
                  icon: const Icon(Icons.warning_amber_rounded, size: 18),
                  label: Text('$overdue overdue'),
                )
              else
                TextButton(
                  onPressed: () => context.go(Routes.reminders),
                  child: const Text('Reminders'),
                ),
            ],
          ),
        ),
        if (items.isNotEmpty)
          Card(
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: Spacing.md + 48 + Spacing.sm,
                      color: context.statusColors.border,
                    ),
                  UpcomingTile(item: items[i], now: now),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class UpcomingTile extends StatelessWidget {
  const UpcomingTile({required this.item, this.now, super.key});

  final UpcomingItem item;
  final DateTime? now;

  static String kindLabel(UpcomingItem item) => switch (item.kind) {
    UpcomingKind.reminder => 'Reminder',
    UpcomingKind.deadline => 'Deadline',
    UpcomingKind.date => item.detail ?? 'Date',
  };

  static String whenLabel(UpcomingItem item, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(item.at.year, item.at.month, item.at.day);
    final days = (day.difference(today).inHours / 24).round();
    final parts = <String>[
      Formatters.relativeDay(item.at, now: now),
      if (days >= 2 && days < 7) 'in $days days',
      if (item.hasTime) Formatters.time(item.at),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (bg, fg, icon) = switch (item.kind) {
      UpcomingKind.reminder => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.alarm,
      ),
      UpcomingKind.deadline => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.flag_outlined,
      ),
      UpcomingKind.date => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        Icons.event_outlined,
      ),
    };
    final kind = kindLabel(item);
    final when = whenLabel(item, now ?? DateTime.now());
    return Semantics(
      button: true,
      label: '$kind: ${item.title}, $when',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => item.screenshotId != null
            ? context.push(Routes.screenshot(item.screenshotId!))
            : context.go(Routes.reminders),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              _DateBadge(date: item.at, background: bg, foreground: fg),
              const Gap(Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
                        const Gap(Spacing.xxs),
                        Expanded(
                          child: Text(
                            '$kind · $when',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({
    required this.date,
    required this.background,
    required this.foreground,
  });

  final DateTime date;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxs + 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            DateFormat.MMM().format(date).toUpperCase(),
            style: text.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
            maxLines: 1,
          ),
          Text(
            '${date.day}',
            style: text.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

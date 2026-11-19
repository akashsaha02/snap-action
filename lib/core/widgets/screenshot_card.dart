import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../constants/action_meta.dart';
import '../models/screenshot_summary.dart';
import '../theme/app_colors.dart';
import '../theme/category_icons.dart';
import '../theme/spacing.dart';
import '../utils/formatters.dart';
import 'brand.dart';
import 'common.dart';
import 'sensitive_previews.dart';

/// Decodes images at display size to keep memory bounded in long grids.
///
/// Privacy: pass [isSensitive] for screenshots marked sensitive; the image is
/// then blurred whenever the user's "Blur sensitive previews" setting is on
/// (the default). When only a path is known, set [detectSensitive] and the
/// thumbnail looks the path up itself. [blur] forces the blur regardless of
/// the setting (kept for callers that already decided, e.g. a reveal toggle).
class ScreenshotThumbnail extends StatelessWidget {
  const ScreenshotThumbnail({
    required this.path,
    this.fit = BoxFit.cover,
    this.blur = false,
    this.isSensitive = false,
    this.detectSensitive = false,
    super.key,
  });

  final String? path;
  final BoxFit fit;

  /// Always blur, whatever the setting says.
  final bool blur;

  /// The screenshot is marked sensitive: blur it if the setting is on.
  final bool isSensitive;

  /// Look up whether [path] belongs to a sensitive screenshot. Use when the
  /// caller does not know (collection tiles, reminders, wishlist).
  final bool detectSensitive;

  /// Blur radius used for hidden previews.
  static const blurSigma = 12.0;

  @override
  Widget build(BuildContext context) {
    if (blur || path == null) return _image(context, hidden: blur);
    if (isSensitive) {
      // Fail closed: hide when the setting cannot be read.
      return _image(
        context,
        hidden: readHideSensitivePreviews(context) ?? true,
      );
    }
    if (detectSensitive && hasProviderScope(context)) {
      return Consumer(
        builder: (context, ref, _) {
          final paths = ref.watch(sensitivePreviewPathsProvider);
          final hide = readHideSensitivePreviews(context) ?? true;
          final sensitive = switch (paths) {
            AsyncData(:final value) => value.contains(path),
            // Hide until we know, so nothing sensitive flashes up.
            AsyncLoading() => true,
            _ => false,
          };
          return _image(context, hidden: hide && sensitive);
        },
      );
    }
    return _image(context, hidden: false);
  }

  Widget _image(BuildContext context, {required bool hidden}) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant),
      ),
    );
    if (path == null) return placeholder;
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final width = constraints.maxWidth.isFinite
            ? (constraints.maxWidth * dpr).round()
            : 400;
        Widget image = Image.file(
          File(path!),
          fit: fit,
          cacheWidth: width.clamp(64, 1080),
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => placeholder,
        );
        if (hidden) {
          image = ClipRect(
            child: ImageFiltered(
              key: const ValueKey('sensitive_blur'),
              imageFilter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: image,
            ),
          );
        }
        return image;
      },
    );
  }
}

class ScreenshotCard extends StatelessWidget {
  const ScreenshotCard({
    required this.screenshot,
    required this.onTap,
    this.onLongPress,
    this.onFavoriteToggle,
    this.menu,
    this.selected = false,
    this.selectionMode = false,
    this.layout = ScreenshotCardLayout.grid,
    this.hideSensitive = false,
    super.key,
  });

  final ScreenshotSummary screenshot;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteToggle;
  final Widget? menu;
  final bool selected;
  final bool selectionMode;
  final ScreenshotCardLayout layout;

  /// Fallback for the "Blur sensitive previews" setting, used only when the
  /// setting cannot be read (no [ProviderScope], e.g. isolated widget tests).
  /// In the app the setting itself decides, so every screen behaves alike.
  final bool hideSensitive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = screenshot;
    final blur =
        s.isSensitive && (readHideSensitivePreviews(context) ?? hideSensitive);
    final semanticsLabel = [
      s.displayTitle,
      if (s.effectiveCategory != null) s.effectiveCategory!.name,
      'imported ${Formatters.relativeDay(s.importedAt)}',
      if (s.isFavorite) 'favourite',
      if (blur) 'sensitive, preview hidden',
      if (selected) 'selected',
    ].join(', ');

    final thumbnail = Stack(
      fit: StackFit.expand,
      children: [
        ScreenshotThumbnail(
          path: s.thumbnailPath ?? s.localFilePath,
          blur: blur,
        ),
        if (selectionMode)
          Positioned(top: 6, left: 6, child: _SelectionDot(selected: selected)),
        if (blur)
          const Center(
            child: Icon(
              Icons.visibility_off,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
            ),
          ),
      ],
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.displayTitle,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onFavoriteToggle != null)
              // 48 dp touch target around a 20 dp star.
              SizedBox.square(
                key: const ValueKey('screenshot_card_favorite'),
                dimension: Spacing.minTouchTarget,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  tooltip: s.isFavorite ? 'Remove favourite' : 'Add favourite',
                  isSelected: s.isFavorite,
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    s.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: s.isFavorite
                        ? context.statusColors.favorite
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ?menu,
          ],
        ),
        Text(
          [
            Formatters.relativeDay(s.importedAt),
            if (s.effectiveCategory != null) s.effectiveCategory!.name,
          ].join(' • '),
          style: theme.textTheme.labelSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (layout == ScreenshotCardLayout.list &&
            s.textPreview != null &&
            s.textPreview!.isNotEmpty &&
            !blur) ...[
          const Gap(Spacing.xxs),
          Text(
            s.textPreview!,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const Gap(Spacing.xs),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ProcessingStatusBadge(
              status: s.status,
              isReviewed: s.isReviewed,
              isArchived: s.isArchived,
            ),
            for (final a in s.actionTypes.take(3))
              Tooltip(
                message: a.label,
                child: Icon(a.icon, size: 16, color: theme.colorScheme.primary),
              ),
          ],
        ),
      ],
    );

    final border = selected
        ? BorderSide(
            color: theme.colorScheme.primary,
            width: Spacing.outlineBold,
          )
        : null;

    return Semantics(
      label: semanticsLabel,
      button: true,
      selected: selected,
      child: PopShadow(
        child: Card(
          shape: border == null
              ? null
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  side: border,
                ),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: switch (layout) {
              ScreenshotCardLayout.grid => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: thumbnail),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      Spacing.sm,
                      // The 48 dp favourite button already adds air above.
                      onFavoriteToggle == null && menu == null
                          ? Spacing.xs
                          : Spacing.xxs,
                      Spacing.xxs,
                      Spacing.sm,
                    ),
                    child: info,
                  ),
                ],
              ),
              ScreenshotCardLayout.list => Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      child: SizedBox(width: 72, height: 96, child: thumbnail),
                    ),
                    const Gap(Spacing.sm),
                    Expanded(child: info),
                  ],
                ),
              ),
            },
          ),
        ),
      ),
    );
  }
}

enum ScreenshotCardLayout { grid, list }

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? scheme.primary : Colors.black38,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: selected
          ? Icon(Icons.check, size: 14, color: scheme.onPrimary)
          : null,
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
    this.previewPaths = const [],
    super.key,
  });

  final String name;
  final String icon;
  final int color;
  final int count;
  final List<String> previewPaths;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Color(color);
    return Semantics(
      label: '$name, $count screenshots',
      button: true,
      excludeSemantics: true,
      child: PopShadow(
        child: Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Spacing.xs),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(Spacing.radiusSm),
                        ),
                        child: Icon(
                          CategoryIcons.of(icon),
                          color: accent,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Text('$count', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const Gap(Spacing.sm),
                  Expanded(
                    child: previewPaths.isEmpty
                        ? DecoratedBox(
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(
                                Spacing.radiusSm,
                              ),
                            ),
                            child: const SizedBox.expand(),
                          )
                        : Row(
                            children: [
                              for (final (i, p)
                                  in previewPaths.take(3).indexed) ...[
                                if (i > 0) const Gap(Spacing.xxs),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      Spacing.radiusSm - 2,
                                    ),
                                    child: ScreenshotThumbnail(
                                      path: p,
                                      detectSensitive: true,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                  const Gap(Spacing.xs),
                  Text(
                    name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    required this.title,
    required this.dueAt,
    required this.completed,
    required this.onToggleComplete,
    this.subtitle,
    this.overdue = false,
    this.thumbnailPath,
    this.thumbnailSensitive,
    this.onTap,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final DateTime dueAt;
  final bool completed;
  final bool overdue;
  final String? thumbnailPath;

  /// Whether the linked screenshot is marked sensitive. When null the
  /// thumbnail looks it up from [thumbnailPath]. Either way it is blurred
  /// only while "Blur sensitive previews" is on.
  final bool? thumbnailSensitive;
  final VoidCallback onToggleComplete;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueColor = overdue && !completed
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.xs,
          ),
          child: Row(
            children: [
              Checkbox(
                value: completed,
                onChanged: (_) => onToggleComplete(),
                semanticLabel: completed ? 'Mark as not done' : 'Mark as done',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        Icon(
                          overdue && !completed
                              ? Icons.warning_amber
                              : Icons.schedule,
                          size: 14,
                          color: dueColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            overdue && !completed
                                ? 'Overdue • ${Formatters.dateTime(dueAt)}'
                                : Formatters.dateTime(dueAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: dueColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (thumbnailPath != null)
                Padding(
                  padding: const EdgeInsets.only(left: Spacing.xs),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    child: SizedBox(
                      width: 40,
                      height: 52,
                      child: ScreenshotThumbnail(
                        path: thumbnailPath,
                        isSensitive: thumbnailSensitive ?? false,
                        detectSensitive: thumbnailSensitive == null,
                      ),
                    ),
                  ),
                ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

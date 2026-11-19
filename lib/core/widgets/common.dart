import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../constants/action_meta.dart';
import '../database/enums.dart';
import '../theme/app_colors.dart';
import '../theme/spacing.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.lg, bottom: Spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const Gap(Spacing.sm),
              Text(value, style: theme.textTheme.headlineSmall),
              Text(
                label,
                style: theme.textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable pseudo search bar that navigates to the search screen.
class SearchShortcut extends StatelessWidget {
  const SearchShortcut({required this.hint, required this.onTap, super.key});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: hint,
      child: Material(
        color: theme.colorScheme.surface,
        // Brand input: a white pill with an ink outline.
        shape: StadiumBorder(
          side: BorderSide(
            color: theme.brightness == Brightness.light
                ? context.statusColors.outlineStrong
                : context.statusColors.border,
            width: Spacing.outline,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm + 2,
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                const Gap(Spacing.sm),
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      hint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Text field that reports changes after the user pauses typing.
class DebouncedSearchField extends StatefulWidget {
  const DebouncedSearchField({
    required this.onChanged,
    this.hint,
    this.controller,
    this.autofocus = false,
    this.delay = const Duration(milliseconds: 250),
    this.onSubmitted,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hint;
  final TextEditingController? controller;
  final bool autofocus;
  final Duration delay;

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(widget.delay, () => widget.onChanged(value));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: _onChanged,
      onSubmitted: (v) {
        _timer?.cancel();
        widget.onChanged(v);
        widget.onSubmitted?.call(v);
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  _onChanged('');
                },
              ),
      ),
    );
  }
}

class FilterOption<T> {
  const FilterOption(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Horizontally scrolling single-select filter chips.
class FilterChipBar<T> extends StatelessWidget {
  const FilterChipBar({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<FilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: Spacing.pagePadding,
      child: Row(
        children: [
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.xs),
              child: FilterChip(
                label: Text(o.label),
                avatar: o.icon == null
                    ? null
                    : Icon(
                        o.icon,
                        size: 18,
                        // Chips don't resolve avatar colours by state.
                        color: o.value == selected
                            ? context.statusColors.onHighlight
                            : null,
                      ),
                selected: o.value == selected,
                showCheckmark: false,
                onSelected: (_) => onSelected(o.value),
              ),
            ),
        ],
      ),
    );
  }
}

class ProcessingStatusBadge extends StatelessWidget {
  const ProcessingStatusBadge({
    required this.status,
    this.isReviewed = false,
    this.isArchived = false,
    super.key,
  });

  final ProcessingStatus status;
  final bool isReviewed;
  final bool isArchived;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = context.statusColors;
    // (label, tint used for the background, readable foreground, icon).
    // Foregrounds come from the on-* tokens, which reach WCAG AA (4.5:1) on
    // the 12 % tint in both themes.
    final (label, tint, foreground, icon) = switch (this.status) {
      _ when isArchived => (
        'Archived',
        scheme.onSurfaceVariant,
        scheme.onSurfaceVariant,
        Icons.archive_outlined,
      ),
      ProcessingStatus.pending => (
        'Queued',
        status.warning,
        status.onWarning,
        Icons.schedule,
      ),
      ProcessingStatus.processing => (
        'Processing',
        scheme.primary,
        status.onAccent,
        Icons.autorenew,
      ),
      ProcessingStatus.failed => (
        'Failed',
        scheme.error,
        status.onDanger,
        Icons.error_outline,
      ),
      ProcessingStatus.completed when isReviewed => (
        'Reviewed',
        status.success,
        status.onSuccess,
        Icons.check_circle_outline,
      ),
      ProcessingStatus.completed => (
        'Needs review',
        scheme.secondary,
        status.onInfo,
        Icons.inbox_outlined,
      ),
    };
    return StatusBadge(
      label: label,
      icon: icon,
      tint: tint,
      foreground: foreground,
      semanticsLabel: 'Status: $label',
      busy: this.status == ProcessingStatus.processing,
    );
  }
}

/// Small pill with an icon and a short label on a 12 % tint.
///
/// Pass a readable [foreground] (one of the `on*` tokens of [StatusColors]);
/// [tint] is only used for the background. When [foreground] is omitted it
/// falls back to [tint], so only do that for colors that already reach
/// 4.5:1 on the surface.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.tint,
    this.foreground,
    this.icon,
    this.semanticsLabel,
    this.busy = false,
    super.key,
  });

  final String label;
  final Color tint;
  final Color? foreground;
  final IconData? icon;
  final String? semanticsLabel;

  /// Shows a small spinner instead of [icon].
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? tint;
    return Semantics(
      label: semanticsLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: fg),
              )
            else if (icon != null)
              Icon(icon, size: 12, color: fg),
            if (busy || icon != null) const SizedBox(width: Spacing.xxs),
            Flexible(
              child: ExcludeSemantics(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip for a suggested action or a detected entity.
class SmartActionChip extends StatelessWidget {
  const SmartActionChip({
    required this.label,
    required this.icon,
    this.onPressed,
    this.highlighted = false,
    this.tooltip,
    super.key,
  });

  factory SmartActionChip.forAction(
    ActionType type, {
    VoidCallback? onPressed,
    String? label,
    Key? key,
  }) => SmartActionChip(
    key: key,
    label: label ?? type.label,
    icon: type.icon,
    onPressed: onPressed,
    highlighted: true,
  );

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool highlighted;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chip = ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: highlighted
            ? scheme.onPrimaryContainer
            : scheme.onSurfaceVariant,
      ),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      backgroundColor: highlighted ? scheme.primaryContainer : null,
      side: highlighted ? BorderSide.none : null,
      labelStyle: highlighted
          ? TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            )
          : null,
      onPressed: onPressed,
    );
    return tooltip == null ? chip : Tooltip(message: tooltip, child: chip);
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);
    final button = icon == null || loading
        ? FilledButton(onPressed: loading ? null : onPressed, child: child)
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: child,
          );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = icon == null
        ? OutlinedButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

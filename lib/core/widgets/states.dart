import 'package:material_ui/material_ui.dart';

import '../theme/spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      // Scrolls instead of overflowing on short screens or large text.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const Gap(Spacing.lg),
            Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(Spacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const Gap(Spacing.lg), action!],
          ],
        ),
      ),
    );
  }
}

/// Full-area error message with an optional retry button.
///
/// [message] should be a friendly sentence. Anything technical in it (an
/// error appended with `'\n$e'`, stack frames, file paths) is split off and
/// never shown as the main text; a short, sanitised one-line summary can be
/// expanded under "Show details". Stack traces are never displayed.
class ErrorState extends StatefulWidget {
  const ErrorState({
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.details,
    this.showDetails = true,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  /// Optional technical detail, such as the caught error. It is sanitised
  /// and shown collapsed.
  final Object? details;

  /// Whether the collapsed "Show details" section is offered at all.
  final bool showDetails;

  /// Shown when [message] contains nothing but technical text.
  static const fallbackMessage = 'Something went wrong. Please try again.';

  /// Longest technical summary that is ever shown.
  static const maxDetailsLength = 160;

  static final _technical = RegExp(
    r'(Exception|\w+Error\b|Error:|^#\d+|^\s*at\s+\S+\s*\(|package:|dart:|'
    r'StackTrace|\.dart\b|<asynchronous suspension>|0x[0-9a-fA-F]{4,})',
  );
  static final _frame = RegExp(
    r'^\s*(#\d+|at\s+\S+\s*\(|<asynchronous suspension>)|package:|dart:[a-z_]+/|'
    r'\.dart:\d+',
  );
  static final _path = RegExp(r'(/[\w.\-]+){2,}/?|[A-Za-z]:\\[^\s]+');

  /// Splits [message] (plus optional [details]) into the friendly text to
  /// show and a short, sanitised technical summary (null when there is
  /// none). Stack frames are always dropped.
  static ({String message, String? details}) sanitize(
    String message, [
    Object? details,
  ]) {
    final friendly = <String>[];
    final technical = <String>[];
    for (final raw in message.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      (_technical.hasMatch(line) ? technical : friendly).add(line);
    }
    if (details != null) {
      for (final raw in details.toString().split('\n')) {
        final line = raw.trim();
        if (line.isNotEmpty) technical.add(line);
      }
    }
    // Keep only the first line that is not a stack frame: the error summary.
    String? summary;
    for (final line in technical) {
      if (_frame.hasMatch(line)) continue;
      summary = line.replaceAll(_path, '…');
      break;
    }
    if (summary != null && summary.length > maxDetailsLength) {
      summary = '${summary.substring(0, maxDetailsLength - 1)}…';
    }
    return (
      message: friendly.isEmpty ? fallbackMessage : friendly.join('\n'),
      details: summary,
    );
  }

  @override
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clean = ErrorState.sanitize(widget.message, widget.details);
    final details = widget.showDetails ? clean.details : null;
    return Center(
      // Scrolls instead of overflowing on short screens or large text.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const Gap(Spacing.md),
            Semantics(
              liveRegion: true,
              child: Text(
                clean.message,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if (details != null) ...[
              const Gap(Spacing.xs),
              TextButton.icon(
                key: const ValueKey('error_state_details_toggle'),
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_expanded ? 'Hide details' : 'Show details'),
              ),
              if (_expanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: SelectableText(
                    details,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
            if (widget.onRetry != null) ...[
              const Gap(Spacing.lg),
              OutlinedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(widget.retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pulsing placeholder used while content loads.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    this.width,
    this.height = 16,
    this.radius = Spacing.radiusSm,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHigh;
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({this.itemCount = 6, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Spacing.md),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const Gap(Spacing.sm),
      itemBuilder: (_, _) => const Row(
        children: [
          SkeletonBox(width: 64, height: 64, radius: Spacing.radiusSm + 4),
          Gap(Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160),
                Gap(Spacing.xs),
                SkeletonBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

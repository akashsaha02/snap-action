import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../services/platform/platform_service.dart';
import '../application/import_controller.dart';
import '../application/import_service.dart';

/// Receives images shared from other apps, both at cold start and while
/// running, and shows import progress and results for every import source.
///
/// Shares that arrive while an import runs are queued and imported together
/// afterwards. Results that arrive while a result sheet is open are merged
/// into that sheet instead of stacking a new one. While a screen is pushed
/// above the shell, progress is shown in a floating banner on the root
/// overlay so it stays visible everywhere.
class ImportCoordinator extends ConsumerStatefulWidget {
  const ImportCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ImportCoordinator> createState() => _ImportCoordinatorState();
}

class _ImportCoordinatorState extends ConsumerState<ImportCoordinator> {
  StreamSubscription<List<SharedFile>>? _shares;
  final _queue = <SharedFile>[];
  bool _draining = false;

  /// Result shown by the open result sheet; null while no sheet is open.
  ValueNotifier<ImportResult>? _sheet;

  /// Location pushed for quick review of the last share, so the next share
  /// replaces it instead of stacking another screen.
  String? _quickReviewLocation;

  OverlayEntry? _floatingBanner;
  bool _shellOnTop = true;

  @override
  void initState() {
    super.initState();
    // Resumes queued processing jobs left from a previous session.
    ref.read(jobRunnerProvider);
    final platform = ref.read(platformServiceProvider);
    _shares = platform.incomingShares.listen(_onShared);
    unawaited(platform.takePendingShares().then(_onShared));
  }

  @override
  void dispose() {
    unawaited(_shares?.cancel());
    _floatingBanner
      ?..remove()
      ..dispose();
    _floatingBanner = null;
    super.dispose();
  }

  void _onShared(List<SharedFile> files) {
    if (files.isEmpty || !mounted) return;
    _queue.addAll(files);
    unawaited(_drain());
  }

  /// Imports queued shares once no other import is running.
  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (mounted &&
          _queue.isNotEmpty &&
          !ref.read(importControllerProvider).running) {
        final batch = List.of(_queue);
        _queue.clear();
        await ref.read(importControllerProvider.notifier).importShared(batch);
      }
    } finally {
      _draining = false;
    }
  }

  void _acknowledge(ImportResult result) {
    final state = ref.read(importControllerProvider);
    // Never clear a newer import that started in the meantime.
    if (identical(state.result, result)) {
      ref.read(importControllerProvider.notifier).acknowledge();
    }
  }

  String? _topLocation(GoRouter router) {
    try {
      return router.routerDelegate.currentConfiguration.last.matchedLocation;
    } on Object {
      return null;
    }
  }

  void _quickReview(GoRouter router, String location) {
    final replace =
        _quickReviewLocation != null &&
        _topLocation(router) == _quickReviewLocation;
    _quickReviewLocation = location;
    unawaited(
      replace ? router.pushReplacement(location) : router.push(location),
    );
  }

  void _onResult(ImportResult result, ScreenshotSource? source) {
    _acknowledge(result);
    final open = _sheet;
    if (open != null) {
      open.value = open.value.merge(result);
      return;
    }
    final router = GoRouter.of(context);
    final quickReview = source == ScreenshotSource.share;

    if (result.failures.isEmpty && result.duplicates.isEmpty) {
      if (result.importedCount == 0) return;
      if (quickReview && result.importedCount == 1) {
        _quickReview(router, Routes.screenshot(result.importedIds.single));
        return;
      }
      context.showSnack(
        result.importedCount == 1
            ? 'Imported 1 screenshot'
            : 'Imported ${result.importedCount} screenshots',
        actionLabel: 'Review',
        onAction: () => unawaited(router.push(Routes.inbox)),
      );
      if (quickReview) _quickReview(router, Routes.inbox);
      return;
    }
    _showSheet(result, router);
  }

  void _showSheet(ImportResult result, GoRouter router) {
    final notifier = ValueNotifier(result);
    _sheet = notifier;
    unawaited(
      showAppBottomSheet<void>(
        context,
        builder: (sheetContext) => ValueListenableBuilder<ImportResult>(
          valueListenable: notifier,
          builder: (_, value, _) => ImportResultSummary(
            result: value,
            onOpen: (route) {
              Navigator.of(sheetContext).pop();
              unawaited(router.push(route));
            },
          ),
        ),
      ).whenComplete(() {
        // The notifier is left to the garbage collector: the sheet may still
        // be animating out and listening to it.
        if (identical(_sheet, notifier)) _sheet = null;
      }),
    );
  }

  void _syncFloatingBanner(bool show) {
    if (show == (_floatingBanner != null)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final want = ref.read(importControllerProvider).running && !_shellOnTop;
      if (want && _floatingBanner == null) {
        final entry = OverlayEntry(
          builder: (_) => const _FloatingImportBanner(),
        );
        Overlay.of(context, rootOverlay: true).insert(entry);
        _floatingBanner = entry;
      } else if (!want && _floatingBanner != null) {
        _floatingBanner!
          ..remove()
          ..dispose();
        _floatingBanner = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(importControllerProvider, (prev, next) {
      final result = next.result;
      if (result != null && !identical(prev?.result, result)) {
        _onResult(result, next.source);
      }
      if ((prev?.running ?? false) && !next.running && _queue.isNotEmpty) {
        unawaited(_drain());
      }
    });
    final state = ref.watch(importControllerProvider);
    // False while a screen, sheet or dialog is above the shell.
    _shellOnTop = ModalRoute.isCurrentOf(context) ?? true;
    _syncFloatingBanner(state.running && !_shellOnTop);
    return Column(
      children: [
        if (state.running) ImportProgressBanner(state: state),
        Expanded(
          // The banner already consumed the status bar inset.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: state.running,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

String _progressLabel(ImportState state) => state.total <= 1
    ? 'Importing screenshot…'
    : 'Importing ${state.done} of ${state.total}…';

class ImportProgressBanner extends StatelessWidget {
  const ImportProgressBanner({required this.state, super.key});

  final ImportState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _progressLabel(state);
    return Material(
      color: theme.colorScheme.primaryContainer,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          liveRegion: true,
          label: label,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.xs,
              Spacing.md,
              Spacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Gap(Spacing.xxs),
                LinearProgressIndicator(value: state.progress),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact progress pill shown above pushed screens. It ignores touches so
/// it never blocks the app bar below it.
class _FloatingImportBanner extends ConsumerWidget {
  const _FloatingImportBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importControllerProvider);
    if (!state.running) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = _progressLabel(state);
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: Spacing.xs),
          child: IgnorePointer(
            child: Semantics(
              key: const Key('floating_import_banner'),
              liveRegion: true,
              label: label,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Material(
                  color: scheme.primaryContainer,
                  elevation: 3,
                  shape: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            value: state.progress,
                            strokeWidth: 2,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const Gap(Spacing.xs),
                        Flexible(
                          child: ExcludeSemantics(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outcome of an import: what was added, skipped and why something failed.
class ImportResultSummary extends StatelessWidget {
  const ImportResultSummary({
    required this.result,
    required this.onOpen,
    super.key,
  });

  final ImportResult result;
  final ValueChanged<String> onOpen;

  /// Sheet title; never claims success when nothing was imported.
  static String titleFor(ImportResult result) {
    if (result.importedCount > 0) return 'Import finished';
    if (result.failures.isNotEmpty) return 'Import failed';
    return 'Nothing new to import';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = context.statusColors;
    final imported = result.importedCount;
    final failed = result.failures.isNotEmpty;

    final (headIcon, headColor, headText) = imported > 0
        ? (
            Icons.check_circle_outline,
            status.success,
            imported == 1
                ? '1 screenshot imported'
                : '$imported screenshots imported',
          )
        : failed
        ? (Icons.error_outline, scheme.error, 'No screenshots imported')
        : (Icons.info_outline, scheme.onSurfaceVariant, 'No new screenshots');

    // Same reason for many files (for example a burst of shares) is one row.
    final byReason = <String, List<String>>{};
    for (final f in result.failures) {
      byReason.putIfAbsent(f.reason, () => []).add(f.name);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            titleFor(result),
            key: const Key('import_result_title'),
            style: theme.textTheme.titleLarge,
          ),
        ),
        const Gap(Spacing.md),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              _Row(
                key: const Key('import_result_head'),
                icon: headIcon,
                color: headColor,
                text: headText,
              ),
              if (result.duplicates.isNotEmpty)
                _Row(
                  icon: Icons.copy_all_outlined,
                  color: status.warning,
                  text: result.duplicates.length == 1
                      ? '1 was already in your library'
                      : '${result.duplicates.length} were already in your '
                            'library',
                ),
              if (result.similar.isNotEmpty)
                _Row(
                  icon: Icons.compare_outlined,
                  color: scheme.secondary,
                  text:
                      '${result.similar.length} look similar to existing '
                      'screenshots',
                ),
              for (final MapEntry(key: reason, value: names)
                  in byReason.entries)
                _Row(
                  icon: Icons.error_outline,
                  color: scheme.error,
                  text: names.length == 1
                      ? '${names.single}: $reason'
                      : '${names.length} files: $reason',
                ),
              const Gap(Spacing.md),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  if (imported > 0)
                    FilledButton(
                      onPressed: () => onOpen(
                        imported == 1
                            ? Routes.screenshot(result.importedIds.single)
                            : Routes.inbox,
                      ),
                      child: const Text('Review'),
                    ),
                  if (result.duplicates.length == 1)
                    OutlinedButton(
                      onPressed: () => onOpen(
                        Routes.screenshot(result.duplicates.single.existingId),
                      ),
                      child: const Text('Open existing'),
                    ),
                  if (result.similar.isNotEmpty)
                    OutlinedButton(
                      onPressed: () => onOpen(Routes.duplicates),
                      child: const Text('Compare similar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.color,
    required this.text,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(Spacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

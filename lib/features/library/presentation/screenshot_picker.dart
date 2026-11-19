import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../core/repositories/screenshot_repository.dart';
import '../../../core/services/settings_repository.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import 'stable_page.dart';

/// Lets the user pick library screenshots that are not yet in
/// [collectionId]. Returns the chosen ids, or null when cancelled.
Future<List<int>?> pickScreenshotsForCollection(
  BuildContext context, {
  required int collectionId,
  String? collectionName,
}) => Navigator.of(context).push<List<int>>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => ScreenshotPickerScreen(
      excludeCollectionId: collectionId,
      title: collectionName == null ? 'Add screenshots' : 'Add to $collectionName',
    ),
  ),
);

class ScreenshotPickerScreen extends ConsumerStatefulWidget {
  const ScreenshotPickerScreen({
    required this.title,
    this.excludeCollectionId,
    super.key,
  });

  final String title;
  final int? excludeCollectionId;

  @override
  ConsumerState<ScreenshotPickerScreen> createState() =>
      _ScreenshotPickerScreenState();
}

class _ScreenshotPickerScreenState
    extends ConsumerState<ScreenshotPickerScreen> {
  static const _pageSize = 60;

  int _limit = _pageSize;
  final _selected = <int>{};
  final _page = StablePage();

  ScreenshotQuery get _query => ScreenshotQuery(
    excludeCollectionId: widget.excludeCollectionId,
    limit: _limit,
  );

  void _toggle(int id) => setState(() {
    if (!_selected.remove(id)) _selected.add(id);
  });

  Future<void> _selectAll() async {
    final ids = await ref
        .read(screenshotRepositoryProvider)
        .idsMatching(_query);
    if (mounted) setState(() => _selected.addAll(ids));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(screenshotsProvider(_query));
    final items = _page.resolve(_query, async);
    final hideSensitive = ref
        .watch(settingsRepositoryProvider)
        .getBool(SettingsKeys.hideSensitivePreviews, fallback: true);
    final n = _selected.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancel',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(n == 0 ? widget.title : '$n selected'),
        actions: [
          if (items != null && items.isNotEmpty)
            IconButton(
              tooltip: 'Select all',
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
            ),
          Padding(
            padding: const EdgeInsets.only(right: Spacing.xs),
            child: FilledButton(
              key: const Key('picker_add'),
              onPressed: n == 0
                  ? null
                  : () => Navigator.of(context).pop(_selected.toList()),
              child: const Text('Add'),
            ),
          ),
        ],
      ),
      body: items == null
          ? async.hasError
                ? ErrorState(
                    message: 'Your screenshots could not be loaded.',
                    onRetry: () => ref.invalidate(screenshotsProvider(_query)),
                  )
                : const SkeletonList()
          : items.isEmpty
          ? const EmptyState(
              icon: Icons.photo_library_outlined,
              title: 'Nothing to add',
              message:
                  'Every screenshot in your library is already here. '
                  'Import more from Home.',
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (note) {
                if (note.metrics.extentAfter < 600 &&
                    !async.isLoading &&
                    items.length >= _limit) {
                  setState(() => _limit += _pageSize);
                }
                return false;
              },
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.xs,
                  Spacing.md,
                  Spacing.xl,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: Spacing.sm,
                  mainAxisSpacing: Spacing.sm,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final s = items[i];
                  return ScreenshotCard(
                    key: ValueKey(s.id),
                    screenshot: s,
                    hideSensitive: hideSensitive,
                    selectionMode: true,
                    selected: _selected.contains(s.id),
                    onTap: () => _toggle(s.id),
                    onLongPress: () => _toggle(s.id),
                  );
                },
              ),
            ),
    );
  }
}

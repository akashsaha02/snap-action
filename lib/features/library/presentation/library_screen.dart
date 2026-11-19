import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/screenshot_summary.dart';
import '../../../core/repositories/screenshot_repository.dart';
import '../../../core/services/settings_repository.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../../collections/presentation/collection_dialogs.dart';
import '../../screenshot_details/presentation/screenshot_details_screen.dart';
import '../../screenshot_import/application/import_controller.dart';
import 'category_picker.dart';
import 'screenshot_picker.dart';
import 'stable_page.dart';

/// Browsable screenshot list used for the inbox, filtered views, categories
/// and collections.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({
    this.initialFilter = ScreenshotFilter.inbox,
    this.categoryId,
    this.collectionId,
    this.tagId,
    this.title,
    this.showFilters = true,
    this.actions = const [],
    super.key,
  });

  final ScreenshotFilter initialFilter;
  final int? categoryId;
  final int? collectionId;
  final int? tagId;
  final String? title;
  final bool showFilters;
  final List<Widget> actions;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  static const _pageSize = 60;

  late ScreenshotFilter _filter = widget.initialFilter;
  ScreenshotSort _sort = ScreenshotSort.newest;
  int _limit = _pageSize;
  final _selected = <int>{};
  final _page = StablePage();
  bool _selectingAll = false;
  bool _retrying = false;
  late bool _grid =
      ref
          .read(settingsRepositoryProvider)
          .getString(SettingsKeys.inboxViewMode) !=
      'list';

  bool get _selecting => _selected.isNotEmpty;

  ScreenshotQuery get _query => ScreenshotQuery(
    filter: _filter,
    sort: _sort,
    categoryId: widget.categoryId,
    collectionId: widget.collectionId,
    tagId: widget.tagId,
    limit: _limit,
  );

  /// [_query] with a fixed limit, for counts and "everything matching".
  ScreenshotQuery get _allQuery => _query.copyWith(limit: 0);

  /// A collection, category or tag view rather than the library itself.
  bool get _inContext =>
      widget.collectionId != null ||
      widget.categoryId != null ||
      widget.tagId != null;

  static const _filters = [
    FilterOption(
      ScreenshotFilter.inbox,
      'Needs review',
      icon: Icons.inbox_outlined,
    ),
    FilterOption(
      ScreenshotFilter.all,
      'All',
      icon: Icons.photo_library_outlined,
    ),
    FilterOption(
      ScreenshotFilter.favorites,
      'Favourites',
      icon: Icons.star_outline,
    ),
    FilterOption(
      ScreenshotFilter.processing,
      'Processing',
      icon: Icons.autorenew,
    ),
    FilterOption(ScreenshotFilter.failed, 'Failed', icon: Icons.error_outline),
    FilterOption(
      ScreenshotFilter.archived,
      'Archived',
      icon: Icons.archive_outlined,
    ),
  ];

  void _toggle(int id) => setState(() {
    if (!_selected.remove(id)) _selected.add(id);
  });

  /// Selects every screenshot matching the current view, including those
  /// not loaded yet, so bulk actions never silently miss items.
  Future<void> _selectAll() async {
    if (_selectingAll) return;
    setState(() => _selectingAll = true);
    try {
      final ids = await ref
          .read(screenshotRepositoryProvider)
          .idsMatching(_allQuery);
      if (mounted) setState(() => _selected.addAll(ids));
    } finally {
      if (mounted) setState(() => _selectingAll = false);
    }
  }

  Future<void> _retryAllFailed() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      final ids = await ref
          .read(screenshotRepositoryProvider)
          .idsMatching(_allQuery, failedOnly: true);
      if (ids.isEmpty) return;
      await ref.read(jobRunnerProvider).retry(ids);
      if (mounted) {
        context.showSnack(
          ids.length == 1
              ? 'Processing 1 screenshot again'
              : 'Processing ${ids.length} screenshots again',
        );
      }
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  /// Lets the user pick library screenshots and adds them to the collection.
  Future<void> _addScreenshots() async {
    final collectionId = widget.collectionId;
    if (collectionId == null) return;
    final ids = await pickScreenshotsForCollection(
      context,
      collectionId: collectionId,
      collectionName: widget.title,
    );
    if (ids == null || ids.isEmpty || !mounted) return;
    await ref
        .read(organizationRepositoryProvider)
        .addToCollection(collectionId, ids);
    if (mounted) {
      context.showSnack(
        ids.length == 1
            ? 'Added 1 screenshot'
            : 'Added ${ids.length} screenshots',
      );
    }
  }

  void _import() =>
      unawaited(ref.read(importControllerProvider.notifier).pickFromGallery());

  Future<void> _setLayout(bool grid) async {
    setState(() => _grid = grid);
    await ref
        .read(settingsRepositoryProvider)
        .setString(SettingsKeys.inboxViewMode, grid ? 'grid' : 'list');
  }

  Future<void> _bulk(
    Future<void> Function(List<int> ids) action,
    String done,
  ) async {
    final ids = _selected.toList();
    setState(_selected.clear);
    await action(ids);
    if (mounted) context.showSnack(done);
  }

  Future<void> _delete() async {
    final count = _selected.length;
    final ok = await showConfirmationDialog(
      context,
      title: count == 1 ? 'Delete screenshot?' : 'Delete $count screenshots?',
      message:
          'This removes the copy stored in Snaptiq with its text, notes and '
          'suggestions. Images in your gallery are not affected.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _bulk(
      (ids) => ref.read(libraryServiceProvider).delete(ids),
      count == 1 ? 'Screenshot deleted' : '$count screenshots deleted',
    );
  }

  Future<void> _addToCollection() async {
    final id = await showCollectionPicker(context, ref);
    if (id == null || !mounted) return;
    await _bulk(
      (ids) =>
          ref.read(organizationRepositoryProvider).addToCollection(id, ids),
      'Added to collection',
    );
  }

  Future<void> _addTag() async {
    final tag = await showTagInput(context);
    if (tag == null || !mounted) return;
    try {
      await _bulk(
        (ids) =>
            ref.read(organizationRepositoryProvider).addTagToMany(ids, tag),
        'Tag added',
      );
    } on ArgumentError catch (e) {
      if (mounted) context.showSnack('${e.message}', error: true);
    }
  }

  Future<void> _setCategory() async {
    final id = await showCategoryPicker(context);
    if (id == null || !mounted) return;
    await _bulk(
      (ids) => ref.read(screenshotRepositoryProvider).setCategory(ids, id),
      'Category updated',
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(screenshotRepositoryProvider);
    final async = ref.watch(screenshotsProvider(_query));
    // Keeps the current page on screen while a longer one loads.
    final items = _page.resolve(_query, async);
    final importing = ref.watch(
      importControllerProvider.select((s) => s.running),
    );
    final hideSensitive = ref
        .watch(settingsRepositoryProvider)
        .getBool(SettingsKeys.hideSensitivePreviews, fallback: true);
    final archived = _filter == ScreenshotFilter.archived;
    final showRetry =
        !_selecting &&
        (_filter == ScreenshotFilter.failed ||
            (items?.any((s) => s.status == ProcessingStatus.failed) ?? false));
    final failedCount = showRetry
        ? ref
              .watch(
                screenshotCountProvider((query: _allQuery, failedOnly: true)),
              )
              .value
        : null;

    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_selected.clear);
      },
      child: Scaffold(
        appBar: _selecting
            ? AppBar(
                leading: IconButton(
                  tooltip: 'Clear selection',
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(_selected.clear),
                ),
                title: Text('${_selected.length} selected'),
                actions: [
                  IconButton(
                    key: const Key('library_select_all'),
                    tooltip: 'Select all',
                    icon: const Icon(Icons.select_all),
                    onPressed: _selectingAll ? null : _selectAll,
                  ),
                  IconButton(
                    tooltip: 'Mark reviewed',
                    icon: const Icon(Icons.done_all),
                    onPressed: () => _bulk(
                      (ids) => repo.setReviewed(ids, value: true),
                      'Marked as reviewed',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _delete,
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    onSelected: (v) => switch (v) {
                      'category' => _setCategory(),
                      'collection' => _addToCollection(),
                      'tag' => _addTag(),
                      'uncollect' => _bulk(
                        (ids) => ref
                            .read(organizationRepositoryProvider)
                            .removeFromCollection(widget.collectionId!, ids),
                        'Removed from collection',
                      ),
                      'favorite' => _bulk(
                        (ids) => repo.setFavorite(ids, value: true),
                        'Added to favourites',
                      ),
                      'archive' => _bulk(
                        (ids) => repo.setArchived(ids, value: !archived),
                        archived ? 'Restored from archive' : 'Archived',
                      ),
                      'retry' => _bulk(
                        (ids) => ref.read(jobRunnerProvider).retry(ids),
                        'Processing again',
                      ),
                      _ => Future<void>.value(),
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'category',
                        child: Text('Change category'),
                      ),
                      const PopupMenuItem(
                        value: 'collection',
                        child: Text('Add to collection'),
                      ),
                      const PopupMenuItem(value: 'tag', child: Text('Add tag')),
                      if (widget.collectionId != null)
                        const PopupMenuItem(
                          value: 'uncollect',
                          child: Text('Remove from collection'),
                        ),
                      const PopupMenuItem(
                        value: 'favorite',
                        child: Text('Add to favourites'),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Text(archived ? 'Unarchive' : 'Archive'),
                      ),
                      const PopupMenuItem(
                        value: 'retry',
                        child: Text('Process again'),
                      ),
                    ],
                  ),
                ],
              )
            : AppBar(
                title: Text(widget.title ?? 'Library'),
                actions: [
                  ...widget.actions,
                  IconButton(
                    tooltip: _grid ? 'Show as list' : 'Show as grid',
                    icon: Icon(
                      _grid ? Icons.view_agenda_outlined : Icons.grid_view,
                    ),
                    onPressed: () => _setLayout(!_grid),
                  ),
                  PopupMenuButton<ScreenshotSort>(
                    tooltip: 'Sort',
                    icon: const Icon(Icons.sort),
                    initialValue: _sort,
                    onSelected: (s) => setState(() {
                      _sort = s;
                      _limit = _pageSize;
                    }),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: ScreenshotSort.newest,
                        child: Text('Newest first'),
                      ),
                      PopupMenuItem(
                        value: ScreenshotSort.oldest,
                        child: Text('Oldest first'),
                      ),
                      PopupMenuItem(
                        value: ScreenshotSort.title,
                        child: Text('Title A-Z'),
                      ),
                    ],
                  ),
                ],
              ),
        floatingActionButton: _selecting
            ? null
            : widget.collectionId != null
            ? PopShadow.pill(
                child: FloatingActionButton.extended(
                  key: const Key('collection_add_screenshots'),
                  heroTag: 'collection_add',
                  onPressed: _addScreenshots,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add screenshots'),
                ),
              )
            // Importing from a category or tag view would not file the new
            // screenshots there, so importing is offered in the library only.
            : _inContext
            ? null
            : PopShadow.pill(
                child: FloatingActionButton.extended(
                  key: const Key('library_import'),
                  heroTag: 'library_import',
                  onPressed: importing ? null : _import,
                  icon: importing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(importing ? 'Importing…' : 'Import'),
                ),
              ),
        body: Column(
          children: [
            if (widget.showFilters)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: FilterChipBar<ScreenshotFilter>(
                  options: _filters,
                  selected: _filter,
                  onSelected: (f) => setState(() {
                    _filter = f;
                    _limit = _pageSize;
                    _selected.clear();
                  }),
                ),
              ),
            if (showRetry && (failedCount ?? 0) > 0)
              _RetryBar(
                count: failedCount!,
                busy: _retrying,
                onRetry: _retryAllFailed,
              ),
            Expanded(
              child: items == null
                  ? async.hasError
                        ? ErrorState(
                            message: 'Your screenshots could not be loaded.',
                            onRetry: () =>
                                ref.invalidate(screenshotsProvider(_query)),
                          )
                        : const SkeletonList()
                  : items.isEmpty
                  ? _empty(importing)
                  : Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            // A list shorter than the limit is complete; a
                            // longer page may already be loading.
                            if (n.metrics.extentAfter < 600 &&
                                !async.isLoading &&
                                items.length >= _limit) {
                              setState(() => _limit += _pageSize);
                            }
                            return false;
                          },
                          child: _grid
                              ? _buildGrid(items, hideSensitive)
                              : _buildList(items, hideSensitive),
                        ),
                        if (async.isLoading)
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: LinearProgressIndicator(
                              key: Key('library_loading_more'),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ScreenshotCard _card(
    ScreenshotSummary s,
    bool hideSensitive,
    ScreenshotCardLayout layout,
  ) => ScreenshotCard(
    key: ValueKey(s.id),
    screenshot: s,
    layout: layout,
    hideSensitive: hideSensitive,
    selectionMode: _selecting,
    selected: _selected.contains(s.id),
    onTap: () => _selecting
        ? _toggle(s.id)
        : context.push(
            // From "Needs review" the details screen offers "Reviewed & next".
            _filter == ScreenshotFilter.inbox
                ? ScreenshotDetailsScreen.inboxRoute(s.id)
                : Routes.screenshot(s.id),
          ),
    onLongPress: () => _toggle(s.id),
    onFavoriteToggle: _selecting
        ? null
        : () => ref.read(screenshotRepositoryProvider).setFavorite([
            s.id,
          ], value: !s.isFavorite),
  );

  Widget _buildGrid(List<ScreenshotSummary> items, bool hideSensitive) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.62,
        crossAxisSpacing: Spacing.sm,
        mainAxisSpacing: Spacing.sm,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) =>
          _card(items[i], hideSensitive, ScreenshotCardLayout.grid),
    );
  }

  Widget _buildList(List<ScreenshotSummary> items, bool hideSensitive) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Gap(Spacing.xs),
      itemBuilder: (_, i) =>
          _card(items[i], hideSensitive, ScreenshotCardLayout.list),
    );
  }

  Widget _empty(bool importing) {
    if (_filter == ScreenshotFilter.all && _inContext) {
      if (widget.collectionId != null) {
        return EmptyState(
          art: BrandArt.emptyLibrary,
          icon: Icons.folder_open_outlined,
          title: 'This collection is empty',
          message: 'Add screenshots from your library to keep them together.',
          action: PrimaryButton(
            key: const Key('collection_empty_add'),
            label: 'Add screenshots',
            icon: Icons.add_photo_alternate_outlined,
            onPressed: _addScreenshots,
          ),
        );
      }
      if (widget.tagId != null) {
        return const EmptyState(
          art: BrandArt.noResults,
          icon: Icons.sell_outlined,
          title: 'No screenshots with this tag',
          message:
              'Add tags from a screenshot, or select screenshots in your '
              'library and choose "Add tag".',
        );
      }
      return const EmptyState(
        art: BrandArt.emptyLibrary,
        icon: Icons.category_outlined,
        title: 'Nothing in this category yet',
        message:
            'Screenshots sorted into this category appear here. You can '
            'change the category of any screenshot from its details.',
      );
    }
    final (icon, title, message) = switch (_filter) {
      ScreenshotFilter.inbox => (
        Icons.inbox_outlined,
        'All caught up',
        'New imports appear here until you review them.',
      ),
      ScreenshotFilter.favorites => (
        Icons.star_outline,
        'No favourites yet',
        'Tap the star on a screenshot to keep it close.',
      ),
      ScreenshotFilter.archived => (
        Icons.archive_outlined,
        'Archive is empty',
        'Archived screenshots stay searchable but out of the way.',
      ),
      ScreenshotFilter.failed => (
        Icons.check_circle_outline,
        'No failures',
        'Every screenshot was processed.',
      ),
      ScreenshotFilter.processing => (
        Icons.hourglass_empty,
        'Nothing in the queue',
        'Imported screenshots are processed on this device.',
      ),
      ScreenshotFilter.all => (
        Icons.photo_library_outlined,
        'No screenshots yet',
        'Import screenshots or share them to Snaptiq from any app.',
      ),
    };
    return EmptyState(
      // Nothing left to do is good news; an empty library is an invitation.
      art: switch (_filter) {
        ScreenshotFilter.inbox ||
        ScreenshotFilter.failed ||
        ScreenshotFilter.processing => BrandArt.allDone,
        ScreenshotFilter.all => BrandArt.emptyLibrary,
        ScreenshotFilter.favorites ||
        ScreenshotFilter.archived => BrandArt.noResults,
      },
      icon: icon,
      title: title,
      message: message,
      action:
          !_inContext &&
              (_filter == ScreenshotFilter.all ||
                  _filter == ScreenshotFilter.inbox)
          ? PrimaryButton(
              label: 'Import screenshots',
              icon: Icons.add_photo_alternate_outlined,
              loading: importing,
              onPressed: _import,
            )
          : null,
    );
  }
}

/// Offers to queue every failed screenshot in the current view again.
class _RetryBar extends StatelessWidget {
  const _RetryBar({
    required this.count,
    required this.busy,
    required this.onRetry,
  });

  final int count;
  final bool busy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card.filled(
      color: scheme.errorContainer,
      margin: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.sm,
          Spacing.xxs,
          Spacing.xxs,
          Spacing.xxs,
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const Gap(Spacing.sm),
            Expanded(
              child: Text(
                count == 1
                    ? '1 screenshot could not be processed.'
                    : '$count screenshots could not be processed.',
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
            TextButton(
              key: const Key('library_retry_failed'),
              onPressed: busy ? null : onRetry,
              child: const Text('Retry all failed'),
            ),
          ],
        ),
      ),
    );
  }
}

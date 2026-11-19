import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/models/screenshot_summary.dart';
import '../../../core/repositories/search_repository.dart';
import '../../../core/services/settings_repository.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../../../l10n/generated/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  /// Query parameter that asks the screen to focus the search field. Its
  /// value is a token: each new value focuses the field once, so callers
  /// should pass a fresh one per tap (see [focusLocation]).
  static const focusParam = 'focus';

  /// Location that opens the Search tab with the keyboard up, for example
  /// from the search bar on Home.
  static String focusLocation() =>
      '${Routes.search}?$focusParam=${DateTime.now().microsecondsSinceEpoch}';

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _fieldKey = GlobalKey();
  SearchRequest _request = const SearchRequest();
  List<String> _suggestions = const [];
  String? _handledFocusToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String? token;
    try {
      token = GoRouterState.of(context)
          .uri
          .queryParameters[SearchScreen.focusParam];
    } on GoError {
      token = null;
    }
    if (token == null || token.isEmpty || token == _handledFocusToken) return;
    _handledFocusToken = token;
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusField());
  }

  /// Focuses the text field inside [DebouncedSearchField], which does not
  /// expose its focus node.
  void _focusField() {
    if (!mounted) return;
    void visit(Element e) {
      final w = e.widget;
      if (w is EditableText) {
        w.focusNode.requestFocus();
        return;
      }
      e.visitChildElements(visit);
    }

    _fieldKey.currentContext?.visitChildElements(visit);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onQuery(String text) async {
    setState(() => _request = _request.copyWith(text: text));
    final suggestions = await ref
        .read(searchRepositoryProvider)
        .suggestions(text);
    if (mounted) setState(() => _suggestions = suggestions);
  }

  void _useQuery(String q) {
    _controller
      ..text = q
      ..selection = TextSelection.collapsed(offset: q.length);
    unawaited(_onQuery(q));
    unawaited(ref.read(searchRepositoryProvider).remember(q));
  }

  void _toggleContent(SearchContent c) {
    final next = {..._request.contains};
    if (!next.remove(c)) next.add(c);
    setState(() => _request = _request.copyWith(contains: next));
  }

  Future<void> _pickCategory() async {
    final categories =
        ref.read(categoriesProvider).value ?? const <CategoryInfo>[];
    final id = await showAppBottomSheet<int>(
      context,
      title: 'Category',
      builder: (c) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('Any category'),
            onTap: () => Navigator.of(c).pop(-1),
          ),
          for (final cat in categories)
            ListTile(
              title: Text(cat.name),
              selected: cat.id == _request.categoryId,
              onTap: () => Navigator.of(c).pop(cat.id),
            ),
        ],
      ),
    );
    if (id == null) return;
    setState(
      () =>
          _request = _request.copyWith(categoryId: () => id == -1 ? null : id),
    );
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: _request.from == null
          ? null
          : DateTimeRange(start: _request.from!, end: _request.to ?? now),
    );
    if (range == null) return;
    setState(
      () => _request = _request.copyWith(
        from: () => range.start,
        to: () => range.end,
      ),
    );
  }

  void _clearFilters() => setState(
    () => _request = SearchRequest(text: _request.text, sort: _request.sort),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categories =
        ref.watch(categoriesProvider).value ?? const <CategoryInfo>[];
    final categoryName = categories
        .where((c) => c.id == _request.categoryId)
        .map((c) => c.name)
        .firstOrNull;
    final r = _request;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSearch),
        actions: [
          PopupMenuButton<SearchSort>(
            tooltip: 'Sort results',
            icon: const Icon(Icons.sort),
            initialValue: r.sort,
            onSelected: (s) => setState(() => _request = r.copyWith(sort: s)),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: SearchSort.relevance,
                child: Text('Best match'),
              ),
              PopupMenuItem(
                value: SearchSort.newest,
                child: Text('Newest first'),
              ),
              PopupMenuItem(
                value: SearchSort.oldest,
                child: Text('Oldest first'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              0,
              Spacing.md,
              Spacing.xs,
            ),
            child: KeyedSubtree(
              key: _fieldKey,
              child: DebouncedSearchField(
                key: const Key('search_field'),
                controller: _controller,
                hint: l10n.searchHint,
                onChanged: _onQuery,
                onSubmitted: (q) =>
                    ref.read(searchRepositoryProvider).remember(q),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              children: [
                _chip(
                  label: categoryName ?? 'Category',
                  icon: Icons.category_outlined,
                  selected: categoryName != null,
                  onTap: _pickCategory,
                ),
                _chip(
                  label: r.from == null
                      ? 'Date'
                      : '${Formatters.relativeDay(r.from!)} – ${Formatters.relativeDay(r.to ?? DateTime.now())}',
                  icon: Icons.date_range_outlined,
                  selected: r.from != null,
                  onTap: _pickDates,
                ),
                _chip(
                  label: 'Favourites',
                  icon: Icons.star_outline,
                  selected: r.favoritesOnly,
                  onTap: () => setState(
                    () =>
                        _request = r.copyWith(favoritesOnly: !r.favoritesOnly),
                  ),
                ),
                for (final (c, label, icon) in const [
                  (
                    SearchContent.date,
                    'Has date',
                    Icons.calendar_today_outlined,
                  ),
                  (SearchContent.amount, 'Has amount', Icons.payments_outlined),
                  (SearchContent.link, 'Has link', Icons.link),
                  (SearchContent.phone, 'Has phone', Icons.call_outlined),
                  (SearchContent.address, 'Has address', Icons.place_outlined),
                  (SearchContent.code, 'Has code', Icons.code),
                ])
                  _chip(
                    label: label,
                    icon: icon,
                    selected: r.contains.contains(c),
                    onTap: () => _toggleContent(c),
                  ),
                _chip(
                  label: 'Include archived',
                  icon: Icons.archive_outlined,
                  selected: r.includeArchived,
                  onTap: () => setState(
                    () => _request = r.copyWith(
                      includeArchived: !r.includeArchived,
                    ),
                  ),
                ),
                if (r.hasFilters)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          if (_suggestions.isNotEmpty && r.text.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                children: [
                  for (final s in _suggestions)
                    Padding(
                      padding: const EdgeInsets.only(right: Spacing.xs),
                      child: ActionChip(
                        avatar: const Icon(Icons.north_west, size: 16),
                        label: Text(s),
                        onPressed: () => _useQuery(s),
                      ),
                    ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: r.isEmpty
                ? _History(onSelect: _useQuery)
                : _Results(request: r, theme: theme),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.only(right: Spacing.xs, bottom: Spacing.xs),
    child: FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
    ),
  );
}

class _History extends ConsumerWidget {
  const _History({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(searchHistoryProvider).value ?? const <String>[];
    if (history.isEmpty) {
      return EmptyState(
        icon: Icons.manage_search_rounded,
        title: l10n.emptySearchTitle,
        message: l10n.emptySearchBody,
      );
    }
    final repo = ref.read(searchRepositoryProvider);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: SectionHeader(
            title: 'Recent searches',
            actionLabel: 'Clear',
            onAction: repo.clearHistory,
          ),
        ),
        for (final q in history)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(q),
            onTap: () => onSelect(q),
            trailing: IconButton(
              tooltip: 'Remove from history',
              icon: const Icon(Icons.close),
              onPressed: () => repo.forget(q),
            ),
          ),
      ],
    );
  }
}

class _Results extends ConsumerStatefulWidget {
  const _Results({required this.request, required this.theme});

  final SearchRequest request;
  final ThemeData theme;

  @override
  ConsumerState<_Results> createState() => _ResultsState();
}

class _ResultsState extends ConsumerState<_Results> {
  int _limit = SearchRequest.defaultLimit;

  /// Results kept on screen while a longer page of the same search loads.
  SearchResults? _last;
  SearchRequest? _lastBase;

  @override
  void didUpdateWidget(_Results oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request != widget.request) {
      _limit = SearchRequest.defaultLimit;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request.copyWith(limit: _limit);
    final theme = widget.theme;
    final async = ref.watch(searchResultsProvider(request));
    if (async.hasValue) {
      _last = async.value;
      _lastBase = widget.request;
    }
    final results = async.value ?? (_lastBase == widget.request ? _last : null);
    final loadingMore = async.isLoading && results != null;
    final hideSensitive = ref
        .watch(settingsRepositoryProvider)
        .getBool(SettingsKeys.hideSensitivePreviews, fallback: true);
    if (results == null) {
      return async.hasError
          ? ErrorState(
              message: 'Search failed. Try different words.',
              onRetry: () => ref.invalidate(searchResultsProvider(request)),
            )
          : const SkeletonList();
    }
    if (results.hits.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No matches',
        message: request.text.trim().isEmpty
            ? 'No screenshots match these filters.'
            : 'Nothing matches "${request.text.trim()}". Try fewer words or remove filters.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.xl,
      ),
      itemCount: results.hits.length + (results.hasMore ? 2 : 1),
      separatorBuilder: (_, _) => const Gap(Spacing.xs),
      itemBuilder: (context, i) {
        if (i == 0) {
          final n = results.hits.length;
          return Semantics(
            liveRegion: true,
            child: Text(
              results.hasMore
                  ? '$n+ results'
                  : n == 1
                  ? '1 result'
                  : '$n results',
              key: const Key('search_result_count'),
              style: theme.textTheme.labelMedium,
            ),
          );
        }
        if (i > results.hits.length) {
          return Center(
            child: OutlinedButton(
              key: const Key('search_load_more'),
              onPressed: loadingMore
                  ? null
                  : () => setState(() => _limit += SearchRequest.defaultLimit),
              child: loadingMore
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load more'),
            ),
          );
        }
        final hit = results.hits[i - 1];
        final s = hit.screenshot;
        final blur = hideSensitive && s.isSensitive;
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              unawaited(
                ref
                    .read(searchRepositoryProvider)
                    .remember(widget.request.text),
              );
              unawaited(context.push(Routes.screenshot(s.id)));
            },
            child: Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    child: SizedBox(
                      width: 64,
                      height: 86,
                      child: ScreenshotThumbnail(
                        path: s.thumbnailPath ?? s.localFilePath,
                        blur: blur,
                      ),
                    ),
                  ),
                  const Gap(Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.displayTitle,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          [
                            Formatters.relativeDay(s.importedAt),
                            if (s.effectiveCategory != null)
                              s.effectiveCategory!.name,
                          ].join(' • '),
                          style: theme.textTheme.labelSmall,
                        ),
                        if (hit.snippet != null && !blur) ...[
                          const Gap(Spacing.xxs),
                          HighlightedText(
                            hit.snippet!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Renders text with [SearchHit] highlight markers as bold, tinted spans.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.marked, {
    this.style,
    this.maxLines = 3,
    super.key,
  });

  final String marked;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spans = <TextSpan>[];
    final parts = marked.split(SearchHit.highlightStart);
    for (final (i, part) in parts.indexed) {
      if (i == 0) {
        spans.add(TextSpan(text: part));
        continue;
      }
      final end = part.indexOf(SearchHit.highlightEnd);
      if (end < 0) {
        spans.add(TextSpan(text: part));
        continue;
      }
      spans
        ..add(
          TextSpan(
            text: part.substring(0, end),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              backgroundColor: scheme.primaryContainer,
              color: scheme.onPrimaryContainer,
            ),
          ),
        )
        ..add(TextSpan(text: part.substring(end + 1)));
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

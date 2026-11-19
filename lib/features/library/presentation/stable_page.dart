import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/screenshot_summary.dart';
import '../../../core/repositories/screenshot_repository.dart';

/// Remembers the last loaded page of a paged screenshot list so it stays on
/// screen while a longer page for the same query loads.
///
/// Growing the page limit changes the provider key, and a new provider
/// starts out loading. Without this the list would be swapped for a loading
/// placeholder in the middle of scrolling.
class StablePage {
  ScreenshotQuery? _base;
  List<ScreenshotSummary>? _items;

  /// The items to show for [query]: the current value when there is one,
  /// otherwise the previous page of the same query (ignoring the limit), or
  /// null when nothing for this query has loaded yet.
  List<ScreenshotSummary>? resolve(
    ScreenshotQuery query,
    AsyncValue<List<ScreenshotSummary>> async,
  ) {
    final base = query.copyWith(limit: 0);
    if (async.hasValue) {
      _base = base;
      _items = async.value;
      return _items;
    }
    return _base == base ? _items : null;
  }
}

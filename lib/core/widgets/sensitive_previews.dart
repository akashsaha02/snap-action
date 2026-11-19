import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/bootstrap.dart';
import '../services/settings_repository.dart';

/// Reads the "Blur sensitive previews" setting.
///
/// Returns `null` when the setting cannot be read: there is no
/// [ProviderScope] above [context] or the app has not finished starting.
/// Callers decide on the fallback; for previews it should be "hide", the
/// same default the settings screen shows.
bool? readHideSensitivePreviews(BuildContext context) {
  final ProviderContainer container;
  try {
    container = ProviderScope.containerOf(context, listen: false);
  } on StateError {
    return null;
  }
  // Never start the bootstrap from a thumbnail (it opens the database):
  // only read settings that are already loaded.
  final ready =
      container.read(settingsRepositoryProvider.exists) ||
      (container.read(appBootstrapProvider.exists) &&
          container.read(appBootstrapProvider).hasValue);
  if (!ready) return null;
  try {
    return container
        .read(settingsRepositoryProvider)
        .getBool(SettingsKeys.hideSensitivePreviews, fallback: true);
  } on Object {
    return null;
  }
}

/// Whether a [ProviderScope] is available above [context].
bool hasProviderScope(BuildContext context) {
  try {
    ProviderScope.containerOf(context, listen: false);
    return true;
  } on StateError {
    return false;
  }
}

/// File paths (originals and thumbnails) of screenshots marked sensitive.
///
/// Lets previews that only know a path (collection tiles, reminder and
/// wishlist thumbnails) honour the "Blur sensitive previews" setting.
final sensitivePreviewPathsProvider = StreamProvider.autoDispose<Set<String>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .customSelect(
        'SELECT thumbnail_path AS t, local_file_path AS l '
        'FROM screenshots WHERE is_sensitive = 1',
        readsFrom: {db.screenshots},
      )
      .watch()
      .map(
        (rows) => <String>{
          for (final r in rows) ...[
            ?r.read<String?>('t'),
            ?r.read<String?>('l'),
          ],
        },
      )
      .distinct(setEquals);
});

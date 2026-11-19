import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/services/feature_flags.dart';
import 'package:snapaction/core/services/settings_repository.dart';

import '../helpers/test_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('every flag is off on a fresh install', () async {
    final flags = FeatureFlags(await SettingsRepository.load(db));
    for (final f in FeatureFlag.values) {
      expect(flags.isEnabled(f), isFalse, reason: f.name);
    }
    expect(flags.enabled, isEmpty);
  });

  test('a flag persists across restarts and does not affect others', () async {
    await FeatureFlags(await SettingsRepository.load(db))
        .setEnabled(FeatureFlag.semanticSearch, enabled: true);

    // A new repository reads the stored value, as after an app restart.
    final reloaded = FeatureFlags(await SettingsRepository.load(db));
    expect(reloaded.isEnabled(FeatureFlag.semanticSearch), isTrue);
    expect(reloaded.enabled, [FeatureFlag.semanticSearch]);

    await reloaded.setEnabled(FeatureFlag.semanticSearch, enabled: false);
    expect(reloaded.isEnabled(FeatureFlag.semanticSearch), isFalse);
  });

  test('flag keys are stable', () {
    // Stored on devices; renaming an enum value would silently reset it.
    expect(FeatureFlag.values.map((f) => f.settingsKey), [
      'flag_unifiedMemories',
      'flag_newNavigation',
      'flag_semanticSearch',
      'flag_modelCenter',
      'flag_pdfImport',
      'flag_spaces',
    ]);
  });
}

import 'settings_repository.dart';

/// Experiments for the RecallOS programme (docs/IMPLEMENTATION_ROADMAP.md).
///
/// Every flag is off by default and is stored per device in `app_settings`.
/// A flag only switches behaviour; it never migrates or deletes data, which
/// happens through schema versions instead.
enum FeatureFlag {
  /// New memory types (documents, notes, links) in import and the library.
  unifiedMemories,

  /// Home / Memories / Recall / Connections / Profile navigation.
  newNavigation,

  /// Hybrid keyword and semantic retrieval in search.
  semanticSearch,

  /// On-device model management in Settings.
  modelCenter,

  /// PDF capture and viewer.
  pdfImport,

  /// Spaces, related memories and the timeline.
  spaces;

  String get settingsKey => 'flag_$name';
}

class FeatureFlags {
  const FeatureFlags(this._settings);

  final SettingsRepository _settings;

  bool isEnabled(FeatureFlag flag) =>
      _settings.getBool(flag.settingsKey, fallback: false);

  Future<void> setEnabled(FeatureFlag flag, {required bool enabled}) =>
      _settings.setBool(flag.settingsKey, value: enabled);

  /// Flags that are currently on, for diagnostics screens.
  List<FeatureFlag> get enabled => [
    for (final f in FeatureFlag.values)
      if (isEnabled(f)) f,
  ];
}

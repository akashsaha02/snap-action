import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/services/settings_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/entity_extraction/entity_models.dart';
import '../../backup/application/backup_service.dart';
import '../../reminders/application/reminder_defaults.dart';
import '../../security/application/app_lock.dart';
import 'backup_actions.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  SettingsRepository get _settings => ref.read(settingsRepositoryProvider);

  /// True while "Re-analyse all" runs, so it cannot be started twice.
  bool _reanalyzing = false;

  Future<void> _setBool(String key, bool value) async {
    await _settings.setBool(key, value: value);
    setState(() {});
  }

  /// Re-runs analysis on every screenshot behind a progress dialog.
  Future<void> _reanalyzeAll() async {
    if (_reanalyzing) return;
    setState(() => _reanalyzing = true);
    try {
      await runWithProgress(
        context,
        'Re-analysing screenshots…',
        () => ref.read(jobRunnerProvider).reanalyzeAll(),
      );
      if (mounted) context.showSnack('Screenshots re-analysed');
    } on Object catch (e) {
      if (mounted) context.showSnack('Re-analysis failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _reanalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    final s = ref.watch(settingsRepositoryProvider);
    final lock = ref.watch(appLockProvider);
    final notificationsOn = ref.watch(notificationsEnabledProvider).value;
    final usage = ref.watch(storageUsageProvider).value;
    final dateOrder =
        DateOrder.values.asNameMap()[s.getString(SettingsKeys.dateOrder)] ??
        DateOrder.dmy;
    final reminderTime = defaultReminderTime(s);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          const _Header('Appearance'),
          Padding(
            padding: Spacing.pagePadding,
            child: SegmentedButton<ThemeMode>(
              key: const ValueKey('theme_selector'),
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('System'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (sel) =>
                  ref.read(themeModeProvider.notifier).set(sel.first),
            ),
          ),

          const _Header('Text recognition'),
          SwitchListTile(
            key: const Key('ocr_enabled'),
            secondary: const Icon(Icons.document_scanner_outlined),
            title: const Text('Read text in screenshots'),
            subtitle: const Text(
              'Runs on this device. Turn off to only store images.',
            ),
            value: s.getBool(SettingsKeys.ocrEnabled, fallback: true),
            onChanged: (v) => _setBool(SettingsKeys.ocrEnabled, v),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('Date format in screenshots'),
            subtitle: Text(switch (dateOrder) {
              DateOrder.dmy => 'Day first (31/12/2026)',
              DateOrder.mdy => 'Month first (12/31/2026)',
              DateOrder.ymd => 'Year first (2026/12/31)',
            }),
            onTap: () async {
              final picked = await showDialog<DateOrder>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('How are dates usually written?'),
                  children: [
                    RadioGroup<DateOrder>(
                      groupValue: dateOrder,
                      onChanged: (v) => Navigator.of(context).pop(v),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final (order, label) in [
                            (DateOrder.dmy, 'Day first: 31/12/2026'),
                            (DateOrder.mdy, 'Month first: 12/31/2026'),
                            (DateOrder.ymd, 'Year first: 2026/12/31'),
                          ])
                            RadioListTile<DateOrder>(
                              value: order,
                              title: Text(label),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              if (picked == null || picked == dateOrder) return;
              await _settings.setString(SettingsKeys.dateOrder, picked.name);
              setState(() {});
              if (context.mounted) {
                context.showSnack(
                  'Applies to new screenshots.',
                  actionLabel: 'Re-analyse all',
                  onAction: () => unawaited(_reanalyzeAll()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: const Text('Process two screenshots at once'),
            subtitle: const Text('Faster on newer phones; uses more memory.'),
            trailing: Switch(
              value: s.getInt(SettingsKeys.ocrConcurrency, fallback: 1) > 1,
              onChanged: (v) async {
                await _settings.setInt(SettingsKeys.ocrConcurrency, v ? 2 : 1);
                setState(() {});
              },
            ),
          ),
          ListTile(
            key: const Key('reanalyze_all'),
            leading: const Icon(Icons.refresh),
            title: const Text('Re-analyse all screenshots'),
            subtitle: const Text(
              'Re-runs categories, details and suggestions on the stored text. '
              'Categories you chose yourself are kept.',
            ),
            enabled: !_reanalyzing,
            onTap: () async {
              final ok = await showConfirmationDialog(
                context,
                title: 'Re-analyse all screenshots?',
                message: 'This can take a while for large libraries. Your own edits are kept.',
                confirmLabel: 'Re-analyse',
              );
              if (!ok) return;
              await _reanalyzeAll();
            },
          ),

          const _Header('Import'),
          SwitchListTile(
            secondary: const Icon(Icons.compare_outlined),
            title: const Text('Detect similar screenshots'),
            subtitle: const Text(
              'Compares new imports with your library. Exact duplicates are always skipped.',
            ),
            value: s.getBool(SettingsKeys.similarDetection, fallback: true),
            onChanged: (v) {
              unawaited(_setBool(SettingsKeys.similarDetection, v));
              ref.invalidate(importServiceProvider);
            },
          ),
          const _Note(
            'Mindtiq keeps its own private copy of every screenshot you import. '
            'Deleting a screenshot here removes only that copy. The original stays in '
            'your gallery, and Mindtiq never deletes gallery images.',
          ),

          const _Header('Notifications'),
          ListTile(
            leading: Icon(
              notificationsOn ?? true
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
            ),
            title: const Text('Reminder notifications'),
            subtitle: Text(
              notificationsOn == null
                  ? 'Checking…'
                  : notificationsOn
                  ? 'On. Delivery may be delayed a few minutes by Android battery saving.'
                  : 'Off. Reminders still appear in the Reminders tab.',
            ),
            trailing: notificationsOn == false
                ? TextButton(
                    onPressed: () async {
                      final granted = await ref
                          .read(notificationServiceProvider)
                          .requestPermission();
                      ref.invalidate(notificationsEnabledProvider);
                      if (granted) {
                        await ref.read(reminderServiceProvider).resyncAll();
                      } else if (context.mounted) {
                        context.showSnack(
                          'You can allow notifications in Android settings.',
                        );
                      }
                    },
                    child: const Text('Turn on'),
                  )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Default reminder time'),
            subtitle: Text(reminderTime.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: reminderTime,
                initialEntryMode: TimePickerEntryMode.dialOnly,
              );
              if (picked == null) return;
              await saveDefaultReminderTime(_settings, picked);
              setState(() {});
            },
          ),

          const _Header('Privacy and security'),
          SwitchListTile(
            key: const Key('app_lock'),
            secondary: const Icon(Icons.fingerprint),
            title: const Text('App lock'),
            subtitle: const Text(
              'Asks for your fingerprint, face or screen lock when you open Mindtiq. '
              'This restricts access; it does not encrypt your files.',
            ),
            value: lock.enabled,
            onChanged: (v) async {
              final error = await ref
                  .read(appLockProvider.notifier)
                  .setEnabled(enabled: v);
              if (!context.mounted) return;
              context.showSnack(
                error ?? (v ? 'App lock is on' : 'App lock is off'),
                error: error != null,
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: const Text('Hide in recent apps'),
            subtitle: const Text(
              'Blanks Mindtiq in the app switcher and blocks screenshots of the app.',
            ),
            value: s.getBool(SettingsKeys.secureWindow),
            onChanged: (v) async {
              await _setBool(SettingsKeys.secureWindow, v);
              await ref.read(platformServiceProvider).setSecure(secure: v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.blur_on),
            title: const Text('Blur sensitive previews'),
            subtitle: const Text(
              'Screenshots that look like passwords, banking or IDs are blurred in lists.',
            ),
            value: s.getBool(
              SettingsKeys.hideSensitivePreviews,
              fallback: true,
            ),
            onChanged: (v) => _setBool(SettingsKeys.hideSensitivePreviews, v),
          ),

          const _Header('Storage'),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(
              usage == null
                  ? 'Calculating…'
                  : 'Using ${Formatters.fileSize(usage.totalBytes)}',
            ),
            subtitle: usage == null
                ? null
                : Text(
                    '${usage.imageCount} images ${Formatters.fileSize(usage.imageBytes)} · '
                    'thumbnails ${Formatters.fileSize(usage.thumbnailBytes)} · '
                    'database ${Formatters.fileSize(usage.databaseBytes)}',
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.compare_outlined),
            title: const Text('Review similar screenshots'),
            onTap: () => context.push(Routes.duplicates),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Clear search history'),
            onTap: () async {
              await ref
                  .read(dataManagementServiceProvider)
                  .clearSearchHistory();
              if (context.mounted) context.showSnack('Search history cleared');
            },
          ),

          const _Header('Backup and export'),
          const _Note(
            'Exports can contain sensitive information from your screenshots. '
            'Store them somewhere safe. Nothing is uploaded unless you choose a cloud location.',
          ),
          ListTile(
            key: const Key('export_zip'),
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Full backup (ZIP)'),
            subtitle: const Text(
              'Images, text, collections, tags, notes, reminders and wishlist',
            ),
            onTap: () => exportData(context, ref, ExportKind.zip),
          ),
          ListTile(
            leading: const Icon(Icons.data_object),
            title: const Text('Export metadata (JSON)'),
            subtitle: const Text('Everything except the images'),
            onTap: () => exportData(context, ref, ExportKind.json),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: const Text('Export detected details (CSV)'),
            subtitle: const Text(
              'Dates, amounts, links and more, for spreadsheets',
            ),
            onTap: () => exportData(context, ref, ExportKind.csv),
          ),
          ListTile(
            key: const Key('restore_backup'),
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text('Restore from backup'),
            subtitle: const Text(
              'Adds screenshots from a Mindtiq ZIP. Nothing is overwritten.',
            ),
            onTap: () => restoreBackup(context, ref),
          ),

          const _Header('Delete data'),
          ListTile(
            key: const Key('delete_all'),
            leading: Icon(
              Icons.delete_forever_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Delete all Mindtiq data',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text(
              'Removes Mindtiq\'s copies and everything it extracted. Gallery originals are not affected.',
            ),
            onTap: () async {
              await deleteAllData(context, ref);
              if (mounted) setState(() {});
            },
          ),

          const _Header('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Mindtiq'),
            subtitle: const Text('Version ${AppInfo.version}'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppInfo.name,
              applicationVersion: '${AppInfo.version} (${AppInfo.build})',
              applicationIcon: const AppLogo(size: 48),
              children: const [
                Text(
                  'Turns screenshots into searchable, actionable information. '
                  'Everything runs on this device; no account and no internet connection are needed.',
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            onTap: () => context.push(Routes.privacyPolicy),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Open-source licences'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: AppInfo.name,
              applicationVersion: AppInfo.version,
              applicationIcon: const Padding(
                padding: EdgeInsets.all(Spacing.sm),
                child: AppLogo(size: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.md,
      Spacing.lg,
      Spacing.md,
      Spacing.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: context.statusColors.onAccent),
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.md,
      Spacing.xxs,
      Spacing.md,
      Spacing.xs,
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

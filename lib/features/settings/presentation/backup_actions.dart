import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../backup/application/backup_codec.dart';
import '../../backup/application/backup_service.dart';

/// Shows a blocking progress dialog while [task] runs.
Future<T> runWithProgress<T>(
  BuildContext context,
  String label,
  Future<T> Function() task,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const Gap(Spacing.md),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await task();
  } finally {
    navigator.pop();
  }
}

Future<void> exportData(
  BuildContext context,
  WidgetRef ref,
  ExportKind kind,
) async {
  final ok = await showConfirmationDialog(
    context,
    title: switch (kind) {
      ExportKind.zip => 'Create a full backup?',
      ExportKind.json => 'Export metadata?',
      ExportKind.csv => 'Export detected details?',
    },
    message:
        'The file can contain sensitive information from your screenshots, such as '
        'amounts, addresses, codes or account details${kind == ExportKind.zip ? ', and the images themselves' : ''}. '
        'Only save or share it somewhere you trust.',
    confirmLabel: 'Export',
  );
  if (!ok || !context.mounted) return;

  final ExportResult result;
  try {
    result = await runWithProgress(
      context,
      kind == ExportKind.zip ? 'Creating backup…' : 'Exporting…',
      () => ref.read(backupServiceProvider).export(kind),
    );
  } on Object catch (e) {
    if (context.mounted) context.showSnack('Export failed: $e', error: true);
    return;
  }
  if (!context.mounted) return;

  final size = Formatters.fileSize(await result.file.length());
  if (!context.mounted) return;
  final choice = await showAppBottomSheet<String>(
    context,
    title: 'Export ready',
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${result.name} · $size · ${result.screenshots} screenshots'),
        const Gap(Spacing.md),
        ListTile(
          key: const Key('export_save'),
          leading: const Icon(Icons.save_alt),
          title: const Text('Save to device'),
          subtitle: const Text('Choose a folder, for example Downloads'),
          onTap: () => Navigator.of(context).pop('save'),
        ),
        ListTile(
          leading: const Icon(Icons.share_outlined),
          title: const Text('Share'),
          subtitle: const Text('Send to another app'),
          onTap: () => Navigator.of(context).pop('share'),
        ),
      ],
    ),
  );
  if (!context.mounted) return;
  switch (choice) {
    case 'save':
      try {
        final saved = await ref
            .read(platformServiceProvider)
            .saveDocument(
              path: result.file.path,
              name: result.name,
              mime: result.mime,
            );
        if (saved && context.mounted) context.showSnack('Saved ${result.name}');
      } on PlatformException catch (e) {
        if (context.mounted) {
          context.showSnack(
            'Could not save the file: ${e.message}',
            error: true,
          );
        }
      }
    case 'share':
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(result.file.path, mimeType: result.mime, name: result.name),
          ],
        ),
      );
  }
}

Future<void> restoreBackup(BuildContext context, WidgetRef ref) async {
  final platform = ref.read(platformServiceProvider);
  final backup = ref.read(backupServiceProvider);
  final picked = await platform.openBackupDocument();
  if (picked == null || !context.mounted) return;
  final path = picked.path;
  if (picked.error != null || path == null) {
    context.showSnack(switch (picked.error) {
      'too_large' => 'That file is too large to be a Snaptiq backup.',
      'no_space' => 'Not enough free space to read the backup.',
      _ => 'Could not read that file.',
    }, error: true);
    return;
  }

  final BackupPreview preview;
  try {
    preview = await runWithProgress(
      context,
      'Checking backup…',
      () => backup.inspect(path),
    );
  } on BackupException catch (e) {
    if (context.mounted) context.showSnack(e.message, error: true);
    return;
  } on Object {
    if (context.mounted) {
      context.showSnack('This is not a valid Snaptiq backup.', error: true);
    }
    return;
  }
  if (!context.mounted) return;

  final missing = preview.missingImages > 0
      ? '\n\n${_n(preview.missingImages, 'image')} missing from the file.'
      : '';
  final ok = await showConfirmationDialog(
    context,
    title: 'Restore this backup?',
    message:
        'It contains ${_n(preview.screenshots, 'screenshot')}, '
        '${_n(preview.collections, 'collection')}, ${_n(preview.tags, 'tag')}, '
        '${_n(preview.reminders, 'reminder')} and '
        '${_n(preview.wishlistItems, 'wishlist item')}.'
        '$missing\n\nThey are added to your library. Screenshots you already have are skipped, '
        'and nothing you have now is changed.',
    confirmLabel: 'Restore',
  );
  if (!ok || !context.mounted) return;

  final RestoreReport report;
  try {
    report = await runWithProgress(
      context,
      'Restoring…',
      () => backup.restore(path),
    );
  } on BackupException catch (e) {
    if (context.mounted) context.showSnack(e.message, error: true);
    return;
  } on Object catch (e) {
    if (context.mounted) context.showSnack('Restore failed: $e', error: true);
    return;
  }
  await ref.read(reminderServiceProvider).resyncAll();
  ref.read(jobRunnerProvider).kick();
  ref.invalidate(storageUsageProvider);
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Restore complete'),
      content: Text(
        [
          '${_n(report.restored, 'screenshot')} restored.',
          if (report.duplicates > 0)
            '${report.duplicates} ${report.duplicates == 1 ? 'was' : 'were'} '
                'already in your library and skipped.',
          if (report.corrupted > 0)
            '${report.corrupted} ${report.corrupted == 1 ? 'was' : 'were'} '
                'damaged in the file and skipped.',
          if (report.reminders > 0)
            '${_n(report.reminders, 'reminder')} restored.',
        ].join('\n'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> deleteAllData(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => const _DeleteAllDialog(),
  );
  if (ok != true || !context.mounted) return;
  try {
    await runWithProgress(
      context,
      'Deleting…',
      () => ref.read(dataManagementServiceProvider).deleteAll(),
    );
  } on Object catch (e) {
    if (context.mounted) {
      context.showSnack('Could not delete everything: $e', error: true);
    }
    return;
  }
  ref.invalidate(storageUsageProvider);
  if (context.mounted) context.showSnack('All Snaptiq data was deleted');
}

/// Requires typing DELETE so the action can't be confirmed by accident.
class _DeleteAllDialog extends StatefulWidget {
  const _DeleteAllDialog();

  @override
  State<_DeleteAllDialog> createState() => _DeleteAllDialogState();
}

class _DeleteAllDialogState extends State<_DeleteAllDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final armed = _controller.text.trim().toUpperCase() == 'DELETE';
    return AlertDialog(
      title: const Text('Delete all Snaptiq data?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently removes Snaptiq\'s copies of your screenshots and the text, '
              'details, collections, tags, notes, reminders and wishlist. It cannot be undone.\n\n'
              'The original screenshots in your gallery are not touched.\n\n'
              'Make a full backup first if you may want this later.',
            ),
            const Gap(Spacing.md),
            TextField(
              key: const Key('delete_confirm_field'),
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Type DELETE to confirm',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('delete_confirm'),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: armed ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Delete everything'),
        ),
      ],
    );
  }
}

/// "1 reminder", "3 reminders".
String _n(int count, String noun) => '$count $noun${count == 1 ? '' : 's'}';

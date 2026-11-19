import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/screenshot_detail.dart';
import '../../../core/services/settings_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/category_icons.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../../actions/presentation/action_center_screen.dart';
import '../../collections/presentation/collection_dialogs.dart';
import '../../library/presentation/category_picker.dart';
import '../../reminders/presentation/reminder_editor.dart';
import '../application/inbox_navigation.dart';
import 'entity_list.dart';
import 'image_viewer_page.dart';
import 'text_editor_page.dart';

class _RemindersSection extends ConsumerWidget {
  const _RemindersSection({required this.detail});

  final ScreenshotDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = [
      for (final r in detail.reminders)
        if (r.status == ReminderStatus.scheduled) r,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Reminders',
          actionLabel: 'Add',
          onAction: () => showReminderEditor(
            context,
            prefill: ReminderPrefill(
              title: detail.screenshot.title,
              screenshotId: detail.screenshot.id,
            ),
          ),
        ),
        if (active.isEmpty)
          Text(
            'No reminders for this screenshot.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          for (final r in active)
            ReminderCard(
              title: r.title,
              dueAt: r.scheduledAt,
              completed: false,
              overdue: r.scheduledAt.isBefore(DateTime.now()),
              onToggleComplete: () =>
                  ref.read(reminderServiceProvider).complete(r.id),
              onTap: () => showReminderEditor(context, existing: r),
            ),
      ],
    );
  }
}

class ScreenshotDetailsScreen extends ConsumerWidget {
  const ScreenshotDetailsScreen({required this.screenshotId, super.key});

  final int screenshotId;

  /// Route for opening a screenshot from the inbox. The details screen then
  /// offers "Reviewed & next".
  static String inboxRoute(int id) => '${Routes.screenshot(id)}?from=inbox';

  static bool _openedFromInbox(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.queryParameters['from'] == 'inbox';
    } on GoError {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromInbox = _openedFromInbox(context);
    final async = ref.watch(screenshotDetailProvider(screenshotId));
    return async.when(
      skipLoadingOnReload: true,
      loading: () =>
          Scaffold(appBar: AppBar(), body: const SkeletonList(itemCount: 4)),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: 'This screenshot could not be loaded.',
          onRetry: () => ref.invalidate(screenshotDetailProvider(screenshotId)),
        ),
      ),
      data: (detail) => detail == null
          ? Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                icon: Icons.image_not_supported_outlined,
                title: 'Screenshot not found',
                message: 'It may have been deleted.',
              ),
            )
          : _DetailsView(detail: detail, fromInbox: fromInbox),
    );
  }
}

class _DetailsView extends ConsumerStatefulWidget {
  const _DetailsView({required this.detail, required this.fromInbox});

  final ScreenshotDetail detail;
  final bool fromInbox;

  @override
  ConsumerState<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends ConsumerState<_DetailsView> {
  /// Whether the stored image exists; checked once per file path rather
  /// than on every rebuild.
  late bool _storageOk = _checkStorage();
  bool _advancing = false;

  ScreenshotDetail get detail => widget.detail;

  ScreenshotRow get s => detail.screenshot;

  bool _checkStorage() =>
      File(widget.detail.screenshot.localFilePath).existsSync();

  @override
  void didUpdateWidget(covariant _DetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.screenshot.localFilePath != s.localFilePath) {
      _storageOk = _checkStorage();
    }
  }

  Future<void> _reviewedAndNext() async {
    if (_advancing) return;
    setState(() => _advancing = true);
    final router = GoRouter.of(context);
    try {
      await ref.read(screenshotRepositoryProvider).setReviewed([
        s.id,
      ], value: true);
      final next = await nextInboxScreenshot(ref.read(appDatabaseProvider), s);
      if (!mounted) return;
      if (next == null) {
        context.showSnack('Inbox cleared');
        if (router.canPop()) router.pop();
      } else {
        unawaited(
          router.pushReplacement(ScreenshotDetailsScreen.inboxRoute(next)),
        );
      }
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  Future<void> _editTitle(BuildContext context, WidgetRef ref) async {
    final value = await showTextInputDialog(
      context,
      title: 'Edit title',
      initialValue: s.title,
      maxLength: 120,
    );
    if (value == null) return;
    await ref.read(screenshotRepositoryProvider).setTitle(s.id, value);
    await ref.read(searchIndexerProvider).reindex(s.id);
  }

  Future<void> _editText(BuildContext context, WidgetRef ref) async {
    final value = await showTextEditorPage(
      context,
      initialText: detail.text,
      title: 'Edit recognized text',
      note:
          'Saving updates the detected details and suggestions. Details you '
          'confirmed or removed are detected again from the new text.',
    );
    if (value == null || value == detail.text) return;
    await ref.read(jobRunnerProvider).updateText(s.id, value);
    if (context.mounted) context.showSnack('Text saved. Suggestions updated.');
  }

  Future<void> _changeCategory(BuildContext context, WidgetRef ref) async {
    final id = await showCategoryPicker(
      context,
      selectedId: detail.category?.id,
      suggestedId: s.suggestedCategoryId,
    );
    if (id == null) return;
    await ref.read(screenshotRepositoryProvider).setCategory([s.id], id);
    await ref.read(searchIndexerProvider).reindex(s.id);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmationDialog(
      context,
      title: 'Delete screenshot?',
      message:
          'This removes the copy stored in SnapAction with its text, notes and '
          'suggestions. The image in your gallery is not affected.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final router = GoRouter.of(context);
    await ref.read(libraryServiceProvider).delete([s.id]);
    if (router.canPop()) router.pop();
    if (context.mounted) context.showSnack('Screenshot deleted');
  }

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(s.localFilePath)],
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> _copyText(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: detail.text));
    if (context.mounted) context.showSnack('Text copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ref.read(screenshotRepositoryProvider);
    final hideSensitive = ref
        .watch(settingsRepositoryProvider)
        .getBool(SettingsKeys.hideSensitivePreviews, fallback: true);
    final storageOk = _storageOk;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detail.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: s.isFavorite ? 'Remove favourite' : 'Add favourite',
            icon: Icon(
              s.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: s.isFavorite ? context.statusColors.favorite : null,
            ),
            onPressed: () => repo.setFavorite([s.id], value: !s.isFavorite),
          ),
          IconButton(
            tooltip: 'Share image',
            icon: const Icon(Icons.share_outlined),
            onPressed: storageOk ? () => _share(context) : null,
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) => switch (v) {
              'title' => _editTitle(context, ref),
              'copy' => _copyText(context),
              'reviewed' => repo.setReviewed([s.id], value: !s.isReviewed),
              'archive' => repo.setArchived([s.id], value: !s.isArchived),
              'retry' => ref.read(jobRunnerProvider).retry([s.id]),
              'delete' => _delete(context, ref),
              _ => Future<void>.value(),
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'title', child: Text('Edit title')),
              if (detail.hasText)
                const PopupMenuItem(value: 'copy', child: Text('Copy text')),
              PopupMenuItem(
                value: 'reviewed',
                child: Text(
                  s.isReviewed ? 'Mark as not reviewed' : 'Mark reviewed',
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Text(s.isArchived ? 'Unarchive' : 'Archive'),
              ),
              const PopupMenuItem(value: 'retry', child: Text('Process again')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: s.isReviewed || s.isArchived
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.xs,
                  Spacing.md,
                  Spacing.sm,
                ),
                child: widget.fromInbox
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              key: const Key('mark_reviewed'),
                              onPressed: () =>
                                  repo.setReviewed([s.id], value: true),
                              child: const Text('Mark reviewed'),
                            ),
                          ),
                          const Gap(Spacing.xs),
                          Expanded(
                            child: FilledButton.icon(
                              key: const Key('reviewed_next'),
                              onPressed: _advancing ? null : _reviewedAndNext,
                              icon: const Icon(Icons.skip_next),
                              label: const Text('Reviewed & next'),
                            ),
                          ),
                        ],
                      )
                    : PrimaryButton(
                        key: const Key('mark_reviewed'),
                        label: 'Mark reviewed',
                        icon: Icons.done,
                        expand: true,
                        onPressed: () => repo.setReviewed([s.id], value: true),
                      ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          0,
          Spacing.md,
          Spacing.xl,
        ),
        children: [
          _Preview(
            path: s.localFilePath,
            title: detail.displayTitle,
            blur: hideSensitive && s.isSensitive,
            aspect:
                s.imageWidth != null &&
                    s.imageHeight != null &&
                    s.imageHeight! > 0
                ? s.imageWidth! / s.imageHeight!
                : 9 / 16,
          ),
          const Gap(Spacing.md),
          InkWell(
            onTap: () => _editTitle(context, ref),
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    detail.displayTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const Icon(Icons.edit_outlined, size: 20),
              ],
            ),
          ),
          const Gap(Spacing.xs),
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ProcessingStatusBadge(
                status: s.processingStatus,
                isReviewed: s.isReviewed,
                isArchived: s.isArchived,
              ),
              if (s.isSensitive)
                const Chip(
                  avatar: Icon(Icons.shield_outlined, size: 16),
                  label: Text('Sensitive'),
                  visualDensity: VisualDensity.compact,
                ),
              Text(
                'Imported ${Formatters.dateTime(s.importedAt)}',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const Gap(Spacing.md),
          _CategoryTile(
            detail: detail,
            onChange: () => _changeCategory(context, ref),
            onConfirm: () async {
              final id = detail.effectiveCategory?.id;
              if (id != null) await repo.setCategory([s.id], id);
            },
          ),
          _StatusSection(detail: detail),
          SuggestedActionsSection(actions: detail.actions),
          _RemindersSection(detail: detail),
          if (EntityList.visible(detail.entities).isNotEmpty) ...[
            const SectionHeader(title: 'Detected details'),
            EntityList(entities: detail.entities, actions: detail.actions),
          ],
          SectionHeader(
            title: 'Text',
            actionLabel: s.processingStatus == ProcessingStatus.completed
                ? 'Edit'
                : null,
            onAction: () => _editText(context, ref),
          ),
          _TextSection(detail: detail, onCopy: () => _copyText(context)),
          _OrganizeSection(detail: detail),
          const SectionHeader(title: 'File'),
          _FileInfo(row: s, available: storageOk),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.path,
    required this.title,
    required this.blur,
    required this.aspect,
  });

  final String path;
  final String title;
  final bool blur;
  final double aspect;

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * 0.45).clamp(
      200.0,
      480.0,
    );
    return Semantics(
      button: true,
      label: 'Open full screen',
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => ImageViewerPage(path: path, title: title),
          ),
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: AspectRatio(
              aspectRatio: aspect,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ScreenshotThumbnail(
                    path: path,
                    fit: BoxFit.contain,
                    blur: blur,
                  ),
                  if (blur)
                    const Center(
                      child: Chip(
                        avatar: Icon(Icons.visibility_outlined, size: 16),
                        label: Text('Tap to view'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.detail,
    required this.onChange,
    required this.onConfirm,
  });

  final ScreenshotDetail detail;
  final VoidCallback onChange;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = detail.effectiveCategory;
    final s = detail.screenshot;
    final color = c == null
        ? theme.colorScheme.onSurfaceVariant
        : Color(c.color);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  c == null
                      ? Icons.category_outlined
                      : CategoryIcons.of(c.icon),
                  color: color,
                ),
                const Gap(Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category', style: theme.textTheme.labelSmall),
                      Text(
                        c?.name ?? 'Not classified yet',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onChange, child: const Text('Change')),
              ],
            ),
            if (s.needsCategoryConfirmation &&
                !s.categoryLocked &&
                c != null) ...[
              const Gap(Spacing.xs),
              Text(
                'SnapAction was not sure about this category. Is it right?',
                style: theme.textTheme.bodySmall,
              ),
              const Gap(Spacing.xs),
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: onConfirm,
                    child: const Text('Yes, keep it'),
                  ),
                  const Gap(Spacing.xs),
                  OutlinedButton(
                    onPressed: onChange,
                    child: const Text('Choose another'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusSection extends ConsumerStatefulWidget {
  const _StatusSection({required this.detail});

  final ScreenshotDetail detail;

  @override
  ConsumerState<_StatusSection> createState() => _StatusSectionState();
}

class _StatusSectionState extends ConsumerState<_StatusSection> {
  /// The failure message, loaded once per failure rather than per build.
  Future<String?>? _error;
  (int, DateTime)? _errorFor;

  Future<String?>? _lastError(ScreenshotRow s) {
    if (s.processingStatus != ProcessingStatus.failed) {
      _error = null;
      _errorFor = null;
      return null;
    }
    final key = (s.id, s.updatedAt);
    if (_error == null || _errorFor != key) {
      _errorFor = key;
      _error = ref.read(jobRunnerProvider).lastError(s.id);
    }
    return _error;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.detail.screenshot;
    final theme = Theme.of(context);
    switch (s.processingStatus) {
      case ProcessingStatus.pending:
      case ProcessingStatus.processing:
        return Padding(
          padding: const EdgeInsets.only(top: Spacing.md),
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const Gap(Spacing.sm),
              Expanded(
                child: Text(
                  s.processingStatus == ProcessingStatus.pending
                      ? 'Waiting to read the text on this device…'
                      : 'Reading text and looking for useful details…',
                ),
              ),
            ],
          ),
        );
      case ProcessingStatus.failed:
        return FutureBuilder<String?>(
          future: _lastError(s),
          builder: (context, snap) => Card(
            key: const Key('processing_failed'),
            margin: const EdgeInsets.only(top: Spacing.md),
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const Gap(Spacing.sm),
                  Expanded(
                    child: Text(
                      snap.data ?? 'Processing failed.',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    key: const Key('retry_processing'),
                    onPressed: () => ref.read(jobRunnerProvider).retry([s.id]),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      case ProcessingStatus.completed:
        return const SizedBox.shrink();
    }
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.detail, required this.onCopy});

  final ScreenshotDetail detail;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = detail.screenshot;
    if (!detail.hasText) {
      return Text(
        s.processingStatus == ProcessingStatus.completed
            ? 'No text was found in this image. You can add it with Edit.'
            : 'Text appears here once processing finishes.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final edited = detail.ocr?.correctedText != null;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(detail.text, style: theme.textTheme.bodyMedium),
            const Gap(Spacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    edited ? 'Edited by you' : 'Recognized on this device',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizeSection extends ConsumerWidget {
  const _OrganizeSection({required this.detail});

  final ScreenshotDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(organizationRepositoryProvider);
    final id = detail.screenshot.id;
    final note = detail.note?.content;

    Future<void> addTag() async {
      final tag = await showTagInput(context);
      if (tag == null) return;
      try {
        await repo.addTag(id, tag);
      } on ArgumentError catch (e) {
        if (context.mounted) context.showSnack('${e.message}', error: true);
      }
    }

    Future<void> addToCollection() async {
      final collectionId = await showCollectionPicker(context, ref);
      if (collectionId != null) await repo.addToCollection(collectionId, [id]);
    }

    Future<void> editNote() async {
      final value = await showTextInputDialog(
        context,
        title: note == null ? 'Add note' : 'Edit note',
        initialValue: note,
        maxLines: 6,
        maxLength: 2000,
      );
      if (value != null) await repo.setNote(id, value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Organize'),
        Text('Tags', style: theme.textTheme.labelLarge),
        const Gap(Spacing.xxs),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            for (final t in detail.tags)
              InputChip(
                label: Text('#${t.name}'),
                onPressed: () => context.push(
                  '/tags/${t.id}?name=${Uri.encodeQueryComponent(t.name)}',
                ),
                onDeleted: () => repo.removeTag(id, t.id),
                deleteButtonTooltipMessage: 'Remove tag ${t.name}',
              ),
            ActionChip(
              key: const Key('add_tag'),
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Add tag'),
              onPressed: addTag,
            ),
          ],
        ),
        const Gap(Spacing.sm),
        Text('Collections', style: theme.textTheme.labelLarge),
        const Gap(Spacing.xxs),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            for (final c in detail.collections)
              InputChip(
                avatar: Icon(
                  CategoryIcons.of(c.icon),
                  size: 18,
                  color: Color(c.color),
                ),
                label: Text(c.name),
                onPressed: () => context.push(Routes.collection(c.id)),
                onDeleted: () => repo.removeFromCollection(c.id, [id]),
                deleteButtonTooltipMessage: 'Remove from ${c.name}',
              ),
            ActionChip(
              key: const Key('add_to_collection'),
              avatar: const Icon(Icons.create_new_folder_outlined, size: 18),
              label: const Text('Add to collection'),
              onPressed: addToCollection,
            ),
          ],
        ),
        const Gap(Spacing.sm),
        Row(
          children: [
            Expanded(child: Text('Note', style: theme.textTheme.labelLarge)),
            TextButton(
              onPressed: editNote,
              child: Text(note == null ? 'Add' : 'Edit'),
            ),
          ],
        ),
        if (note != null)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: SelectableText(note),
            ),
          ),
      ],
    );
  }
}

class _FileInfo extends StatelessWidget {
  const _FileInfo({required this.row, required this.available});

  final ScreenshotRow row;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String line(String k, String v) => '$k: $v';
    return Text(
      [
        if (row.originalFilename != null) line('Name', row.originalFilename!),
        line('Size', Formatters.fileSize(row.fileSize)),
        if (row.imageWidth != null)
          line('Dimensions', '${row.imageWidth} × ${row.imageHeight}'),
        if (row.capturedAt != null)
          line('Captured', Formatters.dateTime(row.capturedAt!)),
        line('Source', switch (row.source) {
          ScreenshotSource.picker => 'Photo picker',
          ScreenshotSource.share => 'Shared from another app',
          ScreenshotSource.backup => 'Restored from backup',
        }),
        if (!available) 'The stored image file is missing.',
      ].join('\n'),
      style: theme.textTheme.bodySmall,
    );
  }
}

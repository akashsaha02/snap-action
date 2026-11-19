import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/repositories/organization_repository.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'collection_dialogs.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  /// Long-press menu for a single tag chip.
  Future<void> _tagMenu(BuildContext context, WidgetRef ref, TagCount t) async {
    final choice = await showAppBottomSheet<String>(
      context,
      title: '#${t.tag.name}',
      builder: (c) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Rename'),
            onTap: () => Navigator.of(c).pop('rename'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete tag'),
            subtitle: const Text('Screenshots are kept.'),
            onTap: () => Navigator.of(c).pop('delete'),
          ),
        ],
      ),
    );
    if (!context.mounted || choice == null) return;
    await _runTagAction(context, ref, t, choice);
  }

  /// Visible alternative to long-pressing: every tag with rename and delete
  /// buttons.
  Future<void> _manageTags(
    BuildContext context,
    WidgetRef ref,
    List<TagCount> tags,
  ) async {
    final picked = await showAppBottomSheet<(String, TagCount)>(
      context,
      title: 'Manage tags',
      builder: (c) => ListView(
        shrinkWrap: true,
        children: [
          for (final t in tags)
            ListTile(
              key: ValueKey('manage_tag_${t.tag.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                '#${t.tag.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(_screenshotCount(t.count)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Rename #${t.tag.name}',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.of(c).pop(('rename', t)),
                  ),
                  IconButton(
                    tooltip: 'Delete #${t.tag.name}',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => Navigator.of(c).pop(('delete', t)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    if (!context.mounted || picked == null) return;
    await _runTagAction(context, ref, picked.$2, picked.$1);
  }

  static String _screenshotCount(int n) =>
      n == 1 ? '1 screenshot' : '$n screenshots';

  Future<void> _runTagAction(
    BuildContext context,
    WidgetRef ref,
    TagCount t,
    String action,
  ) async {
    final repo = ref.read(organizationRepositoryProvider);
    if (action == 'rename') {
      final name = await showTextInputDialog(
        context,
        title: 'Rename tag',
        initialValue: t.tag.name,
        maxLength: 40,
      );
      if (name == null) return;
      try {
        await repo.renameTag(t.tag.id, name);
      } on ArgumentError catch (e) {
        if (context.mounted) context.showSnack('${e.message}', error: true);
      }
    } else if (action == 'delete') {
      final ok = await showConfirmationDialog(
        context,
        title: 'Delete #${t.tag.name}?',
        message:
            'The tag is removed from ${_screenshotCount(t.count)}. '
            'The screenshots themselves are kept.',
        confirmLabel: 'Delete tag',
        destructive: true,
      );
      if (!ok) return;
      await repo.deleteTag(t.tag.id);
      if (context.mounted) context.showSnack('Tag #${t.tag.name} deleted');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoryCountsProvider);
    final collections =
        ref.watch(collectionsProvider).value ?? const <CollectionSummary>[];
    final tags = ref.watch(tagsProvider).value ?? const <TagCount>[];
    final stats = ref.watch(libraryStatsProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCollections)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new_collection',
        onPressed: () => unawaited(showCollectionEditor(context, ref)),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New collection'),
      ),
      body: categories.when(
        skipLoadingOnReload: true,
        loading: () => const SkeletonList(),
        error: (_, _) => ErrorState(
          message: 'Collections could not be loaded.',
          onRetry: () => ref.invalidate(categoryCountsProvider),
        ),
        data: (cats) {
          final nonEmpty = cats.where((c) => c.count > 0).toList();
          if ((stats?.total ?? 0) == 0 && collections.isEmpty) {
            return EmptyState(
              art: BrandArt.emptyLibrary,
              icon: Icons.grid_view_rounded,
              title: l10n.emptyCollectionsTitle,
              message: l10n.emptyCollectionsBody,
              action: OutlinedButton.icon(
                onPressed: () => context.push(Routes.wishlist),
                icon: const Icon(Icons.favorite_border),
                label: const Text('Wishlist'),
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.star_outline, size: 18),
                        label: Text('Favourites · ${stats?.favorites ?? 0}'),
                        onPressed: () =>
                            context.push('${Routes.inbox}?filter=favorites'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.archive_outlined, size: 18),
                        label: Text('Archive · ${stats?.archived ?? 0}'),
                        onPressed: () =>
                            context.push('${Routes.inbox}?filter=archived'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.favorite_border, size: 18),
                        label: const Text('Wishlist'),
                        onPressed: () => context.push(Routes.wishlist),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.compare_outlined, size: 18),
                        label: const Text('Similar'),
                        onPressed: () => context.push(Routes.duplicates),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(title: 'My collections'),
                ),
              ),
              if (collections.isEmpty)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Group screenshots your way, for example "Thesis" or "Trip to Lisbon".',
                    ),
                  ),
                )
              else
                _grid([
                  for (final c in collections)
                    CategoryCard(
                      key: ValueKey('collection_${c.collection.id}'),
                      name: c.collection.name,
                      icon: c.collection.icon,
                      color: c.collection.color,
                      count: c.count,
                      previewPaths: c.previewPaths,
                      onTap: () =>
                          context.push(Routes.collection(c.collection.id)),
                    ),
                ]),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(title: 'Smart collections'),
                ),
              ),
              if (nonEmpty.isEmpty)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Screenshots are sorted here automatically once processed.',
                    ),
                  ),
                )
              else
                _grid([
                  for (final c in nonEmpty)
                    CategoryCard(
                      key: ValueKey('category_${c.category.slug}'),
                      name: c.category.name,
                      icon: c.category.icon,
                      color: c.category.color,
                      count: c.count,
                      previewPaths: c.previewPaths,
                      onTap: () => context.push(
                        '${Routes.category(c.category.id)}?name=${Uri.encodeQueryComponent(c.category.name)}',
                      ),
                    ),
                ]),
              if (tags.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  sliver: SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Tags',
                      actionLabel: 'Manage',
                      onAction: () => _manageTags(context, ref, tags),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: Spacing.xs,
                      runSpacing: Spacing.xs,
                      children: [
                        for (final t in tags)
                          Semantics(
                            onLongPressHint: 'Rename or delete',
                            child: GestureDetector(
                              key: ValueKey('tag_chip_${t.tag.id}'),
                              onLongPress: () => _tagMenu(context, ref, t),
                              child: ActionChip(
                                label: Text(
                                  '#${t.tag.name} · ${t.count}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onPressed: () => context.push(
                                  '/tags/${t.tag.id}?name=${Uri.encodeQueryComponent(t.tag.name)}',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: Gap(96)),
            ],
          );
        },
      ),
    );
  }

  Widget _grid(List<Widget> children) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: Spacing.sm,
        crossAxisSpacing: Spacing.sm,
        childAspectRatio: 1,
      ),
      delegate: SliverChildListDelegate(children),
    ),
  );
}

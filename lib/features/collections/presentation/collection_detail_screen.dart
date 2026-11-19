import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/repositories/screenshot_repository.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/states.dart';
import '../../library/presentation/library_screen.dart';
import 'collection_dialogs.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({required this.collectionId, super.key});

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(collectionProvider(collectionId));
    return collection.when(
      skipLoadingOnReload: true,
      loading: () => Scaffold(appBar: AppBar(), body: const SkeletonList()),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: const ErrorState(message: 'This collection could not be loaded.'),
      ),
      data: (c) {
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              art: BrandArt.error,
              icon: Icons.folder_off_outlined,
              title: 'Collection not found',
              message: 'It may have been deleted.',
            ),
          );
        }
        return LibraryScreen(
          key: ValueKey('collection_$collectionId'),
          initialFilter: ScreenshotFilter.all,
          collectionId: collectionId,
          title: c.name,
          showFilters: false,
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Collection options',
              onSelected: (v) async {
                if (v == 'edit') {
                  await showCollectionEditor(context, ref, existing: c);
                } else if (v == 'delete') {
                  final ok = await showConfirmationDialog(
                    context,
                    title: 'Delete "${c.name}"?',
                    message: 'The collection is removed. Its screenshots stay in your library.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );
                  if (!ok || !context.mounted) return;
                  final router = GoRouter.of(context);
                  await ref
                      .read(organizationRepositoryProvider)
                      .deleteCollection(c.id);
                  if (router.canPop()) router.pop();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit collection')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete collection'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

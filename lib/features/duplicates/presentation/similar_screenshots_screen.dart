import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/models/screenshot_summary.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../../../services/duplicate_detection/perceptual_hash.dart';

const _ignoredKey = 'similar_ignored_groups';

/// Groups of visually similar screenshots. Nothing is removed automatically.
final similarGroupsProvider =
    FutureProvider.autoDispose<List<List<ScreenshotSummary>>>((ref) async {
      final repo = ref.watch(screenshotRepositoryProvider);
      final settings = ref.watch(settingsRepositoryProvider);
      final ignored = {
        for (final s in (jsonDecode(
          settings.getString(_ignoredKey) ?? '[]',
        ) as List<Object?>))
          s.toString(),
      };
      final hashes = await repo.perceptualHashes();
      final texts = await repo.recognizedTexts();
      final groups = await Isolate.run(
        () => PerceptualHash.group(hashes, texts: texts),
      );
      final result = <List<ScreenshotSummary>>[];
      for (final g in groups) {
        if (ignored.contains(_signature(g))) continue;
        result.add(await repo.summariesByIds(g));
      }
      return [
        for (final g in result)
          if (g.length > 1) g,
      ];
    });

String _signature(Iterable<int> ids) => (ids.toList()..sort()).join('-');

class SimilarScreenshotsScreen extends ConsumerWidget {
  const SimilarScreenshotsScreen({super.key});

  Future<void> _keepAll(WidgetRef ref, List<ScreenshotSummary> group) async {
    final settings = ref.read(settingsRepositoryProvider);
    final ignored =
        (jsonDecode(settings.getString(_ignoredKey) ?? '[]') as List<Object?>)
            .map((e) => e.toString())
            .toSet()
          ..add(_signature(group.map((s) => s.id)));
    await settings.setString(_ignoredKey, jsonEncode(ignored.toList()));
    ref.invalidate(similarGroupsProvider);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ScreenshotSummary s,
  ) async {
    final ok = await showConfirmationDialog(
      context,
      title: 'Delete this copy?',
      message:
          'Only the copy stored in Snaptiq is deleted. Images in your gallery '
          'are not affected.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    await ref.read(libraryServiceProvider).delete([s.id]);
    ref.invalidate(similarGroupsProvider);
    if (context.mounted) context.showSnack('Screenshot deleted');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(similarGroupsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Similar screenshots')),
      body: async.when(
        loading: () => const SkeletonList(itemCount: 3),
        error: (e, _) => ErrorState(
          message: 'Similar screenshots could not be compared.',
          details: e,
          onRetry: () => ref.invalidate(similarGroupsProvider),
        ),
        data: (groups) => groups.isEmpty
            ? const EmptyState(
                icon: Icons.compare_outlined,
                title: 'No similar screenshots',
                message:
                    'Exact duplicates are skipped during import. Screenshots that only '
                    'look alike are listed here for you to decide.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(Spacing.md),
                itemCount: groups.length,
                separatorBuilder: (_, _) => const Gap(Spacing.md),
                itemBuilder: (context, i) {
                  final group = groups[i];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${group.length} similar screenshots',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _keepAll(ref, group),
                                child: const Text('Keep all'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 230,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: group.length,
                              separatorBuilder: (_, _) => const Gap(Spacing.sm),
                              itemBuilder: (context, j) {
                                final s = group[j];
                                return SizedBox(
                                  width: 120,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            Spacing.radiusSm,
                                          ),
                                          onTap: () => context.push(
                                            Routes.screenshot(s.id),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Spacing.radiusSm,
                                            ),
                                            child: ScreenshotThumbnail(
                                              path:
                                                  s.thumbnailPath ??
                                                  s.localFilePath,
                                              isSensitive: s.isSensitive,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(Spacing.xxs),
                                      Text(
                                        s.displayTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                      Text(
                                        Formatters.relativeDay(s.importedAt),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        onPressed: () =>
                                            _delete(context, ref, s),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                        ),
                                        label: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

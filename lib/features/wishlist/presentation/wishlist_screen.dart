import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../../../services/entity_extraction/money_parser.dart';
import '../../actions/application/external_intents.dart';
import '../application/wishlist_repository.dart';
import 'wishlist_editor.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('wishlist_add'),
        onPressed: () => showWishlistEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: wishlist.when(
        loading: () => const SkeletonList(),
        error: (e, _) => ErrorState(
          message: 'Could not load your wishlist.',
          details: e,
          onRetry: () => ref.invalidate(wishlistProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'Your wishlist is empty',
              message: 'Products found in shopping screenshots can be added here, or add one yourself.',
            );
          }
          final totals = WishlistRepository.openTotals(items);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              96,
            ),
            children: [
              if (totals.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: Text(
                    'Still to buy: ${[for (final e in totals.entries) Formatters.money(e.value, e.key, decimals: MoneyParser.decimalsFor(e.key))].join(' + ')}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              for (final entry in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: _WishlistTile(entry: entry),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WishlistTile extends ConsumerWidget {
  const _WishlistTile({required this.entry});

  final WishlistEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final item = entry.item;
    final repo = ref.read(wishlistRepositoryProvider);
    final price = item.amountMinorUnits == null || item.currency == null
        ? null
        : Formatters.money(
            item.amountMinorUnits!,
            item.currency!,
            decimals: MoneyParser.decimalsFor(item.currency),
          );
    final link = ExternalIntents.web(item.productUrl);
    return Card(
      key: ValueKey('wish_${item.id}'),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => showWishlistEditor(context, existing: item),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xs),
          child: Row(
            children: [
              Checkbox(
                value: item.purchased,
                semanticLabel: item.purchased
                    ? 'Mark as not bought'
                    : 'Mark as bought',
                onChanged: (v) =>
                    repo.setPurchased(item.id, purchased: v ?? false),
              ),
              if (entry.thumbnailPath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  child: SizedBox(
                    width: 44,
                    height: 56,
                    child: ScreenshotThumbnail(
                      path: entry.thumbnailPath,
                      detectSensitive: true,
                    ),
                  ),
                ),
                const Gap(Spacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? 'Unnamed product',
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration: item.purchased
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (price != null || item.merchantName != null)
                      Text(
                        [?price, ?item.merchantName].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'More options',
                onSelected: (v) async {
                  switch (v) {
                    case 'link':
                      final ok = await showConfirmationDialog(
                        context,
                        title: 'Open link?',
                        message:
                            'Check the address before you open it:\n\n$link',
                        confirmLabel: 'Open',
                      );
                      if (ok &&
                          !await ExternalIntents.open(link!) &&
                          context.mounted) {
                        context.showSnack(
                          'No app on this device can open this.',
                          error: true,
                        );
                      }
                    case 'screenshot':
                      unawaited(
                        context.push(Routes.screenshot(item.screenshotId!)),
                      );
                    case 'delete':
                      final ok = await showConfirmationDialog(
                        context,
                        title: 'Remove from wishlist?',
                        message: item.productName ?? 'This item',
                        confirmLabel: 'Remove',
                        destructive: true,
                      );
                      if (ok) await repo.delete(item.id);
                  }
                },
                itemBuilder: (_) => [
                  if (link != null)
                    const PopupMenuItem(
                      value: 'link',
                      child: Text('Open link'),
                    ),
                  if (item.screenshotId != null)
                    const PopupMenuItem(
                      value: 'screenshot',
                      child: Text('Open screenshot'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Remove')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

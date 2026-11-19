import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/repositories/screenshot_repository.dart';
import '../../../core/services/settings_repository.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/screenshot_card.dart';
import '../../../core/widgets/states.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../screenshot_import/application/import_controller.dart';
import '../../search/presentation/search_screen.dart';
import '../application/upcoming.dart';
import 'home_widgets.dart';

const _recentQuery = ScreenshotQuery(limit: 10);

/// Space kept free below the last section so the import button never covers
/// content: FAB height plus its margin and a little breathing room.
const _fabClearance = 56 + Spacing.md + Spacing.lg;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// The import button collapses to an icon once the page scrolls.
  bool _fabExtended = true;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final extended = n.metrics.pixels <= Spacing.lg;
    if (extended != _fabExtended) setState(() => _fabExtended = extended);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stats = ref.watch(libraryStatsProvider).value;
    final importing = ref.watch(
      importControllerProvider.select((s) => s.running),
    );
    void import() => unawaited(
      ref.read(importControllerProvider.notifier).pickFromGallery(),
    );

    final isEmpty = stats != null && stats.total == 0 && stats.archived == 0;

    return Scaffold(
      floatingActionButton: isEmpty
          ? null
          : PopShadow.pill(
              child: FloatingActionButton.extended(
                key: const Key('home_import'),
                heroTag: 'home_import',
                tooltip: l10n.importScreenshots,
                isExtended: _fabExtended,
                onPressed: importing ? null : import,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.importScreenshots),
              ),
            ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              titleSpacing: Spacing.md,
              title: Row(
                children: [
                  const ExcludeSemantics(child: AppLogo(size: 28)),
                  const Gap(Spacing.sm),
                  Flexible(
                    child: Text(
                      l10n.appName,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                if (!isEmpty)
                  IconButton(
                    key: const Key('home_library'),
                    tooltip: 'All screenshots',
                    icon: const Icon(Icons.photo_library_outlined),
                    onPressed: () => context.push('${Routes.inbox}?filter=all'),
                  ),
                const Gap(Spacing.xxs),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.xxs,
                Spacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SearchShortcut(
                  hint: l10n.searchHint,
                  onTap: () => context.go(SearchScreen.focusLocation()),
                ),
              ),
            ),
            if (isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  art: BrandArt.emptyLibrary,
                  icon: Icons.photo_library_outlined,
                  title: l10n.emptyLibraryTitle,
                  message: l10n.emptyLibraryBody,
                  action: PrimaryButton(
                    key: const Key('empty_import'),
                    label: l10n.importScreenshots,
                    icon: Icons.add_photo_alternate_outlined,
                    loading: importing,
                    onPressed: import,
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.only(top: Spacing.sm),
                sliver: SliverToBoxAdapter(child: HomeCountStrip(stats: stats)),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.md,
                  0,
                ),
                sliver: SliverToBoxAdapter(child: _ActionCenter()),
              ),
              const SliverPadding(
                padding: Spacing.pagePadding,
                sliver: SliverToBoxAdapter(child: _ComingUp()),
              ),
              SliverPadding(
                padding: Spacing.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Recent',
                    actionLabel: 'See all',
                    onAction: () => context.push('${Routes.inbox}?filter=all'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _RecentRow()),
              const SliverToBoxAdapter(child: Gap(_fabClearance)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionCenter extends ConsumerWidget {
  const _ActionCenter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingActionsProvider).value?.length ?? 0;
    final confirm = ref.watch(needsConfirmationProvider).value?.length ?? 0;
    return ActionCenterBanner(count: pending + confirm);
  }
}

class _ComingUp extends ConsumerWidget {
  const _ComingUp();

  @override
  Widget build(BuildContext context, WidgetRef ref) => ComingUpSection(
    items: ref.watch(upcomingProvider),
    overdue: ref.watch(overdueRemindersProvider),
  );
}

class _RecentRow extends ConsumerWidget {
  const _RecentRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(screenshotsProvider(_recentQuery));
    final hideSensitive = ref
        .watch(settingsRepositoryProvider)
        .getBool(SettingsKeys.hideSensitivePreviews, fallback: true);
    // The thumbnail is fixed; the text lines below it grow with font size.
    final height = 180 + 80 * MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      height: height,
      child: recent.when(
        skipLoadingOnReload: true,
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const ErrorState(
          message: 'Recent screenshots could not be loaded.',
        ),
        data: (items) => ListView.separated(
          padding: Spacing.pagePadding,
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const Gap(Spacing.sm),
          itemBuilder: (context, i) => SizedBox(
            width: 150,
            child: ScreenshotCard(
              screenshot: items[i],
              hideSensitive: hideSensitive,
              onTap: () => context.push(Routes.screenshot(items[i].id)),
            ),
          ),
        ),
      ),
    );
  }
}

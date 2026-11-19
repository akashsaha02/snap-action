import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/repositories/screenshot_repository.dart';
import '../features/actions/presentation/action_center_screen.dart';
import '../features/collections/presentation/collection_detail_screen.dart';
import '../features/collections/presentation/collections_screen.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/duplicates/presentation/similar_screenshots_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/screenshot_details/presentation/screenshot_details_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/privacy_policy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/wishlist/presentation/wishlist_screen.dart';
import 'bootstrap.dart';
import 'routes.dart';
import 'shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(appBootstrapProvider, (_, _) => refresh.value++);
  ref.listen(onboardingCompletedProvider, (_, _) => refresh.value++);

  // A deep link (for example from a notification) that arrived before the
  // database was ready.
  String? pendingLocation;

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final ready = ref.read(appBootstrapProvider).hasValue;
      if (!ready) {
        if (location != Routes.splash && location != Routes.onboarding) {
          pendingLocation = state.uri.toString();
        }
        return location == Routes.splash ? null : Routes.splash;
      }
      final onboarded = ref.read(onboardingCompletedProvider);
      if (!onboarded) {
        return location == Routes.onboarding ? null : Routes.onboarding;
      }
      if (location == Routes.splash || location == Routes.onboarding) {
        final target = pendingLocation ?? Routes.home;
        pendingLocation = null;
        return target;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.inbox,
        builder: (context, state) => LibraryScreen(
          initialFilter:
              ScreenshotFilter.values
                  .asNameMap()[state.uri.queryParameters['filter']] ??
              ScreenshotFilter.inbox,
        ),
      ),
      GoRoute(
        path: '/screenshot/:id',
        builder: (context, state) => ScreenshotDetailsScreen(
          screenshotId: int.tryParse(state.pathParameters['id']!) ?? -1,
        ),
      ),
      GoRoute(
        path: Routes.actions,
        builder: (context, state) => const ActionCenterScreen(),
      ),
      GoRoute(
        path: Routes.wishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: Routes.duplicates,
        builder: (context, state) => const SimilarScreenshotsScreen(),
      ),
      GoRoute(
        path: Routes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/collections/category/:id',
        builder: (context, state) => LibraryScreen(
          initialFilter: ScreenshotFilter.all,
          categoryId: int.tryParse(state.pathParameters['id']!) ?? -1,
          title: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        path: '/collections/:id',
        builder: (context, state) => CollectionDetailScreen(
          collectionId: int.tryParse(state.pathParameters['id']!) ?? -1,
        ),
      ),
      GoRoute(
        path: '/tags/:id',
        builder: (context, state) => LibraryScreen(
          initialFilter: ScreenshotFilter.all,
          tagId: int.tryParse(state.pathParameters['id']!) ?? -1,
          title: '#${state.uri.queryParameters['name'] ?? ''}',
          showFilters: false,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.collections,
                builder: (context, state) => const CollectionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.reminders,
                builder: (context, state) => const RemindersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

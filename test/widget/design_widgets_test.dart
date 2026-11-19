import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/app/bootstrap.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/models/screenshot_summary.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/core/theme/app_colors.dart';
import 'package:snapaction/core/theme/app_theme.dart';
import 'package:snapaction/core/widgets/common.dart';
import 'package:snapaction/core/widgets/screenshot_card.dart';
import 'package:snapaction/core/widgets/sensitive_previews.dart';
import 'package:snapaction/core/widgets/states.dart';

import '../helpers/test_app.dart';

// WCAG 2.x relative luminance and contrast ratio.
double _channel(double c) =>
    c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [tint] at 12 % over [surface], as drawn by StatusBadge.
Color _tinted(Color tint, Color surface) =>
    Color.alphaBlend(tint.withValues(alpha: 0.12), surface);

ScreenshotSummary _shot({bool sensitive = false, bool favorite = false}) =>
    ScreenshotSummary(
      id: 1,
      localFilePath: '/missing/shot.png',
      importedAt: DateTime(2026, 5, 1),
      status: ProcessingStatus.completed,
      title: 'Boarding pass',
      textPreview: 'Gate 12, seat 14C',
      isSensitive: sensitive,
      isFavorite: favorite,
    );

Widget _app(
  Widget child, {
  ThemeData? theme,
  double textScale = 1,
  bool scope = true,
  List<Override> overrides = const [],
}) {
  final app = MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(360, 780),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(body: child),
    ),
  );
  if (!scope) return app;
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  // In the app the settings are loaded before any screen is shown; mount
  // the (overridden) repository the same way.
  container.read(settingsRepositoryProvider);
  return UncontrolledProviderScope(container: container, child: app);
}

/// Overrides the settings repository with an in-memory one.
Override _blurSetting(AppDatabase db, {required bool on}) =>
    settingsRepositoryProvider.overrideWithValue(
      SettingsRepository(db, {SettingsKeys.hideSensitivePreviews: '$on'}),
    );

void main() {
  group('status colour tokens', () {
    const surfaces = {
      'light': (AppColors.lightSurface, AppColors.lightBackground),
      'dark': (AppColors.darkSurface, AppColors.darkBackground),
    };
    for (final (name, status, scheme) in [
      ('light', StatusColors.light, AppTheme.light().colorScheme),
      ('dark', StatusColors.dark, AppTheme.dark().colorScheme),
    ]) {
      test('$name on-* text reaches 4.5:1 on its tint', () {
        final (surface, background) = surfaces[name]!;
        final pairs = {
          'success': (status.onSuccess, status.success),
          'warning': (status.onWarning, status.warning),
          'info': (status.onInfo, scheme.secondary),
          'danger': (status.onDanger, scheme.error),
          'accent': (status.onAccent, scheme.primary),
        };
        for (final MapEntry(key: label, value: (fg, tint)) in pairs.entries) {
          for (final bg in [surface, background]) {
            final ratio = _contrast(fg, _tinted(tint, bg));
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '$name $label: ${ratio.toStringAsFixed(2)}',
            );
          }
        }
        // The star is a graphic: 3:1 (WCAG 1.4.11).
        expect(_contrast(status.favorite, surface), greaterThanOrEqualTo(3));
        // Text on error-coloured buttons and snack bars.
        expect(
          _contrast(scheme.onError, scheme.error),
          greaterThanOrEqualTo(4.5),
        );
      });
    }

    test('the old status colours were the low-contrast ones', () {
      final ratio = _contrast(
        AppColors.warning,
        _tinted(AppColors.warning, AppColors.lightSurface),
      );
      expect(ratio, lessThan(3));
    });
  });

  group('ProcessingStatusBadge', () {
    testWidgets('uses readable foregrounds in light mode', (tester) async {
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              ProcessingStatusBadge(status: ProcessingStatus.pending),
              ProcessingStatusBadge(
                status: ProcessingStatus.completed,
                isReviewed: true,
              ),
            ],
          ),
          scope: false,
        ),
      );
      Color colorOf(String text) =>
          tester.widget<Text>(find.text(text)).style!.color!;
      expect(colorOf('Queued'), AppColors.lightOnWarning);
      expect(colorOf('Reviewed'), AppColors.lightOnSuccess);
      expect(find.bySemanticsLabel('Status: Queued'), findsOneWidget);
    });
  });

  group('favourite star', () {
    testWidgets('has a 48 dp tap target and a 20 dp icon', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 180,
            height: 320,
            child: ScreenshotCard(
              screenshot: _shot(favorite: true),
              onTap: () {},
              onFavoriteToggle: () => taps++,
            ),
          ),
          scope: false,
        ),
      );
      final button = find.byKey(const ValueKey('screenshot_card_favorite'));
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      final icon = find.descendant(of: button, matching: find.byType(Icon));
      expect(tester.getSize(icon), const Size(20, 20));
      expect(tester.widget<Icon>(icon).color, StatusColors.light.favorite);

      // A tap near the corner of the 48 dp box still counts.
      final rect = tester.getRect(button);
      await tester.tapAt(rect.topLeft + const Offset(3, 3));
      expect(taps, 1);
      expect(find.byTooltip('Remove favourite'), findsOneWidget);
    });
  });

  group('sensitive previews', () {
    late AppDatabase db;
    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    Finder blurred() => find.byType(ImageFiltered);

    testWidgets('isSensitive follows the setting', (tester) async {
      for (final on in [true, false]) {
        await tester.pumpWidget(
          _app(
            const SizedBox(
              width: 60,
              height: 80,
              child: ScreenshotThumbnail(path: '/x/a.png', isSensitive: true),
            ),
            overrides: [_blurSetting(db, on: on)],
          ),
        );
        expect(blurred(), on ? findsOneWidget : findsNothing, reason: '$on');
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('non-sensitive thumbnails are never blurred', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 60,
            height: 80,
            child: ScreenshotThumbnail(path: '/x/a.png'),
          ),
          overrides: [_blurSetting(db, on: true)],
        ),
      );
      expect(blurred(), findsNothing);
    });

    testWidgets('fails closed when the setting cannot be read', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 60,
            height: 80,
            child: ScreenshotThumbnail(path: '/x/a.png', isSensitive: true),
          ),
          scope: false,
        ),
      );
      expect(blurred(), findsOneWidget);
    });

    testWidgets('ScreenshotCard obeys the setting, not the caller flag', (
      tester,
    ) async {
      Future<void> pump({required bool setting, required bool flag}) async {
        await tester.pumpWidget(
          _app(
            SizedBox(
              width: 180,
              height: 320,
              child: ScreenshotCard(
                screenshot: _shot(sensitive: true),
                onTap: () {},
                hideSensitive: flag,
              ),
            ),
            overrides: [_blurSetting(db, on: setting)],
          ),
        );
      }

      await pump(setting: true, flag: false);
      expect(blurred(), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('preview hidden')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await pump(setting: false, flag: true);
      expect(blurred(), findsNothing);
    });

    testWidgets('collection tiles and reminder thumbnails look paths up', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CategoryCard(
                  name: 'Travel',
                  icon: 'flight',
                  color: 0xFF635BFF,
                  count: 2,
                  onTap: () {},
                  previewPaths: const ['/x/secret.png', '/x/plain.png'],
                ),
              ),
              ReminderCard(
                title: 'Check in',
                dueAt: DateTime(2026, 5, 2),
                completed: false,
                onToggleComplete: () {},
                thumbnailPath: '/x/secret.png',
              ),
            ],
          ),
          overrides: [
            _blurSetting(db, on: true),
            sensitivePreviewPathsProvider.overrideWith(
              (ref) => Stream.value({'/x/secret.png'}),
            ),
          ],
        ),
      );
      await tester.pump();
      // One collection tile and the reminder thumbnail; not the plain tile.
      expect(blurred(), findsNWidgets(2));
    });
  });

  group('ErrorState', () {
    const raw =
        'Could not load reminders.\n'
        'SqliteException(1): no such table: reminders, SQL logic error '
        '/data/user/0/app.snapaction/databases/snapaction.sqlite\n'
        '#0      NativeDatabase.select (package:drift/native.dart:120:7)\n'
        '<asynchronous suspension>';

    test('sanitize keeps the friendly text and one clean summary line', () {
      final r = ErrorState.sanitize(raw);
      expect(r.message, 'Could not load reminders.');
      expect(r.details, contains('SqliteException'));
      expect(r.details, isNot(contains('#0')));
      expect(r.details, isNot(contains('package:')));
      expect(r.details, isNot(contains('/data/user')));
      expect(r.details!.length, lessThanOrEqualTo(ErrorState.maxDetailsLength));
    });

    test('a bare exception gets a friendly fallback', () {
      final r = ErrorState.sanitize('Exception: boom\n#0 main (file.dart:1)');
      expect(r.message, ErrorState.fallbackMessage);
      expect(r.details, 'Exception: boom');
    });

    testWidgets('details stay collapsed until asked for', (tester) async {
      await tester.pumpWidget(
        _app(ErrorState(message: raw, onRetry: () {}), scope: false),
      );
      expect(find.text('Could not load reminders.'), findsOneWidget);
      expect(find.textContaining('SqliteException'), findsNothing);
      expect(find.textContaining('#0'), findsNothing);

      await tester.tap(find.text('Show details'));
      await tester.pump();
      expect(find.textContaining('SqliteException'), findsOneWidget);
      expect(find.textContaining('#0'), findsNothing);
      expect(find.textContaining('asynchronous'), findsNothing);
    });
  });

  group('large text on a 360 dp phone', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      testWidgets('cards and states do not overflow (${theme.brightness})', (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(1080, 2340)
          ..devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _app(
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SizedBox(
                  // Library grid cell on a 360 dp phone: 158 x 255.
                  height: 255,
                  child: Row(
                    children: [
                      Expanded(
                        child: ScreenshotCard(
                          screenshot: _shot(favorite: true),
                          onTap: () {},
                          onFavoriteToggle: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CategoryCard(
                          name: 'Very long collection name indeed',
                          icon: 'folder',
                          color: 0xFF14B8A6,
                          count: 1234,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                ScreenshotCard(
                  screenshot: _shot(),
                  onTap: () {},
                  onFavoriteToggle: () {},
                  layout: ScreenshotCardLayout.list,
                ),
                ReminderCard(
                  title: 'Pay the electricity bill before the deadline',
                  subtitle: 'From a screenshot of an invoice',
                  dueAt: DateTime(2026, 12, 15, 9),
                  overdue: true,
                  completed: false,
                  onToggleComplete: () {},
                  thumbnailPath: '/x/a.png',
                  thumbnailSensitive: false,
                ),
                const SizedBox(
                  height: 300,
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Nothing here yet',
                    message:
                        'Import screenshots to see them here. They stay on '
                        'this device.',
                  ),
                ),
                SizedBox(
                  height: 260,
                  child: ErrorState(message: 'Could not load.', onRetry: () {}),
                ),
              ],
            ),
            theme: theme,
            textScale: 1.3,
            scope: false,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('tags in collections', () {
    testWidgets('are managed from a visible button and deleting asks first', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        seed: (db) async {
          final shot = await db
              .into(db.screenshots)
              .insert(
                ScreenshotsCompanion.insert(
                  localFilePath: '/missing/tagged.png',
                  contentHash: 'hash-tagged',
                  title: const Value('Tagged'),
                  importedAt: DateTime(2026, 5, 1),
                  source: ScreenshotSource.picker,
                  processingStatus: ProcessingStatus.completed,
                  fileSize: 1,
                ),
              );
          final tag = await db
              .into(db.tags)
              .insert(TagsCompanion.insert(name: 'thesis'));
          await db
              .into(db.screenshotTags)
              .insert(
                ScreenshotTagsCompanion.insert(screenshotId: shot, tagId: tag),
              );
        },
      );
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Collections'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Manage'), 200);
      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Rename #thesis'), findsOneWidget);
      await tester.tap(find.byTooltip('Delete #thesis'));
      await tester.pumpAndSettle();

      // Confirmation first; cancelling keeps the tag.
      expect(find.text('Delete #thesis?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.textContaining('#thesis'), findsOneWidget);
    });
  });
}

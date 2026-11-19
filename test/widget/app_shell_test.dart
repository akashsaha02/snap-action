import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/features/dashboard/presentation/home_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('first launch shows onboarding and completes it', (tester) async {
    final services = await pumpTestApp(tester, onboarded: false);

    expect(find.text('Stop losing important screenshots'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.textContaining('stay on this device'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding_next')));
    await tester.pumpAndSettle();
    expect(find.text('Your screenshots are searchable'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding_next')));
    await tester.pumpAndSettle();
    expect(find.text('Turn information into action'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(services.settings.getBool(SettingsKeys.onboardingCompleted), isTrue);
  });

  testWidgets('skip goes straight to home', (tester) async {
    await pumpTestApp(tester, onboarded: false);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('bottom navigation switches between the five tabs', (
    tester,
  ) async {
    await pumpTestApp(tester);
    expect(find.byType(NavigationBar), findsOneWidget);

    for (final label in ['Collections', 'Search', 'Reminders', 'Settings']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(label)),
        findsOneWidget,
      );
    }
  });

  testWidgets('theme selection applies and persists', (tester) async {
    final services = await pumpTestApp(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(NavigationBar))).brightness,
      Brightness.dark,
    );
    expect(services.settings.getString(SettingsKeys.themeMode), 'dark');

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(NavigationBar))).brightness,
      Brightness.light,
    );
  });

  testWidgets('settings explain privacy and guard destructive actions', (
    tester,
  ) async {
    await pumpTestApp(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();

    final list = find.byType(Scrollable).first;
    for (final (text, detail) in [
      ('Read text in screenshots', null),
      ('Detect similar screenshots', 'never deletes gallery images'),
      ('Default reminder time', null),
      ('App lock', 'does not encrypt'),
      ('Clear search history', null),
      ('Full backup (ZIP)', 'sensitive information'),
      ('Restore from backup', null),
      ('Delete all SnapAction data', 'Gallery originals are not affected'),
      ('Privacy policy', null),
      ('Open-source licences', null),
    ]) {
      await tester.scrollUntilVisible(find.text(text), 200, scrollable: list);
      expect(find.text(text), findsOneWidget);
      if (detail != null) {
        expect(find.textContaining(detail), findsOneWidget, reason: text);
      }
    }

    await tester.scrollUntilVisible(
      find.byKey(const Key('delete_all')),
      200,
      scrollable: list,
    );
    await tester.tap(find.byKey(const Key('delete_all')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        'original screenshots in your gallery are not touched',
      ),
      findsOneWidget,
    );
    final confirm = find.byKey(const Key('delete_confirm'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    await tester.enterText(
      find.byKey(const Key('delete_confirm_field')),
      'delete',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Privacy policy'),
      200,
      scrollable: list,
    );
    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Privacy policy'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('no analytics'), findsOneWidget);
  });
}

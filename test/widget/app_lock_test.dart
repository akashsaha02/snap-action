import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/app/bootstrap.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/features/security/application/app_lock.dart';

import '../helpers/test_app.dart';

class FakeAuthenticator implements DeviceAuthenticator {
  FakeAuthenticator({this.supported = true});

  bool supported;
  final outcomes = <AuthOutcome>[];
  int calls = 0;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    calls++;
    return outcomes.isEmpty ? AuthOutcome.failed : outcomes.removeAt(0);
  }
}

void main() {
  group('AppLockController', () {
    late AppServices services;
    late FakeAuthenticator auth;
    late ProviderContainer container;

    Future<void> start({bool enabled = false}) async {
      services = await createTestServices(
        settings: {if (enabled) SettingsKeys.appLockEnabled: 'true'},
      );
      auth = FakeAuthenticator();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          appBootstrapProvider.overrideWith((ref) async => services),
          deviceAuthenticatorProvider.overrideWithValue(auth),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await services.database.close();
      });
      await container.read(appBootstrapProvider.future);
    }

    AppLockState state() => container.read(appLockProvider);
    AppLockController lock() => container.read(appLockProvider.notifier);

    test('starts unlocked when disabled and locked when enabled', () async {
      await start();
      expect(state().enabled, isFalse);
      expect(state().locked, isFalse);
      container.dispose();
      await services.database.close();

      await start(enabled: true);
      expect(state().enabled, isTrue);
      expect(state().locked, isTrue);
    });

    test('unlocks only after successful authentication', () async {
      await start(enabled: true);
      auth.outcomes.add(AuthOutcome.failed);
      expect(await lock().unlock(), AuthOutcome.failed);
      expect(state().locked, isTrue);

      auth.outcomes.add(AuthOutcome.lockedOut);
      await lock().unlock();
      expect(state().locked, isTrue);
      expect(state().message, contains('Too many attempts'));

      auth.outcomes.add(AuthOutcome.success);
      await lock().unlock();
      expect(state().locked, isFalse);
    });

    test(
      'turns itself off if the device no longer has a screen lock',
      () async {
        await start(enabled: true);
        auth.outcomes.add(AuthOutcome.notAvailable);
        await lock().unlock();
        expect(state().locked, isFalse);
        expect(state().enabled, isFalse);
        expect(state().message, contains('no longer has a screen lock'));
        expect(services.settings.getBool(SettingsKeys.appLockEnabled), isFalse);
      },
    );

    test('enabling requires a supported device and authentication', () async {
      await start();
      auth.supported = false;
      expect(await lock().setEnabled(enabled: true), contains('screen lock'));
      expect(state().enabled, isFalse);
      expect(auth.calls, 0);

      auth.supported = true;
      auth.outcomes.add(AuthOutcome.failed);
      expect(
        await lock().setEnabled(enabled: true),
        'App lock was not turned on.',
      );
      expect(state().enabled, isFalse);

      auth.outcomes.add(AuthOutcome.success);
      expect(await lock().setEnabled(enabled: true), isNull);
      expect(state().enabled, isTrue);
      expect(state().locked, isFalse);
      expect(services.settings.getBool(SettingsKeys.appLockEnabled), isTrue);
    });

    test('disabling requires authentication', () async {
      await start(enabled: true);
      auth.outcomes.add(AuthOutcome.failed);
      expect(await lock().setEnabled(enabled: false), 'App lock is still on.');
      expect(services.settings.getBool(SettingsKeys.appLockEnabled), isTrue);

      auth.outcomes.add(AuthOutcome.success);
      expect(await lock().setEnabled(enabled: false), isNull);
      expect(state().enabled, isFalse);
      expect(services.settings.getBool(SettingsKeys.appLockEnabled), isFalse);
    });

    test('locks again only after the grace period in the background', () async {
      await start(enabled: true);
      var now = DateTime(2026, 11, 18, 12);
      lock().clock = () => now;
      auth.outcomes.add(AuthOutcome.success);
      await lock().unlock();

      lock().onBackground();
      now = now.add(const Duration(seconds: 10));
      lock().onForeground();
      expect(state().locked, isFalse);

      lock().onBackground();
      now = now.add(AppLockController.grace);
      lock().onForeground();
      expect(state().locked, isTrue);
    });
  });

  group('AppLockGate', () {
    testWidgets('covers the app until the user authenticates', (tester) async {
      final auth = FakeAuthenticator()..outcomes.add(AuthOutcome.failed);
      await pumpTestApp(
        tester,
        settings: {SettingsKeys.appLockEnabled: 'true'},
        overrides: [deviceAuthenticatorProvider.overrideWithValue(auth)],
      );
      expect(find.text('Mindtiq is locked'), findsOneWidget);
      // The automatic prompt on open failed; the app stays covered.
      expect(auth.calls, 1);
      expect(find.byType(NavigationBar).hitTestable(), findsNothing);

      auth.outcomes.add(AuthOutcome.success);
      await tester.tap(find.byKey(const Key('unlock_button')));
      await tester.pumpAndSettle();
      expect(find.text('Mindtiq is locked'), findsNothing);
      expect(find.byType(NavigationBar).hitTestable(), findsOneWidget);
    });

    testWidgets('does nothing when the lock is off', (tester) async {
      final auth = FakeAuthenticator();
      await pumpTestApp(
        tester,
        overrides: [deviceAuthenticatorProvider.overrideWithValue(auth)],
      );
      expect(find.text('Mindtiq is locked'), findsNothing);
      expect(auth.calls, 0);
    });
  });
}

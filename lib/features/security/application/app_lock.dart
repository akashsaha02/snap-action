import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../app/bootstrap.dart';
import '../../../core/services/settings_repository.dart';

enum AuthOutcome { success, failed, notAvailable, lockedOut }

/// Device authentication (biometrics or the screen-lock PIN, pattern or
/// password). This restricts access to the app; it does not encrypt data.
abstract interface class DeviceAuthenticator {
  Future<bool> isSupported();

  Future<AuthOutcome> authenticate(String reason);
}

class LocalDeviceAuthenticator implements DeviceAuthenticator {
  final _auth = LocalAuthentication();

  @override
  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
      return ok ? AuthOutcome.success : AuthOutcome.failed;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.uiUnavailable => AuthOutcome.notAvailable,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => AuthOutcome.lockedOut,
        _ => AuthOutcome.failed,
      };
    } on PlatformException {
      return AuthOutcome.failed;
    }
  }
}

final deviceAuthenticatorProvider = Provider<DeviceAuthenticator>(
  (ref) => LocalDeviceAuthenticator(),
);

class AppLockState {
  const AppLockState({
    required this.enabled,
    required this.locked,
    this.message,
  });

  final bool enabled;
  final bool locked;
  final String? message;

  AppLockState copyWith({bool? enabled, bool? locked, String? message}) =>
      AppLockState(
        enabled: enabled ?? this.enabled,
        locked: locked ?? this.locked,
        message: message,
      );
}

class AppLockController extends Notifier<AppLockState> {
  /// How long the app may stay in the background before it locks again.
  static const grace = Duration(seconds: 30);

  DateTime? _pausedAt;
  bool _authenticating = false;
  DateTime Function() clock = DateTime.now;

  @override
  AppLockState build() {
    final enabled =
        ref
            .watch(appBootstrapProvider)
            .value
            ?.settings
            .getBool(SettingsKeys.appLockEnabled) ??
        false;
    return AppLockState(enabled: enabled, locked: enabled);
  }

  Future<AuthOutcome> unlock() async {
    if (_authenticating) return AuthOutcome.failed;
    _authenticating = true;
    try {
      final outcome = await ref
          .read(deviceAuthenticatorProvider)
          .authenticate('Unlock Mindtiq');
      switch (outcome) {
        case AuthOutcome.success:
          state = state.copyWith(locked: false);
        case AuthOutcome.notAvailable:
          // The screen lock was removed, which itself needs the old
          // credential. Keeping the app locked would lock the user out.
          await ref
              .read(settingsRepositoryProvider)
              .setBool(SettingsKeys.appLockEnabled, value: false);
          state = const AppLockState(
            enabled: false,
            locked: false,
            message: 'App lock was turned off because this device no longer has a screen lock.',
          );
        case AuthOutcome.lockedOut:
          state = state.copyWith(
            message: 'Too many attempts. Try again later.',
          );
        case AuthOutcome.failed:
          state = state.copyWith(message: null);
      }
      return outcome;
    } finally {
      _authenticating = false;
    }
  }

  /// Returns an error message, or null when the change was applied.
  Future<String?> setEnabled({required bool enabled}) async {
    final auth = ref.read(deviceAuthenticatorProvider);
    if (enabled) {
      if (!await auth.isSupported()) {
        return 'Set up a screen lock (PIN, pattern, password or biometrics) in Android settings first.';
      }
      _authenticating = true;
      final outcome = await auth.authenticate(
        'Confirm it is you to turn on app lock',
      );
      _authenticating = false;
      if (outcome == AuthOutcome.notAvailable) {
        return 'Set up a screen lock in Android settings first.';
      }
      if (outcome != AuthOutcome.success) return 'App lock was not turned on.';
    } else {
      _authenticating = true;
      final outcome = await auth.authenticate(
        'Confirm it is you to turn off app lock',
      );
      _authenticating = false;
      if (outcome != AuthOutcome.success &&
          outcome != AuthOutcome.notAvailable) {
        return 'App lock is still on.';
      }
    }
    await ref
        .read(settingsRepositoryProvider)
        .setBool(SettingsKeys.appLockEnabled, value: enabled);
    state = AppLockState(enabled: enabled, locked: false);
    return null;
  }

  void onBackground() {
    if (_authenticating) return;
    _pausedAt ??= clock();
  }

  void onForeground() {
    final paused = _pausedAt;
    _pausedAt = null;
    if (!state.enabled || _authenticating || paused == null) return;
    if (clock().difference(paused) >= grace) {
      state = state.copyWith(locked: true);
    }
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);

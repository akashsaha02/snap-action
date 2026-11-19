import 'dart:async';

import 'package:flutter/services.dart';

class SharedFile {
  const SharedFile({this.path, this.name, this.mime, this.error});

  factory SharedFile.fromMap(Map<Object?, Object?> map) => SharedFile(
    path: map['path'] as String?,
    name: map['name'] as String?,
    mime: map['mime'] as String?,
    error: map['error'] as String?,
  );

  final String? path;
  final String? name;
  final String? mime;

  /// `inaccessible`, `unsupported`, `too_large` or `no_space`.
  final String? error;
}

/// Wrapper around the `snapaction/platform` method channel implemented in
/// `MainActivity.kt`.
class PlatformService {
  PlatformService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('snapaction/platform');

  final MethodChannel _channel;
  final _shares = StreamController<List<SharedFile>>.broadcast();
  bool _listening = false;

  /// Shares delivered while the app is already running.
  Stream<List<SharedFile>> get incomingShares => _shares.stream;

  /// Starts listening and returns shares that launched the app.
  Future<List<SharedFile>> takePendingShares() async {
    if (!_listening) {
      _listening = true;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onShare') {
          _shares.add(_parse(call.arguments));
        }
        return null;
      });
    }
    try {
      final result = await _channel.invokeMethod<List<Object?>>(
        'takePendingShares',
      );
      return _parse(result);
    } on MissingPluginException {
      return const [];
    }
  }

  List<SharedFile> _parse(Object? raw) => [
    for (final item in (raw as List<Object?>?) ?? const [])
      if (item is Map<Object?, Object?>) SharedFile.fromMap(item),
  ];

  Future<bool> insertCalendarEvent({
    required String title,
    DateTime? begin,
    DateTime? end,
    bool allDay = false,
    String? description,
    String? location,
  }) async {
    final ok = await _channel.invokeMethod<bool>('insertCalendarEvent', {
      'title': title,
      'beginMillis': begin?.millisecondsSinceEpoch,
      'endMillis': end?.millisecondsSinceEpoch,
      'allDay': allDay,
      'description': description,
      'location': location,
    });
    return ok ?? false;
  }

  /// Offers the network to the system's "Save Wi-Fi network?" sheet
  /// (Android 11+). False when unsupported or the details are invalid.
  Future<bool> addWifiNetwork({required String ssid, String? password}) async {
    final ok = await _channel.invokeMethod<bool>('addWifiNetwork', {
      'ssid': ssid,
      'password': password,
    });
    return ok ?? false;
  }

  Future<bool> openWifiSettings() async =>
      await _channel.invokeMethod<bool>('openWifiSettings') ?? false;

  Future<bool> insertContact({
    String? name,
    String? phone,
    String? email,
  }) async {
    final ok = await _channel.invokeMethod<bool>('insertContact', {
      'name': name,
      'phone': phone,
      'email': email,
    });
    return ok ?? false;
  }

  /// Lets the user pick where to save [path] via the system document picker.
  /// Returns false when cancelled or the copy failed.
  Future<bool> saveDocument({
    required String path,
    required String name,
    required String mime,
  }) async {
    final ok = await _channel.invokeMethod<bool>('saveDocument', {
      'path': path,
      'name': name,
      'mime': mime,
    });
    return ok ?? false;
  }

  /// Lets the user pick a backup file; it is copied into the app cache.
  /// Returns null when cancelled.
  Future<SharedFile?> openBackupDocument() async {
    final raw = await _channel.invokeMethod<Map<Object?, Object?>>(
      'openDocument',
    );
    return raw == null ? null : SharedFile.fromMap(raw);
  }

  /// Hides the app's content in the recent-apps screen and blocks
  /// screenshots of Mindtiq itself.
  Future<void> setSecure({required bool secure}) async {
    try {
      await _channel.invokeMethod<bool>('setSecure', {'secure': secure});
    } on MissingPluginException {
      // Not available on this platform.
    }
  }

  void dispose() => _shares.close();
}

import 'package:url_launcher/url_launcher.dart';

/// Builds and validates the only URIs SnapAction may hand to other apps.
/// Anything that fails validation is refused rather than "fixed".
abstract final class ExternalIntents {
  static final _email = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,24}$',
  );
  static final _phone = RegExp(r'^\+?\d{3,15}$');

  static Uri? web(String? raw) {
    if (raw == null) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) {
      return null;
    }
    if (uri.host.isEmpty ||
        !uri.host.contains('.') ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri;
  }

  static Uri? dial(String? raw) {
    final digits = raw?.replaceAll(RegExp(r'[\s().-]'), '');
    if (digits == null || !_phone.hasMatch(digits)) return null;
    return Uri(scheme: 'tel', path: digits);
  }

  static Uri? email(String? raw, {String? subject}) {
    final address = raw?.trim();
    if (address == null || !_email.hasMatch(address)) return null;
    return Uri(
      scheme: 'mailto',
      path: address,
      query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}',
    );
  }

  static Uri? map(String? address) {
    final q = address?.trim();
    if (q == null || q.isEmpty || q.length > 300) return null;
    return Uri(scheme: 'geo', path: '0,0', queryParameters: {'q': q});
  }

  /// Opens [uri] in another app. Returns false when no app can handle it.
  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}

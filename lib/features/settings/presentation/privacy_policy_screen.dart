import 'package:material_ui/material_ui.dart';

import '../../../core/theme/spacing.dart';

/// In-app copy of PRIVACY.md. Keep the two in sync.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = <(String, String)>[
    (
      'Summary',
      'SnapAction works entirely on your device. It has no account, no server, no analytics, '
          'no advertising and no tracking. Your screenshots and everything extracted from them '
          'never leave your phone unless you export or share them yourself.',
    ),
    (
      'What SnapAction stores',
      'A private copy of each screenshot you import, a small thumbnail, the text recognised in '
          'it, the details found (such as dates, amounts, links and codes), and anything you add: '
          'categories, collections, tags, notes, reminders and wishlist items. Settings and search '
          'history are stored too. All of it lives in SnapAction\'s private app storage.',
    ),
    (
      'How text is recognised',
      'Text recognition uses Google ML Kit\'s on-device model, which is bundled with the app. '
          'Images are processed on the phone and are not sent to Google or anyone else. '
          'Categories, details and suggestions come from rules that run on the device.',
    ),
    (
      'Permissions',
      'Photos are chosen with the Android photo picker, so SnapAction only sees the images you '
          'pick or share with it. It does not ask for access to your whole gallery. Notifications, '
          'and restoring them after the phone restarts, are used only for reminders you create. Biometric access is used only if you turn on '
          'the app lock. SnapAction does not request internet, location, contacts or calendar '
          'permissions; adding a contact or calendar event opens the relevant app for you to confirm.',
    ),
    (
      'Your original screenshots',
      'SnapAction never deletes or changes the images in your gallery. Deleting a screenshot in '
          'SnapAction removes only SnapAction\'s copy.',
    ),
    (
      'App lock',
      'The optional app lock asks for your fingerprint, face or screen lock before showing the '
          'app. It restricts access to the app; it does not encrypt the stored files or database. '
          '"Hide in recent apps" blanks the app in the app switcher and blocks screenshots of '
          'SnapAction itself.',
    ),
    (
      'Backups and exports',
      'SnapAction\'s data is excluded from Android cloud backup and device transfer. You can '
          'create an export or full backup yourself. These files are not encrypted and can contain '
          'sensitive information, so keep them somewhere you trust. Where they go is up to you.',
    ),
    (
      'Deleting your data',
      'Settings → Delete all SnapAction data removes everything SnapAction stored '
          '(it keeps your theme and app-lock choices). '
          'Uninstalling the app removes it too.',
    ),
    (
      'Contact',
      'SnapAction does not collect personal data, so there is nothing for us to access, '
          'correct or delete on your behalf.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: ListView(
        padding: Spacing.pagePadding.copyWith(bottom: Spacing.xl),
        children: [
          for (final (title, body) in _sections) ...[
            const Gap(Spacing.md),
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            const Gap(Spacing.xs),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

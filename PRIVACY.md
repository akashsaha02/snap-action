# Snaptiq privacy policy

The same text is shown in the app under Settings → Privacy policy
(`lib/features/settings/presentation/privacy_policy_screen.dart`). Keep the
two in sync.

## Summary

Snaptiq works entirely on your device. It has no account, no server, no
analytics, no advertising and no tracking. Your screenshots and everything
extracted from them never leave your phone unless you export or share them
yourself.

## What Snaptiq stores

A private copy of each screenshot you import, a small thumbnail, the text
recognised in it, the details found (such as dates, amounts, links and codes),
and anything you add: categories, collections, tags, notes, reminders and
wishlist items. Settings and search history are stored too. All of it lives in
Snaptiq's private app storage.

## How text is recognised

Text recognition uses Google ML Kit's on-device model, which is bundled with
the app. Images are processed on the phone and are not sent to Google or
anyone else. Categories, details and suggestions come from rules that run on
the device. No cloud AI or language model is used.

## Permissions

| Permission | Why |
| --- | --- |
| `POST_NOTIFICATIONS` | Reminder notifications; asked for only when you save a reminder with notifications on or tap "Turn on" |
| `RECEIVE_BOOT_COMPLETED` | Restores scheduled reminder notifications after the phone restarts |
| `USE_BIOMETRIC` (added by `local_auth`) | The optional app lock |

Photos are chosen with the Android photo picker, so Snaptiq only sees the
images you pick or share with it. It does not ask for access to your whole
gallery. The manifest explicitly removes storage, media, exact-alarm and
internet permissions. Adding a contact or calendar event opens the relevant
app for you to confirm; Snaptiq has no contacts or calendar permission.

Debug and profile builds include the internet permission because Flutter's
development tools need it; release builds do not.

## Your original screenshots

Snaptiq never deletes or changes the images in your gallery. Deleting a
screenshot in Snaptiq removes only Snaptiq's copy.

## App lock

The optional app lock asks for your fingerprint, face or screen lock before
showing the app. It restricts access to the app; it does not encrypt the
stored files or database. "Hide in recent apps" blanks the app in the app
switcher and blocks screenshots of Snaptiq itself.

## Backups and exports

Snaptiq's data is excluded from Android cloud backup and device transfer
(`allowBackup="false"` and `data_extraction_rules.xml`). You can create an
export or full backup yourself from Settings. These files are not encrypted
and can contain sensitive information, so keep them somewhere you trust.
Where they go is up to you.

## Deleting your data

Settings → Delete all Snaptiq data removes everything Snaptiq stored
(it keeps your theme and app-lock choices). Uninstalling the app removes it
too.

## Contact

Snaptiq does not collect personal data, so there is nothing for us to
access, correct or delete on your behalf.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../services/entity_extraction/entity_models.dart';
import '../../reminders/presentation/reminder_editor.dart';
import '../../wishlist/presentation/wishlist_editor.dart';
import 'action_repository.dart';
import 'external_intents.dart';

/// Runs a suggested action after the user has reviewed it. Nothing derived
/// from OCR is ever executed without an explicit confirmation step.
abstract final class ActionExecutor {
  /// Returns true when the action was carried out and marked accepted.
  static Future<bool> run(
    BuildContext context,
    WidgetRef ref,
    SuggestedActionRow action,
  ) async {
    final payload = ActionRepository.decode(action.payloadJson);
    final done = await _dispatch(context, ref, action, payload);
    if (done) {
      await ref
          .read(actionRepositoryProvider)
          .setStatus(action.id, ActionStatus.accepted);
    }
    return done;
  }

  static Future<bool> _dispatch(
    BuildContext context,
    WidgetRef ref,
    SuggestedActionRow action,
    Map<String, Object?> p,
  ) async {
    final screenshotId = action.screenshotId;
    switch (action.actionType) {
      case ActionType.createReminder:
        final id = await showReminderEditor(
          context,
          prefill: ReminderPrefill.fromPayload(p, screenshotId: screenshotId),
        );
        return id != null;

      case ActionType.addToWishlist:
        final id = await showWishlistEditor(
          context,
          payload: p,
          screenshotId: screenshotId,
        );
        if (id != null && context.mounted) {
          context.showSnack('Added to wishlist');
        }
        return id != null;

      case ActionType.addCalendarEvent:
        return _calendar(context, ref, p);

      case ActionType.openUrl:
        final uri = ExternalIntents.web(p['url'] as String?);
        if (uri == null) {
          return _invalid(context, 'This link is not a valid web address.');
        }
        final insecure = uri.scheme == 'http'
            ? '\n\nThis page does not use a secure connection.'
            : '';
        return _confirmAndOpen(
          context,
          uri,
          title: 'Open link?',
          message: 'Check the address before you open it:\n\n$uri$insecure',
          confirmLabel: 'Open',
        );

      case ActionType.callPhone:
        final uri = ExternalIntents.dial(p['phone'] as String?);
        if (uri == null) {
          return _invalid(context, 'This phone number does not look valid.');
        }
        return _confirmAndOpen(
          context,
          uri,
          title: 'Open dialer?',
          message:
              '${uri.path}\n\nThe number is filled in for you. Nothing is called until you press call.',
          confirmLabel: 'Open dialer',
        );

      case ActionType.sendEmail:
        final uri = ExternalIntents.email(p['email'] as String?);
        if (uri == null) {
          return _invalid(context, 'This email address does not look valid.');
        }
        return _confirmAndOpen(
          context,
          uri,
          title: 'Write an email?',
          message:
              '${uri.path}\n\nYour email app opens with a new draft. Nothing is sent automatically.',
          confirmLabel: 'Open email app',
        );

      case ActionType.openMap:
        final address = p['address'] as String?;
        final uri = ExternalIntents.map(address);
        if (uri == null) {
          return _invalid(context, 'This address cannot be shown on a map.');
        }
        return _confirmAndOpen(
          context,
          uri,
          title: 'Show on map?',
          message:
              '$address\n\nThe address was read from the screenshot and may be incomplete.',
          confirmLabel: 'Open maps',
        );

      case ActionType.saveContact:
        return _contact(context, ref, p);

      case ActionType.saveTransaction:
        final lines = [
          if (_money(p) case final m?) 'Amount: $m',
          if (p['reference'] case final String r) 'Reference: $r',
          if (p['date'] case final String d) 'Date: ${Formatters.isoDate(d)}',
        ];
        return _saveToNote(
          context,
          ref,
          screenshotId,
          heading: 'Payment',
          lines: lines,
          tag: 'payment',
          warning: p['currencyAmbiguous'] == true
              ? 'The currency was guessed from a symbol such as \$. Edit the note if it is wrong.'
              : null,
        );

      case ActionType.saveTravel:
        final date = p['date'] as String?;
        final time = p['time'] as String?;
        final lines = [
          if (p['flight'] case final String f) 'Flight: $f',
          if (p['route'] case final String r) 'Route: $r',
          if (p['details'] case final String d) d,
          if (date != null)
            'Date: ${Formatters.isoDate(date)}${time == null ? '' : ' $time'}',
        ];
        return _saveToNote(
          context,
          ref,
          screenshotId,
          heading: 'Trip',
          lines: lines,
          tag: 'travel',
        );

      case ActionType.saveNotes:
        final ocr =
            await (ref
                    .read(appDatabaseProvider)
                    .select(ref.read(appDatabaseProvider).ocrResults)
                  ..where((o) => o.screenshotId.equals(screenshotId)))
                .getSingleOrNull();
        final text = (ocr?.correctedText ?? ocr?.rawText ?? '').trim();
        if (text.isEmpty) {
          if (!context.mounted) return false;
          return _invalid(context, 'There is no text to save.');
        }
        if (!context.mounted) return false;
        return _saveToNote(
          context,
          ref,
          screenshotId,
          heading: null,
          lines: [text],
          tag: 'notes',
        );

      case ActionType.copyWifi:
        return _copyWifi(context, ref, p);

      case ActionType.copyCode:
        final code = p['code'] as String?;
        if (code == null || code.isEmpty) {
          return _invalid(context, 'There is no code to copy.');
        }
        await Clipboard.setData(ClipboardData(text: code));
        if (context.mounted) context.showSnack('Code copied');
        return true;
    }
  }

  static Future<bool> _confirmAndOpen(
    BuildContext context,
    Uri uri, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final ok = await showConfirmationDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    );
    if (!ok) return false;
    final opened = await ExternalIntents.open(uri);
    if (!opened && uri.scheme == 'geo') {
      final fallback = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': uri.queryParameters['q'] ?? '',
      });
      if (await ExternalIntents.open(fallback)) return true;
    }
    if (!opened && context.mounted) {
      context.showSnack('No app on this device can open this.', error: true);
    }
    return opened;
  }

  static Future<bool> _calendar(
    BuildContext context,
    WidgetRef ref,
    Map<String, Object?> p,
  ) async {
    final title = (p['title'] as String?)?.trim();
    final iso = p['date'] as String?;
    final date = PartialDate.parseIso(iso);
    final time = RegExp(r'^(\d{2}):(\d{2})$')
        .firstMatch(p['time'] as String? ?? '');
    final location = p['location'] as String?;
    final description = (p['description'] as String?)?.trim();

    DateTime? begin;
    var allDay = false;
    if (date != null && date.hasYear) {
      if (time != null) {
        begin = DateTime(
          date.year!,
          date.month,
          date.day,
          int.parse(time[1]!),
          int.parse(time[2]!),
        );
      } else {
        begin = DateTime(date.year!, date.month, date.day);
        allDay = true;
      }
    }
    final when = begin == null
        ? (date == null
              ? 'No date found. Pick it in your calendar app.'
              : '${Formatters.isoDate(iso)}. The year is missing, so pick the date in your calendar app.')
        : allDay
        ? '${Formatters.fullDate(begin)} (all day)'
        : '${Formatters.fullDate(begin)}, ${Formatters.time(begin)}';
    final check = p['needsConfirmation'] == true && begin != null
        ? '\n\nThe date format was ambiguous. Please check it in your calendar app.'
        : '';
    final ok = await showConfirmationDialog(
      context,
      title: 'Add to calendar?',
      message:
          '${title ?? 'Event'}\n$when${location == null ? '' : '\n$location'}$check\n\n'
          'Your calendar app opens so you can review the event before saving it.',
      confirmLabel: 'Open calendar',
    );
    if (!ok) return false;
    final opened = await ref
        .read(platformServiceProvider)
        .insertCalendarEvent(
          title: title ?? 'Event',
          begin: begin,
          end: begin == null || allDay
              ? null
              : begin.add(const Duration(hours: 1)),
          allDay: allDay,
          location: location,
          description: description == null || description.isEmpty
              ? null
              : description,
        )
        .catchError((Object _) => false);
    if (!opened && context.mounted) {
      context.showSnack(
        'No calendar app was found on this device.',
        error: true,
      );
    }
    return opened;
  }

  static Future<bool> _contact(
    BuildContext context,
    WidgetRef ref,
    Map<String, Object?> p,
  ) async {
    final phone = ExternalIntents.dial(p['phone'] as String?)?.path;
    final email = ExternalIntents.email(p['email'] as String?)?.path;
    final name = (p['name'] as String?)?.trim();
    if (phone == null && email == null) {
      return _invalid(
        context,
        'No valid phone number or email address was found.',
      );
    }
    final ok = await showConfirmationDialog(
      context,
      title: 'Save contact?',
      message:
          '${[?name, ?phone, ?email].join('\n')}\n\n'
          'Your contacts app opens with these details so you can check them '
          'and save.',
      confirmLabel: 'Open contacts',
    );
    if (!ok) return false;
    final opened = await ref
        .read(platformServiceProvider)
        .insertContact(
          name: name == null || name.isEmpty ? null : name,
          phone: phone,
          email: email,
        )
        .catchError((Object _) => false);
    if (!opened && context.mounted) {
      context.showSnack(
        'No contacts app was found on this device.',
        error: true,
      );
    }
    return opened;
  }

  static Future<bool> _saveToNote(
    BuildContext context,
    WidgetRef ref,
    int screenshotId, {
    required String? heading,
    required List<String> lines,
    required String tag,
    String? warning,
  }) async {
    if (lines.isEmpty) return _invalid(context, 'Nothing was found to save.');
    final block = [?heading, ...lines].join('\n');
    final preview = block.length > 400 ? '${block.substring(0, 400)}…' : block;
    final ok = await showConfirmationDialog(
      context,
      title: 'Save to note?',
      message:
          '$preview\n\nThis is added to the screenshot\'s note and tagged #$tag. '
          'You can edit it afterwards.${warning == null ? '' : '\n\n$warning'}',
      confirmLabel: 'Save',
    );
    if (!ok) return false;
    final repo = ref.read(organizationRepositoryProvider);
    await repo.appendNote(screenshotId, block);
    await repo.addTag(screenshotId, tag);
    if (context.mounted) context.showSnack('Saved to note');
    return true;
  }

  static Future<bool> _copyWifi(
    BuildContext context,
    WidgetRef ref,
    Map<String, Object?> p,
  ) async {
    final ssid = p['ssid'] as String?;
    final password = p['password'] as String?;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(ssid == null ? 'Wi-Fi details' : 'Wi-Fi: $ssid'),
        children: [
          if (ssid != null)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('connect'),
              child: const ListTile(
                leading: Icon(Icons.wifi),
                title: Text('Connect'),
                subtitle: Text('Android asks before saving the network'),
              ),
            ),
          if (password != null)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('password'),
              child: const ListTile(
                leading: Icon(Icons.key_outlined),
                title: Text('Copy password'),
                subtitle: Text('Hidden'),
              ),
            ),
          if (ssid != null)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('ssid'),
              child: ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy network name'),
                subtitle: Text(ssid),
              ),
            ),
        ],
      ),
    );
    if (choice == null) return false;
    final platform = ref.read(platformServiceProvider);
    if (choice == 'connect' && ssid != null) {
      final offered = await platform
          .addWifiNetwork(ssid: ssid, password: password)
          .catchError((Object _) => false);
      if (offered) return true;
      // Older Android, or details the system rejects: copy the password and
      // open Wi-Fi settings so the user can paste it.
      if (password != null) {
        await Clipboard.setData(ClipboardData(text: password));
      }
      await platform.openWifiSettings().catchError((Object _) => false);
      if (context.mounted) {
        context.showSnack(
          password == null
              ? 'Pick "$ssid" in Wi-Fi settings.'
              : 'Password copied. Pick "$ssid" in Wi-Fi settings and paste it.',
        );
      }
      return true;
    }
    final text = choice == 'password' ? password : ssid;
    if (text == null) return false;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      context.showSnack(
        choice == 'password' ? 'Password copied' : 'Network name copied',
      );
    }
    return true;
  }

  static Future<bool> _invalid(BuildContext context, String message) async {
    context.showSnack(message, error: true);
    return false;
  }

  static String? _money(Map<String, Object?> p) {
    final minor = (p['minorUnits'] as num?)?.toInt();
    final currency = p['currency'] as String?;
    if (minor == null || currency == null) return null;
    return Formatters.money(
      minor,
      currency,
      decimals: (p['decimals'] as num?)?.toInt() ?? 2,
    );
  }
}

/// Short human description of what an action will do, for list rows.
String describeAction(SuggestedActionRow action) {
  final p = ActionRepository.decode(action.payloadJson);
  return switch (action.actionType) {
    ActionType.openUrl => p['url'] as String? ?? '',
    ActionType.callPhone || ActionType.saveContact => [
      ?p['phone'] as String?,
      ?p['email'] as String?,
    ].join(' · '),
    ActionType.sendEmail => p['email'] as String? ?? '',
    ActionType.openMap => p['address'] as String? ?? '',
    ActionType.copyWifi => p['ssid'] as String? ?? '',
    ActionType.addToWishlist => p['productName'] as String? ?? '',
    _ => '',
  };
}

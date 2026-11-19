import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../services/entity_extraction/entity_models.dart';
import '../application/reminder_defaults.dart';
import '../application/reminder_service.dart';

/// Values suggested from a screenshot. The user always reviews them before
/// anything is saved; a date without a year is never completed silently.
class ReminderPrefill {
  const ReminderPrefill({
    this.title,
    this.description,
    this.date,
    this.time,
    this.hint,
    this.screenshotId,
  });

  /// Builds a prefill from a `createReminder` action payload.
  factory ReminderPrefill.fromPayload(
    Map<String, Object?> payload, {
    required int screenshotId,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final iso = payload['date'] as String?;
    final parsed = PartialDate.parseIso(iso);
    final time = _parseTime(payload['time'] as String?);
    final isDeadline = payload['isDeadline'] == true;
    final unconfirmed = payload['needsConfirmation'] == true;

    DateTime? date;
    var movedEarlier = false;
    final hints = <String>[];
    if (parsed != null) {
      final label = Formatters.isoDate(iso);
      hints.add(
        isDeadline
            ? 'Deadline on screenshot: $label'
            : 'Date on screenshot: $label',
      );
      if (parsed.hasYear) {
        date = DateTime(parsed.year!, parsed.month, parsed.day);
        // Remind the day before a deadline when there is still time.
        if (isDeadline) {
          final before = date.subtract(const Duration(days: 1));
          if (!before.isBefore(DateTime(today.year, today.month, today.day))) {
            date = before;
            movedEarlier = true;
            hints.add(
              'Suggested: the day before the deadline, at your usual '
              'reminder time.',
            );
          }
        }
      } else {
        hints.add('The year is missing, so please pick the date.');
      }
      if (unconfirmed && parsed.hasYear) {
        hints.add('The date format was ambiguous. Please check it.');
      }
    }
    return ReminderPrefill(
      title: payload['title'] as String?,
      date: date,
      // A day-early reminder at the deadline's own time (often 23:59) is
      // useless; leave it to the default reminder time from Settings.
      time: movedEarlier
          ? null
          : time ?? (isDeadline ? const TimeOfDay(hour: 9, minute: 0) : null),
      hint: hints.isEmpty ? null : hints.join('\n'),
      screenshotId: screenshotId,
    );
  }

  final String? title;
  final String? description;
  final DateTime? date;
  final TimeOfDay? time;
  final String? hint;
  final int? screenshotId;

  static TimeOfDay? _parseTime(String? hhmm) {
    final m = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(hhmm ?? '');
    if (m == null) return null;
    return TimeOfDay(hour: int.parse(m[1]!), minute: int.parse(m[2]!));
  }
}

/// Returns the reminder id when saved.
Future<int?> showReminderEditor(
  BuildContext context, {
  ReminderRow? existing,
  ReminderPrefill? prefill,
}) {
  return showAppBottomSheet<int>(
    context,
    title: existing == null ? 'New reminder' : 'Edit reminder',
    builder: (_) => _ReminderEditor(existing: existing, prefill: prefill),
  );
}

class _ReminderEditor extends ConsumerStatefulWidget {
  const _ReminderEditor({this.existing, this.prefill});

  final ReminderRow? existing;
  final ReminderPrefill? prefill;

  @override
  ConsumerState<_ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends ConsumerState<_ReminderEditor> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  DateTime? _date;
  TimeOfDay? _time;
  RepeatRule _repeat = RepeatRule.none;
  bool _notify = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final p = widget.prefill;
    _title = TextEditingController(text: e?.title ?? p?.title ?? '');
    _notes = TextEditingController(
      text: e?.description ?? p?.description ?? '',
    );
    if (e != null) {
      _date = DateTime(
        e.scheduledAt.year,
        e.scheduledAt.month,
        e.scheduledAt.day,
      );
      _time = TimeOfDay.fromDateTime(e.scheduledAt);
      _repeat = e.repeatRule;
      _notify = e.notify;
    } else {
      _date = p?.date;
      _time = p?.time;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  TimeOfDay get _defaultTime =>
      defaultReminderTime(ref.read(settingsRepositoryProvider));

  /// True when an existing reminder keeps its schedule, repeat and
  /// notification setting, so only its title or notes change.
  bool _onlyDetailsChanged(DateTime at) {
    final e = widget.existing;
    if (e == null) return false;
    final was = e.scheduledAt;
    return at == DateTime(was.year, was.month, was.day, was.hour, was.minute) &&
        _repeat == e.repeatRule &&
        _notify == e.notify;
  }

  DateTime? get _scheduledAt {
    final d = _date;
    if (d == null) return null;
    final t = _time ?? _defaultTime;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _date != null &&
              !_date!.isBefore(DateTime(now.year, now.month, now.day))
          ? _date
          : now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? _defaultTime,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final at = _scheduledAt;
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a title.');
      return;
    }
    if (at == null) {
      setState(() => _error = 'Please choose a date.');
      return;
    }
    final detailsOnly = _onlyDetailsChanged(at);
    if (detailsOnly) {
      // Renaming an overdue or completed reminder must not force a new time.
      setState(() {
        _saving = true;
        _error = null;
      });
      final id = widget.existing!.id;
      await ref
          .read(reminderServiceProvider)
          .rename(id, title: _title.text, description: _notes.text);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(id);
      messenger.showSnackBar(const SnackBar(content: Text('Reminder updated')));
      return;
    }
    if (!at.isAfter(DateTime.now()) && _repeat == RepeatRule.none) {
      setState(() => _error = 'Please choose a time in the future.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final service = ref.read(reminderServiceProvider);
    final notifications = ref.read(notificationServiceProvider);
    final draft = ReminderDraft(
      title: _title.text,
      description: _notes.text,
      scheduledAt: at,
      screenshotId:
          widget.existing?.screenshotId ?? widget.prefill?.screenshotId,
      repeat: _repeat,
      notify: _notify,
    );
    var permissionDenied = false;
    if (_notify && !await notifications.areEnabled()) {
      permissionDenied = !await notifications.requestPermission();
    }
    final int id;
    if (widget.existing case final existing?) {
      await service.update(existing.id, draft);
      id = existing.id;
    } else {
      id = await service.create(draft);
    }
    ref.invalidate(notificationsEnabledProvider);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          permissionDenied
              ? 'Reminder saved. Notifications are off, so it will only show in the app.'
              : 'Reminder set for ${Formatters.dateTime(at)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final at = _scheduledAt;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.prefill?.hint case final hint?) ...[
            Card.filled(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const Gap(Spacing.sm),
                    Expanded(
                      child: Text(hint, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(Spacing.md),
          ],
          TextField(
            key: const Key('reminder_title'),
            controller: _title,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _notes,
            maxLines: 3,
            minLines: 1,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const Gap(Spacing.sm),
          ListTile(
            key: const Key('reminder_date'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(
              _date == null ? 'Choose date' : Formatters.fullDate(_date!),
            ),
            onTap: _pickDate,
          ),
          ListTile(
            key: const Key('reminder_time'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(
              _time == null
                  ? '${_defaultTime.format(context)} (default)'
                  : _time!.format(context),
            ),
            onTap: _pickTime,
          ),
          const Gap(Spacing.xs),
          Text('Repeat', style: theme.textTheme.labelLarge),
          const Gap(Spacing.xs),
          SegmentedButton<RepeatRule>(
            segments: const [
              ButtonSegment(value: RepeatRule.none, label: Text('Once')),
              ButtonSegment(value: RepeatRule.daily, label: Text('Daily')),
              ButtonSegment(value: RepeatRule.weekly, label: Text('Weekly')),
              ButtonSegment(value: RepeatRule.monthly, label: Text('Monthly')),
            ],
            selected: {_repeat},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _repeat = s.first),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notify me'),
            subtitle: const Text(
              'Android may deliver it a few minutes late to save battery.',
            ),
            value: _notify,
            onChanged: (v) => setState(() => _notify = v),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          FilledButton(
            key: const Key('reminder_save'),
            onPressed: _saving ? null : _save,
            child: Text(
              at == null ? 'Save' : 'Save · ${Formatters.dateTime(at)}',
            ),
          ),
        ],
      ),
    );
  }
}

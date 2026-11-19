import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class ActionItem {
  const ActionItem({
    required this.action,
    required this.payload,
    required this.screenshotTitle,
    required this.thumbnailPath,
    required this.isSensitive,
    this.importedAt,
  });

  final SuggestedActionRow action;
  final Map<String, Object?> payload;
  final String? screenshotTitle;
  final String? thumbnailPath;
  final bool isSensitive;
  final DateTime? importedAt;
}

/// Entity types whose uncertainty keeps a screenshot in "Needs your
/// confirmation".
const confirmableEntityTypes = {
  EntityType.date,
  EntityType.deadline,
  EntityType.amount,
};

/// Action types that are about a moment in time and are listed first.
const timeBoundActionTypes = {
  ActionType.createReminder,
  ActionType.addCalendarEvent,
  ActionType.saveTravel,
};

/// The payload field that an action is "about". When the user rejects that
/// value the action no longer makes sense and is dismissed.
const _primaryField = <ActionType, String>{
  ActionType.createReminder: 'date',
  ActionType.addCalendarEvent: 'date',
  ActionType.openUrl: 'url',
  ActionType.callPhone: 'phone',
  ActionType.sendEmail: 'email',
  ActionType.openMap: 'address',
  ActionType.saveTravel: 'flight',
  ActionType.copyCode: 'code',
};

class ActionRepository {
  ActionRepository(
    this._db, {
    this.recheckInterval = const Duration(minutes: 15),
  });

  final AppDatabase _db;

  /// Upper bound for how long a pending-suggestions stream waits before it
  /// re-checks postponed suggestions. Dart timers can run late while the
  /// device sleeps, so long waits are split up.
  final Duration recheckInterval;

  static Map<String, Object?> decode(String json) {
    try {
      final v = jsonDecode(json);
      return v is Map<String, Object?> ? v : const {};
    } on FormatException {
      return const {};
    }
  }

  /// Suggestions waiting for a decision, including postponed ones that are
  /// due again. Archived screenshots are left out.
  ///
  /// With a fixed [now] the list is evaluated once per database change.
  /// Without it the stream also re-emits when a postponed suggestion becomes
  /// due, so a long-lived listener (such as Home) sees it come back.
  /// Items are ordered by [sortForReview].
  Stream<List<ActionItem>> watchPending({
    DateTime? now,
    DateTime Function()? clock,
  }) {
    final source = _watchCandidates();
    if (now != null) {
      return source.map((all) => sortForReview(_due(all, now), now));
    }
    return _reevaluating(source, clock ?? DateTime.now);
  }

  Stream<List<ActionItem>> _watchCandidates() {
    final q =
        _db.select(_db.suggestedActions).join([
            innerJoin(
              _db.screenshots,
              _db.screenshots.id.equalsExp(_db.suggestedActions.screenshotId),
            ),
          ])
          ..where(
            _db.screenshots.isArchived.equals(false) &
                _db.suggestedActions.status.isInValues(const [
                  ActionStatus.suggested,
                  ActionStatus.postponed,
                ]),
          )
          ..orderBy([
            OrderingTerm.desc(_db.screenshots.importedAt),
            OrderingTerm.asc(_db.suggestedActions.id),
          ]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          () {
            final a = r.readTable(_db.suggestedActions);
            final s = r.readTable(_db.screenshots);
            return ActionItem(
              action: a,
              payload: decode(a.payloadJson),
              screenshotTitle: s.title,
              thumbnailPath: s.thumbnailPath ?? s.localFilePath,
              isSensitive: s.isSensitive,
              importedAt: s.importedAt,
            );
          }(),
      ],
    );
  }

  static List<ActionItem> _due(List<ActionItem> all, DateTime at) => [
    for (final i in all)
      if (i.action.status == ActionStatus.suggested ||
          (i.action.status == ActionStatus.postponed &&
              !(i.action.postponedUntil?.isAfter(at) ?? false)))
        i,
  ];

  Stream<List<ActionItem>> _reevaluating(
    Stream<List<ActionItem>> source,
    DateTime Function() clock,
  ) {
    late final StreamController<List<ActionItem>> controller;
    StreamSubscription<List<ActionItem>>? subscription;
    Timer? timer;
    List<ActionItem>? latest;

    void emit() {
      timer?.cancel();
      timer = null;
      final all = latest;
      if (all == null || controller.isClosed) return;
      final at = clock();
      controller.add(sortForReview(_due(all, at), at));
      DateTime? next;
      for (final i in all) {
        final until = i.action.postponedUntil;
        if (i.action.status == ActionStatus.postponed &&
            until != null &&
            until.isAfter(at) &&
            (next == null || until.isBefore(next))) {
          next = until;
        }
      }
      if (next == null) return;
      var wait = next.difference(at) + const Duration(milliseconds: 10);
      if (wait > recheckInterval) wait = recheckInterval;
      timer = Timer(wait, emit);
    }

    controller = StreamController<List<ActionItem>>(
      onListen: () {
        subscription = source.listen(
          (rows) {
            latest = rows;
            emit();
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            unawaited(controller.close());
          },
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () async {
        timer?.cancel();
        timer = null;
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  /// Time-bound suggestions (reminders, calendar, travel) with an upcoming
  /// date come first, soonest first. Everything else follows, newest
  /// screenshot first.
  static List<ActionItem> sortForReview(List<ActionItem> items, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final keyed = [
      for (final (index, item) in items.indexed)
        (item: item, index: index, due: _dueDate(item, today)),
    ];
    keyed.sort((a, b) {
      final ad = a.due;
      final bd = b.due;
      if (ad != null && bd != null) {
        final c = ad.compareTo(bd);
        if (c != 0) return c;
      } else if (ad != null) {
        return -1;
      } else if (bd != null) {
        return 1;
      } else {
        final ai = a.item.importedAt;
        final bi = b.item.importedAt;
        if (ai != null && bi != null) {
          final c = bi.compareTo(ai);
          if (c != 0) return c;
        }
      }
      return a.index.compareTo(b.index);
    });
    return [for (final k in keyed) k.item];
  }

  /// The upcoming moment a time-bound action refers to, or null. Dates
  /// without a year sort by their next occurrence (for ordering only).
  static DateTime? _dueDate(ActionItem item, DateTime today) {
    if (!timeBoundActionTypes.contains(item.action.actionType)) return null;
    final iso = item.payload['date'];
    if (iso is! String) return null;
    final full = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    final partial = RegExp(r'^--(\d{2})-(\d{2})$').firstMatch(iso);
    DateTime? day;
    if (full != null) {
      day = DateTime(
        int.parse(full[1]!),
        int.parse(full[2]!),
        int.parse(full[3]!),
      );
    } else if (partial != null) {
      final m = int.parse(partial[1]!);
      final d = int.parse(partial[2]!);
      day = DateTime(today.year, m, d);
      if (day.isBefore(today)) day = DateTime(today.year + 1, m, d);
    }
    if (day == null || day.isBefore(today)) return null;
    final time = RegExp(r'^(\d{2}):(\d{2})$')
        .firstMatch(item.payload['time'] as String? ?? '');
    return time == null
        ? day
        : day.add(
            Duration(hours: int.parse(time[1]!), minutes: int.parse(time[2]!)),
          );
  }

  Stream<int> watchPendingCount() => watchPending().map((l) => l.length);

  Future<SuggestedActionRow?> byId(int id) => (_db.select(
    _db.suggestedActions,
  )..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<void> setStatus(
    int id,
    ActionStatus status, {
    DateTime? postponedUntil,
  }) => (_db.update(_db.suggestedActions)..where((a) => a.id.equals(id))).write(
    SuggestedActionsCompanion(
      status: Value(status),
      postponedUntil: Value(postponedUntil),
      updatedAt: Value(DateTime.now()),
    ),
  );

  Future<void> updatePayload(int id, Map<String, Object?> payload) =>
      (_db.update(_db.suggestedActions)..where((a) => a.id.equals(id))).write(
        SuggestedActionsCompanion(
          payloadJson: Value(jsonEncode(payload)),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Screenshots with a category or detected value the user should confirm.
  /// Values the user confirmed or rejected no longer count.
  Stream<List<int>> watchNeedingConfirmation() => _db
      .customSelect(
        'SELECT s.id FROM screenshots s WHERE s.is_archived = 0 AND s.processing_status = \'completed\' '
        'AND ((s.needs_category_confirmation = 1 AND s.category_locked = 0) '
        'OR EXISTS (SELECT 1 FROM extracted_entities e '
        "WHERE e.screenshot_id = s.id AND e.validation_status = 'needsConfirmation' "
        "AND e.entity_type IN ('date', 'deadline', 'amount'))) "
        'ORDER BY s.imported_at DESC LIMIT 50',
        readsFrom: {_db.screenshots, _db.extractedEntities},
      )
      .watch()
      .map((rows) => [for (final r in rows) r.read<int>('id')]);

  // ---------------------------------------------------------------------------
  // Confirming detected values
  //
  // Note: re-analysing a screenshot (edited text, "Process again") deletes and
  // re-creates its detected values, so earlier confirmations are lost then.

  /// Date and deadline rows created from the same date share one decision.
  Future<List<ExtractedEntityRow>> _withSiblings(ExtractedEntityRow e) async {
    if (e.entityType != EntityType.date &&
        e.entityType != EntityType.deadline) {
      return [e];
    }
    final value = e.normalizedValue;
    if (value == null) return [e];
    final rows =
        await (_db.select(_db.extractedEntities)..where(
              (x) =>
                  x.screenshotId.equals(e.screenshotId) &
                  x.entityType.isInValues(const [
                    EntityType.date,
                    EntityType.deadline,
                  ]) &
                  x.normalizedValue.equals(value),
            ))
            .get();
    return rows.isEmpty ? [e] : rows;
  }

  Future<void> _setValidation(Iterable<int> ids, ValidationStatus status) =>
      (_db.update(_db.extractedEntities)..where((x) => x.id.isIn(ids))).write(
        ExtractedEntitiesCompanion(validationStatus: Value(status)),
      );

  Future<List<SuggestedActionRow>> _openActions(int screenshotId) =>
      (_db.select(_db.suggestedActions)..where(
            (a) =>
                a.screenshotId.equals(screenshotId) &
                a.status.isInValues(const [
                  ActionStatus.suggested,
                  ActionStatus.postponed,
                ]),
          ))
          .get();

  Future<void> _writeAction(
    SuggestedActionRow a, {
    Map<String, Object?>? payload,
    String? title,
    ActionStatus? status,
  }) =>
      (_db.update(_db.suggestedActions)..where((x) => x.id.equals(a.id))).write(
        SuggestedActionsCompanion(
          payloadJson: payload == null
              ? const Value.absent()
              : Value(jsonEncode(payload)),
          title: title == null ? const Value.absent() : Value(title),
          status: status == null ? const Value.absent() : Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

  static String _stripConfirm(String title) => title.endsWith(' (confirm)')
      ? title.substring(0, title.length - ' (confirm)'.length)
      : title;

  /// Same short form the action generator uses in titles (`15 Mar 2026`,
  /// or `15 Mar` without a year).
  static String? describeIsoDate(String? iso) {
    if (iso == null) return null;
    final m = RegExp(r'^(?:(\d{4})|-)-(\d{2})-(\d{2})$').firstMatch(iso);
    if (m == null) return null;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = int.parse(m[2]!);
    if (month < 1 || month > 12) return null;
    final day = int.parse(m[3]!);
    return '$day ${months[month - 1]}${m[1] == null ? '' : ' ${m[1]}'}';
  }

  static bool _sameMoney(Map<String, Object?> p, Map<String, Object?> meta) =>
      p['minorUnits'] != null &&
      p['minorUnits'] == meta['minorUnits'] &&
      p['currency'] == meta['currency'];

  static Map<String, Object?> _meta(ExtractedEntityRow e) =>
      e.metadataJson == null ? const {} : decode(e.metadataJson!);

  /// The user says the detected value is right.
  Future<void> confirmEntity(ExtractedEntityRow e) =>
      _db.transaction(() => _confirm(e));

  Future<void> _confirm(ExtractedEntityRow e) async {
    final rows = await _withSiblings(e);
    await _setValidation(rows.map((r) => r.id), ValidationStatus.confirmed);
    final value = e.normalizedValue;
    final meta = _meta(e);
    for (final a in await _openActions(e.screenshotId)) {
      final p = decode(a.payloadJson);
      if (e.entityType == EntityType.amount &&
          _sameMoney(p, meta) &&
          p['currencyAmbiguous'] == true) {
        await _writeAction(a, payload: {...p, 'currencyAmbiguous': false});
      } else if (value != null &&
          p['date'] == value &&
          p['needsConfirmation'] == true &&
          !value.startsWith('--')) {
        // A year-less date stays flagged: the reminder editor still has to
        // ask for the year.
        await _writeAction(
          a,
          payload: {...p, 'needsConfirmation': false},
          title: _stripConfirm(a.title),
        );
      }
    }
  }

  /// The detected value is wrong: hide it and drop suggestions built on it.
  Future<void> rejectEntity(ExtractedEntityRow e) => _db.transaction(() async {
    final rows = await _withSiblings(e);
    await _setValidation(rows.map((r) => r.id), ValidationStatus.rejected);
    final value = e.normalizedValue ?? e.rawValue;
    final meta = _meta(e);
    for (final a in await _openActions(e.screenshotId)) {
      final p = decode(a.payloadJson);
      if (e.entityType == EntityType.amount) {
        if (!_sameMoney(p, meta)) continue;
        if (a.actionType == ActionType.saveTransaction) {
          await _writeAction(a, status: ActionStatus.dismissed);
        } else {
          await _writeAction(
            a,
            payload: {
              ...p,
              'minorUnits': null,
              'currency': null,
              'decimals': null,
              'currencyAmbiguous': false,
            },
          );
        }
        continue;
      }
      final primary = _primaryField[a.actionType];
      if (primary != null && p[primary] == value) {
        await _writeAction(a, status: ActionStatus.dismissed);
        continue;
      }
      final keys = [
        for (final entry in p.entries)
          if (entry.value == value) entry.key,
      ];
      if (keys.isNotEmpty) {
        await _writeAction(a, payload: {...p, for (final k in keys) k: null});
      }
    }
  });

  /// The user corrected the detected value. [normalized] replaces the old
  /// value everywhere it was used; [metadata] replaces the stored metadata
  /// when given.
  Future<void> correctEntity(
    ExtractedEntityRow e, {
    required String normalized,
    Map<String, Object?>? metadata,
  }) => _db.transaction(() async {
    final rows = await _withSiblings(e);
    final old = e.normalizedValue ?? e.rawValue;
    for (final r in rows) {
      Map<String, Object?>? meta;
      if (metadata != null) {
        meta = r.id == e.id ? {...metadata} : {..._meta(r), ...metadata};
        if (r.entityType == EntityType.deadline) meta['date'] = normalized;
      }
      await (_db.update(
        _db.extractedEntities,
      )..where((x) => x.id.equals(r.id))).write(
        ExtractedEntitiesCompanion(
          normalizedValue: Value(normalized),
          metadataJson: meta == null
              ? const Value.absent()
              : Value(jsonEncode(meta)),
          validationStatus: const Value(ValidationStatus.confirmed),
        ),
      );
    }
    final oldMeta = _meta(e);
    for (final a in await _openActions(e.screenshotId)) {
      final p = decode(a.payloadJson);
      var title = a.title;
      Map<String, Object?>? next;
      if (e.entityType == EntityType.amount) {
        if (!_sameMoney(p, oldMeta) || metadata == null) continue;
        next = {
          ...p,
          'minorUnits': metadata['minorUnits'],
          'currency': metadata['currency'],
          'decimals': metadata['decimals'],
          'currencyAmbiguous': false,
        };
      } else {
        final keys = [
          for (final entry in p.entries)
            if (entry.value == old) entry.key,
        ];
        if (keys.isEmpty) continue;
        next = {...p, for (final k in keys) k: normalized};
        if (next['needsConfirmation'] == true && !normalized.startsWith('--')) {
          next['needsConfirmation'] = false;
        }
      }
      final shownOld = describeIsoDate(old);
      final shownNew = describeIsoDate(normalized);
      if (shownOld != null && shownNew != null) {
        title = title.replaceAll(shownOld, shownNew);
      }
      title = _stripConfirm(title);
      if (old.isNotEmpty && title.contains(old)) {
        title = title.replaceAll(old, normalized);
      }
      await _writeAction(a, payload: next, title: title);
    }
  });

  /// "Mark all as checked": accepts every uncertain date, deadline, amount
  /// and suggested category on [screenshotIds] as it is.
  Future<void> confirmAll(Iterable<int> screenshotIds) async {
    final ids = screenshotIds.toList();
    if (ids.isEmpty) return;
    final rows =
        await (_db.select(_db.extractedEntities)..where(
              (x) =>
                  x.screenshotId.isIn(ids) &
                  x.validationStatus.equalsValue(
                    ValidationStatus.needsConfirmation,
                  ) &
                  x.entityType.isInValues(confirmableEntityTypes),
            ))
            .get();
    await _db.transaction(() async {
      for (final r in rows) {
        await _confirm(r);
      }
      await (_db.update(_db.screenshots)..where(
            (s) => s.id.isIn(ids) & s.needsCategoryConfirmation.equals(true),
          ))
          .write(
            ScreenshotsCompanion(
              needsCategoryConfirmation: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );
    });
  }
}

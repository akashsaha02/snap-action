import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/constants/action_meta.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../services/entity_extraction/entity_models.dart';
import '../../../services/entity_extraction/money_parser.dart';
import '../../actions/application/action_executor.dart';
import '../../actions/application/action_repository.dart';
import '../../actions/application/external_intents.dart';

/// Detected details of one screenshot. Links, phone numbers, email
/// addresses and addresses can be tapped; uncertain values can be confirmed,
/// corrected or removed.
class EntityList extends ConsumerStatefulWidget {
  const EntityList({required this.entities, required this.actions, super.key});

  final List<ExtractedEntityRow> entities;
  final List<SuggestedActionRow> actions;

  /// How many rows are shown before "Show all".
  static const collapsedCount = 24;

  static Map<String, Object?> _meta(ExtractedEntityRow e) =>
      e.metadataJson == null
      ? const <String, Object?>{}
      : ActionRepository.decode(e.metadataJson!);

  static String display(ExtractedEntityRow e) {
    final meta = _meta(e);
    return switch (e.entityType) {
      EntityType.date || EntityType.deadline => [
        Formatters.isoDate(e.normalizedValue),
        if (meta['time'] case final String t) t,
      ].join(', '),
      EntityType.amount => switch ((
        meta['minorUnits'],
        meta['currency'],
        meta['decimals'],
      )) {
        (final int minor, final String cur, final int dec) => Formatters.money(
          minor,
          cur,
          decimals: dec,
        ),
        _ => e.normalizedValue ?? e.rawValue,
      },
      EntityType.wifiCredentials =>
        'Network: ${meta['ssid'] ?? e.normalizedValue}',
      EntityType.codeSnippet =>
        '${e.rawValue.split('\n').length} lines of code',
      _ => e.normalizedValue ?? e.rawValue,
    };
  }

  static String copyValue(ExtractedEntityRow e) =>
      e.normalizedValue ?? e.rawValue;

  /// Rows worth showing: rejected values are hidden, a lone time is dropped
  /// when a date already carries it, and a date that is also a deadline is
  /// shown once, as the deadline.
  static List<ExtractedEntityRow> visible(List<ExtractedEntityRow> all) {
    final shown = [
      for (final e in all)
        if (e.validationStatus != ValidationStatus.rejected) e,
    ];
    final deadlines = {
      for (final d in shown)
        if (d.entityType == EntityType.deadline) d.normalizedValue,
    };
    return shown
        .where(
          (e) =>
              (e.entityType != EntityType.time ||
                  shown.every((d) => d.entityType != EntityType.date)) &&
              !(e.entityType == EntityType.date &&
                  deadlines.contains(e.normalizedValue)),
        )
        .toList();
  }

  @override
  ConsumerState<EntityList> createState() => _EntityListState();
}

/// Suggested action type and payload field that open each tappable type.
const _openable = <EntityType, (ActionType, String)>{
  EntityType.url: (ActionType.openUrl, 'url'),
  EntityType.phone: (ActionType.callPhone, 'phone'),
  EntityType.email: (ActionType.sendEmail, 'email'),
  EntityType.address: (ActionType.openMap, 'address'),
};

class _EntityListState extends ConsumerState<EntityList> {
  bool _expanded = false;

  ActionRepository get _repo => ref.read(actionRepositoryProvider);

  Future<void> _open(ExtractedEntityRow e) async {
    final (type, field) = _openable[e.entityType]!;
    final value = EntityList.copyValue(e);
    // Prefer the matching suggestion so it is marked as done afterwards.
    final match = widget.actions
        .where(
          (a) =>
              a.actionType == type &&
              ActionRepository.decode(a.payloadJson)[field] == value,
        )
        .firstOrNull;
    if (match != null) {
      await ActionExecutor.run(context, ref, match);
      return;
    }
    final (uri, title, message, label, invalid) = switch (e.entityType) {
      EntityType.url => (
        ExternalIntents.web(value),
        'Open link?',
        'Check the address before you open it:\n\n$value',
        'Open',
        'This link is not a valid web address.',
      ),
      EntityType.phone => (
        ExternalIntents.dial(value),
        'Open dialer?',
        '$value\n\nThe number is filled in for you. Nothing is called until you press call.',
        'Open dialer',
        'This phone number does not look valid.',
      ),
      EntityType.email => (
        ExternalIntents.email(value),
        'Write an email?',
        '$value\n\nYour email app opens with a new draft. Nothing is sent automatically.',
        'Open email app',
        'This email address does not look valid.',
      ),
      _ => (
        ExternalIntents.map(value),
        'Show on map?',
        '$value\n\nThe address was read from the screenshot and may be incomplete.',
        'Open maps',
        'This address cannot be shown on a map.',
      ),
    };
    if (uri == null) {
      context.showSnack(invalid, error: true);
      return;
    }
    final ok = await showConfirmationDialog(
      context,
      title: title,
      message: message,
      confirmLabel: label,
    );
    if (!ok) return;
    final opened = await ExternalIntents.open(uri);
    if (!opened && mounted) {
      context.showSnack('No app on this device can open this.', error: true);
    }
  }

  Future<void> _confirm(ExtractedEntityRow e) async {
    await _repo.confirmEntity(e);
    if (mounted) context.showSnack('${e.entityType.label} confirmed');
  }

  Future<void> _reject(ExtractedEntityRow e) async {
    await _repo.rejectEntity(e);
    if (mounted) context.showSnack('${e.entityType.label} removed');
  }

  Future<void> _edit(ExtractedEntityRow e) async {
    final meta = Map<String, Object?>.of(EntityList._meta(e));
    switch (e.entityType) {
      case EntityType.date || EntityType.deadline:
        final current = PartialDate.parseIso(e.normalizedValue);
        final now = DateTime.now();
        var initial = current == null
            ? now
            : DateTime(current.year ?? now.year, current.month, current.day);
        final first = DateTime(1970);
        final last = DateTime(2100, 12, 31);
        if (initial.isBefore(first) || initial.isAfter(last)) initial = now;
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: first,
          lastDate: last,
          helpText: 'Correct the ${e.entityType.label.toLowerCase()}',
        );
        if (picked == null) return;
        final iso = PartialDate(
          year: picked.year,
          month: picked.month,
          day: picked.day,
        ).iso;
        meta
          ..remove('alternative')
          ..['yearMissing'] = false
          ..['ambiguous'] = false;
        await _repo.correctEntity(e, normalized: iso, metadata: meta);
      case EntityType.amount:
        final amount = await showDialog<MoneyAmount>(
          context: context,
          builder: (_) => _AmountDialog(
            minorUnits: (meta['minorUnits'] as num?)?.toInt(),
            currency: meta['currency'] as String?,
            decimals: (meta['decimals'] as num?)?.toInt() ?? 2,
          ),
        );
        if (amount == null) return;
        meta
          ..remove('currencyAmbiguous')
          ..['minorUnits'] = amount.minorUnits
          ..['currency'] = amount.currency
          ..['decimals'] = amount.decimals;
        await _repo.correctEntity(
          e,
          normalized: amount.formatted,
          metadata: meta,
        );
      default:
        final value = await showTextInputDialog(
          context,
          title: 'Correct ${e.entityType.label.toLowerCase()}',
          initialValue: EntityList.copyValue(e),
          maxLines: e.entityType == EntityType.address ? 3 : 1,
          maxLength: 300,
        );
        if (value == null || value.isEmpty) return;
        await _repo.correctEntity(e, normalized: value);
    }
    if (mounted) context.showSnack('${e.entityType.label} updated');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final all = EntityList.visible(widget.entities);
    final truncated = !_expanded && all.length > EntityList.collapsedCount;
    final shown = truncated
        ? all.take(EntityList.collapsedCount).toList()
        : all;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (final e in shown) ...[
            ListTile(
              key: ValueKey('entity_${e.id}'),
              leading: Icon(e.entityType.icon),
              onTap: _openable.containsKey(e.entityType)
                  ? () => _open(e)
                  : null,
              title: Text(
                EntityList.display(e),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _openable.containsKey(e.entityType)
                    ? TextStyle(color: theme.colorScheme.primary)
                    : null,
              ),
              subtitle: Row(
                children: [
                  Flexible(
                    child: Text(
                      e.entityType.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (e.validationStatus ==
                      ValidationStatus.needsConfirmation) ...[
                    const Gap(Spacing.xs),
                    Icon(Icons.help_outline, size: 14, color: status.onWarning),
                    const SizedBox(width: 2),
                    Text(
                      'Please check',
                      style: TextStyle(color: status.onWarning),
                    ),
                  ],
                ],
              ),
              trailing: e.entityType == EntityType.wifiCredentials
                  ? null
                  : IconButton(
                      tooltip: 'Copy ${e.entityType.label.toLowerCase()}',
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: EntityList.copyValue(e)),
                        );
                        if (context.mounted) {
                          context.showSnack('${e.entityType.label} copied');
                        }
                      },
                    ),
            ),
            if (e.validationStatus == ValidationStatus.needsConfirmation)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  56,
                  0,
                  Spacing.xs,
                  Spacing.xs,
                ),
                child: Wrap(
                  spacing: Spacing.xs,
                  children: [
                    FilledButton.tonal(
                      key: ValueKey('confirm_entity_${e.id}'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _confirm(e),
                      child: const Text('Looks right'),
                    ),
                    TextButton(
                      key: ValueKey('edit_entity_${e.id}'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _edit(e),
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      key: ValueKey('reject_entity_${e.id}'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _reject(e),
                      child: const Text('Not correct'),
                    ),
                  ],
                ),
              ),
          ],
          if (truncated)
            TextButton(
              key: const Key('entities_show_all'),
              onPressed: () => setState(() => _expanded = true),
              child: Text('Show all ${all.length}'),
            ),
        ],
      ),
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.minorUnits,
    required this.currency,
    required this.decimals,
  });

  final int? minorUnits;
  final String? currency;
  final int decimals;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final _amount = TextEditingController(
    text: widget.minorUnits == null
        ? ''
        : MoneyParser.formatUserAmount(
            widget.minorUnits!,
            decimals: widget.decimals,
          ),
  );
  late final _currency = TextEditingController(text: widget.currency ?? '');
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _currency.dispose();
    super.dispose();
  }

  void _save() {
    final currency = _currency.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      setState(() => _error = 'Enter a three-letter currency code, e.g. EUR.');
      return;
    }
    final decimals = MoneyParser.decimalsFor(currency);
    final minor = MoneyParser.parseUserAmount(_amount.text, decimals: decimals);
    if (minor == null) {
      setState(() => _error = 'Enter an amount such as 12.50.');
      return;
    }
    Navigator.of(context).pop(
      MoneyAmount(minorUnits: minor, currency: currency, decimals: decimals),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Correct amount'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('amount_value'),
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          TextField(
            key: const Key('amount_currency'),
            controller: _currency,
            textCapitalization: TextCapitalization.characters,
            maxLength: 3,
            decoration: const InputDecoration(labelText: 'Currency'),
            onSubmitted: (_) => _save(),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

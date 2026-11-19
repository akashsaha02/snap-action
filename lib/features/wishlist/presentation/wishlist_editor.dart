import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../services/entity_extraction/money_parser.dart';
import '../../actions/application/external_intents.dart';
import '../application/wishlist_repository.dart';

/// Opens the wishlist form. [payload] is an `addToWishlist` action payload.
Future<int?> showWishlistEditor(
  BuildContext context, {
  WishlistItemRow? existing,
  Map<String, Object?>? payload,
  int? screenshotId,
}) {
  return showAppBottomSheet<int>(
    context,
    title: existing == null ? 'Add to wishlist' : 'Edit wishlist item',
    builder: (_) => _WishlistEditor(
      existing: existing,
      payload: payload,
      screenshotId: screenshotId,
    ),
  );
}

class _WishlistEditor extends ConsumerStatefulWidget {
  const _WishlistEditor({this.existing, this.payload, this.screenshotId});

  final WishlistItemRow? existing;
  final Map<String, Object?>? payload;
  final int? screenshotId;

  @override
  ConsumerState<_WishlistEditor> createState() => _WishlistEditorState();
}

class _WishlistEditorState extends ConsumerState<_WishlistEditor> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _currency;
  late final TextEditingController _merchant;
  late final TextEditingController _url;
  late final TextEditingController _notes;
  String? _error;
  bool _currencyAmbiguous = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final p = widget.payload ?? const {};
    final currency = e?.currency ?? p['currency'] as String?;
    final minor = e?.amountMinorUnits ?? (p['minorUnits'] as num?)?.toInt();
    final decimals =
        (p['decimals'] as num?)?.toInt() ?? MoneyParser.decimalsFor(currency);
    _currencyAmbiguous = e == null && p['currencyAmbiguous'] == true;
    _name = TextEditingController(
      text: e?.productName ?? p['productName'] as String? ?? '',
    );
    _price = TextEditingController(
      text: minor == null
          ? ''
          : MoneyParser.formatUserAmount(minor, decimals: decimals),
    );
    _currency = TextEditingController(text: currency ?? '');
    _merchant = TextEditingController(text: e?.merchantName ?? '');
    _url = TextEditingController(
      text: e?.productUrl ?? p['productUrl'] as String? ?? '',
    );
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _price, _currency, _merchant, _url, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final currency = _currency.text.trim().toUpperCase();
    int? minor;
    if (_price.text.trim().isNotEmpty) {
      minor = MoneyParser.parseUserAmount(
        _price.text,
        decimals: MoneyParser.decimalsFor(currency),
      );
      if (minor == null) {
        setState(
          () => _error = 'Enter the price as a number, for example 49.99.',
        );
        return;
      }
      if (!RegExp(r'^[A-Z]{2,3}$').hasMatch(currency)) {
        setState(() => _error = 'Enter a currency code such as EUR or USD.');
        return;
      }
    }
    final url = _url.text.trim();
    if (url.isNotEmpty && ExternalIntents.web(url) == null) {
      setState(() => _error = 'The link must start with http:// or https://.');
      return;
    }
    final draft = WishlistDraft(
      productName: _name.text,
      minorUnits: minor,
      currency: minor == null ? null : currency,
      merchantName: _merchant.text,
      productUrl: url,
      notes: _notes.text,
      screenshotId: widget.existing?.screenshotId ?? widget.screenshotId,
    );
    final repo = ref.read(wishlistRepositoryProvider);
    try {
      final int id;
      if (widget.existing case final existing?) {
        await repo.update(existing.id, draft);
        id = existing.id;
      } else {
        id = await repo.add(draft);
      }
      if (mounted) Navigator.of(context).pop(id);
    } on ArgumentError catch (e) {
      setState(() => _error = '${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('wishlist_name'),
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Product'),
          ),
          const Gap(Spacing.sm),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  key: const Key('wishlist_price'),
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Price (optional)',
                  ),
                ),
              ),
              const Gap(Spacing.sm),
              Expanded(
                child: TextField(
                  controller: _currency,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() => _currencyAmbiguous = false),
                ),
              ),
            ],
          ),
          if (_currencyAmbiguous)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: context.statusColors.onWarning,
                  ),
                  const Gap(Spacing.xxs),
                  Expanded(
                    child: Text(
                      'The currency was guessed from a symbol such as \$. Please check it.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.statusColors.onWarning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Gap(Spacing.sm),
          TextField(
            controller: _merchant,
            decoration: const InputDecoration(labelText: 'Shop (optional)'),
          ),
          const Gap(Spacing.sm),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'Link (optional)'),
          ),
          const Gap(Spacing.sm),
          TextField(
            controller: _notes,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          const Gap(Spacing.md),
          FilledButton(
            key: const Key('wishlist_save'),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

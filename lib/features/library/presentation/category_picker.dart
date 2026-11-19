import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/models/screenshot_summary.dart';
import '../../../core/theme/category_icons.dart';
import '../../../core/widgets/dialogs.dart';

/// Lets the user choose a category. Returns the chosen category id.
Future<int?> showCategoryPicker(
  BuildContext context, {
  int? selectedId,
  int? suggestedId,
}) {
  return showAppBottomSheet<int>(
    context,
    title: 'Choose category',
    builder: (context) =>
        _CategoryList(selectedId: selectedId, suggestedId: suggestedId),
  );
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({this.selectedId, this.suggestedId});

  final int? selectedId;
  final int? suggestedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final sorted = [
      ...categories.where((c) => c.id == suggestedId),
      ...categories.where((c) => c.id != suggestedId),
    ];
    return ListView(
      shrinkWrap: true,
      children: [
        for (final CategoryInfo c in sorted)
          ListTile(
            leading: Icon(CategoryIcons.of(c.icon), color: Color(c.color)),
            title: Text(c.name),
            subtitle: c.id == suggestedId ? const Text('Suggested') : null,
            trailing: c.id == selectedId ? const Icon(Icons.check) : null,
            selected: c.id == selectedId,
            onTap: () => Navigator.of(context).pop(c.id),
          ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/repositories/organization_repository.dart';
import '../../../core/theme/category_icons.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/dialogs.dart';

class CollectionDraft {
  const CollectionDraft({
    required this.name,
    this.description,
    this.icon = 'folder',
    this.color = 0xFF635BFF,
  });

  final String name;
  final String? description;
  final String icon;
  final int color;
}

/// Create or edit a collection. Returns the saved collection id.
Future<int?> showCollectionEditor(
  BuildContext context,
  WidgetRef ref, {
  CollectionRow? existing,
}) async {
  final draft = await showDialog<CollectionDraft>(
    context: context,
    builder: (_) => _CollectionEditor(existing: existing),
  );
  if (draft == null) return null;
  final repo = ref.read(organizationRepositoryProvider);
  try {
    if (existing == null) {
      return await repo.createCollection(
        name: draft.name,
        description: draft.description,
        icon: draft.icon,
        color: draft.color,
      );
    }
    await repo.updateCollection(
      existing.id,
      name: draft.name,
      description: draft.description,
      icon: draft.icon,
      color: draft.color,
    );
    return existing.id;
  } on DuplicateNameException catch (e) {
    if (context.mounted) {
      context.showSnack(
        'A collection named "${e.name}" already exists.',
        error: true,
      );
    }
  } on ArgumentError catch (e) {
    if (context.mounted) context.showSnack('${e.message}', error: true);
  }
  return null;
}

class _CollectionEditor extends StatefulWidget {
  const _CollectionEditor({this.existing});

  final CollectionRow? existing;

  @override
  State<_CollectionEditor> createState() => _CollectionEditorState();
}

class _CollectionEditorState extends State<_CollectionEditor> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  late String _icon = widget.existing?.icon ?? 'folder';
  late int _color = widget.existing?.color ?? CategoryIcons.palette.first;
  String? _error;

  static const _icons = [
    'folder',
    'bookmark',
    'star',
    'favorite',
    'lightbulb',
    'home',
    'work',
    'school',
    'flight',
    'shopping',
    'health',
    'music',
  ];

  /// Spoken names for [CategoryIcons.palette], in the same order.
  static const _colorNames = [
    'Indigo',
    'Teal',
    'Pink',
    'Orange',
    'Green',
    'Sky blue',
    'Yellow',
    'Red',
    'Violet',
    'Slate',
  ];

  static String _iconLabel(String key) => switch (key) {
    'lightbulb' => 'Idea',
    'favorite' => 'Heart',
    _ => '${key[0].toUpperCase()}${key.substring(1)}',
  };

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a name.');
      return;
    }
    Navigator.of(context).pop(
      CollectionDraft(
        name: name,
        description: _description.text,
        icon: _icon,
        color: _color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'New collection' : 'Edit collection',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('collection_name'),
              controller: _name,
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: 'Name', errorText: _error),
              onSubmitted: (_) => _save(),
            ),
            TextField(
              controller: _description,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
            const Gap(Spacing.sm),
            Text('Icon', style: Theme.of(context).textTheme.labelLarge),
            Wrap(
              children: [
                for (final i in _icons)
                  IconButton(
                    tooltip: _iconLabel(i),
                    isSelected: _icon == i,
                    icon: Icon(CategoryIcons.of(i)),
                    color: _icon == i ? Color(_color) : null,
                    onPressed: () => setState(() => _icon = i),
                  ),
              ],
            ),
            Text('Colour', style: Theme.of(context).textTheme.labelLarge),
            const Gap(Spacing.xs),
            Wrap(
              children: [
                for (final (index, c) in CategoryIcons.palette.indexed)
                  Semantics(
                    button: true,
                    selected: c == _color,
                    label: index < _colorNames.length
                        ? _colorNames[index]
                        : 'Colour ${index + 1}',
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => setState(() => _color = c),
                      customBorder: const CircleBorder(),
                      // 48 dp touch target around a 32 dp swatch.
                      child: SizedBox.square(
                        dimension: Spacing.minTouchTarget,
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: c == _color
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      width: 3,
                                    )
                                  : null,
                            ),
                            // A check mark so the choice does not rely on
                            // the border alone.
                            child: c == _color
                                ? const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 3,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
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

/// Picks a collection, offering to create one. Returns its id.
Future<int?> showCollectionPicker(BuildContext context, WidgetRef ref) {
  return showAppBottomSheet<int>(
    context,
    title: 'Add to collection',
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final collections = ref.watch(collectionsProvider).value ?? const [];
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New collection'),
              onTap: () async {
                final id = await showCollectionEditor(context, ref);
                if (id != null && sheetContext.mounted) {
                  Navigator.of(sheetContext).pop(id);
                }
              },
            ),
            for (final c in collections)
              ListTile(
                leading: Icon(
                  CategoryIcons.of(c.collection.icon),
                  color: Color(c.collection.color),
                ),
                title: Text(c.collection.name),
                trailing: Text('${c.count}'),
                onTap: () => Navigator.of(sheetContext).pop(c.collection.id),
              ),
          ],
        );
      },
    ),
  );
}

/// Asks for a tag name, suggesting existing tags.
Future<String?> showTagInput(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _TagDialog(),
  );
}

class _TagDialog extends ConsumerStatefulWidget {
  const _TagDialog();

  @override
  ConsumerState<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends ConsumerState<_TagDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider).value ?? const [];
    final typed = OrganizationRepository.normalizeTag(_controller.text);
    final matches = tags
        .where((t) => typed.isEmpty || t.tag.name.contains(typed))
        .take(8);
    return AlertDialog(
      title: const Text('Add tag'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('tag_input'),
            controller: _controller,
            autofocus: true,
            maxLength: 40,
            decoration: const InputDecoration(
              hintText: 'e.g. thesis',
              prefixText: '#',
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
          Wrap(
            spacing: Spacing.xs,
            children: [
              for (final t in matches)
                ActionChip(
                  label: Text('#${t.tag.name}'),
                  onPressed: () => Navigator.of(context).pop(t.tag.name),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

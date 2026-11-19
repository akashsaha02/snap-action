import 'package:material_ui/material_ui.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/widgets/dialogs.dart';

/// Opens a full-screen editor for the recognized text. Returns the edited
/// text, or null when the user leaves without saving.
Future<String?> showTextEditorPage(
  BuildContext context, {
  required String initialText,
  String title = 'Edit text',
  String? note,
}) => Navigator.of(context).push<String>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) =>
        TextEditorPage(initialText: initialText, title: title, note: note),
  ),
);

class TextEditorPage extends StatefulWidget {
  const TextEditorPage({
    required this.initialText,
    this.title = 'Edit text',
    this.note,
    super.key,
  });

  final String initialText;
  final String title;
  final String? note;

  @override
  State<TextEditorPage> createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  late final _controller = TextEditingController(text: widget.initialText);
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final dirty = _controller.text != widget.initialText;
      if (dirty != _dirty) setState(() => _dirty = dirty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final discard = await showConfirmationDialog(
      context,
      title: 'Discard changes?',
      message: 'Your edits to the text will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      destructive: true,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope<String>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          title: Text(widget.title),
          actions: [
            TextButton(
              key: const Key('text_editor_save'),
              onPressed: _dirty
                  ? () => Navigator.of(context).pop(_controller.text)
                  : null,
              child: const Text('Save'),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.xs,
              Spacing.md,
              Spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.note != null) ...[
                  Text(widget.note!, style: theme.textTheme.bodySmall),
                  const Gap(Spacing.xs),
                ],
                Expanded(
                  child: TextField(
                    key: const Key('text_editor_field'),
                    controller: _controller,
                    autofocus: true,
                    expands: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Text in this screenshot',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../theme/spacing.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
  String? hint,
  String confirmLabel = 'Save',
  int maxLines = 1,
  int? maxLength,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextInputDialog(
      title: title,
      initialValue: initialValue,
      hint: hint,
      confirmLabel: confirmLabel,
      maxLines: maxLines,
      maxLength: maxLength,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.confirmLabel,
    required this.maxLines,
    this.initialValue,
    this.hint,
    this.maxLength,
  });

  final String title;
  final String? initialValue;
  final String? hint;
  final String confirmLabel;
  final int maxLines;
  final int? maxLength;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: widget.maxLines == 1
            ? (v) => Navigator.of(context).pop(v.trim())
            : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Modal bottom sheet with consistent padding and safe-area handling.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  bool scrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: Spacing.md,
        right: Spacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Gap(Spacing.md),
          ],
          Flexible(child: builder(context)),
        ],
      ),
    ),
  );
}

extension SnackbarX on BuildContext {
  void showSnack(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    bool error = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;
    final scheme = Theme.of(this).colorScheme;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? scheme.error : null,
          action: actionLabel != null && onAction != null
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }
}

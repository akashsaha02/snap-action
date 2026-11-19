import 'dart:io';

import 'package:material_ui/material_ui.dart';

/// Full-screen, zoomable view of the stored original.
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({required this.path, required this.title, super.key});

  final String path;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Semantics(
        image: true,
        label: 'Screenshot: $title. Pinch to zoom.',
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          child: Center(
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Text(
                'The image could not be shown.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

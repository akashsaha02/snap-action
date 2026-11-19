import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final inter = await rootBundle.loadString('assets/fonts/Inter-OFL.txt');
    yield LicenseEntryWithLineBreaks(['Inter font'], inter);
    final grotesk = await rootBundle.loadString(
      'assets/fonts/SpaceGrotesk-OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['Space Grotesk font'], grotesk);
  });
  runApp(
    ProviderScope(
      // Startup failures are shown on the splash screen with a manual retry.
      retry: (_, _) => null,
      child: const SnaptiqApp(),
    ),
  );
}

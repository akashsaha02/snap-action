import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/core/widgets/screenshot_card.dart';

import '../helpers/test_app.dart';

Future<int> _seedScreenshot(
  AppDatabase db,
  String title, {
  bool sensitive = false,
}) => db
    .into(db.screenshots)
    .insert(
      ScreenshotsCompanion.insert(
        localFilePath: '/missing/$title.png',
        contentHash: 'hash-$title',
        title: Value(title),
        importedAt: DateTime(2026, 5, 1),
        source: ScreenshotSource.picker,
        processingStatus: ProcessingStatus.completed,
        fileSize: 1,
        isSensitive: Value(sensitive),
      ),
    );

Future<void> _openActionCenter(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('action_center_card')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('"Mark all as checked" clears the confirmation strip', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      seed: (db) async {
        final shot = await _seedScreenshot(db, 'Receipt');
        await db
            .into(db.extractedEntities)
            .insert(
              ExtractedEntitiesCompanion.insert(
                screenshotId: shot,
                entityType: EntityType.amount,
                rawValue: r'$12',
                normalizedValue: const Value('USD 12.00'),
                validationStatus: ValidationStatus.needsConfirmation,
              ),
            );
      },
    );
    await _openActionCenter(tester);
    expect(find.text('Needs your confirmation (1)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm_all')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as checked'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Needs your confirmation'), findsNothing);
    expect(find.text('All caught up'), findsOneWidget);
  });

  testWidgets(
    'suggestions are grouped per screenshot without repeating its title',
    (tester) async {
      await pumpTestApp(
        tester,
        settings: {SettingsKeys.hideSensitivePreviews: 'false'},
        seed: (db) async {
          final shot = await _seedScreenshot(
            db,
            'Wireless Headphones Pro',
            sensitive: true,
          );
          for (final (type, title, payload) in [
            (
              ActionType.addToWishlist,
              'Add to wishlist',
              {'productName': 'Wireless Headphones Pro'},
            ),
            (
              ActionType.openUrl,
              'Open shop.example.com',
              {'url': 'https://shop.example.com'},
            ),
          ]) {
            await db
                .into(db.suggestedActions)
                .insert(
                  SuggestedActionsCompanion.insert(
                    screenshotId: shot,
                    actionType: type,
                    title: title,
                    payloadJson: jsonEncode(payload),
                    status: ActionStatus.suggested,
                  ),
                );
          }
        },
      );
      await _openActionCenter(tester);

      expect(find.text('Wireless Headphones Pro'), findsOneWidget);
      expect(find.text('2 suggestions'), findsOneWidget);
      expect(find.textContaining('From:'), findsNothing);
      // Blurring follows the "Blur sensitive previews" setting.
      final thumb = tester.widget<ScreenshotThumbnail>(
        find.byType(ScreenshotThumbnail).first,
      );
      expect(thumb.blur, isFalse);
    },
  );
}

import 'package:material_ui/material_ui.dart';

import '../database/enums.dart';

extension ActionTypeMeta on ActionType {
  IconData get icon => switch (this) {
    ActionType.createReminder => Icons.alarm_add_outlined,
    ActionType.addCalendarEvent => Icons.event_available_outlined,
    ActionType.addToWishlist => Icons.favorite_border,
    ActionType.openUrl => Icons.open_in_new,
    ActionType.callPhone => Icons.call_outlined,
    ActionType.saveContact => Icons.person_add_alt_outlined,
    ActionType.sendEmail => Icons.mail_outline,
    ActionType.openMap => Icons.map_outlined,
    ActionType.saveTransaction => Icons.receipt_long_outlined,
    ActionType.saveTravel => Icons.luggage_outlined,
    ActionType.saveNotes => Icons.sticky_note_2_outlined,
    ActionType.copyWifi => Icons.wifi,
    ActionType.copyCode => Icons.code,
  };

  String get label => switch (this) {
    ActionType.createReminder => 'Create reminder',
    ActionType.addCalendarEvent => 'Add to calendar',
    ActionType.addToWishlist => 'Add to wishlist',
    ActionType.openUrl => 'Open website',
    ActionType.callPhone => 'Call',
    ActionType.saveContact => 'Save contact',
    ActionType.sendEmail => 'Send email',
    ActionType.openMap => 'Open in maps',
    ActionType.saveTransaction => 'Save transaction',
    ActionType.saveTravel => 'Save travel item',
    ActionType.saveNotes => 'Save as notes',
    ActionType.copyWifi => 'Connect to Wi-Fi',
    ActionType.copyCode => 'Copy code',
  };

  /// Actions that leave the app and therefore need explicit confirmation.
  bool get isExternal => switch (this) {
    ActionType.addCalendarEvent ||
    ActionType.openUrl ||
    ActionType.callPhone ||
    ActionType.saveContact ||
    ActionType.sendEmail ||
    ActionType.openMap => true,
    _ => false,
  };
}

extension EntityTypeMeta on EntityType {
  IconData get icon => switch (this) {
    EntityType.email => Icons.alternate_email,
    EntityType.phone => Icons.call_outlined,
    EntityType.url => Icons.link,
    EntityType.date => Icons.calendar_today_outlined,
    EntityType.time => Icons.schedule,
    EntityType.amount => Icons.payments_outlined,
    EntityType.deadline => Icons.flag_outlined,
    EntityType.flightReference => Icons.flight,
    EntityType.orderReference => Icons.confirmation_number_outlined,
    EntityType.address => Icons.place_outlined,
    EntityType.productName => Icons.shopping_bag_outlined,
    EntityType.eventTitle => Icons.celebration_outlined,
    EntityType.wifiCredentials => Icons.wifi,
    EntityType.codeSnippet => Icons.code,
  };

  String get label => switch (this) {
    EntityType.email => 'Email',
    EntityType.phone => 'Phone',
    EntityType.url => 'Link',
    EntityType.date => 'Date',
    EntityType.time => 'Time',
    EntityType.amount => 'Amount',
    EntityType.deadline => 'Deadline',
    EntityType.flightReference => 'Flight',
    EntityType.orderReference => 'Order reference',
    EntityType.address => 'Address',
    EntityType.productName => 'Product',
    EntityType.eventTitle => 'Event',
    EntityType.wifiCredentials => 'Wi-Fi',
    EntityType.codeSnippet => 'Code',
  };
}

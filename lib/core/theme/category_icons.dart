import 'package:material_ui/material_ui.dart';

/// Icons are referenced by key in the database so they survive app updates
/// and stay tree-shakable.
abstract final class CategoryIcons {
  static const Map<String, IconData> all = {
    'shopping': Icons.shopping_bag_outlined,
    'event': Icons.event_outlined,
    'flight': Icons.flight_takeoff_outlined,
    'restaurant': Icons.restaurant_outlined,
    'receipt': Icons.receipt_long_outlined,
    'school': Icons.school_outlined,
    'work': Icons.work_outline,
    'description': Icons.description_outlined,
    'social': Icons.public_outlined,
    'chat': Icons.chat_bubble_outline,
    'place': Icons.place_outlined,
    'quote': Icons.format_quote_outlined,
    'code': Icons.code,
    'person': Icons.person_outline,
    'category': Icons.category_outlined,
    'star': Icons.star_outline,
    'favorite': Icons.favorite_outline,
    'bookmark': Icons.bookmark_outline,
    'folder': Icons.folder_outlined,
    'lightbulb': Icons.lightbulb_outline,
    'home': Icons.home_outlined,
    'health': Icons.health_and_safety_outlined,
    'music': Icons.music_note_outlined,
    'photo': Icons.photo_outlined,
  };

  static IconData of(String key) => all[key] ?? Icons.category_outlined;

  static const List<int> palette = [
    0xFF635BFF,
    0xFF14B8A6,
    0xFFEC4899,
    0xFFF97316,
    0xFF22C55E,
    0xFF0EA5E9,
    0xFFEAB308,
    0xFFEF4444,
    0xFF8B5CF6,
    0xFF64748B,
  ];
}

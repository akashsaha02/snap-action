class SystemCategory {
  const SystemCategory({
    required this.slug,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String slug;
  final String name;

  /// Key into [CategoryIcons].
  final String icon;
  final int color;
}

abstract final class CategorySlugs {
  static const shopping = 'shopping';
  static const events = 'events';
  static const travel = 'travel';
  static const food = 'food';
  static const finance = 'finance';
  static const education = 'education';
  static const jobs = 'jobs';
  static const documents = 'documents';
  static const social = 'social';
  static const messages = 'messages';
  static const locations = 'locations';
  static const quotes = 'quotes';
  static const technology = 'technology';
  static const personal = 'personal';
  static const other = 'other';
}

const systemCategories = <SystemCategory>[
  SystemCategory(
    slug: CategorySlugs.shopping,
    name: 'Shopping',
    icon: 'shopping',
    color: 0xFFEC4899,
  ),
  SystemCategory(
    slug: CategorySlugs.events,
    name: 'Events',
    icon: 'event',
    color: 0xFF8B5CF6,
  ),
  SystemCategory(
    slug: CategorySlugs.travel,
    name: 'Travel',
    icon: 'flight',
    color: 0xFF0EA5E9,
  ),
  SystemCategory(
    slug: CategorySlugs.food,
    name: 'Food and Recipes',
    icon: 'restaurant',
    color: 0xFFF97316,
  ),
  SystemCategory(
    slug: CategorySlugs.finance,
    name: 'Receipts and Payments',
    icon: 'receipt',
    color: 0xFF22C55E,
  ),
  SystemCategory(
    slug: CategorySlugs.education,
    name: 'Education',
    icon: 'school',
    color: 0xFF635BFF,
  ),
  SystemCategory(
    slug: CategorySlugs.jobs,
    name: 'Jobs and Careers',
    icon: 'work',
    color: 0xFF14B8A6,
  ),
  SystemCategory(
    slug: CategorySlugs.documents,
    name: 'Documents',
    icon: 'description',
    color: 0xFF64748B,
  ),
  SystemCategory(
    slug: CategorySlugs.social,
    name: 'Social Media',
    icon: 'social',
    color: 0xFFF43F5E,
  ),
  SystemCategory(
    slug: CategorySlugs.messages,
    name: 'Messages',
    icon: 'chat',
    color: 0xFF3B82F6,
  ),
  SystemCategory(
    slug: CategorySlugs.locations,
    name: 'Locations',
    icon: 'place',
    color: 0xFFEF4444,
  ),
  SystemCategory(
    slug: CategorySlugs.quotes,
    name: 'Quotes and Inspiration',
    icon: 'quote',
    color: 0xFFEAB308,
  ),
  SystemCategory(
    slug: CategorySlugs.technology,
    name: 'Technology',
    icon: 'code',
    color: 0xFF06B6D4,
  ),
  SystemCategory(
    slug: CategorySlugs.personal,
    name: 'Personal',
    icon: 'person',
    color: 0xFFA855F7,
  ),
  SystemCategory(
    slug: CategorySlugs.other,
    name: 'Other',
    icon: 'category',
    color: 0xFF9CA3AF,
  ),
];

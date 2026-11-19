abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const collections = '/collections';
  static const search = '/search';
  static const reminders = '/reminders';
  static const settings = '/settings';
  static const inbox = '/inbox';
  static const actions = '/actions';
  static const wishlist = '/wishlist';
  static const duplicates = '/duplicates';
  static const privacyPolicy = '/settings/privacy';
  static const storage = '/settings/storage';
  static const backup = '/settings/backup';
  static const rules = '/settings/rules';

  static String screenshot(int id) => '/screenshot/$id';
  static String collection(int id) => '/collections/$id';
  static String category(int id) => '/collections/category/$id';
  static String reminder(int id) => '/reminders/$id';
}

import 'theme_storage_stub.dart'
    if (dart.library.html) 'theme_storage_web.dart';

class ThemeStorageHelper {
  static Future<void> saveTheme(bool isDark) => ThemeStorage.saveTheme(isDark);
  static Future<bool> loadTheme() => ThemeStorage.loadTheme();
}

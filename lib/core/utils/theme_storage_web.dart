import 'dart:html' as html;

class ThemeStorage {
  static Future<void> saveTheme(bool isDark) async {
    try {
      html.window.localStorage['is_dark_theme'] = isDark.toString();
    } catch (_) {}
  }

  static Future<bool> loadTheme() async {
    try {
      return html.window.localStorage['is_dark_theme'] == 'true';
    } catch (_) {
      return false;
    }
  }
}

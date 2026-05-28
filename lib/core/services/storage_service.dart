import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe_gangsta_flutter/features/auth/domain/entities/user_role.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyRole = 'auth_role';

  static Future<void> saveAuth({
    required String token,
    required String refreshToken,
    required UserRole role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyRole, role.name);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyRole);
  }

  static Future<Map<String, String>?> getAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final refreshToken = prefs.getString(_keyRefreshToken);
    final roleName = prefs.getString(_keyRole);
    if (token != null && refreshToken != null && roleName != null) {
      return {
        'token': token,
        'refreshToken': refreshToken,
        'role': roleName,
      };
    }
    return null;
  }
}

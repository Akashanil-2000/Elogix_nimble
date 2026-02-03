// lib/core/storage/session_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _tokenKey = 'nimble_token';
  static const _userIdKey = 'nimble_user_id';

  // 🔹 NEW KEYS
  static const _nameKey = 'nimble_user_name';
  static const _emailKey = 'nimble_user_email';
  static const _companyKey = 'nimble_company';
  static const _timezoneKey = 'nimble_timezone';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
  }

  // 🔹 SAVE PROFILE DATA
  static Future<void> saveProfile({
    required String name,
    required String email,
    required String company,
    required String timezone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_companyKey, company);
    await prefs.setString(_timezoneKey, timezone);
  }

  // 🔹 GET PROFILE DATA
  static Future<String?> getName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_nameKey);
  }

  static Future<String?> getEmail() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_emailKey);
  }

  static Future<String?> getCompany() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_companyKey);
  }

  static Future<String?> getTimezone() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_timezoneKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

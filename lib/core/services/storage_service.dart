import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _themeKey = 'theme_mode';
  static const _rememberKey = 'remember';
  static const _firstuserKey = 'firstuser';

  static Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  static Future<void> saveRemember(String remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberKey, remember);
  }

  static Future<String?> getRemember() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberKey);
  }

  static Future<void> saveFirstuser(String firstuser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstuserKey, firstuser);
  }

  static Future<String?> getFirstuser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstuserKey);
  }

  static Future<void> save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Authentication storage methods
  static const _authTokenKey = 'auth_token';
  static const _userDataKey = 'user_data';
  static const _isLoggedInKey = 'is_logged_in';

  /// Save authentication token
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  /// Get authentication token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// Save user data as JSON string
  static Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }

  /// Get user data JSON string
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  /// Set logged in status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Clear all authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_isLoggedInKey);
  }
}

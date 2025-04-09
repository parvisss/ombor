import 'package:shared_preferences/shared_preferences.dart';

class PasswordHelper {
  static const String _key = 'user_password';

  // Set password
  static Future<void> setPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, password);
  }

  // Get password
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  // Check password
  static Future<bool> checkPassword(String input) async {
    final stored = await getPassword();
    return stored == input;
  }

  // Remove password (for future use)
  static Future<void> removePassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

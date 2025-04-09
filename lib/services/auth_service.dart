import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_password', password);
  }

  Future<bool> verifyPassword(String input) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('app_password');
    return savedPassword == input;
  }

  Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('app_password');
  }
}

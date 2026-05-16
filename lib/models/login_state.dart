import 'package:shared_preferences/shared_preferences.dart';

class LoginState {

  LoginState._();

  static Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  static void login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  static void logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }
}
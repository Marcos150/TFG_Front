import 'package:shared_preferences/shared_preferences.dart';

class LoginState {
  String? token;

  static final LoginState _singleton = LoginState._internal();

  factory LoginState() {
    return _singleton;
  }

  LoginState._internal() {
    _init();
  }

  bool get isLoggedIn => token != null;

  void _init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    token = storedToken;
  }

  void login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    this.token = token;
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token = null;
  }
}
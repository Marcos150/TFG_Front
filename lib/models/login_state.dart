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
    token = prefs.getString('token');
  }

  void login(String token) async {
    this.token = token;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  void logout() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }
}
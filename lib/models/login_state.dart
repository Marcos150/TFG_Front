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
}
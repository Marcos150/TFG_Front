import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/models/login_state.dart';
import 'common_service.dart';

Future<String> register(String email, String password) async {
  final response = await http.post(
    Uri.parse('$urlCommon/register'),
    headers: headersBoth,
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    final token = jsonDecode(response.body)['token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    LoginState().token = token;
    return jsonDecode(response.body)['token'] as String;
  } else {
    throw Exception('Failed to register: ${response.body}');
  }
}

Future<String> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$urlCommon/login'),
    headers: headersBoth,
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final token = jsonDecode(response.body)['token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    LoginState().token = token;
    return jsonDecode(response.body)['token'] as String;
  } else {
    throw Exception('Failed to register: ${response.body}');
  }
}
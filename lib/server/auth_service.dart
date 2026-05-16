import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg/models/login_state.dart';
import 'common_service.dart';

Future<String> register(String email, String password) async {
  final response = await http.post(
    Uri.parse('$urlCommon/register'),
    headers: headersBoth,
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 201) {
    final token = jsonDecode(response.body)['token'] as String;
    LoginState.login(token);
    return jsonDecode(response.body)['token'] as String;
  } else {
    throw Exception('Failed to register: ${response.body}');
  }
}

Future<String> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$urlCommon/login'),
    headers: headersBoth,
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final token = jsonDecode(response.body)['token'] as String;
    LoginState.login(token);
    return jsonDecode(response.body)['token'] as String;
  } else {
    throw Exception('Failed to register: ${response.body}');
  }
}

Future<void> logout() async {
  final headersAuth = await getAuthHeader();
  final response = await http.post(
    Uri.parse('$urlCommon/logout'),
    headers: headersAuth,
  );

  if (response.statusCode == 204) {
    LoginState.logout();
  } else {
    throw Exception('Failed to logout: ${response.body}');
  }
}

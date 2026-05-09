import 'package:tfg/models/login_state.dart';

const String urlCommon = 'http://10.0.2.2:8000/api';
//const String urlCommon = 'http://127.0.0.1:8000/api';
const headersReceive = {'Accept': 'application/json'};
const headersSend = {'Content-Type': 'application/json; charset=UTF-8'};
const headersBoth = {
  'Accept': 'application/json',
  'Content-Type': 'application/json; charset=UTF-8',
};

Future<Map<String, String>> getAuthHeader() async {
  final token = LoginState().token;
  if (token != null) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  return headersBoth;
}
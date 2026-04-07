import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg/models/sheet_music.dart';

const String _url = 'http://10.0.2.2:8000/api/sheet-music';
const _headers = {'Accept': 'application/json'};

Future<SheetMusic> fetchSheetMusic(int id) async {
  final response = await http.get(Uri.parse('$_url/$id'), headers: _headers);

  if (response.statusCode == 200) {
    return SheetMusic.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load sheet music');
  }
}

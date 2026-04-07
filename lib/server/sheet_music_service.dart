import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg/models/sheet_music.dart';

const String _url = 'http://10.0.2.2:8000/api/sheet-music';
const _headersReceive = {'Accept': 'application/json'};
const _headersSend = {'Content-Type': 'application/json; charset=UTF-8'};

Future<SheetMusic> fetchSheetMusic(int id) async {
  final response = await http.get(
    Uri.parse('$_url/$id'),
    headers: _headersReceive,
  );

  if (response.statusCode == 200) {
    return SheetMusic.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load sheet music');
  }
}

Future<SheetMusic> createSheetMusic(SheetMusic sheetMusic) async {
  final response = await http.post(
    Uri.parse(_url),
    headers: _headersSend,
    body: jsonEncode(sheetMusic),
  );

  if (response.statusCode == 201) {
    return SheetMusic.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to create sheet music.');
  }
}

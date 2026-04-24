import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg/models/sheet_music.dart';
import 'common_service.dart';

const _url = '$urlCommon/sheet-music';

Future<SheetMusic> fetchSheetMusic(int id) async {
  final response = await http.get(
    Uri.parse('$_url/$id'),
    headers: headersReceive,
  );

  if (response.statusCode == 200) {
    return SheetMusic.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load sheet music');
  }
}

Future<List<SheetMusic>> getAllSheetMusic() async {
  final response = await http.get(Uri.parse(_url), headers: headersReceive);

  if (response.statusCode == 200) {
    final List<dynamic> list = jsonDecode(response.body);
    final List<SheetMusic> result = [];
    for (final sheetMusic in list) {
      result.add(SheetMusic.fromJson(sheetMusic));
    }
    return result;
  } else {
    throw Exception('Failed to load sheet music');
  }
}

Future<SheetMusic> createSheetMusic(SheetMusic sheetMusic) async {
  final response = await http.post(
    Uri.parse(_url),
    headers: headersSend,
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

Future<SheetMusic> editSheetMusic(SheetMusic sheetMusic) async {
  final response = await http.put(
    Uri.parse('$_url/${sheetMusic.id}'),
    headers: headersSend,
    body: jsonEncode(sheetMusic),
  );

  if (response.statusCode == 200) {
    return SheetMusic.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to create sheet music.');
  }
}

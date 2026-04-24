import 'dart:convert';
import 'dart:io';
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

Future<SheetMusic> createSheetMusic(SheetMusic sheetMusic, File file) async {
  final request = http.MultipartRequest('POST', Uri.parse(_url));
  final Map<String, dynamic> data = sheetMusic.toJson();
  data.forEach((key, value) {
    //TODO: Maybe the if else is not necesary, we can jsonEncode all
    if (value is List || value is Map) {
      request.fields[key] = jsonEncode(value);
    } else {
      request.fields[key] = value.toString();
    }
  });
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  request.headers.addAll(headersSend);
  final response = await request.send();

  if (response.statusCode == 201) {
    return SheetMusic.fromJson(
      jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>,
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

Future<File> getSheetMusicFile(int id) async {
  final response = await http.get(Uri.parse('$_url/$id/file'));

  if (response.statusCode == 200) {
    final extension =
        response.headers['content-type']?.split('/').last ?? 'pdf';
    final bytes = response.bodyBytes;
    final file = File(
      '${Directory.systemTemp.path}/sheet_music_$id.$extension',
    );
    await file.writeAsBytes(bytes);
    return file;
  } else {
    throw Exception('Failed to load sheet music file');
  }
}

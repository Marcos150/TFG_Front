import 'dart:convert';
import 'dart:io' show File;
import 'package:http/http.dart' as http;
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/utils/local_storage.dart';
import 'common_service.dart';

const _url = '$urlCommon/sheet-music';

Future<SheetMusic> fetchSheetMusic(int id) async {
  final headersAuth = await getAuthHeader();
  final response = await http.get(Uri.parse('$_url/$id'), headers: headersAuth);

  if (response.statusCode == 200) {
    return SheetMusic.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load sheet music');
  }
}

Future<List<SheetMusic>> getAllSheetMusic() async {
  final headersAuth = await getAuthHeader();

  try {
    final response = await http.get(Uri.parse(_url), headers: headersAuth);

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body);
      final List<SheetMusic> sheetMusicList = [];
      for (final sheetMusic in list) {
        sheetMusicList.add(SheetMusic.fromJson(sheetMusic));
      }
      final result = await getNewestSheetMusicList(sheetMusicList);

      storeSheetMusicList(result);
      return result;
    } else {
      return getStoredSheetMusicList();
    }
  } catch (_) {
    return getStoredSheetMusicList();
  }
}

Future<SheetMusic> createSheetMusic(SheetMusic sheetMusic, File file) async {
  final headersAuth = await getAuthHeader();
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
  request.headers.addAll(headersAuth);

  final storedSheetMusic = storeSheetMusic(sheetMusic, file: file);
  setPendingUpload(true);
  try {
    final response = await request.send();

    if (response.statusCode == 201) {
      setPendingUpload(false);
      final res = SheetMusic.fromJson(
        jsonDecode(await response.stream.bytesToString())
            as Map<String, dynamic>,
      );
      return res;
    }

    return storedSheetMusic;
  } catch (_) {
    return storedSheetMusic;
  }
}

Future<SheetMusic> editSheetMusic(SheetMusic sheetMusic) async {
  final authHeader = await getAuthHeader();
  authHeader['Content-Type'] = 'application/json; charset=UTF-8';

  final storedSheetMusic = updateStoredSheetMusic(sheetMusic);
  setPendingUpload(true);

  try {
    final response = await http.put(
      Uri.parse('$_url/${sheetMusic.id}'),
      headers: authHeader,
      body: jsonEncode(sheetMusic),
    );

    if (response.statusCode == 200) {
      setPendingUpload(false);
      return SheetMusic.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      return storedSheetMusic;
    }
  } catch (_) {
    return storedSheetMusic;
  }
}

Future<File> getSheetMusicFile(int id) async {
  final localFile = await getStoredSheetMusicFile(id);
  if (localFile != null) return localFile;

  final headersAuth = await getAuthHeader();
  try {
    final response = await http.get(
      Uri.parse('$_url/$id/file'),
      headers: headersAuth,
    );

    if (response.statusCode == 200) {
      final extension =
          response.headers['content-type']?.split('/').last ?? 'pdf';
      final bytes = response.bodyBytes;
      return storeSheetMusicFile(id, bytes, extension);
    } else {
      return (await getStoredSheetMusicFile(id))!;
    }
  } catch (_) {
    return (await getStoredSheetMusicFile(id))!;
  }
}

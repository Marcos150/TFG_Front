import 'dart:convert';
import 'dart:io' show File;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/models/sheet_music.dart';

const sheetMusicListKey = 'sheetMusicList';

void storeSheetMusicList(List<SheetMusic> sheetMusicList) async {
  final prefs = await SharedPreferences.getInstance();
  final storeData = jsonEncode(sheetMusicList.map((e) => e.toJson()).toList());
  prefs.setString(sheetMusicListKey, storeData);
}

void storeSheetMusic(SheetMusic sheetMusic) async {
  final prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString(sheetMusicListKey);

  if (storedData != null) {
    final list = jsonDecode(storedData);
    list.add(sheetMusic.toJson());
    prefs.setString(sheetMusicListKey, jsonEncode(list));
  } else {
    prefs.setString(sheetMusicListKey, jsonEncode([sheetMusic.toJson()]));
  }
}

void storeSheetMusicFilePath(int id, String path) async {
  final prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString(sheetMusicListKey);

  if (storedData != null) {
    final list = jsonDecode(storedData);
    for (final sheetMusic in list) {
      if (sheetMusic['id'] == id) {
        sheetMusic['fileLocalPath'] = path;
        break;
      }
    }
    prefs.setString(sheetMusicListKey, jsonEncode(list));
  }
}

Future<File> getStoredSheetMusicFile(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString(sheetMusicListKey);

  if (storedData != null) {
    final list = jsonDecode(storedData);
    for (final sheetMusic in list) {
      if (sheetMusic['id'] == id) {
        return File(sheetMusic['fileLocalPath']);
      }
    }
  }

  return File('');
}

Future<List<SheetMusic>> getStoredSheetMusicList() async {
  final prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString(sheetMusicListKey);

  if (storedData != null) {
    final list = jsonDecode(storedData);
    final List<SheetMusic> result = [];
    for (final sheetMusic in list) {
      result.add(SheetMusic.fromJson(sheetMusic));
    }
    return result;
  } else {
    return const [];
  }
}

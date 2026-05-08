import 'dart:convert';
import 'dart:io' show File;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:path_provider/path_provider.dart';

const sheetMusicListKey = 'sheetMusicList';
const arePendingUploadKey = 'arePendingUpload';

void setPendingUpload(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(arePendingUploadKey, value);
}

Future<bool> getPendingUpload() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(arePendingUploadKey) ?? false;
}

void storeSheetMusicList(List<SheetMusic> sheetMusicList) async {
  final prefs = await SharedPreferences.getInstance();
  final storeData = jsonEncode(sheetMusicList.map((e) => e.toJson()).toList());
  prefs.setString(sheetMusicListKey, storeData);
}

Future<SheetMusic> storeSheetMusic(SheetMusic sheetMusic, {File? file}) async {
  final prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString(sheetMusicListKey);

  if (storedData != null) {
    final list = jsonDecode(storedData);
    list.add(sheetMusic.toJson());
    prefs.setString(sheetMusicListKey, jsonEncode(list));
  } else {
    prefs.setString(sheetMusicListKey, jsonEncode([sheetMusic.toJson()]));
  }

  if (file != null) {
    final extension = file.path.split('.').last;
    storeSheetMusicFile(sheetMusic.id, file.readAsBytesSync(), extension);
  }

  return sheetMusic;
}

Future<File> storeSheetMusicFile(
  int id,
  List<int> fileBytes,
  String extension,
) async {
  final storedFile = await getStoredSheetMusicFile(id);

  if (storedFile != null && storedFile.path.isNotEmpty) return storedFile;

  final directory = await getApplicationSupportDirectory();
  final filePath = '${directory.path}/sheet_music_$id.$extension';
  final file = File(filePath);
  _storeSheetMusicFilePath(id, filePath);
  await file.writeAsBytes(fileBytes);
  return file;
}

void _storeSheetMusicFilePath(int id, String path) async {
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

Future<File?> getStoredSheetMusicFile(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString(sheetMusicListKey);

  if (storedData != null) {
    final list = jsonDecode(storedData);
    for (final sheetMusic in list) {
      if (sheetMusic['id'] == id) {
        return sheetMusic['fileLocalPath'] != null
            ? File(sheetMusic['fileLocalPath'])
            : null;
      }
    }
  }
  return null;
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

Future<List<SheetMusic>> getNewestSheetMusicList(
  List<SheetMusic> remoteList,
) async {
  final pendingUpload = await getPendingUpload();
  final localSheetMusicList = await getStoredSheetMusicList();
  final newestList = pendingUpload ? localSheetMusicList : remoteList;
  final oldestList = pendingUpload ? remoteList : localSheetMusicList;
  final List<SheetMusic> result = [];

  for (final newSheetMusic in newestList) {
    final oldSheetMusic = oldestList.firstWhere(
      (local) => local.id == newSheetMusic.id,
      orElse: () => const SheetMusic.empty(),
    );

    result.add(newSheetMusic);
    // Don't store again if already stored (id is the same as the DB one)
    if (oldSheetMusic.id == newSheetMusic.id) continue;

    if (pendingUpload) {
      final file = await getStoredSheetMusicFile(newSheetMusic.id);
      createSheetMusic(newSheetMusic, file!);
    } else {
      getSheetMusicFile(newSheetMusic.id); //Gets and stores file from cloud
      storeSheetMusic(newSheetMusic);
    }
  }

  setPendingUpload(false);
  return result;
}

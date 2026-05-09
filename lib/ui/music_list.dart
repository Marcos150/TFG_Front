import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/add_sheet_music_screen.dart';
import 'package:tfg/ui/login_screen.dart';
import 'package:tfg/ui/practice_screen.dart';
import 'package:tfg/utils/utils.dart' hide FileType;

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  late Future<List<SheetMusic>> sheetMusic;
  List<SheetMusic>? _sheetMusicData;
  List<File>? _sheetMusicFiles;
  bool hasInternet = true;

  void _getSheetMusic() => sheetMusic = getAllSheetMusic().catchError((
    Object error,
    StackTrace stackTrace,
  ) {
    if (kDebugMode) {
      print(error);
      print(stackTrace);
    }
    hasInternet = false;
    return const <SheetMusic>[];
  });

  void _getSheetMusicFiles() async {
    final sheetMusicList = await sheetMusic;
    Future.wait(
      sheetMusicList.map((sheetMusic) => getSheetMusicFile(sheetMusic.id)),
    ).then((files) => setState(() => _sheetMusicFiles = files));
  }

  @override
  void initState() {
    _getSheetMusic();
    _getSheetMusicFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Mis partituras'),
      body: Center(
        child: FutureBuilder(
          future: sheetMusic,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _sheetMusicData = snapshot.data!;
              if (_sheetMusicData!.isEmpty) {
                return const Text('Aquí verás las partituras que añadas.');
              }
              return GridView.builder(
                itemCount: _sheetMusicData?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (BuildContext context, int index) => GridTile(
                  footer: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    child: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text(_sheetMusicData![index].title),
                      subtitle: Text(_sheetMusicData![index].author),
                      trailing: Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute<SheetMusic>(
                                      builder: (context) => AddSheetMusicScreen(
                                        sheetMusic: _sheetMusicData![index],
                                      ),
                                    ),
                                  )
                                  .then(
                                    (res) => setState(
                                      () => _sheetMusicData![index] =
                                          res ?? _sheetMusicData![index],
                                    ),
                                  );
                            },
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete),
                            onPressed: () => showSnackbar(
                              'Partitura ${_sheetMusicData![index].title} borrada',
                              context,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_sheetMusicFiles != null &&
                              _sheetMusicFiles!.length > index)
                            Expanded(
                              child: ImageViewer(
                                file: _sheetMusicFiles![index],
                              ),
                            )
                          else
                            const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<SheetMusic>(
                        builder: (context) =>
                            PracticeScreen(sheetMusic: _sheetMusicData![index]),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: widget.key,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        children: [
          Row(
            children: [
              const Text('Importar PDF'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () async {
                  final FilePickerResult? result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpeg', 'jpg', 'png'],
                  );
                  if (result != null) {
                    final File file = File(result.files.single.path!);
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute<SheetMusic>(
                            builder: (context) =>
                                AddSheetMusicScreen(file: file),
                          ),
                        )
                        .then((res) {
                          if (res != null) {
                            setState(() => _sheetMusicData?.add(res));
                          }
                        });
                  } else {
                    showSnackbar('Cancelado', context);
                  }
                },
                child: const Icon(Icons.insert_drive_file),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Escanear'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () async {
                  final test = await scanAsPdf();
                  if (test != null) {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute<SheetMusic>(
                            builder: (context) => AddSheetMusicScreen(
                              file: File.fromUri(Uri.parse(test.images[0])),
                            ),
                          ),
                        )
                        .then((res) {
                          if (res != null) {
                            setState(() => _sheetMusicData?.add(res));
                          }
                        });
                  }
                },
                child: const Icon(Icons.add_a_photo),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Metrónomo'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          const PracticeScreen(sheetMusic: SheetMusic.empty()),
                    ),
                  );
                },
                child: const Icon(Icons.music_note),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Iniciar sesión'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                  _getSheetMusic();
                  setState(() {});
                },
                child: const Icon(Icons.login),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:tfg/models/login_state.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/server/auth_service.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:tfg/ui/add_sheet_music_screen.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/login_screen.dart';
import 'package:tfg/ui/practice_screen.dart';
import 'package:tfg/utils/utils.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  List<SheetMusic>? _sheetMusicData;

  Future<List<SheetMusic>> _getSheetMusic() async =>
      _sheetMusicData = await getAllSheetMusic().catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        if (kDebugMode) {
          print(error);
          print(stackTrace);
        }
        return const <SheetMusic>[];
      });

  Future<List<File>> _getSheetMusicFiles(List<SheetMusic> sheetMList) async {
    final List<File> sheetMusicFiles = List.filled(sheetMList.length, File(''));
    for (int i = 0; i < sheetMList.length; i++) {
      final file = await getSheetMusicFile(sheetMList[i].id);
      sheetMusicFiles[i] = file;
    }

    return sheetMusicFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Can't make appBar const because of login icon
      // Next time I should use proper state management
      // ignore: prefer_const_constructors
      appBar: MyAppBar(title: 'Mis partituras'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FutureBuilder(
          future: _getSheetMusic().then((res) {
            _getSheetMusicFiles(res);
            return res;
          }),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (_sheetMusicData!.isEmpty) {
                return Center(
                  child: Text(
                    'Aquí verás las partituras que añadas.',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                );
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
                      bottom: Radius.circular(8),
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
                            onPressed: () {
                              myShowDialog(
                                'Eliminar partitura',
                                '¿Seguro que quieres eliminar esta partitura?',
                                context,
                                actionLabels: [
                                  const Text('Cancelar'),
                                  Text(
                                    'Borrar',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                  ),
                                ],
                                actions: [
                                  () => showSnackbar(
                                    'Borrado cancelado',
                                    context,
                                  ),
                                  () async {
                                    await deleteSheetMusic(
                                      _sheetMusicData![index].id,
                                    );
                                    showSnackbar(
                                      'Partitura ${_sheetMusicData![index].title} borrada',
                                      context,
                                    );
                                    setState(
                                      () => _sheetMusicData?.removeAt(index),
                                    );
                                  },
                                ],
                              );
                            },
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
                          FutureBuilder(
                            future: _getSheetMusicFiles(_sheetMusicData!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Expanded(
                                  child: ImageViewer(
                                    file: snapshot.data![index],
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
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
              return const Center(child: CircularProgressIndicator());
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
              const Text(
                'Importar partitura',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () async {
                  final FilePickerResult? result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpeg', 'jpg', 'png', 'webp'],
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
              const Text(
                'Escanear',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
              const Text(
                'Metrónomo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
          FutureBuilder(
            future: LoginState.isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return Row(
                  children: [
                    const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    FloatingActionButton.small(
                      heroTag: null,
                      onPressed: () async {
                        await logout();
                        showSnackbar('Sesión cerrada correctamente', context);
                        setState(() {});
                      },
                      child: const Icon(Icons.logout),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    const Text(
                      'Iniciar sesión',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    FloatingActionButton.small(
                      heroTag: null,
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                        setState(() {});
                      },
                      child: const Icon(Icons.login),
                    ),
                  ],
                );
              }
            },
          ),
          Row(
            children: [
              const Text(
                'Licencias',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () => showLicensePage(context: context),
                child: const Icon(Icons.book),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

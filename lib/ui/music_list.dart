import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/add_sheet_music_screen.dart';
import 'package:tfg/utils.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  late Future<List<SheetMusic>> sheetMusic;

  void _getSheetMusic() => sheetMusic = getAllSheetMusic();

  @override
  void initState() {
    _getSheetMusic();
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
              return ListView.builder(
                itemBuilder: (_, int index) {
                  return ListTile(
                    leading: const CircleAvatar(),
                    title: Text(snapshot.data![index].title),
                    trailing: IconButton(
                      onPressed: () {
                        showSnackbar(
                          'Partitura ${snapshot.data![index].title} borrada',
                          context,
                        );
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute<SheetMusic>(
                              builder: (context) => AddSheetMusicScreen(
                                sheetMusic: snapshot.data![index],
                              ),
                            ),
                          )
                          .then((res) => setState(() => _getSheetMusic()));
                    },
                  );
                },
                itemCount: snapshot.data!.length,
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
                        .then((res) => setState(() => _getSheetMusic()));
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
                        .then((res) => setState(() => _getSheetMusic()));
                  }
                },
                child: const Icon(Icons.add_a_photo),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Pruebas'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () async {
                  final music = await fetchSheetMusic(1);
                  final title = music.title;
                  print('AAAAAAAAAAAAAAAAAAAAA: $title');
                },
                child: const Icon(Icons.wheelchair_pickup),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

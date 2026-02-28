import 'package:flutter/material.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/add_sheet_music_screen.dart';
import 'package:tfg/utils.dart';

class MusicList extends StatelessWidget {
  const MusicList({super.key});

  static const List<SheetMusic> sheetMusic = [
    SheetMusic('Amparito Roca'),
    SheetMusic('Danza Húngara Nº5'),
    SheetMusic('Danubio Azul'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Mis partituras'),
      body: Center(
        child: ListView.builder(
          itemBuilder: (_, int i) {
            return ListTile(
              leading: const CircleAvatar(),
              title: Text(sheetMusic[i].name),
              trailing: IconButton(
                onPressed: () {
                  showSnackbar(
                    'Partitura ${sheetMusic[i].name} borrada',
                    context,
                  );
                },
                icon: const Icon(Icons.delete),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AddSheetMusicScreen(),
                  ),
                );
              },
            );
          },
          itemCount: sheetMusic.length,
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: key,
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
                onPressed: () {
                  showSnackbar('Escanear', context);
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
                onPressed: () {
                  showSnackbar('Escanear', context);
                },
                child: const Icon(Icons.add_a_photo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

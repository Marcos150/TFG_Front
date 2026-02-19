import 'package:flutter/material.dart';
import 'package:tfg/models/sheet_music.dart';

class MusicList extends StatelessWidget {
  const MusicList({super.key});

  static const List<SheetMusic> sheetMusic = [
    SheetMusic("Amparito Roca"),
    SheetMusic("Danza Húngara Nº5"),
    SheetMusic("Danubio Azul"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partituras"),
        actions: [
          IconButton(
            onPressed: () {
              print("Abrir perfil");
            },
            icon: const CircleAvatar(),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ListView.builder(
          itemBuilder: (_, int i) {
            return ListTile(
              leading: const CircleAvatar(),
              title: Text(sheetMusic[i].name),
              trailing: IconButton(
                onPressed: () {
                  final snackBar = SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text('Partitura ${sheetMusic[i].name} borrada'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: const Icon(Icons.delete),
              ),
              onTap: () {
                final snackBar = SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text('Click ${sheetMusic[i].name}'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            );
          },
          itemCount: sheetMusic.length,
        ),
      ),
    );
  }
}

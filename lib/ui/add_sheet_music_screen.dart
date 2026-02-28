import 'package:flutter/material.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/forms/sheet_music_form.dart';

class AddSheetMusicScreen extends StatelessWidget {
  const AddSheetMusicScreen({super.key, this.sheetMusic});

  final SheetMusic? sheetMusic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Añadir partitura'),
      body: SheetMusicForm(sheetMusic: sheetMusic),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/forms/sheet_music_form.dart';

class AddSheetMusicScreen extends StatelessWidget {
  const AddSheetMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(title: 'Añadir partitura'),
      body: SheetMusicForm(),
    );
  }
}

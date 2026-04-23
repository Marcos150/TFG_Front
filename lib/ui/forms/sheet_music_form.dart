import 'dart:io' show File;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/models/tag.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/utils.dart';

class SheetMusicForm extends StatefulWidget {
  const SheetMusicForm({super.key, this.sheetMusic, this.file});

  final SheetMusic? sheetMusic;
  final File? file;

  @override
  SheetMusicFormState createState() {
    return SheetMusicFormState();
  }
}

class SheetMusicFormState extends State<SheetMusicForm> {
  final _formKey = GlobalKey<FormState>();

  final List<Tag> tags = [
    const Tag('Pasodoble'),
    const Tag('Vals'),
    const Tag('Rock'),
  ];
  late final List<bool> _value = List.generate(tags.length, (int index) {
    return widget.sheetMusic?.tags.contains(tags[index]) ?? false;
  }, growable: true);
  late final titleController = TextEditingController(
    text: widget.sheetMusic?.title,
  );
  late final authorController = TextEditingController(
    text: widget.sheetMusic?.author,
  );
  final tagController = TextEditingController();
  Uint8List? _imgMat;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsGeometry.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Título',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El título está vacío';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsGeometry.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: TextFormField(
                    controller: authorController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Autor',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El autor está vacío';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 5.0,
            children: [
              ...List<Widget>.generate(tags.length, (int index) {
                return ChoiceChip(
                  label: Text(tags[index].name),
                  selected: _value[index],
                  onSelected: (bool selected) {
                    setState(() {
                      _imgMat = detectSheetMusic(widget.file!);
                      _value[index] = !_value[index];
                    });
                  },
                );
              }),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Añadir etiqueta'),
                        content: TextField(
                          controller: tagController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nombre',
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              tagController.clear();
                            },
                          ),
                          TextButton(
                            child: const Text('Añadir'),
                            onPressed: () {
                              setState(() {
                                tags.add(Tag(tagController.text));
                                _value.add(false);
                              });
                              Navigator.of(context).pop();
                              tagController.clear();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (widget.file != null)
            Expanded(
              child: _imgMat == null
                  ? ImageViewer(file: widget.file!)
                  : Image.memory(_imgMat!),
            ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final sheetMusic = SheetMusic(
                  titleController.text,
                  authorController.text,
                );
                try {
                  await createSheetMusic(sheetMusic);
                  showSnackbar('Partitura guardada', context);
                  Navigator.pop(context, sheetMusic);
                } catch (e) {
                  showSnackbar(
                    'Error al guardar la partitura. Inténtalo más tarde.',
                    context,
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

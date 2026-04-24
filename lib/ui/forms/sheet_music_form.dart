import 'dart:io' show File;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/models/tag.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:tfg/server/tag_service.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/utils.dart';

class SheetMusicForm extends StatefulWidget {
  const SheetMusicForm({
    super.key,
    this.sheetMusic,
    this.file,
    this.isEditing = false,
  });

  final SheetMusic? sheetMusic;
  final File? file;
  final bool isEditing;

  @override
  SheetMusicFormState createState() {
    return SheetMusicFormState();
  }
}

class SheetMusicFormState extends State<SheetMusicForm> {
  final _formKey = GlobalKey<FormState>();

  late final Map<Tag, bool> _tags = Map.from(
    widget.sheetMusic?.tags.asMap().map(
          (key, value) => MapEntry(value, true),
        ) ??
        {},
  );
  late final _titleController = TextEditingController(
    text: widget.sheetMusic?.title,
  );
  late final _authorController = TextEditingController(
    text: widget.sheetMusic?.author,
  );
  final _tagController = TextEditingController();
  Uint8List? _imgMat;
  late File? _file = widget.file;

  @override
  void initState() {
    if (widget.sheetMusic != null) {
      getSheetMusicFile(
        widget.sheetMusic!.id!,
      ).then((value) => setState(() => _file = value));
    }

    getAllTags().then(
      (value) => setState(() {
        for (final tag in value) {
          if (!_tags.keys.contains(tag)) {
            _tags.addAll({tag: false});
          }
        }
      }),
    );
    super.initState();
  }

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
                    controller: _titleController,
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
                    controller: _authorController,
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
              ...List<Widget>.generate(_tags.length, (int index) {
                return ChoiceChip(
                  label: Text(_tags.keys.toList()[index].name),
                  selected: _tags.values.toList()[index],
                  onSelected: (bool selected) {
                    setState(() {
                      //_imgMat = detectSheetMusic(_file!);
                      _tags[_tags.keys.toList()[index]] =
                          !_tags[_tags.keys.toList()[index]]!;
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
                          controller: _tagController,
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
                              _tagController.clear();
                            },
                          ),
                          TextButton(
                            child: const Text('Añadir'),
                            onPressed: () {
                              setState(() {
                                _tags.addAll({Tag(_tagController.text): false});
                              });
                              Navigator.of(context).pop();
                              _tagController.clear();
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
          if (_file != null)
            Expanded(
              child: _imgMat == null
                  ? ImageViewer(file: _file!)
                  : Image.memory(_imgMat!),
            ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  if (widget.isEditing) {
                    final sheetMusic = SheetMusic(
                      _titleController.text,
                      _authorController.text,
                      id: widget.sheetMusic!.id,
                    );
                    await editSheetMusic(sheetMusic);
                  } else {
                    final sheetMusic = SheetMusic(
                      _titleController.text,
                      _authorController.text,
                      tags: _tags.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList(),
                    );
                    await createSheetMusic(sheetMusic, _file!);
                  }
                  showSnackbar('Partitura guardada', context);
                  Navigator.pop(context);
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

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}

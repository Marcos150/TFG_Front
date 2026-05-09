import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:tfg/models/measure.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/models/tag.dart';
import 'package:tfg/server/sheet_music_service.dart';
import 'package:tfg/server/tag_service.dart';
import 'package:tfg/ui/common/image_viewer.dart';
import 'package:tfg/ui/edit_measures_screen.dart';
import 'package:tfg/utils/utils.dart';

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
  late File? _file = widget.file;
  late List<Measure> _measures = widget.sheetMusic?.measures.toList() ?? [];
  bool _isLoadingMeasures = false;
  bool _errorGettingFile = false;

  @override
  void initState() {
    if (widget.sheetMusic != null) {
      getSheetMusicFile(widget.sheetMusic!.id)
          .then((value) => setState(() => _file = value))
          .catchError((_) => setState(() => _errorGettingFile = true));
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
                      _tags[_tags.keys.toList()[index]] =
                          !_tags[_tags.keys.toList()[index]]!;
                    });
                  },
                );
              }),
              IconButton(
                onPressed: () {
                  showDialog<void>(
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
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('Añadir'),
                            onPressed: () {
                              setState(() {
                                _tags.addAll({Tag(_tagController.text): false});
                              });
                              Navigator.of(context).pop();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<List<Measure>>(
                          builder: (context) => EditMeasuresScreen(
                            measures: _measures,
                            file: _file!,
                          ),
                        ),
                      )
                      .then(
                        (res) => setState(() => _measures = res ?? _measures),
                      );
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  setState(() => _isLoadingMeasures = true);
                  _measures = await findMeasures(_file!);
                  setState(() => _isLoadingMeasures = false);
                },
                icon: const Icon(Icons.smart_toy),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  late final SheetMusic sheetMusicRes;
                  if (widget.isEditing) {
                    final sheetMusic = SheetMusic(
                      _titleController.text,
                      _authorController.text,
                      id: widget.sheetMusic!.id,
                      tags: _tags.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList(),
                      measures: _measures,
                    );
                    sheetMusicRes = await editSheetMusic(sheetMusic);
                  } else {
                    final sheetMusic = SheetMusic(
                      _titleController.text,
                      _authorController.text,
                      tags: _tags.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList(),
                      measures: _measures,
                      id: DateTime.now().millisecondsSinceEpoch,
                    );
                    sheetMusicRes = await createSheetMusic(sheetMusic, _file!);
                  }
                  showSnackbar('Partitura guardada', context);
                  Navigator.of(context).pop(sheetMusicRes);
                } catch (e, st) {
                  if (kDebugMode) {
                    print(e);
                    print(st);
                  }
                  showSnackbar(
                    'Error al guardar la partitura. Inténtalo más tarde.',
                    context,
                  );
                }
              }
            },
            icon: const Icon(Icons.save_alt),
            label: const Text('Guardar'),
          ),
          const SizedBox(height: 8),
          if (_isLoadingMeasures)
            const CircularProgressIndicator()
          else if (_errorGettingFile)
            const Text('Error al cargar la partitura')
          else if (_file != null)
            Expanded(
              child: ImageViewer(file: _file!, measures: _measures),
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

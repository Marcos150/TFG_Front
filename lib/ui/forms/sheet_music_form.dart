import 'package:flutter/material.dart';
import 'package:tfg/models/sheet_music.dart';
import 'package:tfg/models/tag.dart';
import 'package:tfg/utils.dart';

class SheetMusicForm extends StatefulWidget {
  const SheetMusicForm({super.key, this.sheetMusic});

  final SheetMusic? sheetMusic;

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
  late final List<bool> _value = List.generate(
    tags.length,
    (int index) {
      return widget.sheetMusic?.tags.contains(tags[index]) ?? false;
    },
    growable: true,
  );
  final tagController = TextEditingController();

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
                    initialValue: widget.sheetMusic?.name,
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
                    initialValue: widget.sheetMusic?.author,
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
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                showSnackbar('Creando partitura...', context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

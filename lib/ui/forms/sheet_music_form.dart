import 'package:flutter/material.dart';
import 'package:tfg/models/tag.dart';
import 'package:tfg/utils.dart';

class SheetMusicForm extends StatefulWidget {
  const SheetMusicForm({super.key});

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
  late final List<bool> _value = List.filled(
    tags.length,
    false,
    growable: true,
  );

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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Título',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo está vacío';
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Autor',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo está vacío';
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
                  setState(() {
                    tags.add(const Tag('Tag nuevo'));
                    _value.add(false);
                  });
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

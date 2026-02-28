import 'package:flutter/material.dart';
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

  int? _value = 1;

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
            children: List<Widget>.generate(3, (int index) {
              return ChoiceChip(
                label: Text('Etiqueta $index'),
                selected: _value == index,
                onSelected: (bool selected) {
                  setState(() {
                    _value = selected ? index : null;
                  });
                },
              );
            }).toList(),
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

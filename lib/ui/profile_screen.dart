import 'package:flutter/material.dart';
import 'package:tfg/server/user_service.dart';
import 'package:tfg/ui/common/my_app_bar.dart';

import '../utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ({String email, int numOfSheetMusic, List<String> favoriteAuthors})? _data;

  Color _getMedalColor(int position) {
    switch (position) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.transparent;
    }
  }

  @override
  void initState() {
    getProfileInfo().then((res) => setState(() => _data = res));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const MyAppBar(title: 'Perfil'),
      body: _data == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    child: Icon(Icons.person, size: 48),
                  ),
                  Text(
                    _data!.email,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Text(
                            '${_data!.numOfSheetMusic}',
                            style: textTheme.displayLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Partituras registradas',
                            style: textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Compositores favoritos',
                            style: textTheme.titleLarge,
                          ),
                        ),
                        const Divider(height: 1),
                        if (_data!.favoriteAuthors.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text('No tienes partituras guardadas'),
                          )
                        else
                          ...List.generate(
                            _data!.favoriteAuthors.length,
                            (index) => ListTile(
                              leading: Icon(
                                Icons.workspace_premium,
                                color: _getMedalColor(index),
                              ),
                              title: Text(_data!.favoriteAuthors[index]),
                            ),
                          ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    label: const Text('Cambiar correo electrónico'),
                    icon: const Icon(Icons.email),
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    label: const Text('Cambiar contraseña'),
                    icon: const Icon(Icons.password),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.delete),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                    ),
                    onPressed: () async {
                      myShowDialog(
                        'Borrar cuenta',
                        '¿Seguro que quieres borrar tu cuenta?',
                        context,
                        actionLabels: [
                          const Text('Cancelar'),
                          Text(
                            'Borrar',
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                        actions: [
                          () => showSnackbar('Borrado cancelado', context),
                          () async {
                            await deleteAccount();
                            showSnackbar('Cuenta borrada con éxito', context);
                            Navigator.of(context).pop();
                          },
                        ],
                      );
                    },
                    label: const Text('Borrar cuenta'),
                  ),
                ],
              ),
            ),
    );
  }
}

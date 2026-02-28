import 'package:flutter/material.dart';

import '../../utils.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () {
            showSnackbar('Abrir perfil', context);
          },
          icon: const CircleAvatar(),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

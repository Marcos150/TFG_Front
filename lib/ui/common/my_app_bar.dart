import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title, this.onBackPressed});

  final String title;
  final Function? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackButton(
        onPressed: () {
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
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

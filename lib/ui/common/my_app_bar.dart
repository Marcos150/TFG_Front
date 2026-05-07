import 'package:flutter/material.dart';
import 'package:tfg/ui/register_screen.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title, this.onBackPressed});

  final String title;
  final Function? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Navigator.of(context).canPop() ? BackButton(
        onPressed: () {
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
      ) : null,
      centerTitle: true,
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const RegisterScreen(),
              ),
            );
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

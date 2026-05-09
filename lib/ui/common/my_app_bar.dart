import 'package:flutter/material.dart';
import 'package:tfg/models/login_state.dart';
import 'package:tfg/ui/profile_screen.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title, this.onBackPressed});

  final String title;
  final Function? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Navigator.of(context).canPop()
          ? BackButton(
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            )
          : null,
      centerTitle: true,
      title: Text(title),
      actions: [
        if (LoginState().isLoggedIn)
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const ProfileScreen(),
              ),
            ),
            icon: const CircleAvatar(child: Icon(Icons.person)),
          ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

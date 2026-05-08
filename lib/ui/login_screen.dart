import 'package:flutter/material.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/register_screen.dart';

import 'forms/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Iniciar sesión'),
      body: Column(
        spacing: 22,
        children: [
          const LoginForm(),
          const Text(
            '¿No tienes una cuenta?',
            style: TextStyle(fontSize: 28),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
              );
            },
            style: const ButtonStyle(
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 22)),
              visualDensity: VisualDensity(horizontal: 1.2, vertical: 1.2),
            ),
            child: const Text('Regístrate'),
          ),
        ],
      ),
    );
  }
}

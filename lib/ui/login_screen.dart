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
          Image.asset('assets/icon/icon.png', height: 260),
          const Card(
            margin: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 80,
                vertical: 40,
              ),
              child: LoginForm(),
            ),
          ),
          Text(
            '¿No tienes cuenta?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          ElevatedButton(
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

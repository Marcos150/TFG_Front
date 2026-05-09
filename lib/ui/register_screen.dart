import 'package:flutter/material.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/forms/register_form.dart';
import 'package:tfg/ui/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Registro'),
      body: Column(
        spacing: 22,
        children: [
          const FlutterLogo(size: 260),
          const Card(
            margin: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 80,
                vertical: 40,
              ),
              child: RegisterForm(),
            ),
          ),
          const Text('¿Ya tienes cuenta?', style: TextStyle(fontSize: 28)),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              );
            },
            style: const ButtonStyle(
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 22)),
              visualDensity: VisualDensity(horizontal: 1.2, vertical: 1.2),
            ),
            child: const Text('Inicia sesión'),
          ),
        ],
      ),
    );
  }
}

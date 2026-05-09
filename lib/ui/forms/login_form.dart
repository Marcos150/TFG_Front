import 'package:flutter/material.dart';
import 'package:tfg/server/auth_service.dart';
import 'package:tfg/utils/utils.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 42,
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introduce un correo electrónico';
              }

              return null;
            },
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introduce una contraseña';
              }

              return null;
            },
          ),
          FilledButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await login(_emailController.text, _passwordController.text);
                  showSnackbar('Inicio de sesión exitoso', context);
                  Navigator.of(context).pop();
                } catch (_) {
                  showSnackbar(
                    'Error al iniciar sesión. Comprueba tus credenciales e inténtalo de nuevo.',
                    context,
                  );
                }
              }
            },
            style: const ButtonStyle(
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 22)),
              visualDensity: VisualDensity(horizontal: 1.2, vertical: 1.2),
            ),
            child: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
  }
}

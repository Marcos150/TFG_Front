import 'package:flutter/material.dart';
import 'package:tfg/server/auth_service.dart';
import 'package:tfg/utils/utils.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();
  late final _repeatPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 26,
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
              if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }

              return null;
            },
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _repeatPasswordController,
            decoration: const InputDecoration(
              labelText: 'Repite contraseña',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          FilledButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await register(_emailController.text, _passwordController.text);
                  Navigator.of(context).pop();
                } catch (_) {
                  showSnackbar(
                    'Error al registrarse. Inténtalo de nuevo más tarde',
                    context,
                  );
                }
              }
            },
            style: const ButtonStyle(
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 22)),
              visualDensity: VisualDensity(horizontal: 1.2, vertical: 1.2),
            ),
            child: const Text('Registrarse'),
          ),
        ],
      ),
    );
  }
}

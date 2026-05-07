import 'package:flutter/material.dart';
import 'package:tfg/ui/common/my_app_bar.dart';
import 'package:tfg/ui/forms/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(title: 'Registro'),
      body: RegisterForm(),
    );
  }
}

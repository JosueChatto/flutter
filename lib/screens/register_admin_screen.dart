import 'package:flutter/material.dart';

class RegisterAdminScreen extends StatelessWidget {
  const RegisterAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Administrador')),
      body: const Center(
        child: Text('Formulario para registrar un nuevo administrador.'),
      ),
    );
  }
}

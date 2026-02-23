import 'package:flutter/material.dart';

class RegisterCafeteriaScreen extends StatelessWidget {
  const RegisterCafeteriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Cafetería')),
      body: const Center(
        child: Text('Formulario para registrar una nueva cafetería.'),
      ),
    );
  }
}


import 'package:flutter/material.dart';

class ScholarshipApplicationScreen extends StatelessWidget {
  const ScholarshipApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscripción a la Beca'),
      ),
      body: const Center(
        child: Text('Pantalla de Formulario de Inscripción'),
      ),
    );
  }
}

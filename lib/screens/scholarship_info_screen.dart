
import 'package:flutter/material.dart';

class ScholarshipInfoScreen extends StatelessWidget {
  const ScholarshipInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información de la Beca'),
      ),
      body: const Center(
        child: Text('Pantalla de Información de la Beca'),
      ),
    );
  }
}

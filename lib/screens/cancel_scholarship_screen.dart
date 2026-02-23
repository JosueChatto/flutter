import 'package:flutter/material.dart';

class CancelScholarshipScreen extends StatelessWidget {
  const CancelScholarshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anular Beca de Estudiante'),
      ),
      body: const Center(
        child: Text('Aquí se podrá anular la beca de un estudiante.'),
      ),
    );
  }
}

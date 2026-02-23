import 'package:flutter/material.dart';

class ManageActiveScholarshipsScreen extends StatelessWidget {
  const ManageActiveScholarshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Convocatorias Vigentes'),
      ),
      body: const Center(
        child: Text('Aquí se podrán editar las convocatorias vigentes.'),
      ),
    );
  }
}

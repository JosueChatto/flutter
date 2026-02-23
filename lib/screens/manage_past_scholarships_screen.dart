import 'package:flutter/material.dart';

class ManagePastScholarshipsScreen extends StatelessWidget {
  const ManagePastScholarshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Convocatorias Anteriores'),
      ),
      body: const Center(
        child: Text('Aquí se podrán eliminar las convocatorias pasadas.'),
      ),
    );
  }
}

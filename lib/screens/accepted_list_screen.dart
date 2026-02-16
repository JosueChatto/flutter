
import 'package:flutter/material.dart';

class AcceptedListScreen extends StatelessWidget {
  const AcceptedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Aceptados'),
      ),
      body: const Center(
        child: Text('Pantalla de Lista de Aceptados'),
      ),
    );
  }
}

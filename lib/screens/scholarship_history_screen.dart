
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScholarshipHistoryScreen extends StatelessWidget {
  const ScholarshipHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Becas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10, // Ejemplo: 10 becas otorgadas
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: const Icon(Icons.school_outlined, color: Colors.indigo),
              ),
              title: Text(
                'Beca de Excelencia Académica ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 4),
                  Text('Estudiante: Nombre del Estudiante'),
                  SizedBox(height: 2),
                  Text('Fecha de Aprobación: 2024-05-23'),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

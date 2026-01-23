
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScholarshipApplicantsScreen extends StatelessWidget {
  const ScholarshipApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Beca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5, // Ejemplo: 5 solicitudes
        itemBuilder: (context, index) {
          return Card(
            elevation: 3.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: const Icon(Icons.person_outline, color: Colors.indigo),
              ),
              title: Text(
                'Nombre del Estudiante ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Ingeniería en Sistemas Computacionales'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.go('/admin-dashboard/scholarship-applicants/applicant-details');
              },
            ),
          );
        },
      ),
    );
  }
}

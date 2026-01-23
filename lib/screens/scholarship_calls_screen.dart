
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScholarshipCallsScreen extends StatelessWidget {
  const ScholarshipCallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convocatorias de Beca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 3, // Ejemplo: 3 convocatorias
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: const Icon(Icons.campaign_outlined, size: 40, color: Colors.indigo),
              title: Text(
                'Beca Alimenticia 2024-B',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text('Periodo de registro: 01/08/2024 - 15/08/2024'),
                  SizedBox(height: 4),
                  Chip(
                    label: Text('Vigente'),
                    backgroundColor: Colors.greenAccent,
                  ),
                ],
              ),
              onTap: () {
                // TODO: Navegar al detalle de la convocatoria
              },
            ),
          );
        },
      ),
    );
  }
}

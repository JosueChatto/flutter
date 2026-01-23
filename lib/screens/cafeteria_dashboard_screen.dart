
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CafeteriaDashboardScreen extends StatelessWidget {
  const CafeteriaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo de estudiantes con beca alimenticia activa
    final List<Map<String, String>> students = List.generate(
      8,
      (index) => {
        'name': 'Estudiante ${index + 1}',
        'id': '202400${index + 1}',
        'status': 'Canjeado' // O 'Pendiente'
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Comedor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Estudiantes con Beca Alimenticia Activa',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final bool isRedeemed = student['status'] == 'Canjeado';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: isRedeemed ? Colors.green.shade100 : Colors.indigo.shade100,
                      child: Icon(
                        isRedeemed ? Icons.check_circle_outline : Icons.pending_outlined,
                        color: isRedeemed ? Colors.green.shade700 : Colors.indigo,
                      ),
                    ),
                    title: Text(
                      student['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('No. Control: ${student['id']!}'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRedeemed ? Colors.grey : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: isRedeemed
                          ? null // Deshabilitar si ya fue canjeado
                          : () {
                              // Lógica para registrar el canje
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Canje registrado para ${student['name']!}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Aquí se actualizaría el estado en la base de datos
                            },
                      child: Text(isRedeemed ? 'Canjeado' : 'Registrar'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

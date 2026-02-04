
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ApplicantDetailsScreen extends StatelessWidget {
  const ApplicantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extraer el ID de la aplicación de los parámetros de la ruta
    final String? applicationId = GoRouterState.of(context).extra as String?;

    if (applicationId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No se proporcionó un ID de solicitud.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Solicitante'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Navegación segura para volver a la lista
          onPressed: () => context.go('/admin-dashboard/scholarship-applicants'),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('applications').doc(applicationId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontró la solicitud.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final studentName = data?['studentName'] as String? ?? 'No disponible';
          final career = data?['career'] as String? ?? 'No disponible';
          final status = data?['status'] as String? ?? 'desconocido';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildDetailCard('Nombre del Estudiante', studentName, Icons.person_outline),
                const SizedBox(height: 16),
                _buildDetailCard('Carrera', career, Icons.school),
                const SizedBox(height: 16),
                _buildStatusCard(status),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Lógica para aprobar la solicitud (se implementará)
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Lógica para rechazar la solicitud (se implementará)
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    final statusInfo = {
      'pending': {
        'text': 'Pendiente',
        'icon': Icons.hourglass_top_outlined,
        'color': Colors.orange,
      },
      'approved': {
        'text': 'Aprobada',
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
      },
      'rejected': {
        'text': 'Rechazada',
        'icon': Icons.cancel_outlined,
        'color': Colors.red,
      },
    };

    final info = statusInfo[status] ?? statusInfo['pending']!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(info['icon'] as IconData, size: 40, color: info['color'] as Color),
        title: const Text('Estado de la Solicitud', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          info['text'] as String,
          style: TextStyle(fontSize: 16, color: info['color'] as Color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

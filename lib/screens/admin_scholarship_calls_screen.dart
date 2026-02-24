import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra el historial de convocatorias de becas para los administradores.
///
/// MEJORA: Ahora utiliza un `StreamBuilder` para mostrar las convocatorias en tiempo real.
/// Cualquier creación o modificación se reflejará instantáneamente sin necesidad de recargar.
class AdminScholarshipCallsScreen extends StatefulWidget {
  const AdminScholarshipCallsScreen({super.key});

  @override
  State<AdminScholarshipCallsScreen> createState() =>
      _AdminScholarshipCallsScreenState();
}

class _AdminScholarshipCallsScreenState
    extends State<AdminScholarshipCallsScreen> {

  /// Formatea un objeto [Timestamp] a una cadena de texto legible (dd/MM/yyyy).
  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy', 'es_ES').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Convocatorias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Crear Nueva Convocatoria',
            onPressed: () =>
                context.go('/admin-dashboard/create-scholarship-call'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // CORRECCIÓN: Apunta a la colección correcta 'calls' y usa snapshots para tiempo real.
        stream: FirebaseFirestore.instance
            .collection('calls')
            .orderBy('startDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar las convocatorias.'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No se han creado convocatorias. Presiona el botón (+) para crear la primera.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final calls = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              final data = call.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Sin Título';
              final periodCode = data['period_code'] ?? 'N/A';
              final startDate = data['startDate'] as Timestamp?;
              final endDate = data['endDate'] as Timestamp?;

              // Lógica para determinar el estatus de la convocatoria.
              final now = Timestamp.now();
              final isVigente =
                  startDate != null &&
                  endDate != null &&
                  now.compareTo(startDate) >= 0 &&
                  now.compareTo(endDate) <= 0;
              final isFinished = endDate != null && now.compareTo(endDate) > 0;

              String statusText;
              Color statusColor;
              IconData statusIcon;

              if (isVigente) {
                statusText = 'Vigente';
                statusColor = Colors.green.shade700;
                statusIcon = Icons.check_circle_outline;
              } else if (isFinished) {
                statusText = 'Finalizada';
                statusColor = Colors.grey.shade600;
                statusIcon = Icons.history;
              } else {
                statusText = 'Próxima';
                statusColor = Colors.blue.shade700;
                statusIcon = Icons.hourglass_top_outlined;
              }

              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(statusIcon, color: statusColor, size: 30),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(periodCode),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.7),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'Periodo: ${startDate != null ? _formatTimestamp(startDate) : 'N/A'} - ${endDate != null ? _formatTimestamp(endDate) : 'N/A'}\nEstatus: $statusText',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  isThreeLine: true,
                  onTap: () {
                    // Navega a la pantalla para ver los aplicantes de la convocatoria seleccionada.
                    context.go(
                      '/admin-dashboard/scholarship-applicants/${call.id}',
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class AcceptedListScreen extends StatelessWidget {
  const AcceptedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Convocatoria'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // --- CORRECCIÓN: Filtrado por fecha en lugar de status ---
        stream: FirebaseFirestore.instance
            .collection('scholarship_calls')
            .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay convocatorias vigentes.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final calls = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              final data = call.data() as Map<String, dynamic>;

              final startDate = (data['startDate'] as Timestamp?)?.toDate();
              final endDate = (data['endDate'] as Timestamp?)?.toDate();

              final period = (startDate != null && endDate != null)
                  ? '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}'
                  : 'Fechas no especificadas';

              // Determinar el estatus dinámicamente
              final statusText = (endDate != null && endDate.isBefore(DateTime.now()))
                  ? 'Finalizada'
                  : 'Vigente';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: Icon(
                    statusText == 'Vigente' ? Icons.check_circle : Icons.history,
                    color: statusText == 'Vigente' ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                  title: Text(
                    data['title'] ?? 'Beca sin título',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Periodo: $period'),
                      const SizedBox(height: 2),
                      Text(
                        'Estatus: $statusText',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.go('/admin-dashboard/accepted-list/${call.id}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

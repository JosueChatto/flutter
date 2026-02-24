import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class AcceptedListScreen extends StatelessWidget {
  const AcceptedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Convocatoria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('calls')
            .orderBy('endDate', descending: true) 
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
                    'No se han encontrado convocatorias.',
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

              final title = data['title'] ?? 'Beca sin título';
              final period = data['period'] ?? 'N/A'; // <-- CORREGIDO (aunque ya parecía estar bien, me aseguro)
              final endDate = (data['endDate'] as Timestamp?)?.toDate();
              
              final isPast = endDate != null && endDate.isBefore(DateTime.now());

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  leading: Icon(
                    isPast ? Icons.history : Icons.check_circle_outline,
                    color: isPast ? Colors.grey : Colors.green,
                    size: 30,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Periodo: $period'
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

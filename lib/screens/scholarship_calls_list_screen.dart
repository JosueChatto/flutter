import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Modelo para facilitar el manejo de los datos de la convocatoria
class ScholarshipCall {
  final String id;
  final String title;
  final Timestamp startDate;
  final Timestamp endDate;
  final String periodCode;

  ScholarshipCall({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.periodCode,
  });

  factory ScholarshipCall.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ScholarshipCall(
      id: doc.id,
      title: data['title'] ?? 'Sin Título',
      startDate: data['startDate'] ?? Timestamp.now(),
      endDate: data['endDate'] ?? Timestamp.now(),
      // Corregido para que coincida con la base de datos
      periodCode: data['period_code'] ?? 'N/A', 
    );
  }

  bool get isVigente {
    final now = Timestamp.now().toDate();
    // La convocatoria es vigente si 'now' está entre la fecha de inicio y la de fin.
    return now.isAfter(startDate.toDate()) && now.isBefore(endDate.toDate());
  }
}

class ScholarshipCallsListScreen extends StatelessWidget {
  const ScholarshipCallsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Convocatoria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('calls') // <<< CORRECCIÓN A 'calls'
            .orderBy('endDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar convocatorias: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay convocatorias vigentes.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final allCalls = snapshot.data!.docs
              .map((doc) => ScholarshipCall.fromFirestore(doc))
              .toList();

          // Filtramos solo las convocatorias vigentes
          final vigenteCalls = allCalls.where((call) => call.isVigente).toList();

          if (vigenteCalls.isEmpty) {
             return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay convocatorias vigentes.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: vigenteCalls.length,
            itemBuilder: (context, index) {
              final call = vigenteCalls[index];
              final formattedStartDate = DateFormat('dd/MM/yyyy').format(call.startDate.toDate());
              final formattedEndDate = DateFormat('dd/MM/yyyy').format(call.endDate.toDate());

              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    context.go(
                      '/student-dashboard/scholarship-application/${call.id}',
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                call.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Chip(
                              label: Text(call.periodCode),
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.date_range_outlined, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Vigencia: $formattedStartDate - $formattedEndDate',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              context.go(
                                '/student-dashboard/scholarship-application/${call.id}',
                              );
                            },
                            child: const Text('Aplicar ahora'),
                          ),
                        )
                      ],
                    ),
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

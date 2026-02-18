
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// Modelo para facilitar el manejo de los datos de la convocatoria
class ScholarshipCall {
  final String id;
  final String title;
  final String description;
  final Timestamp startDate;
  final Timestamp endDate;

  ScholarshipCall({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory ScholarshipCall.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ScholarshipCall(
      id: doc.id,
      title: data['title'] ?? 'Sin Título',
      description: data['description'] ?? 'Sin Descripción',
      startDate: data['startDate'] ?? Timestamp.now(),
      endDate: data['endDate'] ?? Timestamp.now(),
    );
  }

  bool get isVigente {
    final now = Timestamp.now();
    return now.compareTo(startDate) >= 0 && now.compareTo(endDate) <= 0;
  }
}

class ScholarshipCallsListScreen extends StatefulWidget {
  const ScholarshipCallsListScreen({super.key});

  @override
  State<ScholarshipCallsListScreen> createState() => _ScholarshipCallsListScreenState();
}

class _ScholarshipCallsListScreenState extends State<ScholarshipCallsListScreen> {
  late Future<List<ScholarshipCall>> _callsFuture;

  @override
  void initState() {
    super.initState();
    _callsFuture = _fetchScholarshipCalls();
  }

  Future<List<ScholarshipCall>> _fetchScholarshipCalls() async {
    final snapshot = await FirebaseFirestore.instance.collection('scholarship_calls').orderBy('startDate', descending: true).get();
    return snapshot.docs.map((doc) => ScholarshipCall.fromFirestore(doc)).toList();
  }

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
      body: FutureBuilder<List<ScholarshipCall>>(
        future: _callsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las convocatorias.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay convocatorias de beca disponibles en este momento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final calls = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              final bool isVigente = call.isVigente;

              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    isVigente ? Icons.check_circle_outline : Icons.history,
                    color: isVigente ? Colors.green.shade600 : Colors.grey.shade600,
                    size: 30,
                  ),
                  title: Text(call.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    isVigente ? 'Convocatoria Vigente' : 'Convocatoria Cerrada',
                    style: TextStyle(color: isVigente ? Colors.green.shade700 : Colors.grey.shade700),
                  ),
                  trailing: isVigente ? const Icon(Icons.arrow_forward_ios) : null,
                  onTap: isVigente
                      ? () {
                          // Navegar al formulario de aplicación, pasando el ID de la convocatoria
                          context.go('/student-dashboard/scholarship-application/${call.id}');
                        }
                      : null, // Deshabilitar si no está vigente
                  enabled: isVigente,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptedListScreen extends StatefulWidget {
  const AcceptedListScreen({super.key});

  @override
  State<AcceptedListScreen> createState() => _AcceptedListScreenState();
}

class _AcceptedListScreenState extends State<AcceptedListScreen> {
  late Future<List<QueryDocumentSnapshot>> _acceptedStudentsFuture;

  @override
  void initState() {
    super.initState();
    _acceptedStudentsFuture = _fetchAcceptedStudents();
  }

  Future<List<QueryDocumentSnapshot>> _fetchAcceptedStudents() async {
    // Usamos una consulta collectionGroup para buscar en todas las subcolecciones 'applicants'
    final querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('applicants')
        .where('status', isEqualTo: 'approved')
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Aceptados'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _acceptedStudentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los datos: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay estudiantes aceptados por el momento.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final acceptedStudents = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: acceptedStudents.length,
            itemBuilder: (context, index) {
              final studentData = acceptedStudents[index].data() as Map<String, dynamic>;
              final fullName = '${studentData['studentName'] ?? ''} ${studentData['lastName'] ?? ''}'.trim();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('No. Control: ${studentData['numberControl'] ?? 'N/A'}'),
                      const SizedBox(height: 2),
                      Text('Carrera: ${studentData['career'] ?? 'N/A'}'),
                    ],
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

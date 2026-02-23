import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// Widget para mostrar la información de cada estudiante, manejando la carga de datos del usuario.
class StudentInfoTile extends StatelessWidget {
  final Map<String, dynamic> applicantData;
  final String callId; // Se necesita para la navegación

  const StudentInfoTile({
    super.key,
    required this.applicantData,
    required this.callId,
  });

  Future<DocumentSnapshot> _getUserData() {
    final userId = applicantData['userId'];
    if (userId == null) {
      return Future.error('UserID no encontrado en la solicitud.');
    }
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _getUserData(),
      builder: (context, userSnapshot) {
        String nameToShow;
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          nameToShow = 'Cargando nombre...';
        } else if (userSnapshot.hasError ||
            !userSnapshot.hasData ||
            !userSnapshot.data!.exists) {
          nameToShow = 'Estudiante no encontrado';
        } else {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          nameToShow = '${userData['name'] ?? ''} ${userData['lastName'] ?? ''}'
              .trim();
        }

        return _buildTile(
          context,
          name: nameToShow,
          controlNumber: applicantData['numberControl'],
          career: applicantData['career'],
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String name,
    String? controlNumber,
    String? career,
  }) {
    final applicantId =
        applicantData['docId']; // El ID del documento del aplicante

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('No. Control: ${controlNumber ?? 'N/A'}'),
            if (career != null) ...[
              const SizedBox(height: 2),
              Text('Carrera: $career'),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // <<< ACCIÓN DE NAVEGACIÓN >>>
          if (applicantId != null) {
            context.go('/admin-dashboard/accepted-list/$callId/$applicantId');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Error: No se pudo encontrar el ID del estudiante.',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class AcceptedStudentsPerCallScreen extends StatefulWidget {
  final String callId;
  const AcceptedStudentsPerCallScreen({super.key, required this.callId});

  @override
  State<AcceptedStudentsPerCallScreen> createState() =>
      _AcceptedStudentsPerCallScreenState();
}

class _AcceptedStudentsPerCallScreenState
    extends State<AcceptedStudentsPerCallScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes Aceptados')),
      body: Column(children: [_buildSearchBar(), _buildStudentList()]),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por No. Control...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scholarship_calls')
            .doc(widget.callId)
            .collection('applicants')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(
              'No hay estudiantes aceptados para esta convocatoria.',
            );
          }

          var students = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Añadimos el ID del documento del aplicante para la navegación
            data['docId'] = doc.id;
            return data;
          }).toList();

          final filteredStudents = students.where((student) {
            final numberControl = (student['numberControl'] ?? '')
                .toLowerCase();
            return _searchQuery.isEmpty || numberControl.contains(_searchQuery);
          }).toList();

          if (filteredStudents.isEmpty) {
            return _buildEmptyState('No se encontraron estudiantes.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              final studentData = filteredStudents[index];
              return StudentInfoTile(
                applicantData: studentData,
                callId: widget.callId, // Pasamos el callId al Tile
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

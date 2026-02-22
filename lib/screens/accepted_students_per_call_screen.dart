import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptedStudentsPerCallScreen extends StatefulWidget {
  final String callId;
  const AcceptedStudentsPerCallScreen({super.key, required this.callId});

  @override
  State<AcceptedStudentsPerCallScreen> createState() =>
      _AcceptedStudentsPerCallScreenState();
}

class _AcceptedStudentsPerCallScreenState extends State<AcceptedStudentsPerCallScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCareer;
  String? _selectedGender;
  int? _selectedSemester;

  final List<String> _careers = [
    'Ingenieria en Inteligencia Artificial',
    'Ingenieria en Sistemas Computacionales',
    'Ingenieria Mecatronica',
    'Ingenieria Industrial',
    'Ingenieria Informatica',
    'Ingenieria en Gestion Empresarial',
    'Ingenieria Ambiental',
    'Ingenieria Bioquimica',
    'Arquitectura',
    'Licenciatura en Administracion',
    'Contador Publico',
  ];

  final List<String> _genders = ['Hombre', 'Mujer'];
  final List<int> _semesters = List.generate(12, (i) => i + 1);

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
      appBar: AppBar(
        title: const Text('Estudiantes Aceptados'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          _buildStudentList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o No. Control...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: [
          _buildDropdownFilter<String>(
            hint: 'Carrera',
            value: _selectedCareer,
            items: _careers,
            onChanged: (value) {
              setState(() {
                _selectedCareer = value;
              });
            },
          ),
          _buildDropdownFilter<String>(
            hint: 'Género',
            value: _selectedGender,
            items: _genders,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          _buildDropdownFilter<int>(
            hint: 'Semestre',
            value: _selectedSemester,
            items: _semesters,
            onChanged: (value) {
              setState(() {
                _selectedSemester = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required String hint,
    T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButton<T>(
      hint: Text(hint),
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<T>>((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
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
            return _buildEmptyState('No hay estudiantes aceptados para esta convocatoria.');
          }

          var students = snapshot.data!.docs.map((doc) {
            return {'id': doc.id, 'data': doc.data() as Map<String, dynamic>};
          }).toList();

          // Aplicar filtros
          final filteredStudents = students.where((student) {
            // AQUÍ ESTÁ LA CORRECCIÓN
            final data = student['data']! as Map<String, dynamic>;
            final fullName = '${data['name'] ?? ''} ${data['lastName'] ?? ''}'.toLowerCase();
            final numberControl = (data['numberControl'] ?? '').toLowerCase();

            final searchMatch = _searchQuery.isEmpty ||
                fullName.contains(_searchQuery) ||
                numberControl.contains(_searchQuery);
            
            final careerMatch = _selectedCareer == null || data['career'] == _selectedCareer;
            final genderMatch = _selectedGender == null || data['gender'] == _selectedGender;
            final semesterMatch = _selectedSemester == null || data['semester'] == _selectedSemester;

            return searchMatch && careerMatch && genderMatch && semesterMatch;
          }).toList();

          if (filteredStudents.isEmpty) {
            return _buildEmptyState('No se encontraron estudiantes con los filtros aplicados.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              // Y AQUÍ TAMBIÉN PARA ASEGURAR
              final studentData = filteredStudents[index]['data']! as Map<String, dynamic>;
              final fullName = '${studentData['name'] ?? ''} ${studentData['lastName'] ?? ''}'.trim();

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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;

class CafeteriaScholarListScreen extends StatefulWidget {
  final String callId;
  const CafeteriaScholarListScreen({super.key, required this.callId});

  @override
  State<CafeteriaScholarListScreen> createState() =>
      _CafeteriaScholarListScreenState();
}

class _CafeteriaScholarListScreenState extends State<CafeteriaScholarListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCareer, _selectedSemester, _selectedGender;

  late Stream<List<Map<String, dynamic>>> _studentsStream;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _setupStream();
  }

  void _setupStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _studentsStream = Stream.value([]);
      return;
    }
    final cafeteriaId = user.uid;

    _studentsStream = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .collection('applicants')
        .where('status', isEqualTo: 'approved')
        .where('assignedCafeteriaId', isEqualTo: cafeteriaId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return [];

      final userIds = snapshot.docs.map((doc) => doc.id).toList();
      if (userIds.isEmpty) return [];

      final usersSnapshot = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: userIds).get();
      final usersData = {for (var doc in usersSnapshot.docs) doc.id: doc.data()};

      return snapshot.docs.map((doc) {
        final userId = doc.id;
        final userData = usersData[userId];
        return userData != null ? {
          'userName': userData['name'] ?? '',
          'userLastName': userData['lastName'] ?? '',
          'userNumberControl': userData['numberControl'] ?? 'N/A',
          'userCareer': userData['career'] ?? 'N/A',
          'userSemester': userData['semester']?.toString() ?? 'N/A',
          'userGender': userData['gender'] ?? 'N/A',
        } : null;
      }).whereType<Map<String, dynamic>>().toList();
    });
  }

  // MODIFIED: This function now generates the CSV with the format you requested.
  Future<void> _generateAndDownloadCsv(List<Map<String, dynamic>> students) async {
    final callDoc = await FirebaseFirestore.instance.collection('calls').doc(widget.callId).get();
    final callData = callDoc.data();
    final callTitle = callData?['title'] ?? 'Convocatoria';

    final List<List<dynamic>> rows = [];

    // Header row as requested: No. de Control, Nombre Completo, Firma
    final headerRow = ['No. de Control', 'Nombre Completo', 'Firma'];
    rows.add(headerRow);

    // Sort students alphabetically
    students.sort((a, b) => ('${a['userName']} ${a['userLastName']}').compareTo('${b['userName']} ${b['userLastName']}'));

    // Data rows
    for (var student in students) {
      final fullName = '${student['userName'] ?? ''} ${student['userLastName'] ?? ''}'.trim();
      // Row structure with an empty placeholder for the signature
      final row = [student['userNumberControl'] ?? 'N/A', fullName, ''];
      rows.add(row);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    final String fileName = 'asistencia_${callTitle.replaceAll(' ', '_').toLowerCase()}.csv';

    // File download logic remains the same
    if (kIsWeb) {
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement..href = url..style.display = 'none'..download = fileName;
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(path)], text: 'Lista de Asistencia - $callTitle');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Becarios Asignados'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/cafeteria-dashboard'))),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState('No hay becados asignados a esta cafetería.');

          final allStudents = snapshot.data!;
          final careers = allStudents.map((s) => s['userCareer'].toString()).where((c) => c != 'N/A').toSet().toList()..sort();
          final semesters = allStudents.map((s) => s['userSemester'].toString()).where((sem) => sem != 'N/A').toSet().toList()..sort();
          final genders = allStudents.map((s) => s['userGender'].toString()).where((g) => g != 'N/A').toSet().toList()..sort();

          final filteredStudents = _filterStudents(allStudents);

          return Column(children: [
            _buildSearchBar(),
            _buildFilterBar(careers, semesters, genders),
            const Divider(height: 1),
            Expanded(
              child: filteredStudents.isEmpty
                  ? _buildEmptyState('No se encontraron becados con los filtros aplicados.')
                  : _buildStudentList(filteredStudents),
            )
          ]);
        },
      ),
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> students) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: students.length,
        itemBuilder: (context, index) => _buildStudentTile(students[index]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Pass the list of students to be exported
        onPressed: () => _generateAndDownloadCsv(students),
        label: const Text('Exportar Asistencia (CSV)'),
        icon: const Icon(Icons.archive_outlined),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por Nombre o No. de Control...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildFilterBar(List<String> careers, List<String> semesters, List<String> genders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0, runSpacing: 8.0, alignment: WrapAlignment.center,
        children: [
          _buildDropdownFilter('Carrera', _selectedCareer, careers, (v) => setState(() => _selectedCareer = v)),
          _buildDropdownFilter('Semestre', _selectedSemester, semesters, (v) => setState(() => _selectedSemester = v)),
          _buildDropdownFilter('Género', _selectedGender, genders, (v) => setState(() => _selectedGender = v)),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      hint: Text('Todos los $hint'),
      value: value,
      items: [DropdownMenuItem<String>(value: null, child: Text('Todos los $hint')), ...items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))],
      onChanged: onChanged,
    );
  }

  List<Map<String, dynamic>> _filterStudents(List<Map<String, dynamic>> students) {
    return students.where((student) {
      final name = ('${student['userName'] ?? ''} ${student['userLastName'] ?? ''}').toLowerCase();
      final numberControl = (student['userNumberControl'] ?? '').toLowerCase();

      final searchMatch = _searchQuery.isEmpty || name.contains(_searchQuery) || numberControl.contains(_searchQuery);
      final careerMatch = _selectedCareer == null || student['userCareer'] == _selectedCareer;
      final semesterMatch = _selectedSemester == null || student['userSemester'] == _selectedSemester;
      final genderMatch = _selectedGender == null || student['userGender'] == _selectedGender;

      return searchMatch && careerMatch && semesterMatch && genderMatch;
    }).toList();
  }

  Widget _buildStudentTile(Map<String, dynamic> studentData) {
    final name = ('${studentData['userName'] ?? ''} ${studentData['userLastName'] ?? ''}').trim();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name.isEmpty ? 'Nombre no disponible' : name),
        subtitle: Text('No. Control: ${studentData['userNumberControl'] ?? 'N/A'}'),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

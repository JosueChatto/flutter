import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ScholarshipApplicantsScreen extends StatefulWidget {
  final String callId;
  const ScholarshipApplicantsScreen({super.key, required this.callId});

  @override
  State<ScholarshipApplicantsScreen> createState() =>
      _ScholarshipApplicantsScreenState();
}

class _ScholarshipApplicantsScreenState
    extends State<ScholarshipApplicantsScreen> {
  late Future<DocumentSnapshot> _callDetailsFuture;
  late Stream<List<Map<String, dynamic>>> _applicantsStream;

  String? _selectedCareer;
  String? _selectedSemester;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _callDetailsFuture = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .get();
    _setupApplicantsStream();
  }

  void _setupApplicantsStream() {
    _applicantsStream = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .collection('applicants')
        .snapshots()
        .asyncMap((applicantSnapshot) async {
      if (applicantSnapshot.docs.isEmpty) return [];

      final userIds = applicantSnapshot.docs.map((doc) => doc.id).toList();
      
      if (userIds.isEmpty) return [];

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      final usersData = {for (var doc in usersSnapshot.docs) doc.id: doc.data()};

      return applicantSnapshot.docs.map((applicantDoc) {
        final applicantData = applicantDoc.data();
        final userId = applicantDoc.id;
        final userData = usersData[userId];

        if (userData != null) {
          return {
            ...applicantData,
            'id': userId,
            'studentName': userData['name'] ?? 'Nombre no disponible',
            'lastName': userData['lastName'] ?? '',
            'career': userData['career'] ?? 'N/A',
            'semester': userData['semester']?.toString() ?? 'N/A',
            'gender': userData['gender'] ?? 'N/A', // Asegúrate que este campo existe en tus documentos de usuario
            'numberControl': userData['numberControl'] ?? 'N/A',
          };
        }
        return null;
      }).where((item) => item != null).cast<Map<String, dynamic>>().toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCareer = null;
      _selectedSemester = null;
      _selectedGender = null;
    });
  }

  Future<void> _generateAndDownloadCsv(List<Map<String, dynamic>> applicants) async {
    final callDoc = await _callDetailsFuture;
    final String callPeriod;
    if (callDoc.exists && callDoc.data() != null) {
      final data = callDoc.data() as Map<String, dynamic>;
      final startDate = data.containsKey('start_date') ? (data['start_date'] as Timestamp).toDate() : null;
      final endDate = data.containsKey('end_date') ? (data['end_date'] as Timestamp).toDate() : null;
      if (startDate != null && endDate != null) {
        callPeriod = '${DateFormat('dd-MM-yyyy').format(startDate)} a ${DateFormat('dd-MM-yyyy').format(endDate)}';
      } else {
        callPeriod = 'N/A';
      }
    } else {
      callPeriod = 'N/A';
    }

    List<String> getStatusText(String status) {
        switch (status) {
            case 'approved': return ['Aprobado'];
            case 'rejected': return ['Rechazado'];
            default: return ['En Revisión'];
        }
    }

    final List<List<dynamic>> rows = [];
    rows.add(['#', 'Nombre Completo', 'No. de Control', 'Carrera', 'Semestre', 'Género', 'Estatus']);

    for (var i = 0; i < applicants.length; i++) {
        final applicant = applicants[i];
        final fullName = '${applicant['studentName'] ?? ''} ${applicant['lastName'] ?? ''}'.trim();
        rows.add([
            i + 1,
            fullName,
            applicant['numberControl'] ?? 'N/A',
            applicant['career'] ?? 'N/A',
            applicant['semester'] ?? 'N/A',
            applicant['gender'] ?? 'N/A',
            ...getStatusText(applicant['status'] ?? 'pending'),
        ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    final String fileName = 'lista_aplicantes_${callPeriod.replaceAll(' ', '_')}.csv';

    if (kIsWeb) {
      // Lógica para descargar en web
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      // Lógica para móvil
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(path)], text: 'Lista de Aplicantes - $callPeriod');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: _callDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData && snapshot.data!.exists) {
              final callTitle = (snapshot.data!.data() as Map<String, dynamic>)['title'] ?? 'Solicitantes';
              return Text(callTitle, overflow: TextOverflow.ellipsis);
            } else if (snapshot.hasError || (snapshot.connectionState == ConnectionState.done && !snapshot.data!.exists)) {
              return const Text('Error: Convocatoria no encontrada', style: TextStyle(color: Colors.white, fontSize: 16));
            }
            return const Text('Cargando...');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard/admin-scholarship-calls'),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _applicantsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar solicitantes: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay solicitudes para esta convocatoria.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          final allApplicants = snapshot.data!;
          
          final careers = allApplicants.map((a) => a['career'].toString()).where((c) => c != 'N/A').toSet().toList()..sort();
          final semesters = allApplicants.map((a) => a['semester'].toString()).where((s) => s != 'N/A').toSet().toList()..sort();
          // Corregido: Asegurarse que los valores de género son los correctos de la DB.
          final genders = allApplicants.map((a) => a['gender'].toString()).where((g) => g != 'N/A').toSet().toList()..sort();

          final filteredApplicants = allApplicants.where((applicant) {
            final careerMatch = _selectedCareer == null || applicant['career'] == _selectedCareer;
            final semesterMatch = _selectedSemester == null || applicant['semester'] == _selectedSemester;
            // Corregido: Lógica de filtro para género.
            final genderMatch = _selectedGender == null || applicant['gender'] == _selectedGender;
            return careerMatch && semesterMatch && genderMatch;
          }).toList();

          return Scaffold(
            body: Column(
              children: [
                _buildFilterSection(careers, semesters, genders),
                if (filteredApplicants.isEmpty && allApplicants.isNotEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No hay aplicantes que coincidan con los filtros seleccionados.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  ) 
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: filteredApplicants.length,
                      itemBuilder: (context, index) {
                        return _buildApplicantTile(filteredApplicants[index]);
                      },
                    ),
                  ),
              ],
            ),
             floatingActionButton: filteredApplicants.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _generateAndDownloadCsv(filteredApplicants),
                  label: const Text('Exportar a CSV'),
                  icon: const Icon(Icons.archive_outlined),
                )
              : null,
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(List<String> careers, List<String> semesters, List<String> genders) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDropdown('Carrera', careers, _selectedCareer, (v) => setState(() => _selectedCareer = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown('Semestre', semesters, _selectedSemester, (v) => setState(() => _selectedSemester = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown('Género', genders, _selectedGender, (v) => setState(() => _selectedGender = v))),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpiar Filtros'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40), 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
      value: selectedValue,
      items: [
        DropdownMenuItem<String>(value: null, child: Text('Todos')),
        ...items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildApplicantTile(Map<String, dynamic> applicant) {
    final fullName = '${applicant['studentName']} ${applicant['lastName']}'.trim();
    final career = applicant['career'] ?? 'N/A';
    final status = applicant['status'] ?? 'pending';

    Icon statusIcon;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusIcon = const Icon(Icons.check_circle, color: Colors.green);
        statusColor = Colors.green.shade100;
        statusText = 'Aprobado';
        break;
      case 'rejected':
        statusIcon = const Icon(Icons.cancel, color: Colors.red);
        statusColor = Colors.red.shade100;
        statusText = 'Rechazado';
        break;
      default: // pending
        statusIcon = const Icon(Icons.hourglass_empty, color: Colors.orange);
        statusColor = Colors.orange.shade100;
        statusText = 'En Revisión';
    }

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: CircleAvatar(backgroundColor: statusColor, child: statusIcon),
        title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$career - $statusText'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.go(
            '/admin-dashboard/scholarship-applicants/${widget.callId}/applicant-details/${applicant['id']}',
          );
        },
      ),
    );
  }
}

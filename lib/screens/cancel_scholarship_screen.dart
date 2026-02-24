import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CancelScholarshipScreen extends StatefulWidget {
  const CancelScholarshipScreen({super.key});

  @override
  State<CancelScholarshipScreen> createState() =>
      _CancelScholarshipScreenState();
}

class _CancelScholarshipScreenState extends State<CancelScholarshipScreen> {
  String? _selectedCallId;
  String? _selectedCallTitle;

  void _selectCall(String callId, String callTitle) {
    setState(() {
      _selectedCallId = callId;
      _selectedCallTitle = callTitle;
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedCallId = null;
      _selectedCallTitle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCallId == null
            ? 'Anular Beca: Seleccionar Convocatoria'
            : 'Becarios de: $_selectedCallTitle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedCallId != null) {
              _resetSelection();
            } else {
              context.go('/admin-dashboard/settings');
            }
          },
        ),
      ),
      body: _selectedCallId == null
          ? _buildCallSelectionView()
          : _StudentListView(callId: _selectedCallId!),
    );
  }

  Widget _buildCallSelectionView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('calls') // <<< CORREGIDO
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
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
            child: Text('No hay convocatorias vigentes actualmente.'),
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
            final period = (data['endDate'] as Timestamp?)?.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Finaliza: ${period != null ? DateFormat('dd/MM/yyyy').format(period) : 'N/A'}'
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _selectCall(call.id, title),
              ),
            );
          },
        );
      },
    );
  }
}

class _StudentListView extends StatefulWidget {
  final String callId;
  const _StudentListView({required this.callId});

  @override
  State<_StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<_StudentListView> {
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o No. Control...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('calls') // <<< CORREGIDO
                .doc(widget.callId)
                .collection('applicants')
                .where('status', isEqualTo: 'approved')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No hay becarios en esta convocatoria.'));
              }

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _combineWithUserData(snapshot.data!.docs),
                builder: (context, combinedSnapshot) {
                  if (combinedSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final students = combinedSnapshot.data ?? [];
                  final filteredStudents = students.where((student) {
                    final name = student['name'].toLowerCase();
                    final controlNumber = student['numberControl'].toLowerCase();
                    return name.contains(_searchQuery) || controlNumber.contains(_searchQuery);
                  }).toList();

                  if (filteredStudents.isEmpty) {
                    return const Center(child: Text('No se encontraron estudiantes.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final studentName = student['name'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("No. de Control: ${student['numberControl']}"),
                          trailing: ElevatedButton.icon(
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Anular'),
                            onPressed: () {
                              final docRef = FirebaseFirestore.instance
                                  .collection('calls') // <<< CORREGIDO
                                  .doc(widget.callId)
                                  .collection('applicants')
                                  .doc(student['applicantId']);
                              _showAnnulmentDialog(context, docRef);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              foregroundColor: Colors.red,
                              elevation: 0,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _combineWithUserData(
      List<QueryDocumentSnapshot> docs) async {
    final List<Future<Map<String, dynamic>?>> futureStudents = [];
    for (final doc in docs) {
      final applicantData = doc.data() as Map<String, dynamic>;
      final userId = doc.id; // En la subcolección de aplicantes, el ID del documento es el ID del usuario.

      final future = FirebaseFirestore.instance.collection('users').doc(userId).get().then((userDoc) {
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          return {
            'name': '${userData['name'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
            'numberControl': userData['numberControl'] ?? 'N/A', // <<< CORREGIDO
            'applicantId': doc.id,
          };
        } 
        return null;
      });
      futureStudents.add(future);
    }
    final resolved = await Future.wait(futureStudents);
    return resolved.whereType<Map<String, dynamic>>().toList();
  }

  void _showAnnulmentDialog(BuildContext context, DocumentReference docRef) {
    final formKey = GlobalKey<FormState>();
    String? selectedReason;
    final detailsController = TextEditingController();
    final reasons = [
      'Proporcionar datos falsos o alterar documentación',
      'Incumplir con cualquiera de sus obligaciones',
      'Baja temporal, definitiva o deserción del plantel',
      'No utilizar los servicios alimenticios otorgados',
      'Otro (especificar en detalles)',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Anular Beca del Estudiante'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona el motivo de la cancelación y añade detalles si es necesario.'),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Motivo de Cancelación',
                    border: OutlineInputBorder(),
                  ),
                  items: reasons
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => selectedReason = val,
                  validator: (val) => val == null ? 'Seleccione un motivo' : null,
                  isExpanded: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Detalles Adicionales',
                     border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirmar Anulación'),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                docRef.update({
                  'status': 'annulled',
                  'annulmentReason': selectedReason,
                  'annulmentDetails': detailsController.text.trim(),
                  'annulmentDate': FieldValue.serverTimestamp(),
                });
                Navigator.pop(dialogContext);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Beca anulada.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

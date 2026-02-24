import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class AcceptedStudentDetailsScreen extends StatefulWidget {
  final String callId;
  final String applicantId;

  const AcceptedStudentDetailsScreen({
    super.key,
    required this.callId,
    required this.applicantId,
  });

  @override
  State<AcceptedStudentDetailsScreen> createState() =>
      _AcceptedStudentDetailsScreenState();
}

class _AcceptedStudentDetailsScreenState
    extends State<AcceptedStudentDetailsScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _getCombinedData();
  }

  Future<Map<String, dynamic>> _getCombinedData() async {
    // CORRECCIÓN: Apunta a la colección 'calls'
    final applicantDoc = await FirebaseFirestore.instance
        .collection('calls') 
        .doc(widget.callId)
        .collection('applicants')
        .doc(widget.applicantId)
        .get();

    if (!applicantDoc.exists) {
      throw Exception('No se encontró la solicitud del aplicante.');
    }

    final applicantData = applicantDoc.data()!;
    // El userId es el ID del documento en la subcolección 'applicants'
    final userId = widget.applicantId;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return {
      'applicantData': applicantData,
      'userData': userDoc.exists ? userDoc.data() : null,
    };
  }

  int _calculateAge(Timestamp birthDate) {
    final DateTime birth = birthDate.toDate();
    final DateTime today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }

  Future<void> _showAnnulScholarshipDialog() async {
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

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Anular Beca del Estudiante'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona el motivo de la cancelación y añade detalles si es necesario.',
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Motivo de Cancelación',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: selectedReason,
                        items: reasons.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() => selectedReason = newValue);
                        },
                        validator: (value) =>
                            value == null ? 'Debes seleccionar un motivo' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: detailsController,
                        decoration: const InputDecoration(
                          labelText: 'Detalles Adicionales',
                          hintText: 'Opcional, a menos que el motivo sea "Otro".',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (selectedReason == 'Otro (especificar en detalles)' && (value == null || value.trim().isEmpty)) {
                            return 'Debes especificar los detalles para el motivo "Otro".';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(context).pop({
                        'reason': selectedReason,
                        'details': detailsController.text.trim(),
                      });
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Confirmar Anulación'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result['reason'] == null) return;

    try {
      // CORRECCIÓN: Apunta a la colección 'calls'
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .collection('applicants')
          .doc(widget.applicantId)
          .update({
        'status': 'annulled',
        'annulmentReason': result['reason'],
        'annulmentDetails': result['details'] ?? '',
        'annulmentDate': FieldValue.serverTimestamp(),
      });

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beca anulada con éxito.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al anular la beca: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Becario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          final applicantData = snapshot.data!['applicantData'] as Map<String, dynamic>;
          final userData = snapshot.data!['userData'] as Map<String, dynamic>?;
          
          final status = applicantData['status'] ?? '';
          final fullName = userData != null
              ? '${userData['name'] ?? ''} ${userData['lastName'] ?? ''}'.trim()
              : 'Nombre no disponible';

          String ageString = 'N/A';
          if (userData?['yearsold'] is Timestamp) {
            final age = _calculateAge(userData!['yearsold']);
            ageString = '$age años';
          }

          final reasons = applicantData['reasons'] as String?;
          final displayReason = (reasons != null && reasons.trim().isNotEmpty)
              ? reasons.trim()
              : 'El estudiante no proporcionó motivos.';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(status, applicantData),
                const SizedBox(height: 16),
                const Text(
                  'Información del Estudiante',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(context, [
                  _buildInfoRow(Icons.person, 'Nombre', fullName),
                  // CORRECCIÓN: Obtener el no. de control de userData
                  _buildInfoRow(Icons.confirmation_number, 'No. Control', userData?['numberControl'] ?? 'N/A'),
                  _buildInfoRow(Icons.school, 'Carrera', userData?['career'] ?? 'N/A'),
                  _buildInfoRow(Icons.leaderboard, 'Semestre', userData?['semester']?.toString() ?? 'N/A'),
                  _buildInfoRow(Icons.star_border, 'Promedio', applicantData['average']?.toString() ?? 'N/A'),
                  _buildInfoRow(Icons.email, 'Email', userData?['email'] ?? 'N/A'),
                  _buildInfoRow(Icons.phone, 'Teléfono', userData?['numberPhone'] ?? 'N/A'),
                  _buildInfoRow(Icons.cake_outlined, 'Edad', ageString),
                  _buildInfoRow(Icons.wc, 'Género', userData?['gender'] ?? 'N/A'),
                ]),
                const SizedBox(height: 24),
                const Text(
                  'Motivos de la Solicitud',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildReasonCard(context, displayReason),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            final status = (snapshot.data!['applicantData'] as Map<String, dynamic>)['status'] ?? '';
            if (status == 'approved') {
              return FloatingActionButton.extended(
                onPressed: _showAnnulScholarshipDialog,
                label: const Text('Anular Beca'),
                icon: const Icon(Icons.block),
                backgroundColor: Colors.red.shade700,
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(BuildContext context, String reason) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Text(reason, style: const TextStyle(fontSize: 16, height: 1.5), textAlign: TextAlign.justify),
      ),
    );
  }

  Widget _buildStatusBanner(String status, Map<String, dynamic> applicantData) {
    final Map<String, dynamic> statusInfo = {
      'approved': {
        'text': 'BECA APROBADA',
        'icon': Icons.check_circle_outline,
        'color': Colors.green.shade700,
      },
      'annulled': {
        'text': 'BECA ANULADA',
        'icon': Icons.block,
        'color': Colors.grey.shade600,
      },
    };

    final currentStatus = statusInfo[status];
    if (currentStatus == null) return const SizedBox.shrink();

    final color = currentStatus['color'] as Color;

    if (status == 'annulled') {
      final reason = applicantData['annulmentReason'] ?? 'Motivo no especificado.';
      return Card(
        color: color.withAlpha(25),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(currentStatus['icon'] as IconData, color: color, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    currentStatus['text'] as String,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text('Motivo: $reason', style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return Card(
      color: color.withAlpha(25),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(currentStatus['icon'] as IconData, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              currentStatus['text'] as String,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

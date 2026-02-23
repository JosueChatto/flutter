import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    final applicantDoc = await FirebaseFirestore.instance
        .collection('scholarship_calls')
        .doc(widget.callId)
        .collection('applicants')
        .doc(widget.applicantId)
        .get();

    if (!applicantDoc.exists) {
      throw Exception('No se encontró la solicitud del aplicante.');
    }

    final applicantData = applicantDoc.data()!;
    final userId = applicantData['userId'];

    if (userId == null) {
      return {'applicantData': applicantData, 'userData': null};
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      return {'applicantData': applicantData, 'userData': null};
    }

    return {'applicantData': applicantData, 'userData': userDoc.data()!};
  }

  Future<void> _annulScholarship() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Anular Beca?'),
        content: const Text(
          'Esta acción cambiará el estado de la beca a \'anulada\' y el estudiante perderá el beneficio. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, anular'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('scholarship_calls')
          .doc(widget.callId)
          .collection('applicants')
          .doc(widget.applicantId)
          .update({'status': 'annulled'});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Beca anulada con éxito.')));

      if (mounted) {
        context.pop(); // Regresa a la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al anular la beca: $e')));
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
            return Center(
              child: Text('Error al cargar los datos: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          final applicantData =
              snapshot.data!['applicantData'] as Map<String, dynamic>;
          final userData = snapshot.data!['userData'] as Map<String, dynamic>?;
          final status = applicantData['status'] ?? '';

          final fullName = userData != null
              ? '${userData['name'] ?? ''} ${userData['lastName'] ?? ''}'.trim()
              : 'Nombre no disponible';

          String birthDateFormatted = 'N/A';
          if (userData?['yearsold'] is Timestamp) {
            final timestamp = userData!['yearsold'] as Timestamp;
            birthDateFormatted = DateFormat(
              'dd de MMMM de yyyy',
              'es_ES',
            ).format(timestamp.toDate());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              100,
            ), // Espacio para FAB
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(status),
                const SizedBox(height: 16),
                const Text(
                  'Información del Estudiante',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(context, [
                  _buildInfoRow(Icons.person, 'Nombre', fullName),
                  _buildInfoRow(
                    Icons.confirmation_number,
                    'No. Control',
                    applicantData['numberControl'] ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.school,
                    'Carrera',
                    applicantData['career'] ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.leaderboard,
                    'Semestre',
                    applicantData['semester']?.toString() ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.star_border,
                    'Promedio',
                    userData?['gpa']?.toString() ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    userData?['email'] ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.phone,
                    'Teléfono',
                    userData?['numberPhone'] ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.cake,
                    'Fecha de Nacimiento',
                    birthDateFormatted,
                  ),
                  _buildInfoRow(
                    Icons.wc,
                    'Género',
                    userData?['gender'] ?? 'N/A',
                  ),
                ]),
                const SizedBox(height: 24),
                const Text(
                  'Motivos de la Solicitud',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildReasonCard(
                  context,
                  applicantData['reasonWhy'] ??
                      'El estudiante no proporcionó motivos.',
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final applicantData =
                snapshot.data!['applicantData'] as Map<String, dynamic>;
            final status = applicantData['status'] ?? '';

            if (status == 'approved') {
              return FloatingActionButton.extended(
                onPressed: _annulScholarship,
                label: const Text('Anular Beca'),
                icon: const Icon(Icons.block),
                backgroundColor: Colors.red.shade700,
              );
            }
          }
          return const SizedBox.shrink(); // No muestra nada si no está aprobada
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
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reason,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
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

    return Card(
      color: (currentStatus['color'] as Color).withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              currentStatus['icon'] as IconData,
              color: currentStatus['color'] as Color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              currentStatus['text'] as String,
              style: TextStyle(
                color: currentStatus['color'] as Color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

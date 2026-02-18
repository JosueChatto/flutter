
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ApplicantDetailsScreen extends StatefulWidget {
  final String callId;
  final String applicantId;

  const ApplicantDetailsScreen({
    super.key,
    required this.callId,
    required this.applicantId,
  });

  @override
  State<ApplicantDetailsScreen> createState() => _ApplicantDetailsScreenState();
}

class _ApplicantDetailsScreenState extends State<ApplicantDetailsScreen> {
  late Future<DocumentSnapshot> _applicantFuture;

  @override
  void initState() {
    super.initState();
    _applicantFuture = FirebaseFirestore.instance
        .collection('scholarship_calls')
        .doc(widget.callId)
        .collection('applicants')
        .doc(widget.applicantId)
        .get();
  }

  Future<void> _updateApplicationStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('scholarship_calls')
          .doc(widget.callId)
          .collection('applicants')
          .doc(widget.applicantId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud ${newStatus == 'approved' ? 'aprobada' : 'rechazada'}.')),
      );
      
      // Regresar a la lista de aplicantes de la convocatoria actual
      if (mounted) {
        context.go('/admin-dashboard/scholarship-applicants/${widget.callId}');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la solicitud: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión de Solicitud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
           // Navegación de vuelta a la lista de aplicantes correcta
          onPressed: () => context.go('/admin-dashboard/scholarship-applicants/${widget.callId}'),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _applicantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontró la solicitud.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          
          final fullName = '${data['studentName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          final career = data['career'] ?? 'N/A';
          final semester = data['semester']?.toString() ?? 'N/A';
          final gpa = data['gpa']?.toStringAsFixed(2) ?? 'N/A';
          final email = data['email'] ?? 'N/A';
          final numberControl = data['numberControl']?.toString() ?? 'N/A';
          final status = data['status'] ?? 'pending';
          final reasons = data['reasons'] ?? 'Sin motivos especificados.';
          final date = data['applicationDate'] as Timestamp?;
          final formattedDate = date != null ? DateFormat('dd/MM/yyyy').format(date.toDate()) : 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Padding inferior para botones
            child: Column(
              children: [
                _buildDetailCard('Nombre del Estudiante', fullName, Icons.person_outline),
                 _buildDetailCard('No. de Control', numberControl, Icons.confirmation_number_outlined),
                _buildDetailCard('Carrera', career, Icons.school_outlined),
                _buildDetailCard('Semestre', semester, Icons.bar_chart_outlined),
                _buildDetailCard('Promedio', gpa, Icons.star_border_outlined),
                _buildDetailCard('Email', email, Icons.email_outlined),
                _buildDetailCard('Fecha de Solicitud', formattedDate, Icons.calendar_today_outlined),
                _buildReasonsCard('Motivos de la Solicitud', reasons),
                const SizedBox(height: 16),
                _buildStatusCard(status),
              ],
            ),
          );
        },
      ),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildActionButtons(status: ( _applicantFuture as Future<DocumentSnapshot<Map<String,dynamic>>>).then((value) => value.data()?['status'] ?? 'pending') ),
    );
  }
  
  Widget _buildActionButtons({required Future<String> status}){
      return FutureBuilder<String>(
        future: status,
        builder: (context, snapshot) {
          if (snapshot.data == 'pending') {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateApplicationStatus('rejected'),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateApplicationStatus('approved'),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink(); // No mostrar botones si no está pendiente
        },
      );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
     return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }

  Widget _buildReasonsCard(String title, String value) {
    return Card(
       margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            Text(value, style: const TextStyle(fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    final statusMap = {
      'pending': {'text': 'Pendiente de Revisión', 'color': Colors.orange, 'icon': Icons.hourglass_empty},
      'approved': {'text': 'Aprobada', 'color': Colors.green, 'icon': Icons.check_circle},
      'rejected': {'text': 'Rechazada', 'color': Colors.red, 'icon': Icons.cancel},
    };
    final currentStatus = statusMap[status] ?? statusMap['pending']!;

    return Card(
      color: (currentStatus['color'] as Color).withOpacity(0.1),
      child: ListTile(
        leading: Icon(currentStatus['icon'] as IconData, color: currentStatus['color'] as Color),
        title: Text(
          currentStatus['text'] as String,
          style: TextStyle(fontWeight: FontWeight.bold, color: currentStatus['color'] as Color),
        ),
      ),
    );
  }
}

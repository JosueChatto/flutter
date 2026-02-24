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
  late Future<Map<String, DocumentSnapshot?>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, DocumentSnapshot?>> _loadData() async {
    final applicationFuture = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .collection('applicants')
        .doc(widget.applicantId)
        .get();

    final userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.applicantId)
        .get();

    final results = await Future.wait([applicationFuture, userFuture]);
    return {'application': results[0], 'user': results[1]};
  }

  Future<void> _updateApplicationStatus(String newStatus, {String? assignedCafeteria, String? assignedCafeteriaId}) async {
    try {
      final Map<String, dynamic> dataToUpdate = {'status': newStatus};
      if (assignedCafeteria != null && assignedCafeteriaId != null) {
        dataToUpdate['assignedCafeteria'] = assignedCafeteria;
        dataToUpdate['assignedCafeteriaId'] = assignedCafeteriaId;
      }

      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .collection('applicants')
          .doc(widget.applicantId)
          .update(dataToUpdate);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud ${newStatus == 'approved' ? 'aprobada' : 'rechazada'}.')),
      );

      context.go('/admin-dashboard/scholarship-applicants/${widget.callId}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la solicitud: $e')),
      );
    }
  }

  Future<void> _showAssignCafeteriaDialog() async {
    // Correctly query for users with rol: 'cafeteria'
    final cafeteriasSnapshot = await FirebaseFirestore.instance.collection('users').where('rol', isEqualTo: 'cafeteria').get();
    final cafeterias = cafeteriasSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc.data()['nameCafeteria'] as String? ?? 'Sin Nombre Asignado'
      };
    }).toList();

    final formKey = GlobalKey<FormState>();
    Map<String, String>? selectedCafeteria;

    if (!mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Asignar Cafetería'),
          content: Form(
            key: formKey,
            child: DropdownButtonFormField<Map<String, String>>(
              decoration: const InputDecoration(
                labelText: 'Seleccione una cafetería',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Seleccione...'),
              items: cafeterias.map((cafeteria) {
                return DropdownMenuItem<Map<String, String>>(
                  value: {'id': cafeteria['id']!, 'name': cafeteria['name']!},
                  child: Text(cafeteria['name']!),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedCafeteria = newValue;
              },
              validator: (value) => value == null ? 'Por favor, seleccione una cafetería.' : null,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _updateApplicationStatus(
                    'approved',
                    assignedCafeteria: selectedCafeteria!['name'],
                    assignedCafeteriaId: selectedCafeteria!['id'],
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, DocumentSnapshot?>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        Widget bodyWidget;
        String status = 'pending';

        if (snapshot.connectionState == ConnectionState.waiting) {
          bodyWidget = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          bodyWidget = Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || !snapshot.data!['application']!.exists || !snapshot.data!['user']!.exists) {
          bodyWidget = const Center(child: Text('No se encontraron datos de la solicitud o del usuario.'));
        } else {
          final appData = snapshot.data!['application']!.data() as Map<String, dynamic>;
          final userData = snapshot.data!['user']!.data() as Map<String, dynamic>;
          status = appData['status'] as String? ?? 'pending';

          final fullName = '${userData['name'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
          final career = userData['career'] as String? ?? 'N/A';
          final semester = userData['semester']?.toString() ?? 'N/A';
          final gpa = (appData['gpa'] as num?)?.toStringAsFixed(2) ?? 'N/A';
          final email = userData['email'] as String? ?? 'N/A';
          final numberControl = userData['numberControl'] as String? ?? 'N/A';
          final reasons = appData['reasons'] as String? ?? 'Sin motivos especificados.';
          final date = appData['applicationDate'] as Timestamp?;
          final formattedDate = date != null ? DateFormat('dd/MM/yyyy', 'es_ES').format(date.toDate()) : 'N/A';
          final assignedCafeteria = appData['assignedCafeteria'] as String?;

          bodyWidget = SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            child: Column(
              children: [
                _buildDetailCard(context, 'Nombre del Estudiante', fullName, Icons.person_outline),
                _buildDetailCard(context, 'No. de Control', numberControl, Icons.confirmation_number_outlined),
                _buildDetailCard(context, 'Carrera', career, Icons.school_outlined),
                _buildDetailCard(context, 'Semestre', semester, Icons.bar_chart_outlined),
                _buildDetailCard(context, 'Promedio de la Solicitud', gpa, Icons.star_border_outlined),
                _buildDetailCard(context, 'Email', email, Icons.email_outlined),
                _buildDetailCard(context, 'Fecha de Solicitud', formattedDate, Icons.calendar_today_outlined),
                _buildReasonsCard(context, 'Motivos de la Solicitud', reasons),
                const SizedBox(height: 16),
                if (assignedCafeteria != null)
                  _buildDetailCard(context, 'Cafetería Asignada', assignedCafeteria, Icons.storefront_outlined),
                _buildStatusCard(status),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Revisión de Solicitud'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/admin-dashboard/scholarship-applicants/${widget.callId}'),
            ),
          ),
          body: bodyWidget,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildActionButtons(status: status),
        );
      },
    );
  }

   Widget _buildActionButtons({required String status}) {
    if (status != 'pending') {
      return const SizedBox.shrink();
    }
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
              onPressed: _showAssignCafeteriaDialog,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aprobar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
        subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }

  Widget _buildReasonsCard(BuildContext context, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const Divider(height: 20),
            Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
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
        title: Text(currentStatus['text'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: currentStatus['color'] as Color)),
      ),
    );
  }
}

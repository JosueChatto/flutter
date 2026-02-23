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

  Future<void> _updateApplicationStatus(String newStatus, {String? assignedCafeteria}) async {
    try {
      final Map<String, dynamic> dataToUpdate = {'status': newStatus};
      if (assignedCafeteria != null) {
        dataToUpdate['assignedCafeteria'] = assignedCafeteria;
      }

      await FirebaseFirestore.instance
          .collection('scholarship_calls')
          .doc(widget.callId)
          .collection('applicants')
          .doc(widget.applicantId)
          .update(dataToUpdate);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud ${newStatus == 'approved' ? 'aprobada' : 'rechazada'}.')),
      );
      
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

  Future<void> _showAssignCafeteriaDialog() async {
    String? selectedCafeteria;
    final cafeterias = ['Norte', 'Sur', 'Este'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Asignar Cafetería'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Seleccione una cafetería'),
            value: selectedCafeteria,
            items: cafeterias.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              selectedCafeteria = newValue;
            },
            validator: (value) => value == null ? 'Campo requerido' : null,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                if (selectedCafeteria != null) {
                  Navigator.of(context).pop();
                  _updateApplicationStatus('approved', assignedCafeteria: selectedCafeteria);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión de Solicitud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
          final assignedCafeteria = data['assignedCafeteria'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            child: Column(
              children: [
                _buildDetailCard(context, 'Nombre del Estudiante', fullName, Icons.person_outline),
                _buildDetailCard(context, 'No. de Control', numberControl, Icons.confirmation_number_outlined),
                _buildDetailCard(context, 'Carrera', career, Icons.school_outlined),
                _buildDetailCard(context, 'Semestre', semester, Icons.bar_chart_outlined),
                _buildDetailCard(context, 'Promedio', gpa, Icons.star_border_outlined),
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
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<DocumentSnapshot>(
        future: _applicantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            final status = (snapshot.data!.data() as Map<String, dynamic>)['status'] ?? 'pending';
            if (status == 'pending') {
              return _buildActionButtons();
            }
          }
          return const SizedBox.shrink();
        },
      ), 
    );
  }
  
  Widget _buildActionButtons(){
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
     final TextTheme textTheme = Theme.of(context).textTheme;
     return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
        subtitle: Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface, // Color correcto para el tema
          ),
        ),
      ),
    );
  }

  Widget _buildReasonsCard(BuildContext context, String title, String value) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
       margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const Divider(height: 20),
            Text(value, style: textTheme.bodyMedium?.copyWith(height: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
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

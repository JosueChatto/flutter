import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra los detalles completos de la solicitud de un estudiante.
///
/// El administrador puede revisar toda la información proporcionada por el aplicante
/// y tomar una decisión, ya sea aprobando (y asignando una cafetería) o
/// rechazando la solicitud. Las acciones solo están disponibles si la solicitud
/// está en estado 'pendiente'.
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
  /// Futuro que contiene los datos del aplicante, obtenido de Firestore.
  late Future<DocumentSnapshot> _applicantFuture;

  @override
  void initState() {
    super.initState();
    // Se inicializa la carga de datos del aplicante en cuanto se crea el widget.
    _applicantFuture = FirebaseFirestore.instance
        .collection('scholarship_calls')
        .doc(widget.callId)
        .collection('applicants')
        .doc(widget.applicantId)
        .get();
  }

  /// Actualiza el estado de la solicitud en Firestore ('approved' o 'rejected').
  ///
  /// Si se aprueba, también puede incluir la cafetería asignada.
  /// Muestra una notificación (SnackBar) y navega de vuelta a la lista de aplicantes.
  Future<void> _updateApplicationStatus(
    String newStatus, {
    String? assignedCafeteria,
  }) async {
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
        SnackBar(
          content: Text(
            'Solicitud ${newStatus == 'approved' ? 'aprobada' : 'rechazada'}.',
          ),
        ),
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

  /// Muestra un diálogo para que el administrador seleccione una cafetería al aprobar una solicitud.
  Future<void> _showAssignCafeteriaDialog() async {
    String? selectedCafeteria;
    // Lista fija de cafeterías disponibles.
    final cafeterias = ['Norte', 'Sur', 'Este'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Asignar Cafetería'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Seleccione una cafetería',
            ),
            value: selectedCafeteria,
            items: cafeterias.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
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
                  _updateApplicationStatus(
                    'approved',
                    assignedCafeteria: selectedCafeteria,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión de Solicitud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(
            '/admin-dashboard/scholarship-applicants/${widget.callId}',
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _applicantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text('No se encontró la solicitud.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final fullName =
              '${data['studentName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          final career = data['career'] ?? 'N/A';
          final semester = data['semester']?.toString() ?? 'N/A';
          final gpa = data['gpa']?.toStringAsFixed(2) ?? 'N/A';
          final email = data['email'] ?? 'N/A';
          final numberControl = data['numberControl']?.toString() ?? 'N/A';
          final status = data['status'] ?? 'pending';
          final reasons = data['reasons'] ?? 'Sin motivos especificados.';
          final date = data['applicationDate'] as Timestamp?;
          final formattedDate = date != null
              ? DateFormat('dd/MM/yyyy', 'es_ES').format(date.toDate())
              : 'N/A';
          final assignedCafeteria = data['assignedCafeteria'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            child: Column(
              children: [
                _buildDetailCard(
                  context,
                  'Nombre del Estudiante',
                  fullName,
                  Icons.person_outline,
                ),
                _buildDetailCard(
                  context,
                  'No. de Control',
                  numberControl,
                  Icons.confirmation_number_outlined,
                ),
                _buildDetailCard(
                  context,
                  'Carrera',
                  career,
                  Icons.school_outlined,
                ),
                _buildDetailCard(
                  context,
                  'Semestre',
                  semester,
                  Icons.bar_chart_outlined,
                ),
                _buildDetailCard(
                  context,
                  'Promedio',
                  gpa,
                  Icons.star_border_outlined,
                ),
                _buildDetailCard(context, 'Email', email, Icons.email_outlined),
                _buildDetailCard(
                  context,
                  'Fecha de Solicitud',
                  formattedDate,
                  Icons.calendar_today_outlined,
                ),
                _buildReasonsCard(context, 'Motivos de la Solicitud', reasons),
                const SizedBox(height: 16),
                if (assignedCafeteria != null)
                  _buildDetailCard(
                    context,
                    'Cafetería Asignada',
                    assignedCafeteria,
                    Icons.storefront_outlined,
                  ),
                _buildStatusCard(status),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Los botones de acción solo se muestran si el estado es 'pending'.
      floatingActionButton: FutureBuilder<DocumentSnapshot>(
        future: _applicantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final status =
                (snapshot.data!.data() as Map<String, dynamic>)['status'] ??
                'pending';
            if (status == 'pending') {
              return _buildActionButtons();
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Construye los botones de acción para aprobar y rechazar la solicitud.
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateApplicationStatus('rejected'),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Rechazar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showAssignCafeteriaDialog,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aprobar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget reutilizable para mostrar un campo de detalle con ícono, título y valor.
  Widget _buildDetailCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
        ),
        subtitle: Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  /// Widget para mostrar el campo de "motivos" con un formato distintivo.
  Widget _buildReasonsCard(BuildContext context, String title, String value) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Divider(height: 20),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget que muestra el estado actual de la solicitud con un color e ícono representativo.
  Widget _buildStatusCard(String status) {
    final statusMap = {
      'pending': {
        'text': 'Pendiente de Revisión',
        'color': Colors.orange,
        'icon': Icons.hourglass_empty,
      },
      'approved': {
        'text': 'Aprobada',
        'color': Colors.green,
        'icon': Icons.check_circle,
      },
      'rejected': {
        'text': 'Rechazada',
        'color': Colors.red,
        'icon': Icons.cancel,
      },
    };
    final currentStatus = statusMap[status] ?? statusMap['pending']!;

    return Card(
      color: (currentStatus['color'] as Color).withOpacity(0.1),
      child: ListTile(
        leading: Icon(
          currentStatus['icon'] as IconData,
          color: currentStatus['color'] as Color,
        ),
        title: Text(
          currentStatus['text'] as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: currentStatus['color'] as Color,
          ),
        ),
      ),
    );
  }
}

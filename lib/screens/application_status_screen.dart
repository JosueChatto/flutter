
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  late Future<QuerySnapshot> _applicationFuture;

  @override
  void initState() {
    super.initState();
    _loadApplicationStatus();
  }

  void _loadApplicationStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _applicationFuture = FirebaseFirestore.instance
          .collection('applications')
          .where('studentID', isEqualTo: user.uid)
          .limit(1)
          .get();
    } else {
      // Si no hay usuario, creamos un Future que resuelva a un error o a un snapshot vacío.
      _applicationFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatus de la Solicitud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _applicationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildStatusCard(
              context,
              status: 'No Encontrada',
              title: 'Sin Solicitud Registrada',
              message: 'Parece que aún no has enviado tu solicitud de beca. Puedes hacerlo desde la opción \"Inscripción a la Beca\" en tu portal.',
              icon: Icons.search_off_rounded,
              color: Colors.grey.shade600,
            );
          }

          // Tenemos datos, usamos el primer documento encontrado
          final applicationData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final status = applicationData['status'] as String? ?? 'En Revisión';

          return _buildStatusView(context, status);
        },
      ),
    );
  }

  Widget _buildStatusView(BuildContext context, String status) {
    String statusTitle, statusMessage;
    IconData statusIcon;
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'approved':
        statusIcon = Icons.check_circle_outline;
        statusColor = Colors.green.shade700;
        statusTitle = '¡Beca Aprobada!';
        statusMessage = '¡Felicidades! Tu solicitud de beca ha sido aceptada. Pronto recibirás un correo con los siguientes pasos y cómo hacer uso de tu beneficio en la cafetería.';
        break;
      case 'rejected':
        statusIcon = Icons.highlight_off_outlined;
        statusColor = Colors.red.shade700;
        statusTitle = 'Solicitud Rechazada';
        statusMessage = 'Lo sentimos, tu solicitud no fue aprobada en esta ocasión. Te invitamos a estar pendiente de futuras convocatorias y verificar que cumplas con todos los criterios.';
        break;
      case 'pending':
      default:
        statusIcon = Icons.hourglass_empty_outlined;
        statusColor = Colors.amber.shade800;
        statusTitle = 'Solicitud en Proceso';
        statusMessage = 'Hemos recibido tu solicitud y tus documentos. El comité de becas la está revisando. El resultado se publicará en las fechas indicadas en la convocatoria.';
        break;
    }

    return _buildStatusCard(
      context,
      status: status.replaceAll('approved', 'Aprobada').replaceAll('rejected', 'Rechazada').replaceAll('pending', 'En Revisión'),
      title: statusTitle,
      message: statusMessage,
      icon: statusIcon,
      color: statusColor,
    );
  }

  Widget _buildStatusCard(BuildContext context, {required String status, required String title, required String message, required IconData icon, required Color color}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 80, color: color),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (status != 'No Encontrada')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Estado: $status',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Modelo de datos que combina la información de una solicitud de beca
/// con los detalles de su convocatoria correspondiente.
class ApplicationWithCallDetails {
  final Map<String, dynamic> applicationData;
  final Map<String, dynamic> callData;

  ApplicationWithCallDetails({
    required this.applicationData,
    required this.callData,
  });
}

/// Pantalla que muestra al estudiante el estado de todas sus solicitudes de beca.
///
/// Carga las solicitudes del usuario actual y las muestra en una lista, indicando
/// el estado de cada una (En Revisión, Aprobada, Rechazada, Anulada).
class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() =>
      _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  /// Futuro que contendrá la lista combinada de solicitudes y detalles de convocatorias.
  late Future<List<ApplicationWithCallDetails>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _loadUserApplications();
  }

  /// Carga todas las solicitudes del usuario actual y las enriquece con los
  /// datos de sus respectivas convocatorias.
  ///
  /// Este método realiza una consulta principal para obtener las solicitudes y luego
  /// consultas secundarias para obtener los detalles de cada convocatoria, combinándolos
  /// en una lista de [ApplicationWithCallDetails].
  ///
  /// Nota: Este enfoque puede llevar a múltiples lecturas en Firestore. Una posible
  /// optimización a futuro sería la desnormalización de datos, incluyendo
  /// el título de la convocatoria directamente en el documento de la solicitud.
  Future<List<ApplicationWithCallDetails>> _loadUserApplications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // 1. Obtiene todas las solicitudes del usuario actual.
    final applicationsSnapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('studentId', isEqualTo: user.uid)
        .get();

    if (applicationsSnapshot.docs.isEmpty) {
      return [];
    }

    final List<Future<ApplicationWithCallDetails?>> futureDetails = [];

    // 2. Para cada solicitud, prepara una consulta para obtener los detalles de la convocatoria.
    for (final doc in applicationsSnapshot.docs) {
      final applicationData = doc.data();
      final callId = applicationData['callId'] as String?;

      if (callId != null) {
        final futureDetail = FirebaseFirestore.instance
            .collection('scholarship_calls')
            .doc(callId)
            .get()
            .then((callDoc) {
              if (!callDoc.exists)
                return null; // Devuelve null si la convocatoria fue eliminada.
              final callData = callDoc.data()!;
              return ApplicationWithCallDetails(
                applicationData: applicationData,
                callData: callData,
              );
            });
        futureDetails.add(futureDetail);
      }
    }

    // 3. Ejecuta todas las consultas de detalles en paralelo y filtra los resultados nulos.
    final results = await Future.wait(futureDetails);
    return results
        .where((item) => item != null)
        .cast<ApplicationWithCallDetails>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatus de Mis Solicitudes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: FutureBuilder<List<ApplicationWithCallDetails>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar tus solicitudes: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const _NoApplicationsView();
          }

          final applications = snapshot.data!;
          return _ApplicationsListView(applications: applications);
        },
      ),
    );
  }
}

/// Widget que muestra la lista de solicitudes del usuario.
class _ApplicationsListView extends StatelessWidget {
  final List<ApplicationWithCallDetails> applications;

  const _ApplicationsListView({required this.applications});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final item = applications[index];
        final appData = item.applicationData;
        final callData = item.callData;

        final status = appData['status'] as String? ?? 'pending';
        final applicationDate = appData['applicationDate'] as Timestamp?;
        final formattedDate = applicationDate != null
            ? DateFormat('dd/MM/yyyy', 'es_ES').format(applicationDate.toDate())
            : 'Fecha no disponible';
        final callTitle = callData['title'] ?? 'Convocatoria Desconocida';

        final statusInfo = _getStatusInfo(status);

        final isCancelled = status == 'cancelled';
        final cancellationReasons =
            isCancelled && appData['cancellationReasons'] != null
            ? (appData['cancellationReasons'] as List).cast<String>()
            : <String>[];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isCancelled
                ? BorderSide(color: statusInfo['color'], width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      statusInfo['icon'],
                      color: statusInfo['color'],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estado: ${statusInfo['text']}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusInfo['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'Fecha de solicitud: $formattedDate',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (isCancelled && cancellationReasons.isNotEmpty)
                  _buildCancellationReasons(context, cancellationReasons),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye la sección que muestra los motivos de anulación de una beca.
  Widget _buildCancellationReasons(BuildContext context, List<String> reasons) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Motivos de la Anulación:',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Text(reason)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Devuelve un mapa con el texto, color e ícono correspondientes a un estado.
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return {
          'text': 'Aprobada',
          'color': Colors.green.shade700,
          'icon': Icons.check_circle,
        };
      case 'rejected':
        return {
          'text': 'Rechazada',
          'color': Colors.red.shade700,
          'icon': Icons.cancel,
        };
      case 'cancelled':
        return {
          'text': 'Beca Anulada',
          'color': Colors.grey.shade600,
          'icon': Icons.do_not_disturb_on,
        };
      case 'pending':
      default:
        return {
          'text': 'En Revisión',
          'color': Colors.amber.shade800,
          'icon': Icons.hourglass_empty,
        };
    }
  }
}

/// Widget que se muestra cuando el usuario no tiene ninguna solicitud activa.
///
/// Anima al usuario a buscar nuevas convocatorias y le proporciona un botón para ello.
class _NoApplicationsView extends StatelessWidget {
  const _NoApplicationsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_off_outlined,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'Aún no has solicitado becas',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              '¡Anímate! Revisa las convocatorias disponibles y encuentra la ideal para ti.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.search_rounded),
              label: const Text('Ver Convocatorias Disponibles'),
              onPressed: () =>
                  context.go('/student-dashboard/scholarship-calls'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ApplicationWithCallDetails {
  final Map<String, dynamic> applicationData;
  final Map<String, dynamic> callData;
  final DocumentReference applicationReference;

  ApplicationWithCallDetails({
    required this.applicationData,
    required this.callData,
    required this.applicationReference,
  });
}

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() =>
      _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  late Future<List<ApplicationWithCallDetails>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _loadUserApplications();
  }

  /// Carga las solicitudes del usuario actual usando una consulta collectionGroup
  /// para encontrar todas las solicitudes anidadas y las enriquece con los datos de sus
  /// respectivas convocatorias.
  Future<List<ApplicationWithCallDetails>> _loadUserApplications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // 1. Usa collectionGroup para buscar en todas las sub-colecciones 'applicants'.
    //    Filtra por el 'userId' del usuario actual.
    final applicationsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('applicants')
        .where('userId', isEqualTo: user.uid)
        .get();

    if (applicationsSnapshot.docs.isEmpty) {
      return [];
    }

    final List<Future<ApplicationWithCallDetails?>> futureDetails = [];

    // 2. Para cada solicitud encontrada, prepara una consulta para obtener los detalles de su convocatoria padre.
    for (final applicantDoc in applicationsSnapshot.docs) {
      final applicationData = applicantDoc.data();
      
      // La referencia al documento de la convocatoria es el padre de la sub-colección 'applicants'
      final callDocRef = applicantDoc.reference.parent.parent;

      if (callDocRef != null) {
        final futureDetail = callDocRef.get().then((callDoc) {
          if (!callDoc.exists) {
            return null; // Devuelve null si la convocatoria fue eliminada.
          }
          final callData = callDoc.data()!;
          return ApplicationWithCallDetails(
            applicationData: applicationData,
            callData: callData,
            applicationReference: applicantDoc.reference,
          );
        });
        futureDetails.add(futureDetail);
      }
    }

    // 3. Ejecuta todas las consultas en paralelo y filtra los resultados nulos.
    final results = await Future.wait(futureDetails);
    return results.where((item) => item != null).cast<ApplicationWithCallDetails>().toList();
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
          return RefreshIndicator(
            onRefresh: () {
              setState(() {
                _applicationsFuture = _loadUserApplications();
              });
              return _applicationsFuture;
            },
            child: _ApplicationsListView(applications: applications),
          );
        },
      ),
    );
  }
}

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
        final periodCode = callData['period_code'] ?? 'N/A';

        final statusInfo = _getStatusInfo(status);

        final isAnnulled = status == 'annulled';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: statusInfo['color'].withOpacity(isAnnulled ? 1.0 : 0.2),
              width: isAnnulled ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                 Text(
                  'Periodo: $periodCode',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
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
                if (isAnnulled)
                  _buildAnnulmentInfo(context, appData),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnulmentInfo(BuildContext context, Map<String, dynamic> appData) {
    final reason = appData['annulmentReason'] as String?;
    final details = appData['annulmentDetails'] as String?;

    if (reason == null || reason.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de la Anulación:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildInfoItem(context, Icons.label_important_outline, 'Motivo', reason),
          if (details != null && details.isNotEmpty)
            _buildInfoItem(context, Icons.format_quote_outlined, 'Detalles Adicionales', details),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      case 'annulled': // Corregido de 'cancelled'
        return {
          'text': 'Beca Anulada',
          'color': Colors.grey.shade700,
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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

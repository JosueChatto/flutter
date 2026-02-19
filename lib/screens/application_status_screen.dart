
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Modelo para combinar los datos de la solicitud y su convocatoria
class ApplicationWithCallDetails {
  final Map<String, dynamic> applicationData;
  final Map<String, dynamic> callData;

  ApplicationWithCallDetails({
    required this.applicationData,
    required this.callData,
  });
}

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  late Future<List<ApplicationWithCallDetails>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _loadUserApplications();
  }

  Future<List<ApplicationWithCallDetails>> _loadUserApplications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // 1. Usar collectionGroup para buscar en todas las subcolecciones 'applicants'
    final applicationsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('applicants')
        .where('studentID', isEqualTo: user.uid)
        .get();

    if (applicationsSnapshot.docs.isEmpty) {
      return []; // No hay aplicaciones
    }

    final List<Future<ApplicationWithCallDetails>> futureDetails = [];

    for (final doc in applicationsSnapshot.docs) {
      final applicationData = doc.data();
      final callId = applicationData['callId'] as String?;

      if (callId != null) {
        // 2. Para cada aplicación, buscar los detalles de su convocatoria padre
        final futureDetail = FirebaseFirestore.instance
            .collection('scholarship_calls')
            .doc(callId)
            .get()
            .then((callDoc) {
          final callData = callDoc.exists ? callDoc.data()! : <String, dynamic>{};
          return ApplicationWithCallDetails(applicationData: applicationData, callData: callData);
        });
        futureDetails.add(futureDetail);
      }
    }
    // 3. Esperar a que todas las búsquedas de detalles se completen
    return await Future.wait(futureDetails);
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
            return Center(child: Text('Error al cargar tus solicitudes: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const _NoApplicationsView(); // Vista para cuando no hay solicitudes
          }

          final applications = snapshot.data!;
          return _ApplicationsListView(applications: applications);
        },
      ),
    );
  }
}

// --- VISTA CUANDO HAY SOLICITUDES ---
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
            ? DateFormat('dd/MM/yyyy').format(applicationDate.toDate())
            : 'Fecha no disponible';
        final callTitle = callData['title'] ?? 'Convocatoria Desconocida';

        final statusInfo = _getStatusInfo(status);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(statusInfo['icon'], color: statusInfo['color'], size: 20),
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
                Text('Fecha de solicitud: $formattedDate', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return {'text': 'Aprobada', 'color': Colors.green.shade700, 'icon': Icons.check_circle};
      case 'rejected':
        return {'text': 'Rechazada', 'color': Colors.red.shade700, 'icon': Icons.cancel};
      case 'pending':
      default:
        return {'text': 'En Revisión', 'color': Colors.amber.shade800, 'icon': Icons.hourglass_empty};
    }
  }
}

// --- VISTA CUANDO NO HAY SOLICITUDES ---
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
            const Icon(Icons.folder_off_outlined, size: 100, color: Colors.grey),
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
              onPressed: () => context.go('/student-dashboard/scholarship-calls'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

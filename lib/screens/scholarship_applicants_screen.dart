
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScholarshipApplicantsScreen extends StatefulWidget {
  final String callId;
  const ScholarshipApplicantsScreen({super.key, required this.callId});

  @override
  State<ScholarshipApplicantsScreen> createState() => _ScholarshipApplicantsScreenState();
}

class _ScholarshipApplicantsScreenState extends State<ScholarshipApplicantsScreen> {
  late Future<DocumentSnapshot> _callDetailsFuture;

  @override
  void initState() {
    super.initState();
    _callDetailsFuture = FirebaseFirestore.instance.collection('scholarship_calls').doc(widget.callId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: _callDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              final callTitle = (snapshot.data!.data() as Map<String, dynamic>)['title'] ?? 'Solicitantes';
              return Text(callTitle, overflow: TextOverflow.ellipsis);
            }
            return const Text('Cargando...');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard/admin-scholarship-calls'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('scholarship_calls').doc(widget.callId).collection('applicants').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay solicitudes para esta convocatoria.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final applications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              final data = application.data() as Map<String, dynamic>;
              final studentName = data['studentName'] ?? 'Nombre no disponible';
              final lastName = data['lastName'] ?? '';
              final fullName = '$studentName $lastName'.trim();
              final career = data['career'] ?? 'Carrera no disponible';
              final status = data['status'] ?? 'pending';

              Icon statusIcon;
              Color statusColor;
              switch (status) {
                case 'approved':
                  statusIcon = const Icon(Icons.check_circle, color: Colors.green);
                  statusColor = Colors.green.shade100;
                  break;
                case 'rejected':
                  statusIcon = const Icon(Icons.cancel, color: Colors.red);
                  statusColor = Colors.red.shade100;
                  break;
                default: // pending
                  statusIcon = const Icon(Icons.hourglass_empty, color: Colors.orange);
                  statusColor = Colors.orange.shade100;
              }

              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: statusIcon,
                  ),
                  title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(career),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.go(
                      '/admin-dashboard/scholarship-applicants/${widget.callId}/applicant-details/${application.id}',
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

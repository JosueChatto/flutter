import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class CancelScholarshipScreen extends StatefulWidget {
  const CancelScholarshipScreen({super.key});

  @override
  State<CancelScholarshipScreen> createState() => _CancelScholarshipScreenState();
}

class _CancelScholarshipScreenState extends State<CancelScholarshipScreen> {
  
  // Lista de motivos predefinidos para la anulación
  final List<String> _cancellationReasons = [
    'Baja académica temporal o definitiva.',
    'Incumplimiento del reglamento de becas.',
    'El estudiante ha finalizado sus estudios.',
    'Se detectó información falsa en la solicitud.',
    'Solicitud voluntaria por parte del estudiante.',
    'Otro (especificar en observaciones).',
  ];

  Future<void> _showCancelDialog(String applicantId, String studentName) async {
    final selectedReasons = <String>{};
    String? validationError;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Anular Beca de $studentName'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecciona uno o más motivos para la anulación:'),
                    const SizedBox(height: 16),
                    ..._cancellationReasons.map((reason) {
                      return CheckboxListTile(
                        title: Text(reason),
                        value: selectedReasons.contains(reason),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedReasons.add(reason);
                            } else {
                              selectedReasons.remove(reason);
                            }
                            validationError = null; // Limpiar error al cambiar selección
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                    if (validationError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          validationError!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cerrar'),
                ),
                FilledButton(
                  onPressed: () {
                     if (selectedReasons.isEmpty) {
                        setState(() {
                          validationError = 'Debes seleccionar al menos un motivo.';
                        });
                        return;
                      }
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Confirmar Anulación'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      _performCancellation(applicantId, selectedReasons.toList());
    }
  }

  Future<void> _performCancellation(String applicantId, List<String> reasons) async {
    try {
      await FirebaseFirestore.instance.collection('applications').doc(applicantId).update({
        'status': 'cancelled',
        'cancellationReasons': reasons,
        'cancellationDate': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beca anulada correctamente.'), backgroundColor: Colors.green),
      );
      // Forzar la recarga de la pantalla
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al anular la beca: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anular Beca de Estudiante'),
         leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard/settings'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los estudiantes.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay estudiantes con beca aprobada actualmente.'),
            );
          }

          final approvedApplications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: approvedApplications.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final application = approvedApplications[index];
              final studentId = application['studentId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Card(child: ListTile(title: Text('Cargando datos del usuario...')));
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final studentName = "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("No. de Control: ${userData['controlNumber'] ?? 'N/A'}"),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Anular'),
                        onPressed: () => _showCancelDialog(application.id, studentName),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                          elevation: 0,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

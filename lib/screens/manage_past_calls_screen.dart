import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Pantalla para gestionar (ver y eliminar) las convocatorias de becas que ya han finalizado.
///
/// Muestra una lista de todas las convocatorias cuya fecha de finalización (`endDate`)
/// es anterior a la fecha actual. Permite a los administradores eliminar
/// convocatorias antiguas para mantener la base de datos limpia.
class ManagePastCallsScreen extends StatefulWidget {
  const ManagePastCallsScreen({super.key});

  @override
  State<ManagePastCallsScreen> createState() => _ManagePastCallsScreenState();
}

class _ManagePastCallsScreenState extends State<ManagePastCallsScreen> {
  /// Construye la vista principal de la pantalla.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convocatorias Anteriores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Navega de regreso al panel de administrador.
          onPressed: () => context.go('/admin-dashboard'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Realiza una consulta a Firestore para obtener las convocatorias pasadas.
        stream: FirebaseFirestore.instance
            .collection('scholarship_calls')
            .where('endDate', isLessThan: Timestamp.now())
            .orderBy('endDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron convocatorias anteriores.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pastCalls = snapshot.data!.docs;

          // Muestra la lista de convocatorias pasadas.
          return ListView.builder(
            itemCount: pastCalls.length,
            itemBuilder: (context, index) {
              final call = pastCalls[index];
              final data = call.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Sin Título';
              final endDate = (data['endDate'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Finalizó el: ${endDate != null ? DateFormat('dd/MM/yyyy').format(endDate) : 'Fecha no disponible'}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    tooltip: 'Eliminar Convocatoria',
                    onPressed: () => _confirmDelete(context, call.id, title),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar la convocatoria.
  Future<void> _confirmDelete(BuildContext context, String docId, String title) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar la convocatoria "$title"? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                _deleteCall(docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Elimina la convocatoria de Firestore.
  Future<void> _deleteCall(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('scholarship_calls')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convocatoria eliminada con éxito.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la convocatoria: $e')),
      );
    }
  }
}

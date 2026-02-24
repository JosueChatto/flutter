import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublishResultsScreen extends StatefulWidget {
  const PublishResultsScreen({super.key});

  @override
  State<PublishResultsScreen> createState() => _PublishResultsScreenState();
}

class _PublishResultsScreenState extends State<PublishResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _togglePublication(DocumentReference callRef, bool currentState) async {
    try {
      await callRef.update({'isPublished': !currentState});
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El estado de la publicación ha sido actualizado.')),
        );
      }
    } catch (e) {
       if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Resultados de Convocatorias'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('calls').orderBy('endDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay convocatorias disponibles para publicar.'),
            );
          }

          final calls = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              final data = call.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Beca sin título';
              final isPublished = data['isPublished'] as bool? ?? false;

              return Card(
                 margin: const EdgeInsets.only(bottom: 12),
                child: SwitchListTile(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isPublished ? 'Publicado (Visible para cafeterías)' : 'No Publicado (Oculto para cafeterías)'),
                  value: isPublished,
                  onChanged: (bool value) {
                    _togglePublication(call.reference, isPublished);
                  },
                  secondary: Icon(
                    isPublished ? Icons.visibility : Icons.visibility_off,
                    color: isPublished ? Colors.green : Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditContentScreen extends StatefulWidget {
  const EditContentScreen({super.key});

  @override
  State<EditContentScreen> createState() => _EditContentScreenState();
}

class _EditContentScreenState extends State<EditContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rightsController = TextEditingController();
  final _criteriaController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('app_content').doc('student_info').get();
      if (doc.exists) {
        final data = doc.data()!;
        _rightsController.text = data['rights_and_obligations'] ?? '';
        _criteriaController.text = data['selection_criteria'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el contenido: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('app_content').doc('student_info').update({
          'rights_and_obligations': _rightsController.text,
          'selection_criteria': _criteriaController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contenido actualizado con éxito')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el contenido: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Contenido Informativo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text('Derechos y Obligaciones', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rightsController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Describe los derechos y obligaciones de los estudiantes becados...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Criterios de Selección', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _criteriaController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Describe los criterios para la selección de becarios...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveContent,
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _rightsController.dispose();
    _criteriaController.dispose();
    super.dispose();
  }
}

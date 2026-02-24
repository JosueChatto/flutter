import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

/// Pantalla que permite a los administradores editar la información general
/// sobre las becas que se muestra a los estudiantes.
///
/// Carga el contenido desde un documento específico en Firestore, lo muestra en
/// campos de texto editables y guarda los cambios en la base de datos.
class EditScholarshipInfoScreen extends StatefulWidget {
  const EditScholarshipInfoScreen({super.key});

  @override
  State<EditScholarshipInfoScreen> createState() =>
      _EditScholarshipInfoScreenState();
}

class _EditScholarshipInfoScreenState extends State<EditScholarshipInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  // El ID del documento que almacena la información general.
  final String _docId = 'scholarship_general_info';
  bool _isLoading = true;
  bool _isSaving = false;

  // Controladores para los campos del formulario.
  late TextEditingController _detailsController;
  late TextEditingController _requirementsController;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController();
    _requirementsController = TextEditingController();
    _loadInfo();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  /// Carga la información actual desde Firestore y la asigna a los controladores.
  Future<void> _loadInfo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('general_info')
          .doc(_docId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _detailsController.text = data['details'] ?? '';
        _requirementsController.text = data['requirements'] ?? '';
      } 
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la información: $e')),
        );
    } finally {
       if(mounted){
        setState(() => _isLoading = false);
       }
    }
  }

  /// Valida el formulario y guarda los datos actualizados en Firestore.
  Future<void> _saveInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('general_info')
          .doc(_docId)
          .set({
        'details': _detailsController.text.trim(),
        'requirements': _requirementsController.text.trim(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información actualizada con éxito.')),
      );
      // Regresa a la pantalla de configuración.
      context.go('/admin-dashboard/settings');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la información: $e')),
      );
    } finally {
      if(mounted){
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Información'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard/settings'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Información General de Becas',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Modifica el contenido que se muestra a los estudiantes en la sección de "Información de Convocatorias".',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        labelText: 'Detalles de la Beca',
                        helperText: 'Describe en qué consiste la beca, sus beneficios, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      maxLines: 6,
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo no puede estar vacío' : null,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _requirementsController,
                      decoration: const InputDecoration(
                        labelText: 'Requisitos Generales',
                        helperText: 'Enumera los requisitos básicos para aplicar a las becas.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.checklist_rtl_outlined),
                      ),
                      maxLines: 8,
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo no puede estar vacío' : null,
                    ),
                    const SizedBox(height: 32),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.save_alt_outlined),
                            label: const Text('Guardar Cambios'),
                            onPressed: _saveInfo,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

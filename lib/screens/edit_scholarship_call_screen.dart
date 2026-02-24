import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditScholarshipCallScreen extends StatefulWidget {
  final String callId;
  const EditScholarshipCallScreen({super.key, required this.callId});

  @override
  State<EditScholarshipCallScreen> createState() =>
      _EditScholarshipCallScreenState();
}

class _EditScholarshipCallScreenState extends State<EditScholarshipCallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;
  bool _isUpdating = false;
  String _periodCode = '';

  @override
  void initState() {
    super.initState();
    _loadCallData();
  }

  Future<void> _loadCallData() async {
    try {
      // CORRECCIÓN: Apunta a la colección 'calls' para cargar los datos.
      final doc = await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _requirementsController.text = data['requirements'] ?? '';
        _periodCode = data['period_code'] ?? 'N/A';

        if (data['startDate'] != null) {
          _startDate = (data['startDate'] as Timestamp).toDate();
          _startDateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(_startDate!);
        }
        if (data['endDate'] != null) {
          _endDate = (data['endDate'] as Timestamp).toDate();
          _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate!);
        }
      } else {
        _showErrorAndGoBack('La convocatoria no existe.');
      }
    } catch (e) {
      _showErrorAndGoBack('Error al cargar los datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorAndGoBack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.red.shade800, content: Text(message, style: const TextStyle(color: Colors.white))));
    context.go('/admin-dashboard/settings/manage-active-scholarships');
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _updateCall() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      // CORRECCIÓN: Apunta a la colección 'calls' para actualizar los datos.
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .update({
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'requirements': _requirementsController.text.trim(),
            'startDate': _startDate != null
                ? Timestamp.fromDate(_startDate!)
                : null,
            'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convocatoria actualizada con éxito.')),
      );
      context.go('/admin-dashboard/settings/manage-active-scholarships');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Convocatoria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(
            '/admin-dashboard/settings/manage-active-scholarships',
          ),
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
                  children: <Widget>[
                    Center(
                      child: Chip(
                        label: Text('Código: $_periodCode'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(
                      controller: _titleController,
                      label: 'Nombre de la Beca',
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _descriptionController,
                      label: 'Descripción',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _requirementsController,
                      label: 'Requisitos',
                      icon: Icons.rule_folder_outlined,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            context,
                            label: 'Fecha de Inicio',
                            controller: _startDateController,
                            isStartDate: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            context,
                            label: 'Fecha de Cierre',
                            controller: _endDateController,
                            isStartDate: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _isUpdating
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.save_alt_outlined),
                            label: const Text('Guardar Cambios'),
                            onPressed: _updateCall,
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: (value) =>
          value!.isEmpty ? 'Este campo no puede estar vacío' : null,
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required bool isStartDate,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onTap: () => _selectDate(context, isStartDate),
      validator: (value) => value!.isEmpty ? 'Selecciona una fecha' : null,
    );
  }
}

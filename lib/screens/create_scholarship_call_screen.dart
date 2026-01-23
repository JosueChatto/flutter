
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateScholarshipCallScreen extends StatelessWidget {
  const CreateScholarshipCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Convocatoria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Detalles de la Convocatoria',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(label: 'Nombre de la Beca', icon: Icons.title),
            const SizedBox(height: 16),
            _buildTextField(label: 'Descripción', icon: Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(label: 'Requisitos', icon: Icons.rule_folder_outlined, maxLines: 4),
            const SizedBox(height: 24),
            _buildDateFields(context),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // TODO: Implementar lógica para crear convocatoria
                context.go('/admin-dashboard');
              },
              child: const Text('Publicar Convocatoria'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDateFields(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildDateField(context, label: 'Fecha de Inicio'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField(context, label: 'Fecha de Cierre'),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, {required String label}) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.indigo),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onTap: () {
        // TODO: Implementar selector de fecha
      },
    );
  }
}

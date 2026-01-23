
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApplicantDetailsScreen extends StatelessWidget {
  const ApplicantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Solicitud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard/scholarship-applicants'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildApplicantInfo(context),
            const SizedBox(height: 24),
            Text(
              'Documentos Adjuntos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDocumentTile(context, 'Comprobante de Domicilio', Icons.home_work_outlined),
            _buildDocumentTile(context, 'Historial Académico', Icons.school_outlined),
            _buildDocumentTile(context, 'Identificación Oficial', Icons.badge_outlined),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre del Estudiante',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingeniería en Sistemas Computacionales',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Text(
          '8vo Semestre',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const Divider(height: 32, thickness: 1),
      ],
    );
  }

  Widget _buildDocumentTile(BuildContext context, String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo, size: 30),
        title: Text(title),
        trailing: const Icon(Icons.visibility_outlined, color: Colors.grey),
        onTap: () {
          // TODO: Implementar visualización del documento
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Aprobar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            // TODO: Implementar lógica de aprobación
            context.go('/admin-dashboard/scholarship-applicants');
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.highlight_off_outlined),
          label: const Text('Rechazar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            // TODO: Implementar lógica de rechazo
            context.go('/admin-dashboard/scholarship-applicants');
          },
        ),
      ],
    );
  }
}

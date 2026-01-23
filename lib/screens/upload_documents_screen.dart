
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UploadDocumentsScreen extends StatelessWidget {
  const UploadDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carga de Documentos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildDocumentUploadCard(
              context,
              title: 'Comprobante de Domicilio',
              subtitle: 'Sube una imagen o PDF de tu comprobante.',
              onTap: () {
                // TODO: Implementar lógica de selección de archivo
              },
            ),
            const SizedBox(height: 16),
            _buildDocumentUploadCard(
              context,
              title: 'Historial Académico',
              subtitle: 'Sube tu historial académico más reciente.',
              onTap: () {
                // TODO: Implementar lógica de selección de archivo
              },
            ),
            const SizedBox(height: 16),
            _buildDocumentUploadCard(
              context,
              title: 'Identificación Oficial',
              subtitle: 'Sube una foto de tu credencial de estudiante.',
              onTap: () {
                // TODO: Implementar lógica de selección de archivo
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar lógica para enviar documentos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Documentos enviados para revisión.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Enviar Documentos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard(
    BuildContext context,
      {required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              const Icon(Icons.upload_file_outlined, size: 40, color: Colors.indigo),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

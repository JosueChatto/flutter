import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Becas')),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const SizedBox(height: 10),
          Text(
            'Gestión de Becas',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra las convocatorias y el estado de las becas de los estudiantes.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
           _buildSettingsCard(
            context,
            icon: Icons.campaign_outlined, 
            title: 'Publicar Resultados de Convocatorias',
            subtitle: 'Hacer visible la lista de aceptados para la cafetería.',
            onTap: () =>
                context.go('/admin-dashboard/settings/publish-results'),
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            icon: Icons.edit_calendar_outlined,
            title: 'Gestionar Convocatorias Vigentes',
            subtitle:
                'Modificar la información de las convocatorias de becas activas.',
            onTap: () => context.go(
              '/admin-dashboard/settings/manage-active-scholarships',
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            icon: Icons.delete_sweep_outlined,
            title: 'Gestionar Convocatorias Anteriores',
            subtitle:
                'Eliminar convocatorias de becas que ya no están vigentes.',
            onTap: () => context.go(
              '/admin-dashboard/settings/manage-past-scholarships',
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            icon: Icons.cancel_outlined,
            title: 'Anular Beca de Estudiante',
            subtitle:
                'Cancelar la beca de un estudiante y registrar el motivo.',
            onTap: () =>
                context.go('/admin-dashboard/settings/cancel-scholarship'),
          ),
           const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            icon: Icons.edit_note, // Icono para editar contenido
            title: 'Editar Contenido Informativo',
            subtitle: 'Modificar textos como Derechos y Obligaciones.',
            onTap: () => context.go('/admin-dashboard/settings/edit-content'), // RUTA CORREGIDA
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal del Estudiante'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // TODO: Implementar funcionalidad de cerrar sesión
              context.go('/login');
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(24.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: <Widget>[
          _buildDashboardCard(
            context,
            icon: Icons.person_outline,
            title: 'Mi Perfil',
            onTap: () => context.go('/student-dashboard/profile'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.article_outlined,
            title: 'Convocatorias',
            onTap: () => context.go('/student-dashboard/scholarship-calls'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.school_outlined, // Nuevo ícono
            title: 'Información de Becas', // Nuevo título
            onTap: () => context.go('/student-dashboard/scholarships'), // Nueva ruta
          ),
          _buildDashboardCard(
            context,
            icon: Icons.playlist_add_check_outlined,
            title: 'Estatus de Solicitud',
            onTap: () => context.go('/student-dashboard/application-status'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.upload_file_outlined,
            title: 'Subir Documentos',
            onTap: () => context.go('/student-dashboard/upload-documents'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: Theme.of(context).primaryColorDark),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

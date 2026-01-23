
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
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
            icon: Icons.people_outline,
            title: 'Ver Solicitudes',
            onTap: () => context.go('/admin-dashboard/scholarship-applicants'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.post_add_outlined,
            title: 'Crear Convocatoria',
            onTap: () => context.go('/admin-dashboard/create-scholarship-call'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.history_outlined,
            title: 'Historial de Becas',
            onTap: () => context.go('/admin-dashboard/scholarship-history'),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.settings_outlined,
            title: 'Configuración',
            onTap: () {
              // TODO: Navegar a la pantalla de configuración
            },
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

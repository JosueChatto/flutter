
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Para acceder a ThemeProvider

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final List<DashboardItem> items = [
      DashboardItem(
        icon: Icons.person_outline,
        title: 'Perfil',
        subtitle: 'Consulta y edita tus datos escolares.',
        onTap: () => context.go('/student-dashboard/profile'),
      ),
      DashboardItem(
        icon: Icons.playlist_add_check_outlined,
        title: 'Estatus de Beca',
        subtitle: 'Revisa si tu solicitud fue aceptada.',
        onTap: () => context.go('/student-dashboard/application-status'),
      ),
      DashboardItem(
        icon: Icons.article_outlined,
        title: 'Inscripción a la Beca',
        subtitle: 'Llena el formato para solicitar la beca.',
        onTap: () => context.go('/student-dashboard/scholarship-application'),
      ),
      DashboardItem(
        icon: Icons.info_outline,
        title: 'Información de la Beca',
        subtitle: 'Conoce los detalles y la vigencia.',
        onTap: () => context.go('/student-dashboard/scholarship-info'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal del Estudiante'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Cambiar Tema',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(item.icon, size: 40, color: Theme.of(context).colorScheme.primary),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: item.onTap,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          );
        },
      ),
    );
  }
}

class DashboardItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  DashboardItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

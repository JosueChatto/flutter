import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Para acceder a ThemeProvider

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? _adminPosition;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (mounted && userDoc.exists) {
          setState(() {
            _adminPosition = userDoc.data()?['position'];
          });
        }
      } catch (e) {
        // Manejar error si es necesario
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final List<DashboardItem> items = [
      DashboardItem(
        icon: Icons.folder_copy_outlined,
        title: 'Gestionar Convocatorias',
        subtitle: 'Ver historial, solicitudes y crear nuevas.',
        onTap: () => context.go('/admin-dashboard/admin-scholarship-calls'),
      ),
      DashboardItem(
        icon: Icons.checklist_rtl_outlined,
        title: 'Lista de Aceptados',
        subtitle: 'Consulta y filtra la lista de estudiantes aceptados.',
        onTap: () => context.go('/admin-dashboard/accepted-list'),
      ),
      DashboardItem(
        icon: Icons.settings_outlined,
        title: 'Configuración',
        subtitle: 'Gestiona las opciones del sistema.',
        onTap: () => context.go('/admin-dashboard/settings'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Panel de Administración'),
            if (_adminPosition != null)
              Text(
                _adminPosition!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.8),
                    ),
              ),
          ],
        ),
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

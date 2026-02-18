
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Para acceder a ThemeProvider

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String? _studentName;
  String? _lastName;
  String? _numberControl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentHeaderData();
  }

  Future<void> _loadStudentHeaderData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // La fuente de verdad para los datos del perfil es la colección 'applications'
      final doc = await FirebaseFirestore.instance.collection('applications').doc(user.uid).get();
      if (mounted && doc.exists) {
        final data = doc.data()!;
        setState(() {
          _studentName = data['studentName'] as String?;
          _lastName = data['lastName'] as String?;
          _numberControl = data['numberControl'] as String?;
          _isLoading = false;
        });
      } else {
         setState(() => _isLoading = false);
      }
    } catch (e) {
       if(mounted) setState(() => _isLoading = false);
       print('Error al obtener los datos del encabezado: $e');
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
        icon: Icons.person_outline,
        title: 'Mi Perfil',
        subtitle: 'Consulta tus datos personales y académicos.',
        onTap: () => context.go('/student-dashboard/profile'),
      ),
      DashboardItem(
        icon: Icons.playlist_add_check,
        title: 'Estatus de Beca',
        subtitle: 'Revisa si tu solicitud fue aceptada.',
        onTap: () => context.go('/student-dashboard/application-status'),
      ),
      DashboardItem(
        icon: Icons.article_outlined,
        title: 'Inscripción a la Beca',
        subtitle: 'Selecciona una convocatoria y aplica.', // Subtítulo actualizado
        onTap: () => context.go('/student-dashboard/scholarship-calls'), // <- Ruta actualizada
      ),
      DashboardItem(
        icon: Icons.info_outline,
        title: 'Información de Convocatorias',
        subtitle: 'Conoce los detalles y requisitos.',
        onTap: () => context.go('/student-dashboard/scholarship-info'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _loadStudentHeaderData,
            child: ListView.separated(
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
        ),
    );
  }

  Widget _buildAppBarTitle() {
    if (_isLoading) {
        return const Text('Portal del Estudiante');
    }

    String fullName = ('${_studentName ?? ''} ${_lastName ?? ''}').trim();
    if (fullName.isEmpty) {
      fullName = 'Estudiante'; // Fallback si no hay nombre
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fullName, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        if (_numberControl != null && _numberControl!.isNotEmpty)
          Text(
            'No. de Control: $_numberControl',
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
          ),
      ],
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

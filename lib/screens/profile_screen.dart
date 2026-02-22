import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      // Continuamos leyendo de la colección 'users', que es la correcta para el perfil.
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _userData = userDoc.data();
          _isLoading = false;
        });
      } 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el perfil: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    backgroundColor: theme.colorScheme.surface.withOpacity(0.98),
    appBar: AppBar(
      title: const Text('Mi Perfil'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/student-dashboard'),
      ),
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
      foregroundColor: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _userData == null
            ? const Center(child: Text('No se pudo cargar la información del usuario.'))
            : RefreshIndicator(
              onRefresh: _loadUserProfile,
              child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      theme,
                      title: 'Información Personal',
                      children: [
                        // CORRECCIÓN: Usando 'studentName' y 'lastName' en sus respectivos campos.
                        _buildInfoTile(icon: Icons.person_outline, label: 'Nombre(s)', value: _userData!['studentName'] ?? 'N/A'),
                        _buildInfoTile(icon: Icons.person_search_outlined, label: 'Apellido(s)', value: _userData!['lastName'] ?? 'N/A'),
                        _buildInfoTile(icon: Icons.phone_outlined, label: 'Teléfono', value: _userData!['numberPhone'] ?? 'N/A'),
                      ],
                    ),
                    const SizedBox(height: 24),
                     _buildInfoSection(
                      theme,
                      title: 'Información Académica',
                      children: [
                        _buildInfoTile(icon: Icons.confirmation_number_outlined, label: 'Número de Control', value: _userData!['numberControl'] ?? 'N/A'),
                        _buildInfoTile(icon: Icons.school_outlined, label: 'Carrera', value: _userData!['career'] ?? 'N/A'),
                        _buildInfoTile(icon: Icons.format_list_numbered_rtl_outlined, label: 'Semestre', value: _userData!['semester']?.toString() ?? 'N/A'),
                        _buildInfoTile(icon: Icons.star_outline_rounded, label: 'Calificación (Promedio)', value: _userData!['gpa']?.toString() ?? 'N/A'),
                        _buildInfoTile(icon: Icons.email_outlined, label: 'Correo Institucional', value: _userData!['email'] ?? 'N/A'),
                      ],
                    ),
                  ],
                ),
            ),
  );
}

Widget _buildHeader(ThemeData theme) {
  // CORRECCIÓN: Construyendo el nombre completo desde 'studentName' y 'lastName'.
  final String fullName = ('${_userData!['studentName'] ?? ''} ${_userData!['lastName'] ?? ''}').trim();

  return Column(
    children: [
      CircleAvatar(
        radius: 45,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
      ),
      const SizedBox(height: 12),
      Text(
        fullName.isEmpty ? 'Nombre no disponible' : fullName,
        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      if (_userData!['career'] != null)
        Chip(
          label: Text(_userData!['career'] ?? 'Carrera no especificada'),
          backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
          labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          side: BorderSide.none,
          elevation: 1,
        ),
    ],
  );
}

Widget _buildInfoSection(ThemeData theme, {required String title, required List<Widget> children}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
      Card(
        elevation: 0,
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(children: children),
      ),
    ],
  );
}

Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
  final theme = Theme.of(context);
  return ListTile(
    leading: Icon(icon, color: theme.colorScheme.primary),
    title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
    subtitle: Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
  );
}

}

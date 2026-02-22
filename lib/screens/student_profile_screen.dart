
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controladores para mostrar los datos
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _careerController = TextEditingController();
  final _semesterController = TextEditingController();
  final _phoneController = TextEditingController();
  final _statusController = TextEditingController();
  final _numberControlController = TextEditingController(); // Nuevo
  final _gpaController = TextEditingController(); // Nuevo

  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    _user = _auth.currentUser;
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    // El email lo tomamos directamente de Auth para mayor seguridad
    _emailController.text = _user!.email ?? 'No disponible';

    try {
      // La única fuente de verdad para los datos del perfil será la colección 'applications'
      final applicationsQuery = await _firestore
          .collection('applications')
          .doc(_user!.uid) // Buscamos directamente por el UID del usuario
          .get();

      if (applicationsQuery.exists) {
        final data = applicationsQuery.data() as Map<String, dynamic>;

        // Asignamos todos los datos desde 'applications'
        _nameController.text = data['studentName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _phoneController.text = data['numberPhone'] ?? ''; // Corregido de 'phoneNumber'
        _semesterController.text = data['semester']?.toString() ?? '';
        _careerController.text = data['career'] ?? '';
        _statusController.text = data['status'] ?? 'No disponible';
        _numberControlController.text = data['numberControl'] ?? ''; // Nuevo
        _gpaController.text = data['gpa']?.toString() ?? ''; // Nuevo

      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró una solicitud de beca asociada a este perfil.')),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _careerController.dispose();
    _semesterController.dispose();
    _phoneController.dispose();
    _statusController.dispose();
    _numberControlController.dispose(); // Nuevo
    _gpaController.dispose(); // Nuevo
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStudentData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildProfileHeader(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'Información de la Solicitud'),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      icon: Icons.info_outline,
                      label: 'Estatus de la Beca',
                      value: _statusController.text,
                      highlight: true,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'Información Personal'),
                    const SizedBox(height: 16),
                    _buildInfoTile(icon: Icons.person_outline, label: 'Nombre(s)', value: _nameController.text),
                    const SizedBox(height: 16),
                    _buildInfoTile(icon: Icons.person_pin_outlined, label: 'Apellido(s)', value: _lastNameController.text),
                    const SizedBox(height: 16),
                    _buildInfoTile(icon: Icons.phone_outlined, label: 'Teléfono', value: _phoneController.text),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'Información Académica'),
                    const SizedBox(height: 16),
                    // Nuevos campos aquí
                    _buildInfoTile(icon: Icons.confirmation_number_outlined, label: 'Número de Control', value: _numberControlController.text),
                    const SizedBox(height: 16),
                    _buildInfoTile(icon: Icons.star_border_outlined, label: 'Calificación (Promedio)', value: _gpaController.text),
                    const SizedBox(height: 16),
                     _buildInfoTile(icon: Icons.school_outlined, label: 'Carrera', value: _careerController.text),
                    const SizedBox(height: 16),
                    _buildInfoTile(icon: Icons.format_list_numbered, label: 'Semestre', value: _semesterController.text),
                    const SizedBox(height: 16),
                    _buildInfoTile(icon: Icons.email_outlined, label: 'Correo Institucional', value: _emailController.text),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    String fullName = '${_nameController.text} ${_lastNameController.text}'.trim();
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 16),
        Text(
          fullName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (_careerController.text.isNotEmpty)
          Chip(
            label: Text(
              _careerController.text,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value, bool highlight = false}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          value.isNotEmpty ? value : 'No disponible',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? theme.colorScheme.tertiary : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}

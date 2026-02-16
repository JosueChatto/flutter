
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
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controladores para los campos del formulario
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _careerController = TextEditingController();
  final _semesterController = TextEditingController();
  final _phoneController = TextEditingController();
  final _statusController = TextEditingController();

  // Variables de estado
  bool _isEditing = false;
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadAllUserData();
  }

  Future<void> _loadAllUserData() async {
    _user = _auth.currentUser;
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Obtener datos de la colección 'users'
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _nameController.text = userData['name']?.split(' ').first ?? '';
        _lastNameController.text = userData['name']?.split(' ').length > 1 ? userData['name'].split(' ').sublist(1).join(' ') : '';
        _emailController.text = userData['email'] ?? '';
        _careerController.text = userData['career'] ?? '';
      }

      // 2. Obtener datos de la colección 'applications'
      final applicationsQuery = await _firestore
          .collection('applications')
          .where('studentID', isEqualTo: _user!.uid)
          .limit(1)
          .get();

      if (applicationsQuery.docs.isNotEmpty) {
        final applicationData = applicationsQuery.docs.first.data();
         // Sobrescribimos o complementamos con datos de 'applications'
        _nameController.text = applicationData['studentName'] ?? _nameController.text;
        _lastNameController.text = applicationData['lastName'] ?? _lastNameController.text;
        _phoneController.text = applicationData['phoneNumber'] ?? '';
        _semesterController.text = applicationData['semester']?.toString() ?? '';
        _statusController.text = applicationData['status'] ?? 'No disponible';
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
    super.dispose();
  }

  void _toggleEdit() {
    // La edición no está permitida en esta versión
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
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
                    _buildInfoTile(icon: Icons.email_outlined, label: 'Correo Institucional', value: _emailController.text),
                    const SizedBox(height: 16),
                    _buildInfoTile(icon: Icons.school_outlined, label: 'Carrera', value: _careerController.text),
                    const SizedBox(height: 16),
                    _buildInfoTile(icon: Icons.format_list_numbered, label: 'Semestre', value: _semesterController.text),
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
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          value.isNotEmpty ? value : 'No disponible',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}

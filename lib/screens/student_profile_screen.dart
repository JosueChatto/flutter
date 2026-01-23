
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _nameController = TextEditingController(text: 'Nombre del Estudiante');
  final _controlNumberController = TextEditingController(text: '12345678');
  final _emailController = TextEditingController(text: 'estudiante@instituto.edu.mx');
  final _careerController = TextEditingController(text: 'Ingeniería en Sistemas Computacionales');
  final _semesterController = TextEditingController(text: '8');
  final _phoneController = TextEditingController(text: '123-456-7890');

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _controlNumberController.dispose();
    _emailController.dispose();
    _careerController.dispose();
    _semesterController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar la lógica para guardar la información del perfil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      _toggleEdit();
    }
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
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined),
            tooltip: _isEditing ? 'Guardar Cambios' : 'Editar Perfil',
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildProfileHeader(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Información Personal'),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Nombre Completo',
                icon: Icons.person_outline,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _phoneController,
                labelText: 'Teléfono de Contacto',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                enabled: _isEditing,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Información Académica'),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _controlNumberController,
                labelText: 'Número de Control',
                icon: Icons.badge_outlined,
                enabled: false, // El número de control no se puede editar
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _emailController,
                labelText: 'Correo Institucional',
                icon: Icons.email_outlined,
                enabled: false, // El correo no se puede editar
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _careerController,
                labelText: 'Carrera',
                icon: Icons.school_outlined,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _semesterController,
                labelText: 'Semestre',
                icon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
                enabled: _isEditing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}


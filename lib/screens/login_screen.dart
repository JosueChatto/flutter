import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../main.dart'; // Para acceder a ThemeProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    String errorMessage;

    try {
      final userRole = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      switch (userRole) {
        case UserRole.student:
          context.go('/student-dashboard');
          break;
        case UserRole.admin:
          context.go('/admin-dashboard');
          break;
        case UserRole.cafeteria:
          context.go('/cafeteria-dashboard');
          break;
        case UserRole.unknown:
          errorMessage =
              'Tu usuario está autenticado pero no tiene un rol asignado. Contacta al administrador.';
          _showErrorSnackbar(errorMessage);
          break;
      }
    } on FirebaseAuthException catch (e) {
      // Mensaje genérico para credenciales inválidas por seguridad
      const String invalidCredentialsMessage =
          'Las credenciales son incorrectas. Por favor, revisa el correo y la contraseña.';

      switch (e.code) {
        // Códigos de error comunes para credenciales incorrectas
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential': // El código de error moderno que estabas recibiendo
          errorMessage = invalidCredentialsMessage;
          break;
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico no es válido.';
          break;
        case 'user-disabled':
          errorMessage =
              'Este usuario ha sido deshabilitado. Contacta al administrador.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Se ha bloqueado el acceso por demasiados intentos fallidos. Inténtalo de nuevo más tarde.';
          break;
        default:
          // Un mensaje para cualquier otro error inesperado de Firebase
          errorMessage =
              'Ocurrió un error de autenticación inesperado. Código: ${e.code}';
      }
      _showErrorSnackbar(errorMessage);
    } catch (e) {
      errorMessage =
          'Ocurrió un error inesperado. Por favor, intenta de nuevo.';
      _showErrorSnackbar(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSystemInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Qué es AMOBECAL?"),
          content: const SingleChildScrollView(
            child: Text(
              '''**AMOBECAL** (Apoyo y Monitoreo de Becas Alimenticias) es una plataforma digital diseñada para gestionar el programa de becas alimenticias del Instituto.\n\n**Para Estudiantes:**\nPermite solicitar la beca, completar los formularios requeridos, consultar el estado de la solicitud (aprobada, rechazada o en revisión) y acceder a su perfil.\n\n**Para Administradores:**\nOfrece un panel para revisar las solicitudes de los estudiantes, ver sus datos y aprobar o rechazar las becas de manera eficiente.\n\nEl objetivo es hacer el proceso más transparente, rápido y accesible para todos.''',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Entendido"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'AMOBECAL',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitoreo de Becas Alimenticias',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value == null || !value.contains('@'))
                        ? 'Ingresa un correo válido'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    obscureText: _obscureText,
                    validator: (value) => (value == null || value.length < 6)
                        ? 'La contraseña debe tener al menos 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _login,
                          child: const Text('Iniciar Sesión'),
                        ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          themeProvider.themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => themeProvider.toggleTheme(),
                        tooltip: 'Cambiar Tema',
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: _isLoading ? null : _showSystemInfo,
                        tooltip: 'Sobre AMOBECAL',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

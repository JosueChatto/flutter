
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final userRole = await authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
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
          Fluttertoast.showToast(msg: 'Rol de usuario no reconocido.');
          break;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al iniciar sesión: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showRequirements() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Convocatoria Becas Alimenticias 2025-1"),
          content: const SingleChildScrollView(
            child: Text(
              '''Institución: TecNM - Instituto Tecnológico de Colima

**Objetivo**
Propiciar que los estudiantes cuenten con un apoyo para continuar su formación profesional, atendiendo políticas de equidad para estudiantes con capacidades diferentes o situaciones particulares, buscando la permanencia y continuación de sus estudios.

**Disposiciones Generales**
- **Población Objetivo:** Todo el estudiantado inscrito en el TecNM – Instituto Tecnológico de Colima.
- **Características de las becas:** Consisten en el otorgamiento de servicios alimenticios en las cafeterías del Instituto, con un horario de 08:00 a 17:00 horas y de acuerdo al calendario escolar vigente.
- **Requisitos de elegibilidad:** Para solicitar una beca alimenticia, el estudiantado deberá estar inscrito en el semestre actual.

**Criterios de Selección**
Los aspirantes que cumplan con el requisito serán seleccionados prioritariamente en función de los siguientes criterios:
(A) Con situación económica adversa.
(B) Con capacidades diferentes.
(C) Que sean madres solteras o embarazadas.
(D) Que su lugar de residencia esté alejado del instituto.
(E) Que su carga horaria les obligue a estar un mayor número de horas en la institución, siempre y cuando no se deba a reprobación.
(F) Que preferentemente no cuenten con algún beneficio equivalente de tipo económico o en especie otorgado por organismos públicos o privados al momento de solicitar la beca.
(G) Que participen en equipos o grupos representativos de la institución, siempre y cuando lo requieran.

**Derechos y Obligaciones de los Becarios**

*Derechos*
a) Recibir por parte del Comité de becas alimenticias la notificación de la asignación de la beca.
b) Recibir el servicio alimenticio en las cafeterías del TecNM Instituto Tecnológico de Colima, en horario de 08:00 a 17:00 horas y de acuerdo al calendario escolar vigente.

*Obligaciones*
a) Presentar la credencial de estudiante vigente para recibir la beca alimenticia.
b) Asistir con regularidad a clases.
c) Observar buena conducta dentro y fuera de la Institución.
d) Mantener un buen desempeño académico.
e) Participar en eventos y/o proyectos institucionales conforme a los esquemas de control establecidos.

**Causas de Cancelación**
a) Proporcionar datos falsos o alterar la documentación adjunta a su solicitud.
b) Incumplir con cualquiera de sus obligaciones.
c) Baja temporal, definitiva o deserción del plantel.
d) No utilizar los servicios alimenticios otorgados.

**Proceso de Solicitud**
- **Medio de envío:** Correo electrónico institucional.
- **Destinatario:** becasyseguro@colima.tecnm.mx.
- **Formato:** Un solo archivo en formato PDF con el escaneo claro y legible de los documentos requeridos.

**Fechas Importantes (Cronograma)**
- **Recepción de solicitudes:** Del 10 de febrero al 17 de febrero de 2025.
- **Publicación de resultados:** 22 de febrero de 2025 (en la página web del TecNM).
- **Inicio del servicio:** A partir del 24 de febrero del año en curso.
              '''
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar"),
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    obscureText: _obscureText,
                    validator: (value) =>
                        (value == null || value.length < 6)
                            ? 'La contraseña debe tener al menos 6 caracteres'
                            : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () => themeProvider.toggleTheme(),
                        tooltip: 'Cambiar Tema',
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: _showRequirements,
                        tooltip: 'Requisitos de la Beca',
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

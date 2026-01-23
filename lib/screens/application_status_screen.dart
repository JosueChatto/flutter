
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación del estado de la solicitud
    const String status = 'En Revisión'; // Puede ser 'Aceptada', 'Rechazada'

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatus de la Solicitud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildStatusIndicator(context, status),
              const SizedBox(height: 24),
              Text(
                'Tu solicitud está actualmente: $status',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildStatusMessage(context, status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'Aceptada':
        icon = Icons.check_circle_outline;
        color = Colors.green.shade700;
        break;
      case 'Rechazada':
        icon = Icons.highlight_off_outlined;
        color = Colors.red.shade700;
        break;
      case 'En Revisión':
      default:
        icon = Icons.hourglass_empty_outlined;
        color = Colors.amber.shade800;
        break;
    }

    return Icon(icon, size: 100, color: color);
  }

  Widget _buildStatusMessage(BuildContext context, String status) {
    String message;
    switch (status) {
      case 'Aceptada':
        message = '¡Felicidades! Tu beca ha sido aprobada. Revisa tu correo para más detalles.';
        break;
      case 'Rechazada':
        message = 'Lo sentimos, tu solicitud ha sido rechazada. Puedes volver a intentarlo en la próxima convocatoria.';
        break;
      case 'En Revisión':
      default:
        message = 'Tu solicitud y documentos están siendo revisados por el comité. Te notificaremos cualquier cambio.';
        break;
    }

    return Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

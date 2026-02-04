
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación del estado de la solicitud. Cambia este valor para ver los diferentes diseños.
    const String status = 'Aceptada'; // Opciones: 'Aceptada', 'Rechazada', 'En Revisión'

    IconData statusIcon;
    Color statusColor;
    String statusMessage;
    String statusTitle;

    switch (status) {
      case 'Aceptada':
        statusIcon = Icons.check_circle_outline;
        statusColor = Colors.green.shade700;
        statusTitle = '¡Beca Aprobada!';
        statusMessage = '¡Felicidades! Tu solicitud de beca ha sido aceptada. Pronto recibirás un correo con los siguientes pasos y cómo hacer uso de tu beneficio en la cafetería.';
        break;
      case 'Rechazada':
        statusIcon = Icons.highlight_off_outlined;
        statusColor = Colors.red.shade700;
        statusTitle = 'Solicitud Rechazada';
        statusMessage = 'Lo sentimos, tu solicitud no fue aprobada en esta ocasión. Te invitamos a estar pendiente de futuras convocatorias y verificar que cumplas con todos los criterios.';
        break;
      case 'En Revisión':
      default:
        statusIcon = Icons.hourglass_empty_outlined;
        statusColor = Colors.amber.shade800;
        statusTitle = 'Solicitud en Proceso';
        statusMessage = 'Hemos recibido tu solicitud y tus documentos. El comité de becas la está revisando. El resultado se publicará en las fechas indicadas en la convocatoria.';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatus de la Solicitud'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(statusIcon, size: 80, color: statusColor),
                    const SizedBox(height: 20),
                    Text(
                      statusTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Estado: $status',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

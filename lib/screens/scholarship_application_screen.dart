import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ScholarshipApplicationScreen extends StatefulWidget {
  final String callId;
  const ScholarshipApplicationScreen({super.key, required this.callId});

  @override
  State<ScholarshipApplicationScreen> createState() =>
      _ScholarshipApplicationScreenState();
}

class _ScholarshipApplicationScreenState
    extends State<ScholarshipApplicationScreen> {
  Stream<DocumentSnapshot>? _applicationStream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _applicationStream = FirebaseFirestore.instance
            .collection('scholarship_calls')
            .doc(widget.callId)
            .collection('applicants')
            .doc(user.uid)
            .snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solicitud de Beca')),
        body: const Center(child: Text('Usuario no autenticado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud de Beca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard/scholarship-calls'),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _applicationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar la solicitud: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // No ha aplicado, mostramos el formulario
            return _ApplicationFormLoader(callId: widget.callId);
          }

          // Ya aplicó, mostramos el estado
          final applicationData =
              snapshot.data!.data() as Map<String, dynamic>;
          return _AlreadyAppliedView(applicationData: applicationData);
        },
      ),
    );
  }
}


// WIDGET QUE MUESTRA EL ESTADO (SI YA APLICÓ)
class _AlreadyAppliedView extends StatelessWidget {
  final Map<String, dynamic> applicationData;
  const _AlreadyAppliedView({required this.applicationData});

  @override
  Widget build(BuildContext context) {
    final status = applicationData['status'] as String? ?? 'pending';

    String title;
    String subtitle;
    IconData iconData;
    Color color;

    switch (status) {
      case 'accepted':
        title = '¡Solicitud Aceptada!';
        subtitle =
            'Felicidades, tu beca ha sido aprobada. Consulta los siguientes pasos en la coordinación.';
        iconData = Icons.check_circle_outline_rounded;
        color = Colors.green.shade700;
        break;
      case 'rejected':
        title = 'Solicitud Rechazada';
        subtitle =
            'Lamentamos informarte que tu solicitud no fue aceptada en esta ocasión.';
        iconData = Icons.highlight_off_rounded;
        color = Colors.red.shade700;
        break;
      case 'pending':
      default:
        title = 'Solicitud en Proceso';
        subtitle =
            'Ya has aplicado a esta convocatoria. Tu solicitud está en revisión.';
        iconData = Icons.hourglass_empty_outlined;
        color = Colors.amber.shade800;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(iconData, size: 60, color: color),
                const SizedBox(height: 20),
                Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 12),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5)),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () => context.go('/student-dashboard'),
                    child: const Text('Volver al Inicio'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// WIDGET INTERMEDIO PARA CARGAR LOS DATOS DEL USUARIO PARA EL FORMULARIO
class _ApplicationFormLoader extends StatelessWidget {
  final String callId;
  const _ApplicationFormLoader({required this.callId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Error de autenticación."));
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("No se encontró tu perfil de usuario."));
        }
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        return _ApplicationFormView(userData: userData, callId: callId);
      },
    );
  }
}


// WIDGET DEL FORMULARIO DE APLICACIÓN
class _ApplicationFormView extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String callId;

  const _ApplicationFormView({required this.userData, required this.callId});

  @override
  State<_ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<_ApplicationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _reasonsController = TextEditingController();
  final _controlNumberConfirmationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonsController.dispose();
    _controlNumberConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Envío'),
        content: const Text(
            'Una vez confirmada la solicitud, no se podrán realizar cambios. ¿Deseas continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar y Enviar')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser!;
    try {
      final dataToSave = {
        // <<< INICIO DE LA CORRECCIÓN >>>
        'userId': user.uid, // Corregido: de 'studentID' a 'userId'
        // <<< FIN DE LA CORRECCIÓN >>>
        'studentName': widget.userData['name'] ?? 'N/A',
        'lastName': widget.userData['lastName'] ?? '',
        'career': widget.userData['career'] ?? 'N/A',
        'semester': widget.userData['semester'] ?? 0,
        'gpa': widget.userData['gpa'] ?? 0.0,
        'email': user.email,
        'numberControl': widget.userData['numberControl'] ?? 'N/A',
        'numberPhone': widget.userData['numberPhone'] ?? 'N/A',
        'status': 'pending',
        'applicationDate': FieldValue.serverTimestamp(),
        'reasons': _reasonsController.text.trim(),
        'callId': widget.callId,
      };

      await FirebaseFirestore.instance
          .collection('scholarship_calls')
          .doc(widget.callId)
          .collection('applicants')
          .doc(user.uid)
          .set(dataToSave);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Solicitud enviada con éxito!')));
      // No se necesita delay, el StreamBuilder actualizará la UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar la solicitud: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = widget.userData;
    final fullName = ('${userData['name'] ?? ''} ${userData['lastName'] ?? ''}').trim();
    
    final semesterValue = userData['semester'];
    final semester = semesterValue != null ? semesterValue.toString() : '[No definido]';

    final numberControlValue = userData['numberControl'];
    final numberControl = numberControlValue != null ? numberControlValue.toString() : '[No definido]';
    
    final career = userData['career']?.toString() ?? '[No definida]';

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HUGO ERNESTO CUÉLLAR CARREÓN\nDIRECTOR DEL INSTITUTO TECNOLÓGICO DE COLIMA\nPRESENTE',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, color: theme.colorScheme.onSurface),
                    children: <TextSpan>[
                      const TextSpan(text: 'El (la) que suscribe C. '),
                      TextSpan(text: fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ', Estudiante del '),
                      TextSpan(text: semester, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' semestre, de la carrera '),
                      TextSpan(text: career, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ', con número de control '),
                      TextSpan(text: numberControl, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ', por lo que solicito a usted se me conceda la Prestación de Beca Alimenticia, ya que por los siguientes motivos la requiero:'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _reasonsController,
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Escriba aquí los motivos económicos, personales o académicos...',
                    labelText: 'Motivos de la Solicitud',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text('Firma y Confirmación del Solicitante', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Para confirmar su identidad y firmar esta solicitud, por favor ingrese su número de control en el siguiente campo. Esta acción confirma que los datos proporcionados son correctos.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controlNumberConfirmationController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Número de Control',
                    hintText: 'Ingrese su número de control',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.verified_user_outlined), 
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, confirme su número de control.';
                    }
                    if (value.trim() != numberControl) {
                      return 'El número de control no coincide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Firmar y Enviar Solicitud'),
                          onPressed: _submitApplication,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

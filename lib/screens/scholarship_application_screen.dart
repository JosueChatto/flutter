
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ScholarshipApplicationScreen extends StatefulWidget {
  final String callId;
  const ScholarshipApplicationScreen({super.key, required this.callId});

  @override
  State<ScholarshipApplicationScreen> createState() => _ScholarshipApplicationScreenState();
}

class _ScholarshipApplicationScreenState extends State<ScholarshipApplicationScreen> {
  late Future<Map<String, dynamic>?> _initialDataFuture;

  @override
  void initState() {
    super.initState();
    _initialDataFuture = _fetchInitialData();
  }

  Future<Map<String, dynamic>?> _fetchInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final applicationQuery = await FirebaseFirestore.instance
        .collection('scholarship_calls')
        .doc(widget.callId)
        .collection('applicants')
        .doc(user.uid)
        .get();

    if (applicationQuery.exists) {
      return {'existingApplication': applicationQuery.data()};
    } else {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return {'userData': userDoc.data()};
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud de Beca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard/scholarship-calls'),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _initialDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Error: No se pudieron cargar los datos.'));
          }

          final data = snapshot.data!;

          if (data.containsKey('existingApplication')) {
            return _AlreadyAppliedView(applicationData: data['existingApplication']);
          } else if (data.containsKey('userData')) {
            // Aquí se llama al widget que faltaba
            return _ApplicationFormView(userData: data['userData'], callId: widget.callId);
          } else {
            return const Center(child: Text('No se pudo verificar tu estado. Intenta más tarde.'));
          }
        },
      ),
    );
  }
}

// VISTA PARA CUANDO EL USUARIO YA APLICÓ
class _AlreadyAppliedView extends StatelessWidget {
  final Map<String, dynamic> applicationData;
  const _AlreadyAppliedView({required this.applicationData});

  @override
  Widget build(BuildContext context) {
    // ... (sin cambios en esta vista)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.hourglass_empty_outlined, size: 60, color: Colors.amber.shade800),
                const SizedBox(height: 20),
                Text('Solicitud en Proceso', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                const SizedBox(height: 12),
                Text('Ya has aplicado a esta convocatoria. Tu solicitud está en revisión.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => context.go('/student-dashboard'), child: const Text('Volver al Inicio'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- WIDGET DEL FORMULARIO DE APLICACIÓN (EL QUE FALTABA) ---
class _ApplicationFormView extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String callId;

  const _ApplicationFormView({required this.userData, required this.callId});

  @override
  State<_ApplicationFormView> createState() => _ApplicationFormViewState();
}

// --- ESTADO DEL FORMULARIO DE APLICACIÓN (CORREGIDO) ---
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
        content: const Text('Una vez confirmada la solicitud, no se podrán realizar cambios. ¿Deseas continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirmar y Enviar')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() { _isSubmitting = true; });

    final user = FirebaseAuth.instance.currentUser!;
    try {
      final dataToSave = {
        'studentID': user.uid,
        'studentName': widget.userData['name'] ?? 'N/A',
        'lastName': widget.userData['lastName'] ?? '',
        'career': widget.userData['career'] ?? 'N/A',
        'semester': widget.userData['semester'],
        'gpa': widget.userData['gpa'],
        'email': user.email,
        'numberControl': widget.userData['numberControl'],
        'numberPhone': widget.userData['numberPhone'],
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

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Solicitud enviada con éxito!')));
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.go('/student-dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar la solicitud: $e')));
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = widget.userData;
    final fullName = ('${userData['name'] ?? ''} ${userData['lastName'] ?? ''}').trim();
    final semester = userData['semester']?.toString() ?? '[No definido]';
    final career = userData['career']?.toString() ?? '[No definida]';
    final numberControl = userData['numberControl']?.toString() ?? '[No definido]';

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
                  decoration: const InputDecoration( // <-- Se quita el 'const' aquí
                    labelText: 'Confirmar Número de Control',
                    hintText: 'Ingrese su número de control',
                    border: OutlineInputBorder(),
                    // ICONO CORREGIDO Y 'const' REMOVIDO DE LA DECORACIÓN
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


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ScholarshipApplicationScreen extends StatefulWidget {
  final String callId; // ID de la convocatoria seleccionada
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

    // Verificar si ya existe una aplicación PARA ESTA CONVOCATORIA específica
    final applicationQuery = await FirebaseFirestore.instance
        .collection('scholarship_calls')
        .doc(widget.callId)
        .collection('applicants')
        .doc(user.uid)
        .get();

    if (applicationQuery.exists) {
      // Ya existe una aplicación, devolver sus datos para la vista de "ya aplicado".
      return {'existingApplication': applicationQuery.data()};
    } else {
      // No hay aplicación para esta convocatoria, buscar los datos del usuario para el formulario
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return {'userData': userDoc.data()};
      }
    }
    return null; // No se encontraron datos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud de Beca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Volver a la lista de convocatorias
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
            return _ApplicationFormView(userData: data['userData'], callId: widget.callId);
          } else {
            return const Center(child: Text('No se pudo verificar tu estado. Intenta más tarde.'));
          }
        },
      ),
    );
  }
}

// --- VISTA CUANDO YA SE APLICÓ (Sin cambios) ---
class _AlreadyAppliedView extends StatelessWidget {
  final Map<String, dynamic> applicationData;
  const _AlreadyAppliedView({required this.applicationData});
  @override
  Widget build(BuildContext context) {
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

// --- VISTA DEL FORMULARIO DE APLICACIÓN ---
class _ApplicationFormView extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String callId;
  const _ApplicationFormView({required this.userData, required this.callId});

  @override
  State<_ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<_ApplicationFormView> {
  final _reasonsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonsController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (_reasonsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, es obligatorio explicar los motivos de la solicitud.')));
      return;
    }
    
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Envío'),
        content: const Text('Una vez firmada y confirmada la solicitud, no se podrán realizar cambios. ¿Deseas continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirmar y Enviar')),
        ],
      ),
    );

    if (confirmed != true) return; // Si el usuario cancela

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
        'status': 'pending', // Estado inicial de la solicitud
        'applicationDate': FieldValue.serverTimestamp(),
        'reasons': _reasonsController.text.trim(),
        'callId': widget.callId, // Guardar el ID de la convocatoria
      };

      // Guardar en la sub-colección de la convocatoria
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
    String fullName = ('${userData['name'] ?? ''} ${userData['lastName'] ?? ''}').trim();

    return SingleChildScrollView(
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
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  children: <TextSpan>[
                     const TextSpan(text: 'El (la) que suscribe C. '),
                    TextSpan(text: fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ', Estudiante del '),
                    TextSpan(text: '${userData['semester'] ?? '...'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' semestre, de la carrera '),
                    TextSpan(text: '${userData['career'] ?? '...'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ', con número de control '),
                    TextSpan(text: '${userData['numberControl'] ?? '...'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ', por lo que solicito a usted se me conceda la Prestación de Beca Alimenticia, ya que por los siguientes motivos la requiero:'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _reasonsController,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Escriba aquí los motivos económicos, personales o académicos...',
                  labelText: 'Motivos de la Solicitud (Obligatorio)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Firma del Solicitante', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(fullName, style: const TextStyle(fontSize: 16)),
              Text('No. de Control: ${userData['numberControl'] ?? '...'} ', style: const TextStyle(fontSize: 16)),
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
    );
  }
}

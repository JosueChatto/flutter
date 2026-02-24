import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeContent() async {
  try {
    final docRef = FirebaseFirestore.instance.collection('app_content').doc('student_info');
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'rights_and_obligations': '''Derechos:
- Recibir notificación de la asignación de la beca.
- Recibir el servicio alimenticio en las cafeterías del TecNM.

Obligaciones:
- Presentar la credencial de estudiante vigente.
- Asistir con regularidad a clases.
- Observar buena conducta.
- Mantener un buen desempeño académico.
- Participar en eventos y/o proyectos institucionales.''',
        'selection_criteria': '''Los aspirantes que cumplan con el requisito serán seleccionados prioritariamente en función de los siguientes criterios:
- Con situación económica adversa.
- Con capacidades diferentes.
- Que sean madres solteras o embarazadas.
- Que su lugar de residencia esté alejado del instituto.
- Que su carga horaria les obligue a estar un mayor número de horas en la institución, siempre y cuando no se deba a reprobación.
- Que preferentemente no cuenten con algún beneficio equivalente de tipo económico o en especie otorgado por organismos públicos o privados.
- Que participen en equipos o grupos representativos de la institución.''',
      });
      log('Contenido inicial de la aplicación creado en Firestore.', name: 'InitializeContent');
    }
  } catch (e, s) {
    log(
      'Error al inicializar el contenido en Firestore. Esto puede suceder, pero no debería bloquear la aplicación.',
      name: 'InitializeContentError',
      error: e,
      stackTrace: s,
    );
  }
}

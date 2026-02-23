/// Representa el modelo de datos para una beca.
///
/// Esta clase fue definida durante las etapas iniciales del desarrollo para estructurar
/// la información de las becas y fue utilizada en conjunto con los datos de prueba
/// (ver `lib/data/scholarship_data.dart`).
///
/// En la versión actual de la aplicación, que interactúa directamente con Firestore,
/// los datos de las convocatorias se manejan como `Map<String, dynamic>` y no se
/// instancia este objeto. Podría ser reutilizado en el futuro si se decide
/// implementar una capa de modelos más estricta sobre los datos de Firestore.
class Scholarship {
  final String title;
  final String description;
  final String organization;
  final String amount;
  final String deadline;
  final List<String> requirements;

  Scholarship({
    required this.title,
    required this.description,
    required this.organization,
    required this.amount,
    required this.deadline,
    required this.requirements,
  });
}

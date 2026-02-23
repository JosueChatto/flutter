import 'package:flutter/material.dart';
import '../models/scholarship.dart';

/// Un widget de tarjeta reutilizable para mostrar un resumen de una beca.
///
/// Este widget fue diseñado para visualizar los datos del modelo [Scholarship]
/// y se utilizó en las primeras etapas de desarrollo con datos de prueba.
///
/// Actualmente, no se utiliza directamente en las pantallas que consumen datos
/// de Firestore, ya que estas construyen sus propios widgets de tarjeta (ej. `ListTile`)
/// a partir de los datos `Map<String, dynamic>`.
///
/// Podría ser adaptado en el futuro para consumir un `Map<String, dynamic>` si se
/// desea estandarizar la apariencia de las tarjetas de becas en la aplicación.
class ScholarshipCard extends StatelessWidget {
  /// La beca a mostrar.
  final Scholarship scholarship;

  /// La función a ejecutar cuando se toca la tarjeta.
  final VoidCallback onTap;

  const ScholarshipCard({
    super.key,
    required this.scholarship,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scholarship.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                scholarship.organization,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monto:', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    scholarship.amount,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha Límite:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    scholarship.deadline,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

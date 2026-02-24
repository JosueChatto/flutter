import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScholarshipInfoScreen extends StatefulWidget {
  const ScholarshipInfoScreen({super.key});

  @override
  State<ScholarshipInfoScreen> createState() => _ScholarshipInfoScreenState();
}

class _ScholarshipInfoScreenState extends State<ScholarshipInfoScreen> {
  late Future<DocumentSnapshot> _contentFuture;

  @override
  void initState() {
    super.initState();
    _contentFuture = FirebaseFirestore.instance
        .collection('app_content')
        .doc('student_info')
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convocatoria de Beca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el contenido: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontró el contenido.'));
          }

          final content = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(context, 'Convocatoria Becas Alimenticias 2025-1'),
                _buildInfoCard(
                  context,
                  icon: Icons.flag_outlined,
                  title: 'Objetivo',
                  content:
                      'Propiciar que los estudiantes cuenten con un apoyo para continuar su formación profesional, atendiendo políticas de equidad para estudiantes con capacidades diferentes o situaciones particulares, buscando la permanencia y continuación de sus estudios.',
                ),
                _buildInfoCard(
                  context,
                  icon: Icons.groups_outlined,
                  title: 'Población Objetivo',
                  content:
                      'Todo el estudiantado inscrito en el TecNM – Instituto Tecnológico de Colima.',
                ),
                _buildInfoCard(
                  context,
                  icon: Icons.restaurant_menu_outlined,
                  title: 'Características de la Beca',
                  content:
                      'Consisten en el otorgamiento de servicios alimenticios en las cafeterías del Instituto, con un horario de 08:00 a 17:00 horas y de acuerdo al calendario escolar vigente.',
                ),
                _buildInfoCard(
                  context,
                  icon: Icons.checklist_rtl_outlined,
                  title: 'Criterios de Selección',
                  content: content['selection_criteria'] ?? 'Cargando...',
                ),
                _buildInfoCard(
                  context,
                  icon: Icons.gavel_outlined,
                  title: 'Derechos y Obligaciones',
                  content: content['rights_and_obligations'] ?? 'Cargando...',
                ),
                _buildInfoCard(
                  context,
                  icon: Icons.cancel_outlined,
                  title: 'Causas de Cancelación',
                  content:
                      'a) Proporcionar datos falsos o alterar documentación.\nb) Incumplir con cualquiera de sus obligaciones.\nc) Baja temporal, definitiva o deserción.\nd) No utilizar los servicios alimenticios otorgados.',
                ),
                _buildInfoCard(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Fechas Importantes',
                  // CORRECCIÓN: Se usa RichText para formatear el texto sin asteriscos.
                  content:
                      'Recepción de solicitudes: Del 10 de febrero al 17 de febrero de 2025.\nPublicación de resultados: 22 de febrero de 2025.\nInicio del servicio: A partir del 24 de febrero del año en curso.',
                  isLast: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  // CORRECCIÓN: El widget _buildInfoCard ahora usa RichText para el contenido.
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final bodyTextStyle = theme.textTheme.bodyLarge?.copyWith(height: 1.5);
    final boldTextStyle = bodyTextStyle?.copyWith(fontWeight: FontWeight.bold);

    List<TextSpan> buildTextSpans(String text) {
      final spans = <TextSpan>[];
      final lines = text.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final parts = line.split(':');
        if (parts.length > 1) {
          spans.add(TextSpan(text: '${parts[0]}:', style: boldTextStyle));
          spans.add(TextSpan(text: parts.sublist(1).join(':')));
        } else {
          spans.add(TextSpan(text: line));
        }
        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
      }
      return spans;
    }

    return Card(
      elevation: 2.0,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: bodyTextStyle, 
                children: buildTextSpans(content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

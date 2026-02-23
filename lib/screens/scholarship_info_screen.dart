import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScholarshipInfoScreen extends StatelessWidget {
  const ScholarshipInfoScreen({super.key});

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
      body: SingleChildScrollView(
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
              content:
                  'Los aspirantes que cumplan con el requisito serán seleccionados prioritariamente en función de los siguientes criterios:\n\n(A) Con situación económica adversa.\n(B) Con capacidades diferentes.\n(C) Que sean madres solteras o embarazadas.\n(D) Que su lugar de residencia esté alejado del instituto.\n(E) Que su carga horaria les obligue a estar un mayor número de horas en la institución, siempre y cuando no se deba a reprobación.\n(F) Que preferentemente no cuenten con algún beneficio equivalente de tipo económico o en especie otorgado por organismos públicos o privados.\n(G) Que participen en equipos o grupos representativos de la institución.',
            ),
            _buildInfoCard(
              context,
              icon: Icons.gavel_outlined,
              title: 'Derechos y Obligaciones',
              content:
                  '**Derechos:**\n\n a) Recibir notificación de la asignación de la beca.\n b) Recibir el servicio alimenticio en las cafeterías del TecNM.\n\n**Obligaciones:**\n\n a) Presentar la credencial de estudiante vigente.\n b) Asistir con regularidad a clases.\n c) Observar buena conducta.\n d) Mantener un buen desempeño académico.\n e) Participar en eventos y/o proyectos institucionales.',
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
              content:
                  '**Recepción de solicitudes:** Del 10 de febrero al 17 de febrero de 2025.\n**Publicación de resultados:** 22 de febrero de 2025.\n**Inicio del servicio:** A partir del 24 de febrero del año en curso.',
              isLast: true,
            ),
          ],
        ),
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

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
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
            Text(
              content,
              textAlign: TextAlign.justify,
              // Se elimina el color fijo para que se adapte al tema (oscuro/claro)
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

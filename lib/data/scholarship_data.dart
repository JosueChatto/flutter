
import '../models/scholarship.dart';

final List<Scholarship> mockScholarships = [
  Scholarship(
    title: 'Beca de Excelencia Académica',
    description: 'Dirigida a estudiantes con un promedio general superior a 9.5. Esta beca cubre el 100% de la matrícula y ofrece un estipendio mensual.',
    organization: 'Fundación Futuro Brillante',
    amount: 'Matrícula Completa + \$500/mes',
    deadline: '2024-12-15',
    requirements: [
      'Promedio general mínimo de 9.5',
      'Carta de recomendación de un profesor',
      'Ensayo de 500 palabras sobre metas profesionales',
      'Ser estudiante regular de tiempo completo',
    ],
  ),
  Scholarship(
    title: 'Beca para Liderazgo y Servicio Comunitario',
    description: 'Apoyo para estudiantes que demuestren un fuerte compromiso con el servicio a su comunidad y habilidades de liderazgo.',
    organization: 'Organización Líderes del Mañana',
    amount: '\$2,500 por semestre',
    deadline: '2024-11-30',
    requirements: [
      'Mínimo de 100 horas de servicio comunitario comprobables',
      'Evidencia de roles de liderazgo en proyectos o grupos estudiantiles',
      'Dos cartas de recomendación',
      'Entrevista con el comité de selección',
    ],
  ),
  Scholarship(
    title: 'Beca para Mujeres en Tecnología',
    description: 'Iniciativa para impulsar la participación femenina en carreras de ciencia, tecnología, ingeniería y matemáticas (STEM).',
    organization: 'Tech-Mujer Innovadora',
    amount: '\$10,000 anuales',
    deadline: '2025-01-20',
    requirements: [
      'Ser mujer',
      'Estar inscrita en una carrera STEM',
      'Presentar un proyecto personal o académico relacionado con tecnología',
      'Promedio mínimo de 8.5',
    ],
  ),
  Scholarship(
    title: 'Beca de Apoyo Deportivo',
    description: 'Para atletas de alto rendimiento que representan a la institución en competencias nacionales.',
    organization: 'Comité Deportivo Universitario',
    amount: '50% de descuento en matrícula y apoyo para viajes',
    deadline: '2024-10-31',
    requirements: [
      'Ser miembro de un equipo deportivo representativo',
      'Mantener un promedio mínimo de 8.0',
      'Carta de recomendación del entrenador',
      'Participar en todas las competencias programadas',
    ],
  ),
];

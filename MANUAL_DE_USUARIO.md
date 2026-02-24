# Manual de Usuario Extendido de la Aplicación "AMOBECAL"

---

## 1. Introducción

Bienvenido a AMOBECAL, la aplicación integral para la gestión de becas universitarias. Este manual está diseñado para guiar a los usuarios a través de las funcionalidades de la plataforma, detallando el papel fundamental de cada perfil y los flujos de trabajo asociados.

La aplicación está dirigida a tres perfiles de usuario clave:
*   Estudiantes: Solicitantes y beneficiarios de becas.
*   Administradores: Personal encargado de crear, gestionar y resolver las convocatorias de becas.
*   Personal de Cafetería: Responsables de validar y gestionar las becas alimenticias.

El sistema está construido con un diseño moderno e intuitivo (Material Design 3), garantizando una experiencia de usuario fluida, limpia y fácil de navegar, con un fuerte enfoque en la accesibilidad y la transparencia de la información.

---

## 2. Rol del Estudiante

El estudiante es el corazón de AMOBECAL. Su rol principal es buscar, solicitar y dar seguimiento a las becas que le ayudarán a continuar con su formación académica. La plataforma le otorga autonomía y acceso directo a la información.

### 2.1. Funcionalidades Clave para el Estudiante

*   Autenticación Segura: Inicio de sesión con correo institucional y contraseña para proteger su información personal y académica.
*   Panel de Control (Dashboard): Una vista centralizada y dinámica que presenta un resumen de notificaciones importantes, el estado de sus solicitudes activas y accesos directos a las funciones más utilizadas.
*   Visualización de Becas: Lista completa y detallada de las convocatorias de becas activas. Cada beca en la lista muestra información clave como el nombre, el periodo de solicitud y el tipo de ayuda.
*   Detalle de la Beca: Al seleccionar una beca, el estudiante accede a una pantalla con información exhaustiva que incluye:
    *   Descripción Completa: Propósito y alcance de la beca.
    *   Requisitos: Criterios obligatorios que debe cumplir el aspirante (promedio, semestre, etc.).
    *   Criterios de Selección Prioritaria: Factores que dan ventaja a los candidatos, como situación económica, discapacidad, ser madre/padre soltero, vivir en zonas alejadas, etc. Esto aporta total transparencia al proceso.
    *   Obligaciones del Becario: Deberes que el estudiante adquiere si se le otorga la beca (mantener promedio, observar buena conducta, participar en eventos, etc.).
    *   Documentación Requerida: Lista de documentos que deben adjuntarse a la solicitud.
*   Proceso de Solicitud Simplificado: Un formulario intuitivo para aplicar a las becas. La mayor parte de la información académica del estudiante se rellena automáticamente desde los sistemas de la institución, minimizando errores y agilizando el proceso. El estudiante solo debe verificar los datos y adjuntar los documentos solicitados.
*   Carga de Documentos: Una interfaz integrada en el formulario de solicitud que permite subir archivos (PDF, JPG, PNG) directamente desde el dispositivo, como constancias de ingresos, historial académico, etc.
*   Estado de la Solicitud: Seguimiento en tiempo real y detallado del estado de sus solicitudes. Los estados posibles son:
    *   Borrador: Solicitud iniciada pero no enviada.
    *   Enviada: Solicitud completada y recibida por el sistema.
    *   En Revisión: La solicitud está siendo evaluada por un administrador.
    *   Aceptada: La beca ha sido otorgada.
    *   Rechazada: La solicitud no fue aprobada en esta convocatoria.
*   Perfil de Usuario: Acceso y visualización de su información personal y académica, la cual está sincronizada directamente desde la base de datos de la institución para garantizar su exactitud.
*   Historial de Solicitudes: Una sección donde el estudiante puede consultar todas las becas a las que ha aplicado en el pasado, tanto las otorgadas como las no otorgadas.

### 2.2. Flujos de Trabajo del Estudiante

#### a) Flujo de Inicio de Sesión y Exploración
1.  Iniciar Sesión: El estudiante ingresa a la aplicación e introduce sus credenciales institucionales.
2.  Acceder al Dashboard: Al autenticarse, es dirigido al panel de control, donde ve un saludo personalizado y un resumen de su actividad reciente.
3.  Explorar Becas: Desde el dashboard o el menú de navegación, accede a la sección "Ver Becas Disponibles". Aquí puede filtrar o buscar convocatorias por tipo (alimenticia, económica, etc.).
4.  Revisar Detalles a Fondo: Selecciona una beca que le interese. Lee detenidamente los requisitos, los criterios de selección y las obligaciones para asegurarse de que es un buen candidato.

#### b) Flujo de Solicitud de Beca
1.  Iniciar Solicitud: Tras revisar los detalles, el estudiante presiona el botón "Aplicar".
2.  Completar y Verificar Formulario: Revisa los datos pre-cargados (nombre, carrera, promedio). Si la beca lo requiere, responde preguntas adicionales.
3.  Adjuntar Documentación: Utiliza la función de carga de archivos para subir los documentos necesarios, como el comprobante de domicilio o el estudio socioeconómico.
4.  Enviar Solicitud: Al finalizar, revisa toda la información y presiona "Enviar". El sistema le muestra una confirmación en pantalla y el estado de su solicitud cambia a "Enviada".

#### c) Flujo de Seguimiento y Resultados
1.  Consultar Estado: El estudiante ingresa periódicamente a la sección "Mis Solicitudes" para monitorear el progreso.
2.  Recibir Notificaciones: Recibe una notificación push en su teléfono cuando el estado de su solicitud cambia, por ejemplo, de "Enviada" a "En Revisión".
3.  Ver Resultados Finales: Al finalizar el periodo de evaluación, recibe una notificación con el veredicto.
    *   Si es Aceptado: Su panel de control se actualiza para reflejar su estatus de "Becario". Su nombre se añade a la lista interna correspondiente (ej. la lista de cafetería si la beca es alimenticia).
    *   Si es Rechazado: El sistema le informa la decisión, y puede consultar su historial para prepararse mejor para futuras convocatorias.

---

## 3. Rol del Administrador

El administrador es el gestor y supervisor del ecosistema de becas. Su rol es asegurar que el proceso sea justo, transparente y eficiente, desde la planificación de la oferta hasta la selección final de beneficiarios.

### 3.1. Funcionalidades Clave para el Administrador

*   Dashboard Administrativo: Un potente panel de control con estadísticas clave (ej. número total de solicitudes, becas por tipo, aplicantes por convocatoria) y acceso directo a todas las herramientas de gestión.
*   Gestión de Convocatorias (CRUD):
    *   Crear: Diseñar y publicar nuevas convocatorias de becas, definiendo todos los parámetros (nombre, fechas, requisitos, criterios de selección, obligaciones, etc.).
    *   Editar: Modificar convocatorias existentes (siempre que no estén en periodo de revisión).
    *   Archivar: Ocultar convocatorias pasadas para mantener la lista principal limpia, pero conservando el historial.
    *   Eliminar: Borrar convocatorias (función restringida para casos necesarios).
*   Revisión Avanzada de Solicitudes: Interfaz para visualizar la lista de estudiantes que han aplicado a cada convocatoria. Permite:
    *   Filtrar y Ordenar: Clasificar a los aplicantes por promedio, semestre, nombre o fecha de solicitud.
    *   Visualizador de Documentos: Abrir y revisar los documentos adjuntos por los estudiantes directamente en la aplicación, sin necesidad de descargarlos.
*   Detalle del Aplicante: Acceso a un perfil consolidado de cada solicitante, que incluye su información académica, datos de contacto y todos los documentos que ha subido.
*   Publicación de Resultados: Herramienta segura para cambiar masivamente el estado de las solicitudes (aceptar/rechazar) y publicar la lista final de beneficiarios de forma oficial y automatizada.
*   Gestión de Usuarios: Capacidad para crear, desactivar y gestionar los perfiles de otros administradores y del personal de cafetería.
*   Reportes y Estadísticas: Generación de informes exportables (ej. en CSV o PDF) sobre datos demográficos de los solicitantes, tasas de aceptación por beca, y otros indicadores útiles para la toma de decisiones institucionales.
*   Gestión de Contenido: Posibilidad de editar textos informativos, banners o noticias dentro de la aplicación para comunicar anuncios importantes a los estudiantes.

### 3.2. Flujos de Trabajo del Administrador

#### a) Flujo de Creación de una Convocatoria
1.  Acceder al Panel de Gestión: Inicia sesión y navega a "Gestionar Convocatorias".
2.  Crear Nueva Beca: Selecciona "Crear Nueva Convocatoria".
3.  Definir Parámetros Detallados: Rellena un formulario completo donde especifica los criterios extraídos de la normativa, como "situación económica adversa", "madres solteras", etc., como criterios de prioridad.
4.  Publicar Convocatoria: Tras revisar y guardar los detalles, la publica. Inmediatamente, la beca se vuelve visible para todos los estudiantes en la aplicación.

#### b) Flujo de Revisión y Selección de Candidatos
1.  Monitorear Solicitudes: Durante el periodo de solicitud, el administrador observa el flujo de aplicantes en tiempo real.
2.  Cierre y Revisión: Una vez que el plazo finaliza, el sistema bloquea nuevas solicitudes. El administrador accede a la lista de candidatos.
3.  Evaluar Perfiles Sistemáticamente: Utiliza los filtros para ordenar a los candidatos (ej. de mayor a menor promedio). Revisa el perfil de cada uno, verifica que los documentos sean correctos y legibles. El sistema podría resaltar automáticamente a los candidatos que cumplen con criterios de prioridad.
4.  Tomar Decisiones Fundamentadas: Marca cada solicitud como "Pre-Aceptada" o "Rechazada". Puede dejar comentarios internos en cada solicitud si es necesario.

#### c) Flujo de Publicación de Resultados
1.  Revisión Final: El administrador tiene una vista de todos los candidatos "Pre-Aceptados". Puede hacer ajustes finales si el número de plazas es limitado.
2.  Confirmar y Publicar: Utiliza la función "Publicar Resultados". El sistema le pide una confirmación final para evitar errores.
3.  Actualización Automática y Notificación: Al confirmar, el sistema realiza tres acciones simultáneamente:
    *   Actualiza el estado de la solicitud para cada estudiante en su perfil personal.
    *   Envía notificaciones push a todos los aplicantes informándoles del resultado.
    *   Actualiza las listas internas de beneficiarios (ej. la de Cafetería).

---

## 4. Rol del Personal de Cafetería

Este perfil tiene un rol operativo muy específico y crucial: validar que los estudiantes que se presentan en la cafetería son efectivamente beneficiarios de una beca alimenticia activa. La interfaz está diseñada para ser extremadamente rápida y fácil de usar.

### 4.1. Funcionalidades Clave para Cafetería

*   Dashboard de Cafetería: Interfaz minimalista con una sola función principal: verificar becarios.
*   Lista de Becarios en Tiempo Real: Acceso a la lista automáticamente actualizada de todos los estudiantes con una beca alimenticia activa para el periodo en curso. No hay riesgo de usar listas obsoletas.
*   Búsqueda Rápida e Inteligente: Una barra de búsqueda prominente para encontrar a un estudiante por su número de control o nombre en segundos.
*   Detalle Visual del Becario: Al encontrar al estudiante, se muestra en pantalla grande su foto, nombre completo, número de control y el periodo de validez de la beca. Esto permite una verificación visual inequívoca.

### 4.2. Flujo de Trabajo del Personal de Cafetería

#### a) Flujo de Verificación Diaria
1.  Acceso Rápido: El personal inicia sesión con credenciales específicas de cafetería.
2.  Listo para Verificar: Inmediatamente ve la barra de búsqueda y está listo para atender al primer estudiante.
3.  Buscar al Estudiante: Un estudiante llega al mostrador. El personal teclea su número de control. La búsqueda es instantánea.
4.  Confirmar Identidad Visualmente: La ficha del estudiante aparece en la pantalla. El personal compara la foto en la app con la persona que tiene en frente y confirma su nombre.
5.  Validar Servicio:
    *   Si la Verificación es Exitosa: Se le otorga el servicio de comida.
    *   Si el Estudiante no Aparece: Significa que no es beneficiario de la beca alimenticia para ese periodo. El personal le informa cortésmente que debe consultar su estatus en la aplicación o dirigirse a la oficina de becas.
    *   Si la Foto no Coincide: Se le puede pedir una identificación oficial para corroborar, evitando el fraude.

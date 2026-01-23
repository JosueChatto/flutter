
# Blueprint de la Aplicación de Gestión de Becas AMOBECAL

## Descripción General

AMOBECAL es una aplicación móvil integral diseñada para simplificar y automatizar el proceso de solicitud, gestión y seguimiento de becas universitarias. La plataforma está dirigida a tres perfiles de usuario clave: estudiantes, administradores y personal de cafetería, cada uno con funcionalidades específicas para sus roles.

La aplicación ofrece una experiencia de usuario fluida y moderna, con un diseño intuitivo basado en Material Design 3, modo oscuro, y una navegación clara y predecible gracias a `go_router`.

---

## Funcionalidades Implementadas

### Perfil de Estudiante

- **Autenticación:** Pantalla de inicio de sesión para acceder al perfil correspondiente.
- **Panel de Control (Dashboard):**
  - **Mi Perfil:** Visualización y edición de la información personal del estudiante.
  - **Ver Convocatorias:** Lista de becas disponibles con detalles y requisitos.
  - **Subir Documentos:** Interfaz para cargar los documentos necesarios para la solicitud.
  - **Estado de la Solicitud:** Seguimiento en tiempo real del estado de la postulación (enviada, en revisión, aprobada, rechazada).

### Perfil de Administrador

- **Panel de Control (Dashboard):**
  - **Ver Solicitudes:** Lista de todos los estudiantes que han aplicado a una beca.
    - **Detalle del Solicitante:** Vista detallada de la información y documentos del estudiante, con opciones para **aprobar** o **rechazar** la solicitud.
  - **Crear Nueva Convocatoria:** Formulario para publicar nuevas ofertas de becas, especificando nombre, descripción, requisitos y fechas.
  - **Historial de Becas Otorgadas:** Registro de todas las becas concedidas, incluyendo detalles del estudiante y la fecha.

### Perfil de Cafetería

- **Panel de Control (Dashboard):**
  - **Visualizar Reportes:** Muestra una lista en tiempo real de los estudiantes con una beca alimenticia activa.
  - **Registrar Canje:** Permite al personal marcar cuándo un estudiante ha recibido su comida, actualizando el estado para evitar duplicados en el día.

---

## Arquitectura y Diseño

- **Gestión de Estado:** Se utiliza `provider` para el manejo del tema (claro/oscuro), garantizando una actualización reactiva de la interfaz.
- **Enrutamiento:** La navegación se gestiona con `go_router`, permitiendo rutas anidadas y una estructura de navegación organizada.
- **Diseño de Interfaz:**
  - **Tema:** Paleta de colores basada en `Colors.indigo`, con una tipografía moderna y legible utilizando `google_fonts` (principalmente 'Montserrat' y 'Roboto').
  - **Componentes:** Uso de widgets de Material 3 como `Card`, `ListTile`, `ElevatedButton` y `TextField` con un estilo consistente y moderno.
  - **Experiencia de Usuario:** Interfaces limpias, con buena distribución de espacios y una jerarquía visual clara para facilitar la interacción.

---

## Plan de Desarrollo Futuro

1.  **Integración con Backend (Firebase/Supabase):**
    -   Conectar la aplicación a una base de datos como la propuesta en el script SQL para gestionar usuarios, convocatorias, solicitudes y canjes de forma persistente.
    -   Implementar un sistema de autenticación real.
    -   Utilizar servicios de almacenamiento para los documentos de los estudiantes.

2.  **Funcionalidad de Notificaciones:**
    -   Añadir notificaciones push para informar a los estudiantes sobre cambios en el estado de su solicitud o nuevas convocatorias.

3.  **Internacionalización (i18n):**
    -   Preparar la aplicación para soportar múltiples idiomas.

4.  **Pruebas Unitarias y de Integración:**
    -   Desarrollar un conjunto de pruebas para garantizar la estabilidad y fiabilidad del código.

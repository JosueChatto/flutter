# Aplicación de Gestión de Becas "AMOBECAL"

## Descripción General

AMOBECAL es una aplicación móvil integral, construida con Flutter, diseñada para simplificar y automatizar el proceso de solicitud, gestión y seguimiento de becas universitarias. La plataforma está dirigida a tres perfiles de usuario clave: **estudiantes**, **administradores** y personal de **cafetería**, cada uno con funcionalidades específicas para sus roles.

El objetivo principal de la aplicación es ofrecer una experiencia de usuario fluida y moderna, con un diseño intuitivo basado en **Material Design 3**, soporte para modo claro/oscuro, y una navegación clara y predecible.

---

## Funcionalidades Implementadas

La aplicación se estructura en torno a los siguientes perfiles:

### 1. Perfil de Estudiante
- **Autenticación:** Pantalla de inicio de sesión para acceder al sistema.
- **Panel de Control (Dashboard):** Un centro de operaciones para el estudiante con acceso a:
  - **Mi Perfil:** Visualización de la información personal.
  - **Ver Convocatorias:** Una lista de las becas disponibles con sus detalles y requisitos.
  - **Subir Documentos:** Interfaz para cargar fácilmente los documentos necesarios para las postulaciones.
  - **Estado de la Solicitud:** Seguimiento en tiempo real del progreso de una postulación (enviada, en revisión, aprobada o rechazada).

### 2. Perfil de Administrador
- **Panel de Control (Dashboard):** Herramientas para la gestión completa del programa de becas.
  - **Ver Solicitudes:** Acceso a una lista de todos los estudiantes que han aplicado a una beca.
  - **Detalle del Solicitante:** Vista detallada de la información y documentos de cada estudiante, con la capacidad de **aprobar** o **rechazar** la solicitud directamente.
  - **Crear Nueva Convocatoria:** Un formulario para publicar nuevas ofertas de becas, especificando nombre, descripción, requisitos y fechas importantes.
  - **Historial de Becas:** Un registro de todas las becas que han sido otorgadas.

### 3. Perfil de Cafetería
- **Panel de Control (Dashboard):** Funcionalidades específicas para la gestión de becas alimenticias.
  - **Visualizar Reportes:** Muestra una lista en tiempo real de los estudiantes que tienen una beca alimenticia activa.

---

## Arquitectura y Diseño

El proyecto está construido siguiendo las mejores prácticas de desarrollo en Flutter:

-   **Gestión de Estado:** Se utiliza el paquete `provider` para manejar el estado global de la aplicación, como el cambio entre tema claro y oscuro.
-   **Enrutamiento:** La navegación se gestiona con `go_router`, lo que permite una estructura de rutas declarativa, anidada y fácil de mantener.
-   **Diseño de Interfaz:**
    -   **Tema:** Se adhiere a los principios de **Material Design 3**, con una paleta de colores coherente y una tipografía moderna y legible gracias a `google_fonts`.
    -   **Componentes:** Uso de widgets modernos y estilizados para una experiencia de usuario consistente.
    -   **Experiencia de Usuario:** Las interfaces están diseñadas para ser limpias, con una buena distribución de espacios y una jerarquía visual clara que facilita la interacción del usuario.

veremos las solucioes

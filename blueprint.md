
# Blueprint de la Aplicación de Gestión de Becas AMOBECAL

## Descripción General

AMOBECAL es una aplicación móvil integral diseñada para simplificar y automatizar el proceso de solicitud, gestión y seguimiento de becas universitarias. La plataforma está dirigida a tres perfiles de usuario clave: estudiantes, administradores y personal de cafetería, cada uno con funcionalidades específicas para sus roles.

La aplicación ofrece una experiencia de usuario fluida y moderna, con un diseño intuitivo basado en Material Design 3, modo oscuro, y una navegación clara y predecible gracias a `go_router`.

---

## Última Actualización: Refactorización y Ajuste de Roles

**Objetivo:** Modernizar y simplificar la interfaz de usuario para todos los roles, y ajustar las funcionalidades según los requisitos finales.

**Cambios Realizados:**

- **Panel de Estudiante:** Se rediseñó la interfaz a un diseño de lista vertical más limpio con las opciones: "Mi Perfil", "Estado de Solicitud", "Aplicar a Beca" e "Información de Beca".
- **Panel de Administrador:** Se modernizó el panel para seguir el mismo diseño de lista, enfocándose en: "Ver Solicitudes", "Crear Nueva Convocatoria", "Lista de Aceptados" y "Configuración".
- **Revisión del Panel de Cafetería:** Tras una revisión, el rol de cafetería se ha redefinido a un perfil de solo visualización. Ahora, la pantalla principal muestra directamente un "Reporte de Becados" en formato de tabla, eliminando las funcionalidades interactivas de escaneo QR y verificación manual para mayor simplicidad.
- **Consistencia y UX:** Se unificó el estilo visual en todos los paneles y se implementó la funcionalidad de "Cerrar Sesión".

---

## Funcionalidades Implementadas (Post-Refactorización)

### Perfil de Estudiante

- **Autenticación:** Pantalla de inicio de sesión para acceder al perfil.
- **Panel de Control (Dashboard):** Interfaz limpia basada en una lista con las siguientes opciones:
  - **Mi Perfil:** Para que el estudiante vea y gestione su información personal.
  - **Estado de Solicitud:** Para seguir el progreso de su postulación.
  - **Aplicar a Beca:** Un formulario dedicado para iniciar una nueva solicitud.
  - **Información de Beca:** Para consultar detalles sobre las becas disponibles.

### Perfil de Administrador

- **Panel de Control (Dashboard):** Panel de gestión con acceso directo a:
  - **Ver Solicitudes:** Para revisar y gestionar las postulaciones de los estudiantes.
  - **Crear Nueva Convocatoria:** Formulario para publicar nuevas ofertas de becas.
  - **Lista de Aceptados:** Para consultar la lista de estudiantes cuyas solicitudes han sido aprobadas.
  - **Configuración:** Para gestionar opciones y parámetros del sistema.

### Perfil de Cafetería

- **Panel de Control (Dashboard):** Interfaz de solo visualización que presenta un reporte claro y directo:
  - **Ver Reporte de Aceptados:** Muestra una tabla con la lista de estudiantes con derecho a beca, incluyendo detalles como No. de Control, tipo de beca, montos, vigencia y estatus.

---

## Administración de Datos y Seguridad (Implementado Hoy)

**Objetivo:** Establecer un flujo de trabajo robusto para la gestión de datos de usuarios, incluyendo la visualización completa de perfiles y la capacidad de realizar cargas masivas de usuarios de forma segura.

### 1. Perfil de Estudiante Unificado (Firestore)

- **Problema:** La pantalla "Mi Perfil" del estudiante solo mostraba datos de la colección `users`, omitiendo información crucial de la solicitud almacenada en la colección `applications`.
- **Solución Implementada:**
    - Se refactorizó la pantalla `student_profile_screen.dart`.
    - Ahora, al cargar, la pantalla realiza **dos consultas a Firestore**:
        1.  Busca el documento del usuario en la colección `users` usando su UID.
        2.  Busca el documento de solicitud correspondiente en `applications` usando el campo `studentID` (que también es el UID).
    - La información de ambas colecciones se combina para presentar un **perfil de solo lectura completo y unificado**, mostrando al estudiante todos sus datos registrados, incluido el estatus de su beca.

### 2. Carga Masiva de Usuarios (Bulk Import)

Para facilitar la migración y el registro de múltiples estudiantes a la vez, se implementó un proceso seguro de carga masiva utilizando Firebase CLI.

**Pasos y Herramientas:**

1.  **Instalación de Firebase CLI:**
    - Se detectó que la herramienta `firebase-tools` no estaba presente en el entorno de Firebase Studio.
    - Se modificó el archivo de configuración del entorno `.idx/dev.nix` para añadir `pkgs.firebase-tools` a la lista de paquetes.
    - Esto instaló la Firebase CLI, permitiendo ejecutar comandos `firebase` directamente en la terminal del IDE.

2.  **Preparación del Archivo de Datos:**
    - Se definió una estructura de archivo **CSV** (`users.csv`) para la importación, con las columnas `email`, `password`, y `display_name`.
    - Se estableció como buena práctica colocar estos archivos de importación en una carpeta dedicada, por ejemplo: `./scripts/users.csv`, para mantener el código fuente (`lib`) limpio.

3.  **Proceso de Importación Segura:**
    - Al intentar importar las contraseñas en texto plano, Firebase arrojó el error `Error: Must provide hash key...`.
    - **Explicación:** Este es un mecanismo de seguridad. Firebase exige una "llave secreta" (`hash-key`) para encriptar las contraseñas con el algoritmo `SCRYPT` antes de guardarlas.
    - **Generación de la Llave:** Se utilizó el comando `openssl rand -base64 32` para generar una llave criptográficamente segura.
    - **Comando Final de Importación:** Se ejecutó el comando completo, incluyendo la llave generada, para garantizar que las contraseñas se almacenen de forma segura y nunca en texto plano.
      ```bash
      firebase auth:import lib/scripts/users.csv --hash-algo=SCRYPT --hash-key="<TU_LLAVE_GENERADA_AQUI>" --rounds=8 --mem-cost=14
      ```

**Resultado:** Este proceso permite al administrador del sistema añadir cientos de usuarios de forma rápida y segura, creando sus cuentas de autenticación en lote, listas para que luego se les asocien sus perfiles en la base de datos de Firestore.

---

## Arquitectura y Diseño

- **Gestión de Estado:** Se utiliza `provider` para el manejo del tema (claro/oscuro).
- **Enrutamiento:** La navegación se gestiona con `go_router`, permitiendo una estructura de navegación organizada para cada perfil.
- **Diseño de Interfaz:**
  - **Tema:** Paleta de colores basada en `Colors.indigo`, con tipografía de `google_fonts`.
  - **Componentes:** Uso de `Card`, `ListTile` y `DataTable` para crear diseños consistentes y modernos.
  - **Experiencia de Usuario:** Interfaces limpias y centradas en la funcionalidad de cada rol.

---

## Plan de Desarrollo Futuro

1.  **Integración con Backend (Firebase/Supabase):**
    -   Conectar la aplicación a una base de datos para gestionar usuarios, convocatorias, solicitudes y reportes de forma persistente.
    -   Implementar un sistema de autenticación real.

2.  **Desarrollo de Funcionalidades Placeholder:**
    -   Implementar la lógica y la interfaz de usuario para las pantallas que actualmente son marcadores de posición (ej. formularios, perfiles, etc.).

3.  **Funcionalidad de Notificaciones:**
    -   Añadir notificaciones push para informar a los usuarios sobre eventos relevantes.

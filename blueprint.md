
# Blueprint de la Aplicación de Gestión de Becas AMOBECAL

## Descripción General

AMOBECAL es una aplicación móvil integral diseñada para simplificar y automatizar el proceso de solicitud, gestión y seguimiento de becas universitarias. La plataforma está dirigida a tres perfiles de usuario clave: estudiantes, administradores y personal de cafetería, cada uno con funcionalidades específicas para sus roles.

La aplicación ofrece una experiencia de usuario fluida y moderna, con un diseño intuitivo basado en Material Design 3, modo oscuro, y una navegación clara y predecible gracias a `go_router`.

---

## Población Inicial de la Base de Datos (Firestore)

**Objetivo:** Establecer una base de datos inicial en Cloud Firestore con los perfiles y solicitudes de los primeros usuarios, y crear un mecanismo escalable para futuras cargas masivas de datos.

### 1. Definición de la Fuente de Datos (CSV)

- **Problema:** Se necesitaba una forma simple y escalable para introducir los datos de cientos de estudiantes sin tener que escribirlos manualmente en la base de datos o en formatos complejos como JSON.
- **Solución Implementada:**
    - Se creó un archivo `lib/scripts/import_student_data.csv`.
    - Este archivo CSV sirve como la **fuente única de verdad** para la importación de datos. Contiene todas las columnas necesarias para poblar tanto el perfil del usuario como su solicitud de beca (email, nombre, carrera, semestre, etc.).
    - Para futuras importaciones masivas, el administrador solo necesitará añadir nuevas filas a este archivo.

### 2. Creación del Script de Importación Masiva

- **Problema:** Se requería un "motor" que leyera el archivo CSV y lo transformara en la estructura de dos colecciones que definimos en Firestore (`users` y `applications`).
- **Solución Implementada:**
    - Se desarrolló el script `lib/scripts/populate_firestore.js` utilizando Node.js y las librerías `firebase-admin` y `csv-parse`.
    - **Lógica del Script:**
        1.  Lee y parsea el archivo `import_student_data.csv`.
        2.  Verifica que todos los correos del CSV existan en Firebase Authentication para obtener sus UIDs.
        3.  Utiliza una **operación por lotes (batch write)** de Firestore para máxima eficiencia.
        4.  Por cada fila del CSV, crea dos documentos:
            - Un documento en la colección `users` (usando el UID como ID).
            - Un documento en la colección `applications` (vinculado por el `studentID`).
    - **Seguridad:** El script se ejecuta en un entorno de servidor y utiliza una clave de servicio de Firebase (`amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json`) para obtener permisos de administrador y poder escribir en la base de datos.

**Resultado:** Se ha establecido un flujo de trabajo profesional y reutilizable para la gestión de datos. El sistema ahora puede poblarse con datos de 3 o 3000 usuarios con el mismo esfuerzo: actualizar un archivo CSV y ejecutar un comando. Las colecciones `users` y `applications` en Firestore ya contienen los datos de los usuarios iniciales.

---

## Funcionalidades Implementadas (Diseño de UI)

### Perfil de Estudiante

- **Autenticación:** Pantalla de inicio de sesión para acceder al perfil.
- **Panel de Control (Dashboard):** Interfaz limpia basada en una lista con: "Mi Perfil", "Estado de Solicitud", "Aplicar a Beca" e "Información de Beca".

### Perfil de Administrador

- **Panel de Control (Dashboard):** Panel de gestión con acceso a: "Ver Solicitudes", "Crear Nueva Convocatoria", "Lista de Aceptados" y "Configuración".

### Perfil de Cafetería

- **Panel de Control (Dashboard):** Interfaz de solo visualización que presenta un "Reporte de Becados" en formato de tabla.

---

## Arquitectura y Diseño

- **Gestión de Estado:** Se utiliza `provider` para el manejo del tema (claro/oscuro).
- **Enrutamiento:** La navegación se gestiona con `go_router`.
- **Diseño de Interfaz:** Tema basado en `Colors.indigo` con tipografía de `google_fonts`. Componentes `Card`, `ListTile` y `DataTable`.

---

## Plan de Desarrollo Futuro

1.  **Conexión Frontend-Backend:** Conectar las pantallas de la aplicación Flutter a los datos que acabamos de crear en Cloud Firestore.
2.  **Desarrollo de Funcionalidades:** Implementar la lógica para las pantallas que aún son marcadores de posición (ej. formularios de solicitud, perfiles detallados, etc.).
3.  **Funcionalidad de Notificaciones:** Añadir notificaciones push para informar a los usuarios sobre el estado de sus solicitudes.

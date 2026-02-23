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

## Funcionalidades Implementadas

### Perfil de Estudiante

- **Autenticación:** Pantalla de inicio de sesión para acceder al perfil.
- **Panel de Control (Dashboard):** Interfaz limpia con acceso a las funciones principales del estudiante.
- **Perfil de Usuario Detallado:** La pantalla "Mi Perfil" ha sido rediseñada para mostrar una vista completa de la información del estudiante, obtenida directamente desde Firestore. Los datos se organizan en dos secciones claras:
    - **Información Personal:** Nombre, apellidos, género, teléfono y correo.
    - **Información Académica:** Número de control, carrera, semestre y promedio (GPA).

### Perfil de Administrador

- **Panel Personalizado:** El panel de administración ahora muestra el cargo específico del usuario (ej. "Director Prueba") debajo del título principal, proporcionando una experiencia más personalizada.
- **Configuración de Becas:**
    - La pantalla de "Configuración" ha sido diseñada para centralizar la gestión de becas, con las siguientes opciones:
        - **Gestionar Convocatorias Vigentes:** Para modificar la información de las convocatorias activas.
        - **Gestionar Convocatorias Anteriores:** Para eliminar convocatorias de becas que ya no están vigentes.
        - **Anular Beca de Estudiante:** Para cancelar la beca de un estudiante y registrar el motivo.
- **Flujo de Aprobación de Solicitudes Mejorado:**
    - **Asignación de Cafetería:** Al aprobar la solicitud de un estudiante, el administrador ahora debe asignar una cafetería ("Norte", "Sur" o "Este") a través de un diálogo de selección.
    - **Persistencia de Datos:** El nombre de la cafetería asignada (`assignedCafeteria`) se guarda en el documento de la solicitud del estudiante en Firestore.
    - **Visualización en Detalles:** La pantalla de detalles del solicitante ahora muestra la cafetería asignada una vez que la beca ha sido aprobada. Esto es fundamental para que el personal de cada cafetería pueda consultar únicamente a los estudiantes que le corresponden.

- **Gestión de Convocatorias:** Acceso a la gestión integral de convocatorias.
- **Lista de Aceptados con Búsqueda y Filtros:**
    - La sección "Lista de Aceptados" ha sido transformada en una herramienta de consulta avanzada.
    - **Búsqueda en Tiempo Real:** Incluye una barra de búsqueda para encontrar estudiantes instantáneamente por nombre, apellido o número de control.
    - **Filtros Dinámicos:** Se han añadido menús desplegables para filtrar la lista de estudiantes aceptados por **carrera, género y semestre**.
    - La lista se actualiza automáticamente a medida que el administrador escribe o selecciona los filtros.

### Perfil de Cafetería

- **Panel Personalizado:** Al igual que el de administrador, el panel de cafetería ahora muestra un nombre identificativo (ej. "Cafetería Principal") para personalizar la interfaz.
- **Reporte de Becados:** Presenta un reporte de los estudiantes becados en un formato de tabla claro y legible.

---

## Arquitectura y Diseño

- **Gestión de Estado:** Se utiliza `provider` para el manejo del tema (claro/oscuro) y `StatefulWidget` para estados locales en pantallas con interacción compleja (como filtros).
- **Enrutamiento:** La navegación se gestiona con `go_router`.
- **Diseño de Interfaz:** Tema basado en `Colors.indigo` con tipografía de `google_fonts`. Componentes `Card`, `ListTile`, `DataTable`, `TextField` y `DropdownButton`.

# Guía del Sistema AMOBECAL

Este documento describe la arquitectura de la aplicación, el propósito de cada pantalla y los flujos de usuario para los diferentes roles (Estudiante y Administrador).

## Arquitectura General

La aplicación utiliza una arquitectura de navegación basada en **GoRouter**, con una clara separación de responsabilidades por pantalla. El estado global, como el tema de la aplicación y la autenticación, se maneja con el paquete **Provider**.

La persistencia de datos se gestiona a través de **Cloud Firestore**, con una estructura de datos jerárquica que es fundamental para la lógica del negocio.

---

## Roles de Usuario

*   **Estudiante:** Puede ver convocatorias de becas, enviar solicitudes y consultar el estado de sus aplicaciones.
*   **Administrador:** Puede crear y gestionar convocatorias, revisar las solicitudes de los estudiantes y aprobar o rechazar a los aplicantes.
*   **Cafetería:** (Rol definido pero sin funcionalidades implementadas en este rediseño).

---

## Descripción de Pantallas y Flujos

### Portal del Estudiante

**1. `login_screen.dart`**
*   **Usuario:** Todos
*   **Propósito:** Pantalla de inicio de sesión. Permite a los usuarios autenticarse según su rol.

**2. `student_dashboard_screen.dart`**
*   **Usuario:** Estudiante
*   **Propósito:** Panel principal del estudiante. Muestra una bienvenida personalizada y ofrece acceso a las funcionalidades clave.

**3. `scholarship_calls_list_screen.dart`**
*   **Usuario:** Estudiante
*   **Propósito:** Muestra una lista de todas las convocatorias de becas que están **actualmente vigentes**. El estudiante inicia su proceso de solicitud desde aquí.
*   **Flujo:** `StudentDashboard` -> `ScholarshipCallsList`

**4. `scholarship_application_screen.dart`**
*   **Usuario:** Estudiante
*   **Propósito:** Formulario donde el estudiante completa su solicitud para una convocatoria específica. Recibe el `callId` para asociar la solicitud correctamente.
*   **Flujo:** `ScholarshipCallsList` -> `ScholarshipApplication`

**5. `application_status_screen.dart`**
*   **Usuario:** Estudiante
*   **Propósito:** Permite al estudiante ver el estado (pendiente, aprobado, rechazado) de las solicitudes que ha enviado.

**6. `student_profile_screen.dart`**
*   **Usuario:** Estudiante
*   **Propósito:** Muestra la información del perfil del estudiante.

### Portal del Administrador

**1. `admin_dashboard_screen.dart`**
*   **Usuario:** Administrador
*   **Propósito:** Panel principal del administrador. Es el centro de control para la gestión de becas.

**2. `admin_scholarship_calls_screen.dart`**
*   **Usuario:** Administrador
*   **Propósito:** Muestra un **historial completo** de todas las convocatorias, clasificadas por su estado (Próxima, Vigente, Finalizada). Desde aquí, el administrador puede seleccionar una convocatoria para ver a sus aplicantes.
*   **Flujo:** `AdminDashboard` -> `AdminScholarshipCalls`

**3. `create_scholarship_call_screen.dart`**
*   **Usuario:** Administrador
*   **Propósito:** Formulario para crear una nueva convocatoria de beca. Incluye validaciones y un selector de fechas para garantizar la integridad de los datos.
*   **Flujo:** Se accede desde `AdminScholarshipCallsScreen`.

**4. `scholarship_applicants_screen.dart`**
*   **Usuario:** Administrador
*   **Propósito:** Muestra la lista de todos los estudiantes que han aplicado a **una convocatoria específica**. Recibe un `callId` para saber qué aplicantes mostrar. Muestra el estado de cada solicitud (pendiente, aprobado, rechazado).
*   **Flujo:** `AdminScholarshipCalls` -> `ScholarshipApplicants`

**5. `applicant_details_screen.dart`**
*   **Usuario:** Administrador
*   **Propósito:** Muestra la información detallada de la solicitud de un estudiante. Aquí es donde el administrador toma la decisión de **aprobar** o **rechazar** la solicitud.
*   **Flujo:** `ScholarshipApplicants` -> `ApplicantDetails`

**6. `accepted_list_screen.dart`**
*   **Usuario:** Administrador
*   **Propósito:** Muestra una lista consolidada de todos los estudiantes que han sido aceptados en cualquier convocatoria.

**7. `admin_settings_screen.dart`**
*   **Usuario:** Administrador
*   **Propósito:** Pantalla para futuras configuraciones del sistema.
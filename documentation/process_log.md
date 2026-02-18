# Registro del Proceso de Rediseño: Sistema de Becas

Este documento detalla el proceso iterativo de rediseño y corrección de errores llevado a cabo en el sistema de becas AMOBECAL.

## Fase 1: Rediseño del Portal del Estudiante

El objetivo de esta fase fue reestructurar el flujo de solicitud de becas para hacerlo más intuitivo, robusto y evitar solicitudes duplicadas.

### 1.1. Contexto Inicial

*   El estudiante podía solicitar una beca desde su panel, pero el proceso no estaba ligado a una convocatoria específica.
*   Esto generaba una única lista de "solicitudes" difícil de gestionar para el administrador.

### 1.2. Cambios Realizados

1.  **Pantalla de Selección de Convocatorias (`scholarship_calls_list_screen.dart`):**
    *   Se creó una nueva pantalla que muestra al estudiante únicamente las convocatorias **vigentes**.
    *   Se utilizó una consulta a Firestore con un filtro sobre `startDate` y `endDate` para determinar la vigencia.

2.  **Modificación del Flujo de Solicitud:**
    *   El botón "Solicitar Beca" en el panel del estudiante ahora redirige a la pantalla de selección de convocatorias.
    *   Al seleccionar una convocatoria, el estudiante es llevado al formulario de solicitud (`scholarship_application_screen.dart`), que ahora recibe el `callId` como parámetro.

3.  **Implementación de Firma y Confirmación:**
    *   Se añadió un campo de "Firma Electrónica" (el nombre del estudiante) y un diálogo de confirmación para formalizar el envío.

4.  **Nueva Estructura en Firebase:**
    *   Las solicitudes ya no se guardan en una colección global `applications`.
    *   Ahora, cada solicitud se almacena como un documento dentro de una sub-colección del aplicante, anidada en la convocatoria correspondiente: `scholarship_calls/{callId}/applicants/{userId}`.

### 1.3. Comandos Utilizados

*   Para manejar el formateo de fechas en la interfaz, se añadió el paquete `intl`:
    ```bash
    flutter pub add intl
    ```

---

## Fase 2: Rediseño y Corrección del Portal del Administrador

El objetivo principal de esta fase fue solucionar un grave error de lógica en el panel del administrador y adaptar su interfaz a la nueva estructura de datos.

### 2.1. Problema Surgido: Error de Lógica Crítico

*   El panel del administrador tenía un botón "Ver Solicitudes" que llevaba a una lista de todos los aplicantes (`scholarship_applicants_screen.dart`), sin ningún contexto de a qué convocatoria pertenecían.
*   Esto era un vestigio de la antigua estructura de datos y era completamente disfuncional con el nuevo modelo.

### 2.2. Solución: Flujo Centrado en Convocatorias

1.  **Pantalla de Historial de Convocatorias (`admin_scholarship_calls_screen.dart`):**
    *   Se creó una pantalla para el administrador que muestra **todas** las convocatorias (Próximas, Vigentes y Finalizadas).
    *   Esta pantalla se convirtió en el nuevo punto de entrada para la gestión de solicitudes.

2.  **Corrección de la Navegación Principal (`admin_dashboard_screen.dart`):**
    *   El botón "Ver Solicitudes" fue renombrado a "Gestionar Convocatorias".
    *   Su acción ahora redirige al administrador a la nueva pantalla de historial.

3.  **Mejora del Formulario de Creación (`create_scholarship_call_screen.dart`):**
    *   Se reemplazaron los campos de texto de fecha por un `DatePicker` (selector de calendario) para eliminar errores de formato.
    *   Se añadió validación para asegurar que la fecha de fin no sea anterior a la de inicio.
    *   La lógica de publicación ahora guarda las fechas como `Timestamp` de Firestore.

### 2.3. Problema Surgido: Error de Parámetro (`undefined_named_parameter`)

*   **Causa:** Al corregir el flujo, la ruta a `ScholarshipApplicantsScreen` se actualizó para pasar un `callId`, pero el widget de la pantalla no fue modificado para aceptar este parámetro, causando un error de compilación.
*   **Solución:**
    1.  Se modificó `scholarship_applicants_screen.dart` para que aceptara el `callId` requerido.
    2.  Se actualizó su lógica para leer las solicitudes desde la sub-colección `scholarship_calls/{callId}/applicants`.

### 2.4. Problema Surgido: Flujo de Detalles Roto

*   **Causa:** La corrección anterior reveló que la pantalla de detalles del aplicante (`applicant_details_screen.dart`) y su ruta también estaban desactualizadas.
*   **Solución:**
    1.  Se reestructuró la ruta en `main.dart` para anidar correctamente la pantalla de detalles y pasar los parámetros `callId` y `applicantId`.
    2.  Se reescribió `applicant_details_screen.dart` para recibir estos IDs, cargar los datos desde la ubicación correcta y actualizar el estado (`approved`/`rejected`) en el documento correcto de Firebase.

---

## Conclusión

Este proceso de rediseño transformó la lógica de la aplicación de un modelo plano y propenso a errores a una arquitectura jerárquica y robusta, centrada en las convocatorias. Los problemas surgidos fueron cruciales para identificar y corregir las inconsistencias restantes en el código, resultando en un sistema final coherente y funcional.
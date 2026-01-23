
# Blueprint: AMOBECAL - Monitoreo de Becas Alimenticias

## Visión General

AMOBECAL es una aplicación Flutter diseñada para gestionar y monitorear un programa de becas alimenticias. La aplicación proporciona diferentes interfaces y funcionalidades adaptadas a los roles de los usuarios: estudiantes beneficiarios, administradores del programa y personal de la cafetería.

El objetivo es centralizar la comunicación, agilizar los procesos de solicitud y validación, y facilitar el seguimiento del estado de las becas y el consumo de alimentos.

---

## Diseño y Estilo

La aplicación sigue los principios de Material Design 3, buscando una estética moderna, limpia y funcional.

*   **Paleta de Colores:**
    *   **Primario:** `Colors.indigo` se usa como color semilla para generar un esquema de colores armonioso tanto en modo claro como oscuro.
    *   **Énfasis y Botones:** Los tonos derivados del índigo se utilizan para botones, enlaces y elementos interactivos para mantener la consistencia.

*   **Tipografía (Google Fonts):
    *   **Títulos Principales (`displayLarge`):** `Montserrat` en negrita para un impacto visual fuerte y moderno en los encabezados más importantes (ej. "AMOBECAL").
    *   **Títulos de AppBar y Encabezados (`headlineMedium`):** `Montserrat` con un peso seminegrita para una jerarquía clara.
    *   **Cuerpo de Texto (`bodyMedium`):** `Open Sans` para una excelente legibilidad en párrafos y descripciones.
    *   **Botones y Etiquetas (`labelLarge`):** `Roboto` para una apariencia limpia y estándar en elementos de acción.

*   **Estilo de Componentes:
    *   **Campos de Texto:** `InputDecorationTheme` con bordes redondeados (`OutlineInputBorder`) para un look moderno.
    *   **Botones Elevados:** `ElevatedButtonThemeData` con esquinas redondeadas y un relleno generoso para una apariencia amigable y fácil de usar.
    *   **Tema Oscuro:** Soporte completo para modo oscuro con colores y fondos adaptados para reducir la fatiga visual.

---

## Características Implementadas

### 1. **Estructura del Proyecto y Navegación**
*   **Gestión de Paquetes:** Se utiliza `flutter pub add` para gestionar las dependencias: `go_router`, `provider` y `google_fonts`.
*   **Navegación Declarativa:** Se implementa `go_router` para gestionar las rutas de la aplicación de una manera robusta y escalable.
*   **Rutas Definidas:**
    *   `/login`: Pantalla de inicio de sesión.
    *   `/student`: Dashboard del estudiante.
    *   `/admin`: Dashboard del administrador.
    *   `/cafeteria`: Dashboard de la cafetería.

### 2. **Gestión de Tema (Claro/Oscuro)**
*   **Proveedor de Tema:** Se utiliza el paquete `provider` con un `ChangeNotifier` (`ThemeProvider`) para permitir al usuario cambiar entre el modo claro, oscuro y el del sistema en tiempo real.
*   **Ícono de Cambio de Tema:** Un `IconButton` en la pantalla de inicio de sesión permite al usuario alternar el tema.

### 3. **Pantalla de Inicio de Sesión (`/login`)**
*   **Campos de Entrada:** Formularios para correo electrónico y contraseña.
*   **Selección de Rol:** Un `DropdownButtonFormField` permite al usuario seleccionar su rol (Estudiante, Administrador, Cafetería) antes de iniciar sesión.
*   **Lógica de Autenticación (Simulada):** Al presionar "Ingresar", la aplicación utiliza `go_router` para redirigir al usuario al dashboard correspondiente a su rol seleccionado.
*   **Gestión de Estado Local:** Se usa `ValueNotifier` y `ValueListenableBuilder` para manejar eficientemente el estado del rol seleccionado en la UI.

### 4. **Dashboards de Usuario**
Se han creado pantallas base para cada rol, todas con una barra de aplicación (`AppBar`) y un botón para cerrar sesión que redirige de nuevo a `/login`.

*   **Portal del Estudiante (`/student`):**
    *   Muestra un mensaje de bienvenida y un estado de ejemplo de la beca.
*   **Panel de Administración (`/admin`):**
    *   Muestra un mensaje de bienvenida y un botón de ejemplo para "Ver Solicitudes".
*   **Gestión de Comidas (`/cafeteria`):**
    *   Muestra un título de "Reporte de Becas" y un texto de ejemplo.

---

## Plan Actual (Próximos Pasos)

El siguiente paso es ejecutar la aplicación para verificar visualmente todas las funcionalidades implementadas hasta ahora.

1.  **Ejecutar la Aplicación:** Lanzar la aplicación en el emulador.
2.  **Verificar la Pantalla de Login:** Confirmar que la pantalla de inicio de sesión se muestra correctamente con el selector de rol.
3.  **Probar la Navegación:** Iniciar sesión con cada uno de los tres roles y verificar que se redirige al dashboard correcto.
4.  **Probar el Cambio de Tema:** Asegurarse de que el botón para cambiar el tema funciona correctamente en la pantalla de login.


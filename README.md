
# Aplicación de Gestión de Becas "AMOBECAL"

## Descripción General

AMOBECAL es una aplicación móvil integral, construida con Flutter, diseñada para simplificar y automatizar el proceso de solicitud, gestión y seguimiento de becas universitarias. La plataforma está dirigida a tres perfiles de usuario clave: **estudiantes**, **administradores** y personal de **cafetería**, cada uno con funcionalidades específicas para sus roles.

El objetivo principal de la aplicación es ofrecer una experiencia de usuario fluida y moderna, con un diseño intuitivo basado en **Material Design 3**, soporte para modo claro/oscuro, y una navegación clara y predecible.

---

## Registro de Comandos del Proyecto

Esta sección documenta los comandos clave utilizados durante el desarrollo del proyecto, explicando su propósito y el impacto que tienen en el sistema.

### 1. Gestión de Paquetes de Flutter (`flutter pub`)

- **`flutter pub add <nombre_paquete>`**
  - **Propósito:** Añadir una nueva librería (paquete) al proyecto Flutter.
  - **¿Qué afecta?**
    - Modifica el archivo `pubspec.yaml`, añadiendo una línea con el nombre del paquete y su versión.
    - Descarga el código fuente del paquete en el archivo `pubspec.lock` y en la caché del sistema.
    - Permite que el código de la aplicación importe y utilice las funcionalidades del paquete.
  - **Ejemplos usados:**
    - `flutter pub add firebase_auth`: Instaló la librería para la autenticación con Firebase.
    - `flutter pub add cloud_firestore`: Instaló la librería para interactuar con la base de datos Firestore.

### 2. Ejecución de Scripts de Node.js (`node`)

- **`node <ruta_al_script.js>`**
  - **Propósito:** Ejecutar un archivo de JavaScript utilizando el entorno de Node.js.
  - **¿Qué afecta?**
    - Ejecuta la lógica contenida en el script. En nuestro caso, se usó para tareas de backend y manipulación de datos que no se pueden hacer desde la app de Flutter.
    - Puede leer/escribir archivos locales, conectarse a servicios en la nube (como Firebase Admin) y realizar operaciones complejas.
  - **Ejemplos usados:**
    - `node lib/scripts/populate_firestore.js`: Ejecutó nuestro script para leer un CSV y poblar la base de datos de Firestore.
    - `node lib/scripts/migrate_users.js`: Ejecutó el script para migrar usuarios con contraseñas hasheadas a Firebase Authentication.

### 3. Instalación de Dependencias de Node.js (`npm`)

- **`npm install`**
  - **Propósito:** Instalar las dependencias de un proyecto de Node.js.
  - **¿Qué afecta?**
    - Lee el archivo `package.json` para saber qué librerías necesita el proyecto.
    - Descarga y guarda esas librerías en una carpeta llamada `node_modules`.
    - Permite que los scripts de Node.js (como `populate_firestore.js`) puedan importar y usar esas librerías (`firebase-admin`, `csv-parse`, etc.).

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
  - **Registrar Canje:** Permite al personal marcar cuándo un estudiante ha recibido su beneficio alimenticio, actualizando el estado para evitar duplicados.

---

## Arquitectura y Diseño

El proyecto está construido siguiendo las mejores prácticas de desarrollo en Flutter:

-   **Gestión de Estado:** Se utiliza el paquete `provider` para manejar el estado global de la aplicación, como el cambio entre tema claro y oscuro.
-   **Enrutamiento:** La navegación se gestiona con `go_router`, lo que permite una estructura de rutas declarativa, anidada y fácil de mantener.
-   **Diseño de Interfaz:**
    -   **Tema:** Se adhiere a los principios de **Material Design 3**, con una paleta de colores coherente y una tipografía moderna y legible gracias a `google_fonts`.
    -   **Componentes:** Uso de widgets modernos y estilizados para una experiencia de usuario consistente.
    -   **Experiencia de Usuario:** Las interfaces están diseñadas para ser limpias, con una buena distribución de espacios y una jerarquía visual clara que facilita la interacción del usuario.

---

# Proceso de Migración de Usuarios a Firebase

Este documento describe el proceso para importar usuarios de forma masiva al sistema de autenticación de Firebase de este proyecto, utilizando un script de Node.js y el Firebase Admin SDK.

## Archivos Involucrados

- **`migrate_users.js`**: El script principal de Node.js que ejecuta la lógica de migración. Lee los datos del archivo CSV, se conecta a Firebase como administrador y realiza la importación.
- **`users.csv`**: El archivo de datos que contiene la información de los usuarios a importar. **Este archivo sirve como plantilla.** Para cada migración, debe ser reemplazado o llenado con los nuevos datos de los usuarios.
- **`package.json` / `package-lock.json`**: Definen las dependencias de Node.js (`firebase-admin`, `csv-parse`).
- **`[CLAVE_DE_SERVICIO].json`**: Un archivo de credenciales de cuenta de servicio de Firebase. **ESTE ARCHIVO ES TEMPORAL Y ALTAMENTE SENSIBLE.** Debe obtenerse para cada ejecución y borrarse inmediatamente después.

---

## Guía para Futuras Migraciones

Siga estos pasos cada vez que necesite importar un nuevo lote de usuarios:

### Paso 1: Preparar el Archivo `users.csv`

Asegúrese de que el archivo `lib/scripts/users.csv` contenga los datos de los nuevos usuarios con el siguiente formato exacto de 4 columnas, sin cabecera:

`email,password_hash,salt,nombre_completo`

- **`email`**: El correo electrónico del usuario.
- **`password_hash`**: La contraseña del usuario ya procesada (hasheada) con el algoritmo SCRYPT y codificada en **Base64**.
- **`salt`**: La "sal" utilizada en el hash, también codificada en **Base64**.
- **`nombre_completo`**: El nombre para mostrar del usuario.

### Paso 2: Obtener una Nueva Clave de Cuenta de Servicio

1.  Vaya a la **Consola de Firebase > Project settings > Service accounts**.
2.  Haga clic en el botón **"Generate new private key"**.
3.  Se descargará un archivo JSON. Renómbrelo si es necesario y **cópielo a la carpeta raíz del proyecto**.
4.  **¡IMPORTANTE!** Abra el archivo `migrate_users.js` y actualice la línea 5 para que apunte al nombre de su nuevo archivo de clave:
    ```javascript
    const serviceAccount = require('../../NOMBRE_DE_TU_NUEVO_ARCHIVO.json');
    ```

### Paso 3: Instalar Dependencias

Si es la primera vez que se ejecuta en el entorno o si la carpeta `node_modules` no existe, ejecute este comando desde la terminal en la raíz del proyecto:

```bash
npm install
```

### Paso 4: Ejecutar el Script de Migración

Ejecute el script con Node.js:

```bash
node lib/scripts/migrate_users.js
```

El script mostrará en la consola el resultado de la importación.

### Paso 5: ¡Limpieza Inmediata!

Una vez que la migración haya sido exitosa, **elimine inmediatamente el archivo JSON de la clave de cuenta de servicio** de su proyecto. No debe quedar guardado en el repositorio bajo ninguna circunstancia.

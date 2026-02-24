# Manual de Instalación y Configuración de AMOBECAL

---

## 1. Introducción

Este documento proporciona una guía técnica detallada para la instalación, configuración y despliegue de la aplicación de gestión de becas AMOBECAL. El manual está dirigido a personal técnico con conocimientos en desarrollo de aplicaciones móviles, Flutter y Firebase.

AMOBECAL es una aplicación construida sobre el framework Flutter y utiliza los servicios de Google Firebase como backend, lo que garantiza una solución robusta, escalable y en tiempo real.

---

## 2. Prerrequisitos del Sistema

Antes de comenzar, asegúrese de que el entorno de desarrollo cumple con los siguientes requisitos:

*   Sistema Operativo: Windows, macOS o Linux.
*   IDE (Entorno de Desarrollo Integrado): Visual Studio Code (recomendado) o Android Studio, con las extensiones de Flutter y Dart instaladas.
*   SDK de Flutter: Versión 3.10 o superior.
*   SDK de Dart: La versión correspondiente al SDK de Flutter.
*   Node.js: Necesario para ejecutar scripts de mantenimiento y para el uso de Firebase CLI.
*   Firebase CLI (Command Line Interface): Herramienta esencial para la gestión del proyecto Firebase desde la terminal.
*   Cuenta de Google: Necesaria para crear y gestionar el proyecto en Firebase.
*   Git: Para la clonación del repositorio de código fuente.

---

## 3. Configuración del Backend (Firebase)

El corazón de AMOBECAL reside en Firebase. Siga estos pasos para configurar el backend.

### 3.1. Creación del Proyecto en Firebase

1.  Vaya a la Consola de Firebase: Abra su navegador y diríjase a [https://console.firebase.google.com/](https://console.firebase.google.com/).
2.  Inicie Sesión: Utilice su cuenta de Google.
3.  Cree un Nuevo Proyecto:
    *   Haga clic en "Agregar proyecto".
    *   Asigne un nombre al proyecto (ej. "GestionBecas-Institucion").
    *   (Opcional) Edite el ID del proyecto si lo desea.
    *   Acepte los términos y continúe.
    *   Se recomienda habilitar Google Analytics para el proyecto, ya que proporciona información valiosa sobre el uso de la aplicación.
    *   Espere a que el proyecto se cree.

### 3.2. Activación de Servicios de Firebase

Una vez creado el proyecto, debe activar los siguientes servicios desde la consola de Firebase:

1.  Authentication (Autenticación):
    *   Vaya a la sección "Authentication" en el menú de la izquierda.
    *   Haga clic en "Comenzar".
    *   En la pestaña "Sign-in method", habilite el proveedor "Correo electrónico/Contraseña". Esto permitirá que los usuarios se registren e inicien sesión.

2.  Firestore Database (Base de Datos):
    *   Vaya a la sección "Firestore Database".
    *   Haga clic en "Crear base de datos".
    *   Inicie en modo de producción. Esto asegura que sus datos estén protegidos por reglas de seguridad desde el principio.
    *   Seleccione la ubicación del servidor de Firestore (elija la más cercana a la mayoría de sus usuarios, ej. `us-central`).
    *   Haga clic en "Habilitar".

3.  Storage (Almacenamiento):
    *   Vaya a la sección "Storage".
    *   Haga clic en "Comenzar".
    *   Siga las instrucciones para configurar el almacenamiento en la nube. Utilice las reglas de seguridad predeterminadas por ahora.

### 3.3. Configuración de Reglas de Seguridad

Las reglas de seguridad son cruciales para proteger los datos de los usuarios. Deberá aplicar las reglas proporcionadas en el código fuente del proyecto:

1.  Reglas de Firestore:
    *   En la consola de Firebase, vaya a "Firestore Database" y luego a la pestaña "Reglas".
    *   Copie el contenido del archivo `firestore.rules` del proyecto y péguelo en el editor de reglas de la consola.
    *   Haga clic en "Publicar".

2.  Reglas de Storage:
    *   Vaya a la sección "Storage" y a la pestaña "Reglas".
    *   Copie el contenido del archivo `storage.rules` (si existe en el proyecto) y péguelo en el editor.
    *   Haga clic en "Publicar".

---

## 4. Instalación del Frontend (Aplicación Flutter)

### 4.1. Clonación del Repositorio

1.  Abra una terminal o línea de comandos en su máquina.
2.  Navegue al directorio donde desea guardar el proyecto.
3.  Clone el repositorio de código fuente usando Git:
    ```bash
    git clone <URL_DEL_REPOSITORIO>
    ```
4.  Navegue a la carpeta del proyecto:
    ```bash
    cd amobecal-app
    ```

### 4.2. Conexión de la App con Firebase

Para que la aplicación Flutter se comunique con el proyecto de Firebase que acaba de crear, debe configurarla usando FlutterFire.

1.  Instale Firebase CLI: Si aún no lo ha hecho, instálelo globalmente:
    ```bash
    npm install -g firebase-tools
    ```
2.  Inicie Sesión en Firebase:
    ```bash
    firebase login
    ```
3.  Instale el CLI de FlutterFire:
    ```bash
    dart pub global activate flutterfire_cli
    ```
4.  Configure el Proyecto: Ejecute el siguiente comando en la raíz de su proyecto Flutter:
    ```bash
    flutterfire configure
    ```
    *   Siga las instrucciones en pantalla. Se le pedirá que seleccione el proyecto de Firebase que creó anteriormente.
    *   Seleccione las plataformas que desea configurar (android, ios, web).
    *   Este comando generará automáticamente el archivo `lib/firebase_options.dart`, que contiene las "llaves" de conexión de su app.

### 4.3. Instalación de Dependencias

1.  Con la terminal en la raíz del proyecto, ejecute el siguiente comando para descargar todas las librerías y paquetes necesarios:
    ```bash
    flutter pub get
    ```

### 4.4. Ejecución de la Aplicación

Está listo para ejecutar la aplicación.

1.  Asegúrese de tener un dispositivo conectado (un emulador de Android, un simulador de iOS o un dispositivo físico) o un navegador web (para Flutter Web).
2.  Ejecute la aplicación con el siguiente comando:
    ```bash
    flutter run
    ```
3.  La primera compilación puede tardar varios minutos. Las compilaciones posteriores serán mucho más rápidas gracias al Hot Reload de Flutter.

---

## 5. Configuración de Datos Iniciales y Mantenimiento

### 5.1. Creación de Usuarios Administradores

Los primeros usuarios (administradores) deben crearse manually desde la consola de Firebase para poder gestionar el sistema desde la propia aplicación.

1.  Vaya a la sección "Authentication" en la consola de Firebase.
2.  Haga clic en "Agregar usuario".
3.  Ingrese un correo electrónico y una contraseña para el primer administrador.
4.  Una vez creado, copie el "UID" (Identificador de Usuario) que Firebase le asigna.
5.  Vaya a "Firestore Database". Cree una colección llamada `users` si no existe. Dentro de `users`, cree un documento con el UID que copió como ID del documento.
6.  Dentro de ese documento, agregue un campo llamado `role` (de tipo `String`) con el valor `admin`. Esto le otorgará privilegios de administrador dentro de la app.

### 5.2. Scripts de Mantenimiento

El proyecto puede incluir scripts en una carpeta (ej. `lib/scripts`) para tareas como:
*   Importación masiva de estudiantes: Un script para leer un archivo CSV y registrar a todos los estudiantes en la base de datos de una sola vez.
*   Migración de datos: Scripts para actualizar la estructura de la base de datos cuando se introducen cambios en nuevas versiones de la aplicación.

Para ejecutar estos scripts (generalmente escritos en Node.js o Dart), siga las instrucciones del `README.md` que se encuentre dentro de la carpeta de scripts.

---

## 6. Despliegue a Producción

Una vez que la aplicación ha sido probada y está lista para ser lanzada a los usuarios finales.

*   Android: Siga la guía oficial de Flutter para construir y lanzar una app de Android.
*   iOS: Siga la guía oficial de Flutter para construir y lanzar una app de iOS.
*   Web: Si la aplicación se va a usar en la web, puede desplegarla en Firebase Hosting:
    1.  Ejecute `firebase init hosting` en la raíz del proyecto.
    2.  Compile la versión de producción de la app web: `flutter build web`.
    3.  Despliegue a Firebase: `firebase deploy --only hosting`.

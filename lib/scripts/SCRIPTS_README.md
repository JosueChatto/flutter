
# Guía de Scripts de Mantenimiento de Firebase

**ADVERTENCIA: Los scripts contenidos en este documento son herramientas de administrador de alto poder. Utilizan una clave de cuenta de servicio que otorga control total sobre el proyecto de Firebase. Úselos con extrema precaución y solo si entiende completamente lo que hacen.**

Este archivo sirve como una biblioteca de "recetas" para tareas de mantenimiento que no son parte de la operativa normal de la aplicación. El código de estos scripts se ha preservado aquí como guía, pero los archivos `.js` ejecutables han sido eliminados del proyecto para prevenir ejecuciones accidentales.

## Requisito Previo: Clave de Cuenta de Servicio

Todos estos scripts requieren el archivo `amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json` en el directorio raíz del proyecto para poder autenticarse con privilegios de administrador. **NUNCA suba este archivo a un repositorio de Git.**

---

## Receta 1: Eliminar Múltiples Usuarios (Auth y Firestore)

- **Propósito:** Eliminar un conjunto específico de usuarios tanto del sistema de **Firebase Authentication** como de la colección `users` en **Firestore**. Útil para purgar datos corruptos o de prueba.
- **Cuándo usarlo:** Cuando necesites hacer una limpieza masiva y coordinada de usuarios.
- **Riesgo:** **EXTREMO.** Si la lista de UIDs es incorrecta, podría borrar permanentemente usuarios válidos.

### Código (`delete_users.js`)

```javascript
const admin = require('firebase-admin');

// --- CONFIGURACIÓN ---
// Ruta a la clave de cuenta de servicio (ajustar si es necesario)
const serviceAccount = require('../../amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json');

// LISTA DE UIDs A ELIMINAR
const UIDS_TO_DELETE = [
  // Ejemplo: "uid_del_usuario_1",
  // Ejemplo: "uid_del_usuario_2",
];

// --- INICIALIZACIÓN DE FIREBASE ---
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();
const db = admin.firestore();

// --- FUNCIÓN PRINCIPAL ---
async function deleteUsers() {
  if (UIDS_TO_DELETE.length === 0) {
    console.warn("🟡 La lista de UIDs a eliminar está vacía. No se realizará ninguna acción.");
    return;
  }

  console.log(`Intentando eliminar ${UIDS_TO_DELETE.length} usuarios...`);

  try {
    // Paso 1: Eliminar de Firebase Authentication
    const deleteUsersResult = await auth.deleteUsers(UIDS_TO_DELETE);
    console.log(`✅ ${deleteUsersResult.successCount} usuarios eliminados de Authentication.`);
    if (deleteUsersResult.failureCount > 0) {
      console.warn(`🟡 ${deleteUsersResult.failureCount} usuarios no se pudieron eliminar de Authentication.`);
      deleteUsersResult.errors.forEach((err) => {
        console.error(`- Error para UID ${err.uid}: ${err.error.message}`);
      });
    }

    // Paso 2: Eliminar de Firestore
    console.log("Procediendo a eliminar perfiles de Firestore...");
    const batch = db.batch();
    UIDS_TO_DELETE.forEach(uid => {
      const docRef = db.collection('users').doc(uid);
      batch.delete(docRef);
    });
    await batch.commit();
    console.log("✅ Perfiles de Firestore correspondientes eliminados.");

  } catch (error) {
    console.error("❌ Ocurrió un error inesperado durante la eliminación:", error);
  }

  console.log("Proceso de limpieza finalizado.");
}

// Ejecutar la función
deleteUsers();
```

---

## Receta 2: Crear un Usuario en Authentication

- **Propósito:** Crear un nuevo usuario en **Firebase Authentication** con un email y contraseña.
- **Cuándo usarlo:** Para añadir manualmente un usuario al sistema de inicio de sesión.

### Código (`create_student_user.js`)

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('../../amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json');

// --- DATOS DEL USUARIO A CREAR ---
const USER_EMAIL = 'usuario@ejemplo.com';
const USER_PASSWORD = 'passwordSeguro123';
const USER_DISPLAY_NAME = "Nombre Apellido";

// --- INICIALIZACIÓN DE FIREBASE ---
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// --- FUNCIÓN PRINCIPAL ---
async function createUser() {
  console.log(`Intentando crear el usuario: ${USER_EMAIL}...`);
  try {
    const userRecord = await admin.auth().createUser({
      email: USER_EMAIL,
      password: USER_PASSWORD,
      emailVerified: false,
      displayName: USER_DISPLAY_NAME,
    });
    console.log('✅ Usuario creado exitosamente:');
    console.log(`- Email: ${userRecord.email}`);
    console.log(`- UID: ${userRecord.uid}`);
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      console.warn(`🟡 ATENCIÓN: El usuario ${USER_EMAIL} ya existe.`);
    } else {
      console.error('❌ Error inesperado durante la creación:', error);
    }
  }
}

createUser();
```

---

## Receta 3: Crear un Perfil de Usuario en Firestore

- **Propósito:** Crear un documento en la colección `users` para un usuario existente en Authentication.
- **Cuándo usarlo:** Para añadir los datos de perfil básicos a un usuario que ya puede iniciar sesión.

### Código (`create_student_profile.js`)

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('../../amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json');

// --- DATOS DEL PERFIL A CREAR ---
const USER_UID = 'pegar_aqui_el_uid_del_usuario'; // UID obtenido de la Receta 2
const USER_DATA = {
  name: 'Nombre Apellido',
  email: 'usuario@ejemplo.com',
  career: 'Carrera del Estudiante',
  rol: 'estudiante' // o 'admin'
};

// --- INICIALIZACIÓN DE FIREBASE ---
try {
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
} catch (e) { /* Evitar error de doble inicialización */ }

const db = admin.firestore();

// --- FUNCIÓN PRINCIPAL ---
async function createProfile() {
  console.log(`Creando perfil en Firestore para el UID: ${USER_UID}...`);
  const userDocRef = db.collection('users').doc(USER_UID);
  try {
    await userDocRef.set(USER_DATA);
    console.log('✅ Perfil de usuario creado exitosamente en Firestore.');
  } catch (error) {
    console.error('❌ Error al crear el perfil en Firestore:', error);
  }
}

createProfile();
```

---

## Receta 4: Crear una Solicitud de Beca en Firestore

- **Propósito:** Crear un documento en la colección `applications` con los detalles de la solicitud de beca de un estudiante.
- **Cuándo usarlo:** Para añadir los datos que la aplicación muestra al estudiante en su panel.

### Código (`create_student_application.js`)

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('../../amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json');

// --- DATOS DE LA SOLICITUD A CREAR ---
const USER_UID = 'pegar_aqui_el_uid_del_usuario'; // El mismo UID de las recetas 2 y 3

const APPLICATION_DATA = {
  studentName: "Nombre Apellido",
  email: "usuario@ejemplo.com",
  career: "Carrera del Estudiante",
  status: "pending", // pending, approved, rejected
  semester: 1,
  numberControl: "20460000",
  gpa: 95.0,
  studentID: USER_UID, // IMPORTANTE: Vincular al UID de Auth
  date: new Date()
};

// --- INICIALIZACIÓN DE FIREBASE ---
try {
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
} catch (e) { /* Evitar error de doble inicialización */ }

const db = admin.firestore();

// --- FUNCIÓN PRINCIPAL ---
async function createApplication() {
  console.log(`Creando solicitud en Firestore para el UID: ${USER_UID}...`);
  const applicationDocRef = db.collection('applications').doc(USER_UID);
  try {
    await applicationDocRef.set(APPLICATION_DATA);
    console.log('✅ Solicitud de beca creada exitosamente en Firestore.');
  } catch (error) {
    console.error('❌ Error al crear la solicitud en Firestore:', error);
  }
}

createApplication();
```

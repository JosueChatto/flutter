const admin = require('firebase-admin');
const fs = require('fs');
const { parse } = require('csv-parse/sync');

// --- CONFIGURACIÓN ---
// 1. Apunta al archivo de clave de servicio.
// Recuerda subir este archivo a la raíz del proyecto para cada ejecución.
const serviceAccount = require('../../amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json');

// 2. Apunta al archivo CSV con los datos a importar.
const CSV_FILE_PATH = './lib/scripts/import_student_data.csv';

// --- INICIALIZACIÓN DE FIREBASE ---
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (e) {
  if (admin.apps.length === 0) {
    console.error('Error fatal al inicializar Firebase Admin SDK:', e);
    process.exit(1);
  }
}

const auth = admin.auth();
const db = admin.firestore();

// --- FUNCIÓN PRINCIPAL DE IMPORTACIÓN ---
async function importStudentData() {
  console.log(`Iniciando la importación de datos desde: ${CSV_FILE_PATH}`);

  // 1. Leer y parsear el archivo CSV
  let records;
  try {
    const fileContent = fs.readFileSync(CSV_FILE_PATH, 'utf8');
    records = parse(fileContent, { columns: true, skip_empty_lines: true });
    console.log(`Se encontraron ${records.length} registros en el archivo CSV.`);
  } catch (error) {
    console.error(`❌ Error: No se pudo leer o parsear el archivo CSV en ${CSV_FILE_PATH}.`, error);
    return;
  }

  if (records.length === 0) {
    console.warn('⚠️ El archivo CSV está vacío o no tiene registros. No hay nada que importar.');
    return;
  }

  try {
    // 2. Obtener los UIDs de todos los usuarios a la vez
    const userIdentifiers = records.map(record => ({ email: record.email }));
    const authUsersResult = await auth.getUsers(userIdentifiers);

    const uidMap = new Map();
    authUsersResult.users.forEach(user => {
      uidMap.set(user.email, user.uid);
    });

    if (authUsersResult.notFound.length > 0) {
      console.error('❌ Error: Los siguientes emails del CSV no existen en Firebase Authentication y no se pueden importar:');
      authUsersResult.notFound.forEach(user => console.log(`- ${user.email}`));
      return; // Detener el proceso si hay usuarios no encontrados
    }

    console.log(`✅ Se encontraron los ${uidMap.size} usuarios correspondientes en Firebase Authentication.`);

    // 3. Preparar una operación por lotes (batch) para máxima eficiencia
    const batch = db.batch();

    for (const record of records) {
      const uid = uidMap.get(record.email);
      if (!uid) continue; // Seguridad extra

      const { name, role, career, controlNumber, semester, phone } = record;
      const [firstName, ...lastNameParts] = name.split(' ');
      const lastName = lastNameParts.join(' ');

      // a) Preparar documento para la colección 'users'
      const userDocRef = db.collection('users').doc(uid);
      batch.set(userDocRef, {
        name: name,
        email: record.email,
        rol: role,
        career: career
      });

      // b) Preparar documento para la colección 'applications'
      const appDocRef = db.collection('applications').doc(); // Firestore genera el ID
      batch.set(appDocRef, {
        studentID: uid,
        studentName: firstName,
        lastName: lastName,
        semester: parseInt(semester, 10), // Asegurar que sea un número
        status: 'pending',
        phoneNumber: phone,
        numberControl: controlNumber,
        career: career
      });
    }

    // 4. Ejecutar todas las operaciones en la base de datos
    await batch.commit();

    console.log(`✅ ¡Éxito! Se han creado/actualizado los documentos para ${records.length} usuarios.`);
    console.log('Puedes verificar los datos en tu consola de Firestore.');

  } catch (error) {
    console.error('❌ Ocurrió un error catastrófico durante la importación a Firestore:', error);
  } finally {
    // Limpiar la app de admin para no interferir con otros scripts
    admin.apps.forEach(app => app.delete());
  }
}

// --- Ejecutar la función ---
importStudentData();

const admin = require('firebase-admin');
const fs = require('fs');
const { parse } = require('csv-parse/sync');

// --- CONFIGURACIÓN ---
const serviceAccount = require('../../amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json');
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
    // 2. Obtener los UIDs de todos los usuarios
    const userIdentifiers = records.map(record => ({ email: record.email }));
    const authUsersResult = await auth.getUsers(userIdentifiers);

    const uidMap = new Map();
    authUsersResult.users.forEach(user => {
      uidMap.set(user.email, user.uid);
    });

    if (authUsersResult.notFound.length > 0) {
      console.error('❌ Error: Los siguientes emails del CSV no existen en Firebase Authentication:');
      authUsersResult.notFound.forEach(user => console.log(`- ${user.email}`));
      return;
    }

    console.log(`✅ Se encontraron los ${uidMap.size} usuarios correspondientes en Firebase Authentication.`);

    // 3. Preparar una operación por lotes (batch)
    const batch = db.batch();

    for (const record of records) {
      const uid = uidMap.get(record.email);
      if (!uid) continue;

      const { name, role, career, controlNumber, semester, phone } = record;
      const [firstName, ...lastNameParts] = name.split(' ');
      const lastName = lastNameParts.join(' ');
      
      // Generar un GPA aleatorio entre 70.00 y 99.99
      const gpa = parseFloat((Math.random() * (99.99 - 70.00) + 70.00).toFixed(2));

      // a) Preparar documento para la colección 'users'
      const userDocRef = db.collection('users').doc(uid);
      batch.set(userDocRef, {
        name: name,
        email: record.email,
        rol: role,
        career: career
      });

      // b) Preparar documento para la colección 'applications' con los nuevos campos
      const appDocRef = db.collection('applications').doc(); // Firestore genera el ID
      batch.set(appDocRef, {
        studentID: uid,
        studentName: name, // Usar nombre completo para consistencia
        career: career,
        semester: parseInt(semester, 10),
        gpa: gpa, // <-- NUEVO CAMPO
        email: record.email, // <-- NUEVO CAMPO
        status: 'pending',
        date: admin.firestore.FieldValue.serverTimestamp(), // <-- NUEVO CAMPO
        // Manteniendo los campos anteriores que eran útiles
        phoneNumber: phone,
        numberControl: controlNumber,
      });
    }

    // 4. Ejecutar todas las operaciones
    await batch.commit();

    console.log(`✅ ¡Éxito! Se han creado/actualizado los documentos para ${records.length} usuarios con los nuevos campos.`);

  } catch (error) {
    console.error('❌ Ocurrió un error durante la importación a Firestore:', error);
  } finally {
    admin.apps.forEach(app => app.delete());
  }
}

// --- Ejecutar la función ---
importStudentData();


const admin = require('firebase-admin');
const fs = require('fs');
const { parse } = require('csv-parse/sync');

// --- CONFIGURACIÓN ---
// Ruta al archivo de clave de cuenta de servicio que descargaste.
const serviceAccount = require('../../amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json');

// Ruta a tu archivo CSV de usuarios.
const CSV_FILE_PATH = './lib/scripts/users.csv';

// Parámetros de hashing SCRYPT (deben coincidir con los que usaste para generar los hashes).
const SCRYPT_CONFIG = {
  hashKey: 'mKC8h57ogB2ZI/xU8WJ8LDhaRebofnRsahi401b1ogI=', // Tu clave de firma, codificada en Base64
  saltSeparator: 'Bw==', // Separador de sal, codificado en Base64
  rounds: 8,       // Rondas de CPU/memoria
  memCost: 14,     // Coste de memoria
};

// --- INICIALIZACIÓN DE FIREBASE ---
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();

// --- FUNCIÓN PRINCIPAL ---
async function migrateUsers() {
  console.log('Iniciando la migración de usuarios...');

  // 1. Leer y parsear el archivo CSV
  let usersToImport;
  try {
    const fileContent = fs.readFileSync(CSV_FILE_PATH, 'utf-8');
    // Espera que el CSV sea: email,password_hash,salt,display_name
    usersToImport = parse(fileContent, {
      columns: ['email', 'passwordHash', 'salt', 'displayName'],
      skip_empty_lines: true,
    });
  } catch (error) {
    console.error(`❌ Error al leer o parsear el archivo CSV en ${CSV_FILE_PATH}:`, error);
    return;
  }

  if (!usersToImport || usersToImport.length === 0) {
    console.warn('🟡 No se encontraron usuarios en el archivo CSV para importar.');
    return;
  }

  console.log(`Encontrados ${usersToImport.length} usuarios para importar.`);

  // 2. Preparar los datos para la importación
  const userImportRecords = usersToImport.map(user => ({
    uid: user.email.replace(/@.*/, '').replace(/\./g, '_'), // Opcional: UID predecible
    email: user.email,
    displayName: user.displayName,
    passwordHash: Buffer.from(user.passwordHash, 'base64'), // El hash debe ser un Buffer
    salt: Buffer.from(user.salt, 'base64'), // La sal también debe ser un Buffer
  }));

  // 3. Llamar a la función de importación masiva
  try {
    const result = await auth.importUsers(userImportRecords, {
      hash: {
        algorithm: 'SCRYPT',
        key: Buffer.from(SCRYPT_CONFIG.hashKey, 'base64'), // La clave también como Buffer
        saltSeparator: Buffer.from(SCRYPT_CONFIG.saltSeparator, 'base64'),
        rounds: SCRYPT_CONFIG.rounds,
        memoryCost: SCRYPT_CONFIG.memCost,
      },
    });

    // 4. Reportar resultados
    if (result.successCount > 0) {
      console.log(`✅ ¡Éxito! Se importaron ${result.successCount} usuarios correctamente.`);
    }
    if (result.failureCount > 0) {
      console.warn(`🟡 ATENCIÓN: Falló la importación de ${result.failureCount} usuarios.`);
      console.log('Errores detallados:');
      result.errors.forEach(err => {
        console.log(`- Usuario (índice ${err.index}): ${err.error.message}`);
      });
    }

  } catch (error) {
    console.error('❌ Ocurrió un error catastrófico durante la importación:', error);
    console.log('--- Detalles del error ---');
    console.log('Código:', error.code);
    console.log('Mensaje:', error.message);
    if(error.errorInfo) {
        console.log('Info adicional:', error.errorInfo);
    }
  }

  console.log('Proceso de migración finalizado.');
}

// Ejecutar la función
migrateUsers();

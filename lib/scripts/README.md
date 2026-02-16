
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


# Guía de Scripts de Mantenimiento de Firebase

Este documento describe los scripts de Node.js ubicados en el directorio `lib/scripts/` que se utilizan para realizar tareas de mantenimiento en el backend de Firebase.

---

## `delete_users.js`

### Propósito

Este script se utiliza para **eliminar de forma masiva y permanente a usuarios del servicio de Firebase Authentication**. 

Fue creado como una herramienta de mantenimiento para limpiar cuentas de usuario que estaban corruptas, eran de prueba o necesitaban ser eliminadas por cualquier otra razón administrativa.

### Cómo Funciona

1.  **Conexión Segura:** El script utiliza el paquete `firebase-admin` y se inicializa con las credenciales de la cuenta de servicio del proyecto (`amobecal-firebase-adminsdk-fbsvc-4f8ba8c9c8.json`). Esto le otorga los permisos de administrador necesarios para realizar operaciones críticas como la eliminación de usuarios.

2.  **Lista de Objetivos (UIDs):** Dentro del script, hay una constante llamada `UIDS_TO_DELETE`. Esta es una lista (array) de strings donde se deben colocar los **UIDs (Identificadores de Usuario Únicos)** de todas las cuentas que se desean eliminar.

3.  **Operación de Borrado en Lote:** El script utiliza la función `auth.deleteUsers(UIDS_TO_DELETE)`, que es un método del SDK de Admin altamente eficiente. Envía una única solicitud a los servidores de Firebase para borrar todos los usuarios de la lista, en lugar de hacerlo uno por uno.

4.  **Reporte de Resultados:** Al finalizar, el script imprime en la consola un resumen de la operación, indicando cuántos usuarios se eliminaron con éxito y cuántos fallaron, incluyendo los mensajes de error si los hubiera.

### Cuándo Utilizarlo

- **Limpieza de Entorno:** Para eliminar cuentas de prueba o de desarrollo antes de un lanzamiento a producción.
- **Resolución de Problemas:** Para eliminar usuarios específicos que presenten datos corruptos o problemas de autenticación irrecuperables.
- **Mantenimiento General:** Como parte de tareas administrativas para dar de baja a usuarios del sistema.

**¡ADVERTENCIA!** La eliminación de un usuario de Authentication es **permanente e irreversible**. Este script no afecta a los datos del usuario en otras bases de datos como Firestore, por lo que esos datos quedarían "huérfanos" y deben ser manejados por separado.

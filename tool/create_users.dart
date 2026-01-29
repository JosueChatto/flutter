
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/services/auth_service.dart';

/*
Este es un script de un solo uso para crear los usuarios iniciales en Firebase.
Ejecútalo desde la terminal con: dart run tool/create_users.dart
*/

Future<void> main() async {
  // 1. Asegúrate de que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  final usersToCreate = {
    'estudiante1@tecnm.mx': 'password123',
    'estudiante2@tecnm.mx': 'password123',
    'admin@tecnm.mx': 'password123',
    'cafeteria@tecnm.mx': 'password123',
  };

  developer.log('Iniciando creación de usuarios para el proyecto amobecal...', name: 'CreateUsersScript');

  for (var email in usersToCreate.keys) {
    final password = usersToCreate[email]!;
    developer.log('Creando usuario: $email...', name: 'CreateUsersScript');
    
    final error = await authService.signUp(email: email, password: password);
    
    if (error == null) {
      developer.log('>>> ¡Éxito! Usuario $email creado.', name: 'CreateUsersScript');
    } else if (error.contains('email-already-in-use')) {
      developer.log('>>> Info: El usuario $email ya existe.', name: 'CreateUsersScript');
    } else {
      developer.log('>>> Error al crear $email: $error', name: 'CreateUsersScript', level: 900);
    }
  }

  developer.log('\n¡Proceso completado!', name: 'CreateUsersScript');
}

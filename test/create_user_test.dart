
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
// CORRECCIÓN: Usar una ruta relativa para asegurar que se encuentre el archivo.
import '../lib/firebase_options.dart'; 
import 'package:flutter/widgets.dart';
import 'dart:math';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  test('Debe crear un usuario (con email aleatorio) en Auth y Firestore, y luego limpiarlo', () async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    final randomId = Random().nextInt(100000);
    final email = 'testuser_$randomId@test.com';
    const password = 'password123';
    User? user;

    try {
      print('PASO 1: Creando usuario de prueba: $email');
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;

      expect(user, isNotNull, reason: 'La creación del usuario en Firebase Auth no debería fallar.');
      print('PASO 1 ÉXITO: Usuario creado en Auth con UID: ${user!.uid}');

      print('PASO 2: Añadiendo documento a Firestore para el UID: ${user.uid}');
      await firestore.collection('users').doc(user.uid).set({
        'email': email,
        'role': 'cafeteria',
        'name': 'Cafetería de Prueba',
      });
      print('PASO 2 ÉXITO: Documento de usuario añadido a Firestore.');

      final docSnapshot = await firestore.collection('users').doc(user.uid).get();

      expect(docSnapshot.exists, isTrue, reason: 'El documento del usuario debería existir en Firestore.');
      expect(docSnapshot.data()?['role'], 'cafeteria', reason: 'El rol del usuario debería ser "cafeteria".');
      
      print('PASO 3 ÉXITO: ¡Verificación completada con éxito para $email!');

    } catch (e, s) {
      print('ERROR: La prueba falló con una excepción. Error: $e');
      print('Stack trace: $s');
      fail('La prueba falló con la excepción: $e');
    } finally {
      if (user != null) {
        print('PASO 4: Limpiando... Borrando usuario de prueba: ${user.email}');
        await user.delete();
        print('PASO 4 ÉXITO: Usuario de prueba borrado.');
      }
    }
  });
}

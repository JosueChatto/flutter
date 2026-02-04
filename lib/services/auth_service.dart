
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer; // Importar la librería de logging

enum UserRole { student, admin, cafeteria, unknown }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserRole> signIn({required String email, required String password}) async {
    developer.log('--- Iniciando proceso de SignIn ---', name: 'AuthService');
    try {
      // 1. Autenticación con Firebase Auth
      developer.log('Paso 1: Intentando autenticar a $email con Firebase Auth.', name: 'AuthService');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        developer.log('Error: userCredential.user es nulo después del login.', name: 'AuthService', level: 1000);
        return UserRole.unknown;
      }

      final String uid = userCredential.user!.uid;
      developer.log('Paso 1 ÉXITO: Usuario autenticado. UID: $uid', name: 'AuthService');

      // 2. Obtener rol de Firestore
      return await _getUserRole(uid);

    } on FirebaseAuthException catch (e) {
      developer.log('ERROR en Firebase Auth: ${e.code}', error: e, name: 'AuthService', level: 1000);
      // Re-lanzar la excepción para que la UI la pueda manejar y mostrar un mensaje
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e, s) {
      developer.log('ERROR DESCONOCIDO en signIn: $e', name: 'AuthService', error: e, stackTrace: s, level: 1000);
      throw Exception('Ocurrió un error inesperado.');
    }
  }

  Future<UserRole> _getUserRole(String uid) async {
    developer.log('--- Obteniendo rol de usuario ---', name: 'AuthService');
    try {
      developer.log('Paso 2: Buscando documento en /users/$uid', name: 'AuthService');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        developer.log('Paso 2 ÉXITO: Documento encontrado. Datos: $data', name: 'AuthService');

        if (data.containsKey('role')) {
          final role = data['role'] as String;
          developer.log('Rol encontrado: "$role"', name: 'AuthService');
          switch (role) {
            case 'student': return UserRole.student;
            case 'admin': return UserRole.admin;
            case 'cafeteria': return UserRole.cafeteria;
            default:
              developer.log('ADVERTENCIA: Rol "$role" no reconocido.', name: 'AuthService', level: 900);
              return UserRole.unknown;
          }
        } else {
          developer.log('ERROR: El documento existe pero no contiene el campo "role".', name: 'AuthService', level: 1000);
          return UserRole.unknown;
        }
      } else {
        developer.log('ERROR: No se encontró ningún documento para el usuario en la colección "users".', name: 'AuthService', level: 1000);
        return UserRole.unknown;
      }
    } catch (e, s) {
      developer.log('ERROR al obtener rol de Firestore: $e', name: 'AuthService', error: e, stackTrace: s, level: 1000);
      return UserRole.unknown;
    }
  }
}

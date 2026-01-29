
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para el estado de autenticación del usuario
  Stream<User?> get user => _auth.authStateChanges();

  // Iniciar sesión con email y contraseña
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sin errores
    } on FirebaseAuthException catch (e) {
      return e.message; // Devuelve el mensaje de error de Firebase
    }
  }

  // Registrar un nuevo usuario
  Future<String?> signUp({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Por defecto, asignamos el rol 'estudiante' a los nuevos usuarios.
      // Los roles de admin y cafeteria se deben asignar manualmente en Firestore.
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': 'estudiante',
      });
      return null;
    } on FirebaseAuthException catch (e) {
      // Usar developer.log para errores, como se corrigió anteriormente
      developer.log(
        'Error en signUp: ${e.code}',
        name: 'AuthService',
        error: e,
      );
      return e.message;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Verificar si el usuario está logueado
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Obtener el rol del usuario actual
  Future<String?> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          // Asegurarse de que los datos no son nulos antes de acceder a ellos.
          final data = doc.data() as Map<String, dynamic>?;
          return data?['role'] as String?;
        }
      } catch (e) {
        developer.log('Error obteniendo el rol del usuario: $e', name: 'AuthService');
        return null;
      }
    }
    return null;
  }
}


import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para representar los roles de usuario de forma segura y clara.
enum UserRole { student, admin, cafeteria, unknown }

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtiene el estado de autenticación del usuario en tiempo real.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Inicia sesión con email y contraseña y determina el rol del usuario.
  Future<UserRole> signIn({required String email, required String password}) async {
    try {
      // 1. Autenticar al usuario con Firebase Authentication.
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        // Si por alguna razón el usuario es nulo, se considera un error.
        return UserRole.unknown;
      }

      // 2. Obtener el rol del usuario desde Firestore.
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Si el usuario está autenticado pero no tiene un documento en Firestore.
        // Esto es un estado inconsistente que debemos manejar.
        return UserRole.unknown;
      }
      
      // 3. Determinar el rol a partir del documento.
      final data = userDoc.data() as Map<String, dynamic>;
      // CORRECCIÓN: Se busca el campo 'rol' en minúsculas para que coincida con la base de datos.
      final String roleString = data['rol']?.toLowerCase() ?? '';

      switch (roleString) {
        case 'student':
        case 'estudiante': // Añadido para soportar ambos valores
          return UserRole.student;
        case 'admin':
          return UserRole.admin;
        case 'cafeteria':
          return UserRole.cafeteria;
        default:
          // Si el campo 'rol' no existe o tiene un valor inesperado.
          return UserRole.unknown;
      }
    } on FirebaseAuthException {
        // Si ocurre un error de autenticación (ej. contraseña incorrecta),
        // se relanza la excepción para que la UI la pueda atrapar y mostrar un mensaje específico.
        rethrow;
    } catch (e) {
        // Para cualquier otro tipo de error (ej. problema de red, error de Firestore),
        // lo envolvemos en una excepción genérica.
        throw Exception('Ocurrió un error al verificar el rol del usuario.');
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Obtiene el usuario actualmente autenticado.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Define los roles de usuario dentro de la aplicación.
///
/// Utilizar un enum proporciona seguridad de tipos y previene errores al comparar
/// strings de roles, además de centralizar los posibles roles en un único lugar.
enum UserRole { student, admin, cafeteria, unknown }

/// Servicio para gestionar la autenticación de usuarios y la obtención de roles.
///
/// Encapsula toda la lógica de interacción con Firebase Authentication y Firestore
/// relacionada con el registro, inicio de sesión y gestión de la sesión del usuario.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Proporciona un `Stream` para escuchar los cambios en el estado de autenticación.
  ///
  /// Ideal para redirigir al usuario automáticamente cuando inicia o cierra sesión.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Inicia sesión con correo electrónico y contraseña.
  ///
  /// Tras una autenticación exitosa, consulta la colección 'users' en Firestore
  /// para determinar y devolver el [UserRole] del usuario.
  ///
  /// Lanza [FirebaseAuthException] si la autenticación falla, permitiendo a la UI
  /// manejar errores específicos como contraseña incorrecta o usuario no encontrado.
  ///
  /// Lanza una [Exception] genérica para otros errores (ej. red, Firestore).
  Future<UserRole> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autenticar al usuario con Firebase Authentication.
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user == null) {
        return UserRole.unknown;
      }

      // 2. Obtener el documento del usuario desde Firestore para leer su rol.
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Un usuario autenticado sin un documento de rol es un estado inconsistente.
        return UserRole.unknown;
      }

      // 3. Convertir el campo 'rol' del documento al enum [UserRole].
      final data = userDoc.data() as Map<String, dynamic>;
      final String roleString = data['rol']?.toLowerCase() ?? '';

      switch (roleString) {
        case 'student':
        case 'estudiante': // Soporte para ambos valores por consistencia histórica.
          return UserRole.student;
        case 'admin':
          return UserRole.admin;
        case 'cafeteria':
          return UserRole.cafeteria;
        default:
          return UserRole.unknown;
      }
    } on FirebaseAuthException {
      // Relanza la excepción de Firebase para que la UI pueda manejarla.
      rethrow;
    } catch (e) {
      // Envuelve otros errores en una excepción genérica.
      throw Exception('Ocurrió un error al verificar el rol del usuario.');
    }
  }

  /// Cierra la sesión del usuario actualmente autenticado.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Obtiene el objeto [User] de Firebase del usuario actualmente autenticado.
  ///
  /// Devuelve `null` si no hay ningún usuario con sesión iniciada.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import '../core/config/app_config.dart';
import '../core/utils/app_error.dart';

abstract interface class AuthGateway {
  Stream<User?> authStateChanges();
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}

class AuthService implements AuthGateway {
  AuthService(this._auth);
  final FirebaseAuth _auth;
  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();
  @override
  Future<void> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (result.user?.uid != AppConfig.adminUid) {
      await _auth.signOut();
      throw const AppException('Tài khoản này không có quyền Admin.');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

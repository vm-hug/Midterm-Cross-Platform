import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/core/config/app_config.dart';
import 'package:midterm_cross_platform/core/utils/app_error.dart';
import 'package:midterm_cross_platform/services/auth_service.dart';

class FakeUser implements User {
  FakeUser(this.uid);
  @override
  final String uid;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCredential implements UserCredential {
  FakeCredential(this.user);
  @override
  final User? user;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuth extends Fake implements FirebaseAuth {
  String uid = AppConfig.adminUid;
  bool fail = false;
  int signouts = 0;
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (fail) throw FirebaseAuthException(code: 'invalid-credential');
    return FakeCredential(FakeUser(uid));
  }

  @override
  Future<void> signOut() async {
    signouts++;
  }

  @override
  Stream<User?> authStateChanges() => Stream.value(FakeUser(uid));
}

void main() {
  test('Firebase Admin may sign in; logout forwards to Firebase', () async {
    final auth = FakeAuth();
    final service = AuthService(auth);
    await service.signIn('admin@example.com', 'test-only');
    expect((await service.authStateChanges().first)?.uid, AppConfig.adminUid);
    expect(auth.signouts, 0);
    await service.signOut();
    expect(auth.signouts, 1);
  });
  test('Other UID is signed out and rejected', () async {
    final auth = FakeAuth()..uid = 'other';
    await expectLater(
      AuthService(auth).signIn('other@example.com', 'test-only'),
      throwsA(isA<AppException>()),
    );
    expect(auth.signouts, 1);
  });
  test('Wrong password is propagated', () async {
    final auth = FakeAuth()..fail = true;
    await expectLater(
      AuthService(auth).signIn('admin@example.com', 'test-only'),
      throwsA(isA<FirebaseAuthException>()),
    );
    expect(auth.signouts, 0);
  });
}

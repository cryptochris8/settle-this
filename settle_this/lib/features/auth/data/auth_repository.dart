import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthException implements Exception {
  const AuthException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AuthException($code): $message';
}

class AuthRepository {
  FirebaseAuth? _resolveAuth() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseAuth.instance;
    } on FirebaseException {
      return null;
    }
  }

  Stream<User?> authStateChanges() {
    final auth = _resolveAuth();
    if (auth == null) return Stream<User?>.value(null);
    return auth.authStateChanges();
  }

  User? get currentUser => _resolveAuth()?.currentUser;

  Future<User> signInAnonymously() async {
    final auth = _resolveAuth();
    if (auth == null) {
      throw const AuthException(
        "Firebase isn't configured yet. Run 'flutterfire configure' against the dev project.",
        code: 'firebase-not-initialized',
      );
    }
    try {
      final result = await auth.signInAnonymously();
      final user = result.user;
      if (user == null) {
        throw const AuthException('Anonymous sign-in returned no user.');
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthException(
        error.message ?? 'Anonymous sign-in failed.',
        code: error.code,
      );
    }
  }

  Future<void> signOut() async {
    final auth = _resolveAuth();
    if (auth == null) return;
    await auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

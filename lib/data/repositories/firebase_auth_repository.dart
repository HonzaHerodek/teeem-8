import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signUp(String email, String password, String username) async {
    try {
      // Check if username is available
      final usernameDoc = await _firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .get();

      if (usernameDoc.exists) {
        throw AuthException('Username is already taken');
      }

      // Create user account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reserve username
      await _firestore.collection('usernames').doc(username.toLowerCase()).set({
        'uid': userCredential.user!.uid,
      });
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Stream<bool> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) => user != null);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _firebaseAuth.currentUser?.uid;
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return AuthException('No user found with this email');
        case 'wrong-password':
          return AuthException('Wrong password');
        case 'email-already-in-use':
          return AuthException('Email is already in use');
        case 'invalid-email':
          return AuthException('Invalid email address');
        case 'weak-password':
          return AuthException('Password is too weak');
        case 'operation-not-allowed':
          return AuthException('Operation not allowed');
        case 'user-disabled':
          return AuthException('User has been disabled');
        default:
          return AuthException(e.message ?? 'Authentication failed');
      }
    }
    return AuthException('Authentication failed');
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

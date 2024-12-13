import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        return getCurrentUser();
      }
      return null;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserModel?> signUpWithEmailAndPassword(String email, String password, String username) async {
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

      final userData = {
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Create user profile
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);

      // Reserve username
      await _firestore.collection('usernames').doc(username.toLowerCase()).set({
        'uid': userCredential.user!.uid,
      });

      return UserModel(
        id: userCredential.user!.uid,
        email: email,
        username: username,
      );
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
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return UserModel(
        id: user.uid,
        email: user.email!,
        username: userData['username'] as String,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
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

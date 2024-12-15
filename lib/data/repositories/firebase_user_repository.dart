import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  FirebaseUserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    if (currentUser.uid != user.id) {
      throw Exception('Not authorized to update this user');
    }

    final userData = user.toJson();
    userData['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(user.id).update(userData);
  }

  @override
  Future<void> followUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Add to current user's following
    await _firestore.collection('users').doc(currentUser.uid).update({
      'following': FieldValue.arrayUnion([userId])
    });

    // Add to target user's followers
    await _firestore.collection('users').doc(userId).update({
      'followers': FieldValue.arrayUnion([currentUser.uid])
    });
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Remove from current user's following
    await _firestore.collection('users').doc(currentUser.uid).update({
      'following': FieldValue.arrayRemove([userId])
    });

    // Remove from target user's followers
    await _firestore.collection('users').doc(userId).update({
      'followers': FieldValue.arrayRemove([currentUser.uid])
    });
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final queryLower = query.toLowerCase();
    final snapshot = await _firestore
        .collection('users')
        .where('searchableUsername', arrayContains: queryLower)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return UserModel.fromJson(data);
    }).toList();
  }

  @override
  Stream<List<UserModel>> getFollowers(String userId) {
    return _firestore
        .collection('users')
        .where('following', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<UserModel>> getFollowing(String userId) {
    return _firestore
        .collection('users')
        .where('followers', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> updateProfileImage(String imagePath) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Upload image to Firebase Storage
    final ref = _storage.ref().child('profile_images/${currentUser.uid}');
    await ref.putFile(File(imagePath));

    // Get download URL
    final imageUrl = await ref.getDownloadURL();

    // Update user profile
    await _firestore.collection('users').doc(currentUser.uid).update({
      'profileImage': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(currentUser.uid).update({
      'settings': settings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> checkUsername(String username) async {
    final doc = await _firestore
        .collection('usernames')
        .doc(username.toLowerCase())
        .get();
    return !doc.exists;
  }

  @override
  Stream<UserModel> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('User not found');
      final data = doc.data()!;
      data['id'] = doc.id;
      return UserModel.fromJson(data);
    });
  }

  @override
  Future<void> deleteAccount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Delete user data
    await _firestore.collection('users').doc(currentUser.uid).delete();

    // Delete profile image
    try {
      await _storage.ref().child('profile_images/${currentUser.uid}').delete();
    } catch (_) {
      // Ignore if image doesn't exist
    }

    // Delete auth account
    await currentUser.delete();
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(currentUser.uid).update({
      'notificationSettings': settings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) throw Exception('User not found');

    final postsQuery = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();

    final totalLikes = postsQuery.docs.fold<int>(
        0, (sum, post) => sum + (post.data()['likes'] as List).length);

    return {
      'totalPosts': postsQuery.docs.length,
      'totalLikes': totalLikes,
      'followers': (userDoc.data()!['followers'] as List).length,
      'following': (userDoc.data()!['following'] as List).length,
    };
  }
}

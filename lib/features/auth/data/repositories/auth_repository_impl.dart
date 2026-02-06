import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          // Convert Firestore timestamp to DateTime manually if needed,
          // but Freezed/JsonSerializable handles generic maps.
          // However, Timestamp needs explicit conversion often.
          final data = doc.data()!;
          return UserEntity.fromJson({
            'id': doc.id,
            ...data,
            // Handle Timestamp conversion if necessary or let helper do it
            'createdAt': (data['createdAt'] as Timestamp)
                .toDate()
                .toIso8601String(),
          });
        }
        return null; // User exists in Auth but not in Firestore (edge case)
      } catch (e) {
        // Fallback or error handling
        print('Error fetching user data: $e');
        return null;
      }
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserEntity.fromJson({
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String(),
        });
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) throw Exception('Sign in failed');

      final userEntity = await getCurrentUser();
      if (userEntity == null) throw Exception('User data not found');

      return userEntity;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) throw Exception('Sign up failed');

      final now = DateTime.now();
      final userEntity = UserEntity(
        id: result.user!.uid,
        email: email,
        name: name,
        createdAt: now,
      );

      // Save to Firestore
      await _firestore.collection('users').doc(userEntity.id).set({
        'email': email,
        'name': name,
        'phone': null,
        'avatarUrl': null,
        'createdAt': Timestamp.fromDate(now),
      });

      return userEntity;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<UserEntity> signInWithCredential(AuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      if (result.user == null) throw Exception('Sign in failed');

      // Check if user exists in Firestore
      var userEntity = await getCurrentUser();

      if (userEntity == null) {
        // New user, create record
        final now = DateTime.now();
        userEntity = UserEntity(
          id: result.user!.uid,
          email: result.user!.email ?? '',
          name: '', // Name will need to be set later
          createdAt: now,
        );

        await _firestore.collection('users').doc(userEntity.id).set({
          'email': userEntity.email,
          'name': userEntity.name,
          'phone': result.user!.phoneNumber,
          'avatarUrl': null,
          'createdAt': Timestamp.fromDate(now),
        });
      }

      return userEntity;
    } catch (e) {
      throw Exception('Failed to sign in with credential: $e');
    }
  }
}

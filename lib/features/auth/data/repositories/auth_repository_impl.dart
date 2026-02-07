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
          final data = doc.data()!;
          return UserEntity.fromJson({
            'id': doc.id,
            ...data,
            'createdAt': (data['createdAt'] as Timestamp)
                .toDate()
                .toIso8601String(),
            if (data['updatedAt'] != null)
              'updatedAt': (data['updatedAt'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
          });
        }
        return null; // User exists in Auth but not in Firestore (edge case)
      } catch (e) {
        // Fallback or error handling
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
          if (data['updatedAt'] != null)
            'updatedAt': (data['updatedAt'] as Timestamp)
                .toDate()
                .toIso8601String(),
        });
      }
      // Error getting current user
    } catch (_) {}
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
    String username,
    String? phoneNumber,
  ) async {
    try {
      // First, create the Firebase Auth account
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) throw Exception('Sign up failed');

      try {
        // Now check if username is unique (user is authenticated)
        final usernameCheck = await _firestore
            .collection('users')
            .where('username', isEqualTo: username.toLowerCase())
            .limit(1)
            .get();

        if (usernameCheck.docs.isNotEmpty) {
          // Username is taken, delete the auth account and throw error
          await result.user!.delete();
          throw Exception('Username already taken');
        }

        final now = DateTime.now();
        final userEntity = UserEntity(
          id: result.user!.uid,
          email: email,
          name: name,
          username: username.toLowerCase(),
          phoneNumber: phoneNumber,
          createdAt: now,
        );

        // Save to Firestore
        await _firestore.collection('users').doc(userEntity.id).set({
          'email': email,
          'name': name,
          'username': username.toLowerCase(),
          'phoneNumber': phoneNumber,
          'avatarUrl': null,
          'isSearchable': true,
          'friends': [],
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': null,
        });

        return userEntity;
      } catch (e) {
        // If anything fails after auth creation, delete the account
        await result.user!.delete();
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
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
        final phoneNum = result.user!.phoneNumber ?? '';
        // Generate username from phone or email
        final defaultUsername = phoneNum.isNotEmpty
            ? 'user_${phoneNum.replaceAll(RegExp(r'[^0-9]'), '')}'
            : 'user_${result.user!.uid.substring(0, 8)}';

        userEntity = UserEntity(
          id: result.user!.uid,
          email: result.user!.email ?? '',
          name: '', // Name will need to be set later
          username: defaultUsername,
          phoneNumber: result.user!.phoneNumber,
          createdAt: now,
        );

        await _firestore.collection('users').doc(userEntity.id).set({
          'email': userEntity.email,
          'name': userEntity.name,
          'username': userEntity.username,
          'phoneNumber': result.user!.phoneNumber,
          'avatarUrl': null,
          'isSearchable': true,
          'friends': [],
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': null,
        });
      }

      return userEntity;
    } catch (e) {
      throw Exception('Failed to sign in with credential: $e');
    }
  }
}

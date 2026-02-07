import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

// Firebase instances
@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

// Repository
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  );
}

// Current User State
@riverpod
Stream<UserEntity?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

// Login Controller
@riverpod
class LoginController extends _$LoginController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmail(email, password),
    );
  }
}

// Signup Controller
@riverpod
class SignupController extends _$SignupController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    String username,
    String? phoneNumber,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signUpWithEmail(email, password, name, username, phoneNumber),
    );
  }
}

// Signout Controller
@riverpod
class SignOutController extends _$SignOutController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}

// Phone Auth Controller
@riverpod
class PhoneAuthController extends _$PhoneAuthController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    state = const AsyncValue.loading();

    final repo = ref.read(authRepositoryProvider);

    await repo.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        // Auto-verification (common on Android)
        state = await AsyncValue.guard(() async {
          await repo.signInWithCredential(credential);
        });
      },
      verificationFailed: (e) {
        state = AsyncValue.error(e, StackTrace.current);
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (verificationId, resendToken) {
        state = const AsyncValue.data(null); // Reset loading state
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        // Timeout handling if needed
      },
    );
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await ref.read(authRepositoryProvider).signInWithCredential(credential);
    });
  }
}

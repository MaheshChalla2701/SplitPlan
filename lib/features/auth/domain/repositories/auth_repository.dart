import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String name,
  );
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();
}

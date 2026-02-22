// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthHash() => r'8f84097cccd00af817397c1715c5f537399ba780';

/// See also [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = AutoDisposeProvider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthRef = AutoDisposeProviderRef<FirebaseAuth>;
String _$firebaseFirestoreHash() => r'eca974fdc891fcd3f9586742678f47582b20adec';

/// See also [firebaseFirestore].
@ProviderFor(firebaseFirestore)
final firebaseFirestoreProvider =
    AutoDisposeProvider<FirebaseFirestore>.internal(
      firebaseFirestore,
      name: r'firebaseFirestoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firebaseFirestoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseFirestoreRef = AutoDisposeProviderRef<FirebaseFirestore>;
String _$authRepositoryHash() => r'dd2204e76495f071c71958942f418106675dfdcc';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$authStateHash() => r'95c776affe675f041a8d4cf06fbb7ecc1183b699';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<UserEntity?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<UserEntity?>;
String _$loginControllerHash() => r'74c8e91f6686721cf356b2ac0723a34b470f97c6';

/// See also [LoginController].
@ProviderFor(LoginController)
final loginControllerProvider =
    AutoDisposeNotifierProvider<LoginController, AsyncValue<void>>.internal(
      LoginController.new,
      name: r'loginControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loginControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LoginController = AutoDisposeNotifier<AsyncValue<void>>;
String _$signupControllerHash() => r'f448426716bf24ef49b6162b0b3566bd657c9aae';

/// See also [SignupController].
@ProviderFor(SignupController)
final signupControllerProvider =
    AutoDisposeNotifierProvider<SignupController, AsyncValue<void>>.internal(
      SignupController.new,
      name: r'signupControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signupControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignupController = AutoDisposeNotifier<AsyncValue<void>>;
String _$signOutControllerHash() => r'cf30756d3cef6bdb35248acaca7fcf03a36163c2';

/// See also [SignOutController].
@ProviderFor(SignOutController)
final signOutControllerProvider =
    AutoDisposeNotifierProvider<SignOutController, AsyncValue<void>>.internal(
      SignOutController.new,
      name: r'signOutControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signOutControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignOutController = AutoDisposeNotifier<AsyncValue<void>>;
String _$phoneAuthControllerHash() =>
    r'72d3ce8a32d4eb121b700f2cabd088ee63b6d027';

/// See also [PhoneAuthController].
@ProviderFor(PhoneAuthController)
final phoneAuthControllerProvider =
    AutoDisposeNotifierProvider<PhoneAuthController, AsyncValue<void>>.internal(
      PhoneAuthController.new,
      name: r'phoneAuthControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$phoneAuthControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PhoneAuthController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

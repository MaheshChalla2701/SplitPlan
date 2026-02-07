// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentRequestRepositoryHash() =>
    r'6210dd51a9951fed87045803a1e9c571c36ef675';

/// See also [paymentRequestRepository].
@ProviderFor(paymentRequestRepository)
final paymentRequestRepositoryProvider =
    AutoDisposeProvider<PaymentRequestRepository>.internal(
      paymentRequestRepository,
      name: r'paymentRequestRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paymentRequestRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentRequestRepositoryRef =
    AutoDisposeProviderRef<PaymentRequestRepository>;
String _$userPaymentRequestsHash() =>
    r'2b2e2fc3aa0c6aefd5636dcaad1941ce33777fba';

/// See also [userPaymentRequests].
@ProviderFor(userPaymentRequests)
final userPaymentRequestsProvider =
    AutoDisposeStreamProvider<List<PaymentRequestEntity>>.internal(
      userPaymentRequests,
      name: r'userPaymentRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userPaymentRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserPaymentRequestsRef =
    AutoDisposeStreamProviderRef<List<PaymentRequestEntity>>;
String _$paymentRequestsWithFriendHash() =>
    r'c8fdcb7092a1315c219d8648a5f67b5bbd04953f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [paymentRequestsWithFriend].
@ProviderFor(paymentRequestsWithFriend)
const paymentRequestsWithFriendProvider = PaymentRequestsWithFriendFamily();

/// See also [paymentRequestsWithFriend].
class PaymentRequestsWithFriendFamily
    extends Family<AsyncValue<List<PaymentRequestEntity>>> {
  /// See also [paymentRequestsWithFriend].
  const PaymentRequestsWithFriendFamily();

  /// See also [paymentRequestsWithFriend].
  PaymentRequestsWithFriendProvider call(String friendId) {
    return PaymentRequestsWithFriendProvider(friendId);
  }

  @override
  PaymentRequestsWithFriendProvider getProviderOverride(
    covariant PaymentRequestsWithFriendProvider provider,
  ) {
    return call(provider.friendId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'paymentRequestsWithFriendProvider';
}

/// See also [paymentRequestsWithFriend].
class PaymentRequestsWithFriendProvider
    extends AutoDisposeStreamProvider<List<PaymentRequestEntity>> {
  /// See also [paymentRequestsWithFriend].
  PaymentRequestsWithFriendProvider(String friendId)
    : this._internal(
        (ref) => paymentRequestsWithFriend(
          ref as PaymentRequestsWithFriendRef,
          friendId,
        ),
        from: paymentRequestsWithFriendProvider,
        name: r'paymentRequestsWithFriendProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$paymentRequestsWithFriendHash,
        dependencies: PaymentRequestsWithFriendFamily._dependencies,
        allTransitiveDependencies:
            PaymentRequestsWithFriendFamily._allTransitiveDependencies,
        friendId: friendId,
      );

  PaymentRequestsWithFriendProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.friendId,
  }) : super.internal();

  final String friendId;

  @override
  Override overrideWith(
    Stream<List<PaymentRequestEntity>> Function(
      PaymentRequestsWithFriendRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaymentRequestsWithFriendProvider._internal(
        (ref) => create(ref as PaymentRequestsWithFriendRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        friendId: friendId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PaymentRequestEntity>> createElement() {
    return _PaymentRequestsWithFriendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentRequestsWithFriendProvider &&
        other.friendId == friendId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, friendId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PaymentRequestsWithFriendRef
    on AutoDisposeStreamProviderRef<List<PaymentRequestEntity>> {
  /// The parameter `friendId` of this provider.
  String get friendId;
}

class _PaymentRequestsWithFriendProviderElement
    extends AutoDisposeStreamProviderElement<List<PaymentRequestEntity>>
    with PaymentRequestsWithFriendRef {
  _PaymentRequestsWithFriendProviderElement(super.provider);

  @override
  String get friendId => (origin as PaymentRequestsWithFriendProvider).friendId;
}

String _$createPaymentRequestControllerHash() =>
    r'01483f2f70cfadeea906c20d7068aead77e75d34';

/// See also [CreatePaymentRequestController].
@ProviderFor(CreatePaymentRequestController)
final createPaymentRequestControllerProvider =
    AutoDisposeNotifierProvider<
      CreatePaymentRequestController,
      AsyncValue<void>
    >.internal(
      CreatePaymentRequestController.new,
      name: r'createPaymentRequestControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createPaymentRequestControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CreatePaymentRequestController =
    AutoDisposeNotifier<AsyncValue<void>>;
String _$updatePaymentRequestControllerHash() =>
    r'264186519773c053307ae8520579ff2197d37732';

/// See also [UpdatePaymentRequestController].
@ProviderFor(UpdatePaymentRequestController)
final updatePaymentRequestControllerProvider =
    AutoDisposeNotifierProvider<
      UpdatePaymentRequestController,
      AsyncValue<void>
    >.internal(
      UpdatePaymentRequestController.new,
      name: r'updatePaymentRequestControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updatePaymentRequestControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UpdatePaymentRequestController =
    AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

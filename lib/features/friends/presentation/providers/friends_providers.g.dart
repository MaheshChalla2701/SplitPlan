// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$friendsRepositoryHash() => r'0bc7bfd8aa37597a54e134f62b09cb1a257983df';

/// See also [friendsRepository].
@ProviderFor(friendsRepository)
final friendsRepositoryProvider =
    AutoDisposeProvider<FriendsRepository>.internal(
      friendsRepository,
      name: r'friendsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$friendsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FriendsRepositoryRef = AutoDisposeProviderRef<FriendsRepository>;
String _$userFriendsHash() => r'8ea0656fc47cc1e492c22617ef4a185e4924944e';

/// See also [userFriends].
@ProviderFor(userFriends)
final userFriendsProvider =
    AutoDisposeStreamProvider<List<UserEntity>>.internal(
      userFriends,
      name: r'userFriendsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userFriendsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserFriendsRef = AutoDisposeStreamProviderRef<List<UserEntity>>;
String _$pendingFriendRequestsHash() =>
    r'24c619977902ccc73d225047ddb3722f2dd0fb34';

/// See also [pendingFriendRequests].
@ProviderFor(pendingFriendRequests)
final pendingFriendRequestsProvider =
    AutoDisposeStreamProvider<List<FriendshipRequest>>.internal(
      pendingFriendRequests,
      name: r'pendingFriendRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingFriendRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingFriendRequestsRef =
    AutoDisposeStreamProviderRef<List<FriendshipRequest>>;
String _$specificFriendHash() => r'4e8a5e0d3cfd8781c67d2ec7bdfa527f9a2bc35b';

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

/// See also [specificFriend].
@ProviderFor(specificFriend)
const specificFriendProvider = SpecificFriendFamily();

/// See also [specificFriend].
class SpecificFriendFamily extends Family<AsyncValue<UserEntity?>> {
  /// See also [specificFriend].
  const SpecificFriendFamily();

  /// See also [specificFriend].
  SpecificFriendProvider call(String friendId) {
    return SpecificFriendProvider(friendId);
  }

  @override
  SpecificFriendProvider getProviderOverride(
    covariant SpecificFriendProvider provider,
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
  String? get name => r'specificFriendProvider';
}

/// See also [specificFriend].
class SpecificFriendProvider extends AutoDisposeFutureProvider<UserEntity?> {
  /// See also [specificFriend].
  SpecificFriendProvider(String friendId)
    : this._internal(
        (ref) => specificFriend(ref as SpecificFriendRef, friendId),
        from: specificFriendProvider,
        name: r'specificFriendProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$specificFriendHash,
        dependencies: SpecificFriendFamily._dependencies,
        allTransitiveDependencies:
            SpecificFriendFamily._allTransitiveDependencies,
        friendId: friendId,
      );

  SpecificFriendProvider._internal(
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
    FutureOr<UserEntity?> Function(SpecificFriendRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SpecificFriendProvider._internal(
        (ref) => create(ref as SpecificFriendRef),
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
  AutoDisposeFutureProviderElement<UserEntity?> createElement() {
    return _SpecificFriendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SpecificFriendProvider && other.friendId == friendId;
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
mixin SpecificFriendRef on AutoDisposeFutureProviderRef<UserEntity?> {
  /// The parameter `friendId` of this provider.
  String get friendId;
}

class _SpecificFriendProviderElement
    extends AutoDisposeFutureProviderElement<UserEntity?>
    with SpecificFriendRef {
  _SpecificFriendProviderElement(super.provider);

  @override
  String get friendId => (origin as SpecificFriendProvider).friendId;
}

String _$searchUsersControllerHash() =>
    r'9491f0c494316e8da3f448de398b83a13cec4ae3';

/// See also [SearchUsersController].
@ProviderFor(SearchUsersController)
final searchUsersControllerProvider =
    AutoDisposeNotifierProvider<
      SearchUsersController,
      AsyncValue<List<UserEntity>>
    >.internal(
      SearchUsersController.new,
      name: r'searchUsersControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchUsersControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchUsersController =
    AutoDisposeNotifier<AsyncValue<List<UserEntity>>>;
String _$sendFriendRequestControllerHash() =>
    r'6f01df1e2a1c09f9f4b7d347b586e3e9f9dd29d9';

/// See also [SendFriendRequestController].
@ProviderFor(SendFriendRequestController)
final sendFriendRequestControllerProvider =
    AutoDisposeNotifierProvider<
      SendFriendRequestController,
      AsyncValue<void>
    >.internal(
      SendFriendRequestController.new,
      name: r'sendFriendRequestControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sendFriendRequestControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SendFriendRequestController = AutoDisposeNotifier<AsyncValue<void>>;
String _$acceptFriendRequestControllerHash() =>
    r'0ecacd3306c7b579e8dffe9adc18371e3293856b';

/// See also [AcceptFriendRequestController].
@ProviderFor(AcceptFriendRequestController)
final acceptFriendRequestControllerProvider =
    AutoDisposeNotifierProvider<
      AcceptFriendRequestController,
      AsyncValue<void>
    >.internal(
      AcceptFriendRequestController.new,
      name: r'acceptFriendRequestControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$acceptFriendRequestControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AcceptFriendRequestController = AutoDisposeNotifier<AsyncValue<void>>;
String _$createManualFriendControllerHash() =>
    r'28a4bf5864576a8a8e75b2b62a094f277e9562dd';

/// See also [CreateManualFriendController].
@ProviderFor(CreateManualFriendController)
final createManualFriendControllerProvider =
    AutoDisposeNotifierProvider<
      CreateManualFriendController,
      AsyncValue<void>
    >.internal(
      CreateManualFriendController.new,
      name: r'createManualFriendControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createManualFriendControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CreateManualFriendController = AutoDisposeNotifier<AsyncValue<void>>;
String _$mergeManualFriendControllerHash() =>
    r'00fc2eccaede088478dcbe17822df49553ab880b';

/// See also [MergeManualFriendController].
@ProviderFor(MergeManualFriendController)
final mergeManualFriendControllerProvider =
    AutoDisposeNotifierProvider<
      MergeManualFriendController,
      AsyncValue<void>
    >.internal(
      MergeManualFriendController.new,
      name: r'mergeManualFriendControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mergeManualFriendControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MergeManualFriendController = AutoDisposeNotifier<AsyncValue<void>>;
String _$deleteFriendControllerHash() =>
    r'91138262e43bbfc0aeff72ac4910e4356df9641f';

/// See also [DeleteFriendController].
@ProviderFor(DeleteFriendController)
final deleteFriendControllerProvider =
    AutoDisposeNotifierProvider<
      DeleteFriendController,
      AsyncValue<void>
    >.internal(
      DeleteFriendController.new,
      name: r'deleteFriendControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteFriendControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeleteFriendController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

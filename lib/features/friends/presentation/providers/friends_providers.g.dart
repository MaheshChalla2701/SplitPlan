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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

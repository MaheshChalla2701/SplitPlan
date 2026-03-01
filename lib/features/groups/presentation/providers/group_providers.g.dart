// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupRepositoryHash() => r'da3bbdea9c4e9dc3a3a15dc20f5ccf64afb1f0fc';

/// See also [groupRepository].
@ProviderFor(groupRepository)
final groupRepositoryProvider = AutoDisposeProvider<GroupRepository>.internal(
  groupRepository,
  name: r'groupRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupRepositoryRef = AutoDisposeProviderRef<GroupRepository>;
String _$userGroupsHash() => r'49ff76728af4aced5f8dbf577e083671042d8b7a';

/// See also [userGroups].
@ProviderFor(userGroups)
final userGroupsProvider =
    AutoDisposeStreamProvider<List<GroupEntity>>.internal(
      userGroups,
      name: r'userGroupsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userGroupsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserGroupsRef = AutoDisposeStreamProviderRef<List<GroupEntity>>;
String _$groupHash() => r'262999efb6b7f1d9c709eeaca17ef658e2e34b8a';

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

/// See also [group].
@ProviderFor(group)
const groupProvider = GroupFamily();

/// See also [group].
class GroupFamily extends Family<AsyncValue<GroupEntity>> {
  /// See also [group].
  const GroupFamily();

  /// See also [group].
  GroupProvider call(String groupId) {
    return GroupProvider(groupId);
  }

  @override
  GroupProvider getProviderOverride(covariant GroupProvider provider) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupProvider';
}

/// See also [group].
class GroupProvider extends AutoDisposeStreamProvider<GroupEntity> {
  /// See also [group].
  GroupProvider(String groupId)
    : this._internal(
        (ref) => group(ref as GroupRef, groupId),
        from: groupProvider,
        name: r'groupProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupHash,
        dependencies: GroupFamily._dependencies,
        allTransitiveDependencies: GroupFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    Stream<GroupEntity> Function(GroupRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupProvider._internal(
        (ref) => create(ref as GroupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<GroupEntity> createElement() {
    return _GroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupRef on AutoDisposeStreamProviderRef<GroupEntity> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupProviderElement
    extends AutoDisposeStreamProviderElement<GroupEntity>
    with GroupRef {
  _GroupProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupProvider).groupId;
}

String _$groupControllerHash() => r'589ce67df72cb28f7b33e48c88d2417c0c14cc07';

/// See also [GroupController].
@ProviderFor(GroupController)
final groupControllerProvider =
    AutoDisposeNotifierProvider<GroupController, AsyncValue<void>>.internal(
      GroupController.new,
      name: r'groupControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groupControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GroupController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

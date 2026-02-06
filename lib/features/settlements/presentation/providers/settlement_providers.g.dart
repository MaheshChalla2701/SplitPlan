// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settlementRepositoryHash() =>
    r'19378743d2a75a93c53d4c816db7d10c97c69c98';

/// See also [settlementRepository].
@ProviderFor(settlementRepository)
final settlementRepositoryProvider =
    AutoDisposeProvider<SettlementRepository>.internal(
      settlementRepository,
      name: r'settlementRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settlementRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettlementRepositoryRef = AutoDisposeProviderRef<SettlementRepository>;
String _$groupSettlementsHash() => r'8c080f3e168651a99224c9f18bee1231c9b1e32a';

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

/// See also [groupSettlements].
@ProviderFor(groupSettlements)
const groupSettlementsProvider = GroupSettlementsFamily();

/// See also [groupSettlements].
class GroupSettlementsFamily
    extends Family<AsyncValue<List<SettlementEntity>>> {
  /// See also [groupSettlements].
  const GroupSettlementsFamily();

  /// See also [groupSettlements].
  GroupSettlementsProvider call(String groupId) {
    return GroupSettlementsProvider(groupId);
  }

  @override
  GroupSettlementsProvider getProviderOverride(
    covariant GroupSettlementsProvider provider,
  ) {
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
  String? get name => r'groupSettlementsProvider';
}

/// See also [groupSettlements].
class GroupSettlementsProvider
    extends AutoDisposeStreamProvider<List<SettlementEntity>> {
  /// See also [groupSettlements].
  GroupSettlementsProvider(String groupId)
    : this._internal(
        (ref) => groupSettlements(ref as GroupSettlementsRef, groupId),
        from: groupSettlementsProvider,
        name: r'groupSettlementsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupSettlementsHash,
        dependencies: GroupSettlementsFamily._dependencies,
        allTransitiveDependencies:
            GroupSettlementsFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupSettlementsProvider._internal(
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
    Stream<List<SettlementEntity>> Function(GroupSettlementsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupSettlementsProvider._internal(
        (ref) => create(ref as GroupSettlementsRef),
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
  AutoDisposeStreamProviderElement<List<SettlementEntity>> createElement() {
    return _GroupSettlementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupSettlementsProvider && other.groupId == groupId;
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
mixin GroupSettlementsRef
    on AutoDisposeStreamProviderRef<List<SettlementEntity>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupSettlementsProviderElement
    extends AutoDisposeStreamProviderElement<List<SettlementEntity>>
    with GroupSettlementsRef {
  _GroupSettlementsProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupSettlementsProvider).groupId;
}

String _$settlementControllerHash() =>
    r'132cca863c0401ab2071d20bcdc9f7ed758e4bea';

/// See also [SettlementController].
@ProviderFor(SettlementController)
final settlementControllerProvider =
    AutoDisposeNotifierProvider<
      SettlementController,
      AsyncValue<void>
    >.internal(
      SettlementController.new,
      name: r'settlementControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settlementControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettlementController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

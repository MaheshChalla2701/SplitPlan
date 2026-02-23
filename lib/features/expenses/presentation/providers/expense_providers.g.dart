// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseRepositoryHash() => r'9536ef94d73f27e7889f367e9689a8a93cf046b6';

/// See also [expenseRepository].
@ProviderFor(expenseRepository)
final expenseRepositoryProvider =
    AutoDisposeProvider<ExpenseRepository>.internal(
      expenseRepository,
      name: r'expenseRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseRepositoryRef = AutoDisposeProviderRef<ExpenseRepository>;
String _$groupExpensesHash() => r'46920a2c5b283f46205bef1561a1e94764cea99e';

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

/// See also [groupExpenses].
@ProviderFor(groupExpenses)
const groupExpensesProvider = GroupExpensesFamily();

/// See also [groupExpenses].
class GroupExpensesFamily extends Family<AsyncValue<List<ExpenseEntity>>> {
  /// See also [groupExpenses].
  const GroupExpensesFamily();

  /// See also [groupExpenses].
  GroupExpensesProvider call(String groupId) {
    return GroupExpensesProvider(groupId);
  }

  @override
  GroupExpensesProvider getProviderOverride(
    covariant GroupExpensesProvider provider,
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
  String? get name => r'groupExpensesProvider';
}

/// See also [groupExpenses].
class GroupExpensesProvider
    extends AutoDisposeStreamProvider<List<ExpenseEntity>> {
  /// See also [groupExpenses].
  GroupExpensesProvider(String groupId)
    : this._internal(
        (ref) => groupExpenses(ref as GroupExpensesRef, groupId),
        from: groupExpensesProvider,
        name: r'groupExpensesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupExpensesHash,
        dependencies: GroupExpensesFamily._dependencies,
        allTransitiveDependencies:
            GroupExpensesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupExpensesProvider._internal(
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
    Stream<List<ExpenseEntity>> Function(GroupExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupExpensesProvider._internal(
        (ref) => create(ref as GroupExpensesRef),
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
  AutoDisposeStreamProviderElement<List<ExpenseEntity>> createElement() {
    return _GroupExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupExpensesProvider && other.groupId == groupId;
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
mixin GroupExpensesRef on AutoDisposeStreamProviderRef<List<ExpenseEntity>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupExpensesProviderElement
    extends AutoDisposeStreamProviderElement<List<ExpenseEntity>>
    with GroupExpensesRef {
  _GroupExpensesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupExpensesProvider).groupId;
}

String _$groupBalancesHash() => r'e4f0c8858fdb033ce0f1f63eda9fbc1c97b63a00';

/// See also [groupBalances].
@ProviderFor(groupBalances)
const groupBalancesProvider = GroupBalancesFamily();

/// See also [groupBalances].
class GroupBalancesFamily extends Family<AsyncValue<Map<String, double>>> {
  /// See also [groupBalances].
  const GroupBalancesFamily();

  /// See also [groupBalances].
  GroupBalancesProvider call(String groupId) {
    return GroupBalancesProvider(groupId);
  }

  @override
  GroupBalancesProvider getProviderOverride(
    covariant GroupBalancesProvider provider,
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
  String? get name => r'groupBalancesProvider';
}

/// See also [groupBalances].
class GroupBalancesProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// See also [groupBalances].
  GroupBalancesProvider(String groupId)
    : this._internal(
        (ref) => groupBalances(ref as GroupBalancesRef, groupId),
        from: groupBalancesProvider,
        name: r'groupBalancesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupBalancesHash,
        dependencies: GroupBalancesFamily._dependencies,
        allTransitiveDependencies:
            GroupBalancesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupBalancesProvider._internal(
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
    FutureOr<Map<String, double>> Function(GroupBalancesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupBalancesProvider._internal(
        (ref) => create(ref as GroupBalancesRef),
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
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _GroupBalancesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupBalancesProvider && other.groupId == groupId;
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
mixin GroupBalancesRef on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupBalancesProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with GroupBalancesRef {
  _GroupBalancesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupBalancesProvider).groupId;
}

String _$expenseControllerHash() => r'3ca139d10edebd32660ab59e4c37d5564da51159';

/// See also [ExpenseController].
@ProviderFor(ExpenseController)
final expenseControllerProvider =
    AutoDisposeNotifierProvider<ExpenseController, AsyncValue<void>>.internal(
      ExpenseController.new,
      name: r'expenseControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpenseController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

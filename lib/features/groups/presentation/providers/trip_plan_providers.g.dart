// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_plan_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripPlanRepositoryHash() =>
    r'ad4afcb8bfb63144779dbc20a707625bd3ebd6cd';

/// See also [tripPlanRepository].
@ProviderFor(tripPlanRepository)
final tripPlanRepositoryProvider =
    AutoDisposeProvider<TripPlanRepository>.internal(
      tripPlanRepository,
      name: r'tripPlanRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tripPlanRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripPlanRepositoryRef = AutoDisposeProviderRef<TripPlanRepository>;
String _$groupTripPlansHash() => r'b8273326b726b8bfebddcdf558e884b9709a0b3b';

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

/// See also [groupTripPlans].
@ProviderFor(groupTripPlans)
const groupTripPlansProvider = GroupTripPlansFamily();

/// See also [groupTripPlans].
class GroupTripPlansFamily extends Family<AsyncValue<List<TripPlanEntity>>> {
  /// See also [groupTripPlans].
  const GroupTripPlansFamily();

  /// See also [groupTripPlans].
  GroupTripPlansProvider call(String groupId) {
    return GroupTripPlansProvider(groupId);
  }

  @override
  GroupTripPlansProvider getProviderOverride(
    covariant GroupTripPlansProvider provider,
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
  String? get name => r'groupTripPlansProvider';
}

/// See also [groupTripPlans].
class GroupTripPlansProvider
    extends AutoDisposeStreamProvider<List<TripPlanEntity>> {
  /// See also [groupTripPlans].
  GroupTripPlansProvider(String groupId)
    : this._internal(
        (ref) => groupTripPlans(ref as GroupTripPlansRef, groupId),
        from: groupTripPlansProvider,
        name: r'groupTripPlansProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupTripPlansHash,
        dependencies: GroupTripPlansFamily._dependencies,
        allTransitiveDependencies:
            GroupTripPlansFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupTripPlansProvider._internal(
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
    Stream<List<TripPlanEntity>> Function(GroupTripPlansRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupTripPlansProvider._internal(
        (ref) => create(ref as GroupTripPlansRef),
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
  AutoDisposeStreamProviderElement<List<TripPlanEntity>> createElement() {
    return _GroupTripPlansProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupTripPlansProvider && other.groupId == groupId;
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
mixin GroupTripPlansRef on AutoDisposeStreamProviderRef<List<TripPlanEntity>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupTripPlansProviderElement
    extends AutoDisposeStreamProviderElement<List<TripPlanEntity>>
    with GroupTripPlansRef {
  _GroupTripPlansProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupTripPlansProvider).groupId;
}

String _$tripDayCardsHash() => r'9dd6763a2f794a530c719c7de9465245262a4bd8';

/// See also [tripDayCards].
@ProviderFor(tripDayCards)
const tripDayCardsProvider = TripDayCardsFamily();

/// See also [tripDayCards].
class TripDayCardsFamily extends Family<AsyncValue<List<TripDayCardEntity>>> {
  /// See also [tripDayCards].
  const TripDayCardsFamily();

  /// See also [tripDayCards].
  TripDayCardsProvider call(String tripPlanId) {
    return TripDayCardsProvider(tripPlanId);
  }

  @override
  TripDayCardsProvider getProviderOverride(
    covariant TripDayCardsProvider provider,
  ) {
    return call(provider.tripPlanId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tripDayCardsProvider';
}

/// See also [tripDayCards].
class TripDayCardsProvider
    extends AutoDisposeStreamProvider<List<TripDayCardEntity>> {
  /// See also [tripDayCards].
  TripDayCardsProvider(String tripPlanId)
    : this._internal(
        (ref) => tripDayCards(ref as TripDayCardsRef, tripPlanId),
        from: tripDayCardsProvider,
        name: r'tripDayCardsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tripDayCardsHash,
        dependencies: TripDayCardsFamily._dependencies,
        allTransitiveDependencies:
            TripDayCardsFamily._allTransitiveDependencies,
        tripPlanId: tripPlanId,
      );

  TripDayCardsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripPlanId,
  }) : super.internal();

  final String tripPlanId;

  @override
  Override overrideWith(
    Stream<List<TripDayCardEntity>> Function(TripDayCardsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TripDayCardsProvider._internal(
        (ref) => create(ref as TripDayCardsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripPlanId: tripPlanId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TripDayCardEntity>> createElement() {
    return _TripDayCardsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TripDayCardsProvider && other.tripPlanId == tripPlanId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripPlanId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TripDayCardsRef on AutoDisposeStreamProviderRef<List<TripDayCardEntity>> {
  /// The parameter `tripPlanId` of this provider.
  String get tripPlanId;
}

class _TripDayCardsProviderElement
    extends AutoDisposeStreamProviderElement<List<TripDayCardEntity>>
    with TripDayCardsRef {
  _TripDayCardsProviderElement(super.provider);

  @override
  String get tripPlanId => (origin as TripDayCardsProvider).tripPlanId;
}

String _$tripPlanControllerHash() =>
    r'18a1ae2c11b6162222f260bcd024a21ce6ecef4c';

/// See also [TripPlanController].
@ProviderFor(TripPlanController)
final tripPlanControllerProvider =
    AutoDisposeNotifierProvider<TripPlanController, AsyncValue<void>>.internal(
      TripPlanController.new,
      name: r'tripPlanControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tripPlanControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TripPlanController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

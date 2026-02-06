// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SettlementEntity _$SettlementEntityFromJson(Map<String, dynamic> json) {
  return _SettlementEntity.fromJson(json);
}

/// @nodoc
mixin _$SettlementEntity {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get fromUserId => throw _privateConstructorUsedError;
  String get toUserId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get settledAt => throw _privateConstructorUsedError;
  String get settledBy => throw _privateConstructorUsedError;

  /// Serializes this SettlementEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettlementEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettlementEntityCopyWith<SettlementEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementEntityCopyWith<$Res> {
  factory $SettlementEntityCopyWith(
    SettlementEntity value,
    $Res Function(SettlementEntity) then,
  ) = _$SettlementEntityCopyWithImpl<$Res, SettlementEntity>;
  @useResult
  $Res call({
    String id,
    String groupId,
    String fromUserId,
    String toUserId,
    double amount,
    DateTime settledAt,
    String settledBy,
  });
}

/// @nodoc
class _$SettlementEntityCopyWithImpl<$Res, $Val extends SettlementEntity>
    implements $SettlementEntityCopyWith<$Res> {
  _$SettlementEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettlementEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? amount = null,
    Object? settledAt = null,
    Object? settledBy = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            fromUserId: null == fromUserId
                ? _value.fromUserId
                : fromUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            toUserId: null == toUserId
                ? _value.toUserId
                : toUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            settledAt: null == settledAt
                ? _value.settledAt
                : settledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            settledBy: null == settledBy
                ? _value.settledBy
                : settledBy // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettlementEntityImplCopyWith<$Res>
    implements $SettlementEntityCopyWith<$Res> {
  factory _$$SettlementEntityImplCopyWith(
    _$SettlementEntityImpl value,
    $Res Function(_$SettlementEntityImpl) then,
  ) = __$$SettlementEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String groupId,
    String fromUserId,
    String toUserId,
    double amount,
    DateTime settledAt,
    String settledBy,
  });
}

/// @nodoc
class __$$SettlementEntityImplCopyWithImpl<$Res>
    extends _$SettlementEntityCopyWithImpl<$Res, _$SettlementEntityImpl>
    implements _$$SettlementEntityImplCopyWith<$Res> {
  __$$SettlementEntityImplCopyWithImpl(
    _$SettlementEntityImpl _value,
    $Res Function(_$SettlementEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettlementEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? amount = null,
    Object? settledAt = null,
    Object? settledBy = null,
  }) {
    return _then(
      _$SettlementEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        fromUserId: null == fromUserId
            ? _value.fromUserId
            : fromUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        toUserId: null == toUserId
            ? _value.toUserId
            : toUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        settledAt: null == settledAt
            ? _value.settledAt
            : settledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        settledBy: null == settledBy
            ? _value.settledBy
            : settledBy // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementEntityImpl implements _SettlementEntity {
  const _$SettlementEntityImpl({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.settledAt,
    required this.settledBy,
  });

  factory _$SettlementEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String fromUserId;
  @override
  final String toUserId;
  @override
  final double amount;
  @override
  final DateTime settledAt;
  @override
  final String settledBy;

  @override
  String toString() {
    return 'SettlementEntity(id: $id, groupId: $groupId, fromUserId: $fromUserId, toUserId: $toUserId, amount: $amount, settledAt: $settledAt, settledBy: $settledBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.settledAt, settledAt) ||
                other.settledAt == settledAt) &&
            (identical(other.settledBy, settledBy) ||
                other.settledBy == settledBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    groupId,
    fromUserId,
    toUserId,
    amount,
    settledAt,
    settledBy,
  );

  /// Create a copy of SettlementEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementEntityImplCopyWith<_$SettlementEntityImpl> get copyWith =>
      __$$SettlementEntityImplCopyWithImpl<_$SettlementEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementEntityImplToJson(this);
  }
}

abstract class _SettlementEntity implements SettlementEntity {
  const factory _SettlementEntity({
    required final String id,
    required final String groupId,
    required final String fromUserId,
    required final String toUserId,
    required final double amount,
    required final DateTime settledAt,
    required final String settledBy,
  }) = _$SettlementEntityImpl;

  factory _SettlementEntity.fromJson(Map<String, dynamic> json) =
      _$SettlementEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get fromUserId;
  @override
  String get toUserId;
  @override
  double get amount;
  @override
  DateTime get settledAt;
  @override
  String get settledBy;

  /// Create a copy of SettlementEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettlementEntityImplCopyWith<_$SettlementEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

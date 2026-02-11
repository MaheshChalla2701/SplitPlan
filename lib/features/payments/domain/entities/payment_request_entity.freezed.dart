// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentRequestEntity _$PaymentRequestEntityFromJson(Map<String, dynamic> json) {
  return _PaymentRequestEntity.fromJson(json);
}

/// @nodoc
mixin _$PaymentRequestEntity {
  String get id => throw _privateConstructorUsedError;
  String get fromUserId => throw _privateConstructorUsedError;
  String get toUserId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  PaymentRequestType get type => throw _privateConstructorUsedError;
  PaymentRequestStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PaymentRequestEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentRequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentRequestEntityCopyWith<PaymentRequestEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentRequestEntityCopyWith<$Res> {
  factory $PaymentRequestEntityCopyWith(
    PaymentRequestEntity value,
    $Res Function(PaymentRequestEntity) then,
  ) = _$PaymentRequestEntityCopyWithImpl<$Res, PaymentRequestEntity>;
  @useResult
  $Res call({
    String id,
    String fromUserId,
    String toUserId,
    double amount,
    String? description,
    PaymentRequestType type,
    PaymentRequestStatus status,
    DateTime createdAt,
  });
}

/// @nodoc
class _$PaymentRequestEntityCopyWithImpl<
  $Res,
  $Val extends PaymentRequestEntity
>
    implements $PaymentRequestEntityCopyWith<$Res> {
  _$PaymentRequestEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentRequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? amount = null,
    Object? description = freezed,
    Object? type = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PaymentRequestType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PaymentRequestStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentRequestEntityImplCopyWith<$Res>
    implements $PaymentRequestEntityCopyWith<$Res> {
  factory _$$PaymentRequestEntityImplCopyWith(
    _$PaymentRequestEntityImpl value,
    $Res Function(_$PaymentRequestEntityImpl) then,
  ) = __$$PaymentRequestEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String fromUserId,
    String toUserId,
    double amount,
    String? description,
    PaymentRequestType type,
    PaymentRequestStatus status,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$PaymentRequestEntityImplCopyWithImpl<$Res>
    extends _$PaymentRequestEntityCopyWithImpl<$Res, _$PaymentRequestEntityImpl>
    implements _$$PaymentRequestEntityImplCopyWith<$Res> {
  __$$PaymentRequestEntityImplCopyWithImpl(
    _$PaymentRequestEntityImpl _value,
    $Res Function(_$PaymentRequestEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentRequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? amount = null,
    Object? description = freezed,
    Object? type = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PaymentRequestEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PaymentRequestType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PaymentRequestStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentRequestEntityImpl implements _PaymentRequestEntity {
  const _$PaymentRequestEntityImpl({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.description,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory _$PaymentRequestEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentRequestEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String fromUserId;
  @override
  final String toUserId;
  @override
  final double amount;
  @override
  final String? description;
  @override
  final PaymentRequestType type;
  @override
  final PaymentRequestStatus status;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'PaymentRequestEntity(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, amount: $amount, description: $description, type: $type, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentRequestEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fromUserId,
    toUserId,
    amount,
    description,
    type,
    status,
    createdAt,
  );

  /// Create a copy of PaymentRequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentRequestEntityImplCopyWith<_$PaymentRequestEntityImpl>
  get copyWith =>
      __$$PaymentRequestEntityImplCopyWithImpl<_$PaymentRequestEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentRequestEntityImplToJson(this);
  }
}

abstract class _PaymentRequestEntity implements PaymentRequestEntity {
  const factory _PaymentRequestEntity({
    required final String id,
    required final String fromUserId,
    required final String toUserId,
    required final double amount,
    final String? description,
    required final PaymentRequestType type,
    required final PaymentRequestStatus status,
    required final DateTime createdAt,
  }) = _$PaymentRequestEntityImpl;

  factory _PaymentRequestEntity.fromJson(Map<String, dynamic> json) =
      _$PaymentRequestEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get fromUserId;
  @override
  String get toUserId;
  @override
  double get amount;
  @override
  String? get description;
  @override
  PaymentRequestType get type;
  @override
  PaymentRequestStatus get status;
  @override
  DateTime get createdAt;

  /// Create a copy of PaymentRequestEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentRequestEntityImplCopyWith<_$PaymentRequestEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

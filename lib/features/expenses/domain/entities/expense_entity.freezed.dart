// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExpenseEntity _$ExpenseEntityFromJson(Map<String, dynamic> json) {
  return _ExpenseEntity.fromJson(json);
}

/// @nodoc
mixin _$ExpenseEntity {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  List<PaymentShare> get paidBy => throw _privateConstructorUsedError;
  List<ExpenseShare> get splitBetween => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;

  /// Serializes this ExpenseEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseEntityCopyWith<ExpenseEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseEntityCopyWith<$Res> {
  factory $ExpenseEntityCopyWith(
    ExpenseEntity value,
    $Res Function(ExpenseEntity) then,
  ) = _$ExpenseEntityCopyWithImpl<$Res, ExpenseEntity>;
  @useResult
  $Res call({
    String id,
    String groupId,
    String description,
    double amount,
    List<PaymentShare> paidBy,
    List<ExpenseShare> splitBetween,
    DateTime createdAt,
    String createdBy,
  });
}

/// @nodoc
class _$ExpenseEntityCopyWithImpl<$Res, $Val extends ExpenseEntity>
    implements $ExpenseEntityCopyWith<$Res> {
  _$ExpenseEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? description = null,
    Object? amount = null,
    Object? paidBy = null,
    Object? splitBetween = null,
    Object? createdAt = null,
    Object? createdBy = null,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            paidBy: null == paidBy
                ? _value.paidBy
                : paidBy // ignore: cast_nullable_to_non_nullable
                      as List<PaymentShare>,
            splitBetween: null == splitBetween
                ? _value.splitBetween
                : splitBetween // ignore: cast_nullable_to_non_nullable
                      as List<ExpenseShare>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseEntityImplCopyWith<$Res>
    implements $ExpenseEntityCopyWith<$Res> {
  factory _$$ExpenseEntityImplCopyWith(
    _$ExpenseEntityImpl value,
    $Res Function(_$ExpenseEntityImpl) then,
  ) = __$$ExpenseEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String groupId,
    String description,
    double amount,
    List<PaymentShare> paidBy,
    List<ExpenseShare> splitBetween,
    DateTime createdAt,
    String createdBy,
  });
}

/// @nodoc
class __$$ExpenseEntityImplCopyWithImpl<$Res>
    extends _$ExpenseEntityCopyWithImpl<$Res, _$ExpenseEntityImpl>
    implements _$$ExpenseEntityImplCopyWith<$Res> {
  __$$ExpenseEntityImplCopyWithImpl(
    _$ExpenseEntityImpl _value,
    $Res Function(_$ExpenseEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? description = null,
    Object? amount = null,
    Object? paidBy = null,
    Object? splitBetween = null,
    Object? createdAt = null,
    Object? createdBy = null,
  }) {
    return _then(
      _$ExpenseEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        paidBy: null == paidBy
            ? _value._paidBy
            : paidBy // ignore: cast_nullable_to_non_nullable
                  as List<PaymentShare>,
        splitBetween: null == splitBetween
            ? _value._splitBetween
            : splitBetween // ignore: cast_nullable_to_non_nullable
                  as List<ExpenseShare>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseEntityImpl implements _ExpenseEntity {
  const _$ExpenseEntityImpl({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required final List<PaymentShare> paidBy,
    required final List<ExpenseShare> splitBetween,
    required this.createdAt,
    required this.createdBy,
  }) : _paidBy = paidBy,
       _splitBetween = splitBetween;

  factory _$ExpenseEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String description;
  @override
  final double amount;
  final List<PaymentShare> _paidBy;
  @override
  List<PaymentShare> get paidBy {
    if (_paidBy is EqualUnmodifiableListView) return _paidBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paidBy);
  }

  final List<ExpenseShare> _splitBetween;
  @override
  List<ExpenseShare> get splitBetween {
    if (_splitBetween is EqualUnmodifiableListView) return _splitBetween;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splitBetween);
  }

  @override
  final DateTime createdAt;
  @override
  final String createdBy;

  @override
  String toString() {
    return 'ExpenseEntity(id: $id, groupId: $groupId, description: $description, amount: $amount, paidBy: $paidBy, splitBetween: $splitBetween, createdAt: $createdAt, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            const DeepCollectionEquality().equals(other._paidBy, _paidBy) &&
            const DeepCollectionEquality().equals(
              other._splitBetween,
              _splitBetween,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    groupId,
    description,
    amount,
    const DeepCollectionEquality().hash(_paidBy),
    const DeepCollectionEquality().hash(_splitBetween),
    createdAt,
    createdBy,
  );

  /// Create a copy of ExpenseEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseEntityImplCopyWith<_$ExpenseEntityImpl> get copyWith =>
      __$$ExpenseEntityImplCopyWithImpl<_$ExpenseEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseEntityImplToJson(this);
  }
}

abstract class _ExpenseEntity implements ExpenseEntity {
  const factory _ExpenseEntity({
    required final String id,
    required final String groupId,
    required final String description,
    required final double amount,
    required final List<PaymentShare> paidBy,
    required final List<ExpenseShare> splitBetween,
    required final DateTime createdAt,
    required final String createdBy,
  }) = _$ExpenseEntityImpl;

  factory _ExpenseEntity.fromJson(Map<String, dynamic> json) =
      _$ExpenseEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get description;
  @override
  double get amount;
  @override
  List<PaymentShare> get paidBy;
  @override
  List<ExpenseShare> get splitBetween;
  @override
  DateTime get createdAt;
  @override
  String get createdBy;

  /// Create a copy of ExpenseEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseEntityImplCopyWith<_$ExpenseEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentShare _$PaymentShareFromJson(Map<String, dynamic> json) {
  return _PaymentShare.fromJson(json);
}

/// @nodoc
mixin _$PaymentShare {
  String get userId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this PaymentShare to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentShare
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentShareCopyWith<PaymentShare> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentShareCopyWith<$Res> {
  factory $PaymentShareCopyWith(
    PaymentShare value,
    $Res Function(PaymentShare) then,
  ) = _$PaymentShareCopyWithImpl<$Res, PaymentShare>;
  @useResult
  $Res call({String userId, double amount});
}

/// @nodoc
class _$PaymentShareCopyWithImpl<$Res, $Val extends PaymentShare>
    implements $PaymentShareCopyWith<$Res> {
  _$PaymentShareCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentShare
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? amount = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentShareImplCopyWith<$Res>
    implements $PaymentShareCopyWith<$Res> {
  factory _$$PaymentShareImplCopyWith(
    _$PaymentShareImpl value,
    $Res Function(_$PaymentShareImpl) then,
  ) = __$$PaymentShareImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, double amount});
}

/// @nodoc
class __$$PaymentShareImplCopyWithImpl<$Res>
    extends _$PaymentShareCopyWithImpl<$Res, _$PaymentShareImpl>
    implements _$$PaymentShareImplCopyWith<$Res> {
  __$$PaymentShareImplCopyWithImpl(
    _$PaymentShareImpl _value,
    $Res Function(_$PaymentShareImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentShare
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? amount = null}) {
    return _then(
      _$PaymentShareImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentShareImpl implements _PaymentShare {
  const _$PaymentShareImpl({required this.userId, required this.amount});

  factory _$PaymentShareImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentShareImplFromJson(json);

  @override
  final String userId;
  @override
  final double amount;

  @override
  String toString() {
    return 'PaymentShare(userId: $userId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentShareImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, amount);

  /// Create a copy of PaymentShare
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentShareImplCopyWith<_$PaymentShareImpl> get copyWith =>
      __$$PaymentShareImplCopyWithImpl<_$PaymentShareImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentShareImplToJson(this);
  }
}

abstract class _PaymentShare implements PaymentShare {
  const factory _PaymentShare({
    required final String userId,
    required final double amount,
  }) = _$PaymentShareImpl;

  factory _PaymentShare.fromJson(Map<String, dynamic> json) =
      _$PaymentShareImpl.fromJson;

  @override
  String get userId;
  @override
  double get amount;

  /// Create a copy of PaymentShare
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentShareImplCopyWith<_$PaymentShareImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExpenseShare _$ExpenseShareFromJson(Map<String, dynamic> json) {
  return _ExpenseShare.fromJson(json);
}

/// @nodoc
mixin _$ExpenseShare {
  String get userId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this ExpenseShare to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseShare
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseShareCopyWith<ExpenseShare> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseShareCopyWith<$Res> {
  factory $ExpenseShareCopyWith(
    ExpenseShare value,
    $Res Function(ExpenseShare) then,
  ) = _$ExpenseShareCopyWithImpl<$Res, ExpenseShare>;
  @useResult
  $Res call({String userId, double amount});
}

/// @nodoc
class _$ExpenseShareCopyWithImpl<$Res, $Val extends ExpenseShare>
    implements $ExpenseShareCopyWith<$Res> {
  _$ExpenseShareCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseShare
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? amount = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseShareImplCopyWith<$Res>
    implements $ExpenseShareCopyWith<$Res> {
  factory _$$ExpenseShareImplCopyWith(
    _$ExpenseShareImpl value,
    $Res Function(_$ExpenseShareImpl) then,
  ) = __$$ExpenseShareImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, double amount});
}

/// @nodoc
class __$$ExpenseShareImplCopyWithImpl<$Res>
    extends _$ExpenseShareCopyWithImpl<$Res, _$ExpenseShareImpl>
    implements _$$ExpenseShareImplCopyWith<$Res> {
  __$$ExpenseShareImplCopyWithImpl(
    _$ExpenseShareImpl _value,
    $Res Function(_$ExpenseShareImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseShare
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? amount = null}) {
    return _then(
      _$ExpenseShareImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseShareImpl implements _ExpenseShare {
  const _$ExpenseShareImpl({required this.userId, required this.amount});

  factory _$ExpenseShareImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseShareImplFromJson(json);

  @override
  final String userId;
  @override
  final double amount;

  @override
  String toString() {
    return 'ExpenseShare(userId: $userId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseShareImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, amount);

  /// Create a copy of ExpenseShare
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseShareImplCopyWith<_$ExpenseShareImpl> get copyWith =>
      __$$ExpenseShareImplCopyWithImpl<_$ExpenseShareImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseShareImplToJson(this);
  }
}

abstract class _ExpenseShare implements ExpenseShare {
  const factory _ExpenseShare({
    required final String userId,
    required final double amount,
  }) = _$ExpenseShareImpl;

  factory _ExpenseShare.fromJson(Map<String, dynamic> json) =
      _$ExpenseShareImpl.fromJson;

  @override
  String get userId;
  @override
  double get amount;

  /// Create a copy of ExpenseShare
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseShareImplCopyWith<_$ExpenseShareImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

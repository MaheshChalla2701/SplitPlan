// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friendship_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FriendshipEntity _$FriendshipEntityFromJson(Map<String, dynamic> json) {
  return _FriendshipEntity.fromJson(json);
}

/// @nodoc
mixin _$FriendshipEntity {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get friendId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastClearedAt => throw _privateConstructorUsedError;
  bool get isAutoAccept => throw _privateConstructorUsedError;

  /// Serializes this FriendshipEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendshipEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendshipEntityCopyWith<FriendshipEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendshipEntityCopyWith<$Res> {
  factory $FriendshipEntityCopyWith(
    FriendshipEntity value,
    $Res Function(FriendshipEntity) then,
  ) = _$FriendshipEntityCopyWithImpl<$Res, FriendshipEntity>;
  @useResult
  $Res call({
    String id,
    String userId,
    String friendId,
    String status,
    DateTime createdAt,
    DateTime? lastClearedAt,
    bool isAutoAccept,
  });
}

/// @nodoc
class _$FriendshipEntityCopyWithImpl<$Res, $Val extends FriendshipEntity>
    implements $FriendshipEntityCopyWith<$Res> {
  _$FriendshipEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendshipEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? friendId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? lastClearedAt = freezed,
    Object? isAutoAccept = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            friendId: null == friendId
                ? _value.friendId
                : friendId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastClearedAt: freezed == lastClearedAt
                ? _value.lastClearedAt
                : lastClearedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isAutoAccept: null == isAutoAccept
                ? _value.isAutoAccept
                : isAutoAccept // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FriendshipEntityImplCopyWith<$Res>
    implements $FriendshipEntityCopyWith<$Res> {
  factory _$$FriendshipEntityImplCopyWith(
    _$FriendshipEntityImpl value,
    $Res Function(_$FriendshipEntityImpl) then,
  ) = __$$FriendshipEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String friendId,
    String status,
    DateTime createdAt,
    DateTime? lastClearedAt,
    bool isAutoAccept,
  });
}

/// @nodoc
class __$$FriendshipEntityImplCopyWithImpl<$Res>
    extends _$FriendshipEntityCopyWithImpl<$Res, _$FriendshipEntityImpl>
    implements _$$FriendshipEntityImplCopyWith<$Res> {
  __$$FriendshipEntityImplCopyWithImpl(
    _$FriendshipEntityImpl _value,
    $Res Function(_$FriendshipEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendshipEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? friendId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? lastClearedAt = freezed,
    Object? isAutoAccept = null,
  }) {
    return _then(
      _$FriendshipEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        friendId: null == friendId
            ? _value.friendId
            : friendId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastClearedAt: freezed == lastClearedAt
            ? _value.lastClearedAt
            : lastClearedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isAutoAccept: null == isAutoAccept
            ? _value.isAutoAccept
            : isAutoAccept // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendshipEntityImpl implements _FriendshipEntity {
  const _$FriendshipEntityImpl({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    this.lastClearedAt,
    this.isAutoAccept = false,
  });

  factory _$FriendshipEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendshipEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String friendId;
  @override
  final String status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastClearedAt;
  @override
  @JsonKey()
  final bool isAutoAccept;

  @override
  String toString() {
    return 'FriendshipEntity(id: $id, userId: $userId, friendId: $friendId, status: $status, createdAt: $createdAt, lastClearedAt: $lastClearedAt, isAutoAccept: $isAutoAccept)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendshipEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.friendId, friendId) ||
                other.friendId == friendId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastClearedAt, lastClearedAt) ||
                other.lastClearedAt == lastClearedAt) &&
            (identical(other.isAutoAccept, isAutoAccept) ||
                other.isAutoAccept == isAutoAccept));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    friendId,
    status,
    createdAt,
    lastClearedAt,
    isAutoAccept,
  );

  /// Create a copy of FriendshipEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendshipEntityImplCopyWith<_$FriendshipEntityImpl> get copyWith =>
      __$$FriendshipEntityImplCopyWithImpl<_$FriendshipEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendshipEntityImplToJson(this);
  }
}

abstract class _FriendshipEntity implements FriendshipEntity {
  const factory _FriendshipEntity({
    required final String id,
    required final String userId,
    required final String friendId,
    required final String status,
    required final DateTime createdAt,
    final DateTime? lastClearedAt,
    final bool isAutoAccept,
  }) = _$FriendshipEntityImpl;

  factory _FriendshipEntity.fromJson(Map<String, dynamic> json) =
      _$FriendshipEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get friendId;
  @override
  String get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get lastClearedAt;
  @override
  bool get isAutoAccept;

  /// Create a copy of FriendshipEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendshipEntityImplCopyWith<_$FriendshipEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

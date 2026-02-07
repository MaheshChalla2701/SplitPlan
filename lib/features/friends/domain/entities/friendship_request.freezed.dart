// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friendship_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FriendshipRequest _$FriendshipRequestFromJson(Map<String, dynamic> json) {
  return _FriendshipRequest.fromJson(json);
}

/// @nodoc
mixin _$FriendshipRequest {
  String get id => throw _privateConstructorUsedError;
  UserEntity get requester => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this FriendshipRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendshipRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendshipRequestCopyWith<FriendshipRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendshipRequestCopyWith<$Res> {
  factory $FriendshipRequestCopyWith(
    FriendshipRequest value,
    $Res Function(FriendshipRequest) then,
  ) = _$FriendshipRequestCopyWithImpl<$Res, FriendshipRequest>;
  @useResult
  $Res call({
    String id,
    UserEntity requester,
    DateTime createdAt,
    String status,
  });

  $UserEntityCopyWith<$Res> get requester;
}

/// @nodoc
class _$FriendshipRequestCopyWithImpl<$Res, $Val extends FriendshipRequest>
    implements $FriendshipRequestCopyWith<$Res> {
  _$FriendshipRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendshipRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requester = null,
    Object? createdAt = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            requester: null == requester
                ? _value.requester
                : requester // ignore: cast_nullable_to_non_nullable
                      as UserEntity,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of FriendshipRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<$Res> get requester {
    return $UserEntityCopyWith<$Res>(_value.requester, (value) {
      return _then(_value.copyWith(requester: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FriendshipRequestImplCopyWith<$Res>
    implements $FriendshipRequestCopyWith<$Res> {
  factory _$$FriendshipRequestImplCopyWith(
    _$FriendshipRequestImpl value,
    $Res Function(_$FriendshipRequestImpl) then,
  ) = __$$FriendshipRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    UserEntity requester,
    DateTime createdAt,
    String status,
  });

  @override
  $UserEntityCopyWith<$Res> get requester;
}

/// @nodoc
class __$$FriendshipRequestImplCopyWithImpl<$Res>
    extends _$FriendshipRequestCopyWithImpl<$Res, _$FriendshipRequestImpl>
    implements _$$FriendshipRequestImplCopyWith<$Res> {
  __$$FriendshipRequestImplCopyWithImpl(
    _$FriendshipRequestImpl _value,
    $Res Function(_$FriendshipRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendshipRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requester = null,
    Object? createdAt = null,
    Object? status = null,
  }) {
    return _then(
      _$FriendshipRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        requester: null == requester
            ? _value.requester
            : requester // ignore: cast_nullable_to_non_nullable
                  as UserEntity,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendshipRequestImpl implements _FriendshipRequest {
  const _$FriendshipRequestImpl({
    required this.id,
    required this.requester,
    required this.createdAt,
    required this.status,
  });

  factory _$FriendshipRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendshipRequestImplFromJson(json);

  @override
  final String id;
  @override
  final UserEntity requester;
  @override
  final DateTime createdAt;
  @override
  final String status;

  @override
  String toString() {
    return 'FriendshipRequest(id: $id, requester: $requester, createdAt: $createdAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendshipRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requester, requester) ||
                other.requester == requester) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, requester, createdAt, status);

  /// Create a copy of FriendshipRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendshipRequestImplCopyWith<_$FriendshipRequestImpl> get copyWith =>
      __$$FriendshipRequestImplCopyWithImpl<_$FriendshipRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendshipRequestImplToJson(this);
  }
}

abstract class _FriendshipRequest implements FriendshipRequest {
  const factory _FriendshipRequest({
    required final String id,
    required final UserEntity requester,
    required final DateTime createdAt,
    required final String status,
  }) = _$FriendshipRequestImpl;

  factory _FriendshipRequest.fromJson(Map<String, dynamic> json) =
      _$FriendshipRequestImpl.fromJson;

  @override
  String get id;
  @override
  UserEntity get requester;
  @override
  DateTime get createdAt;
  @override
  String get status;

  /// Create a copy of FriendshipRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendshipRequestImplCopyWith<_$FriendshipRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) {
  return _UserEntity.fromJson(json);
}

/// @nodoc
mixin _$UserEntity {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get upiId => throw _privateConstructorUsedError;
  bool get isSearchable => throw _privateConstructorUsedError;
  bool get isManual => throw _privateConstructorUsedError;
  String? get ownerId => throw _privateConstructorUsedError;
  List<String> get friends => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserEntityCopyWith<UserEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserEntityCopyWith<$Res> {
  factory $UserEntityCopyWith(
    UserEntity value,
    $Res Function(UserEntity) then,
  ) = _$UserEntityCopyWithImpl<$Res, UserEntity>;
  @useResult
  $Res call({
    String id,
    String email,
    String name,
    String username,
    String? phoneNumber,
    String? avatarUrl,
    String? upiId,
    bool isSearchable,
    bool isManual,
    String? ownerId,
    List<String> friends,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserEntityCopyWithImpl<$Res, $Val extends UserEntity>
    implements $UserEntityCopyWith<$Res> {
  _$UserEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? username = null,
    Object? phoneNumber = freezed,
    Object? avatarUrl = freezed,
    Object? upiId = freezed,
    Object? isSearchable = null,
    Object? isManual = null,
    Object? ownerId = freezed,
    Object? friends = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            upiId: freezed == upiId
                ? _value.upiId
                : upiId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isSearchable: null == isSearchable
                ? _value.isSearchable
                : isSearchable // ignore: cast_nullable_to_non_nullable
                      as bool,
            isManual: null == isManual
                ? _value.isManual
                : isManual // ignore: cast_nullable_to_non_nullable
                      as bool,
            ownerId: freezed == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            friends: null == friends
                ? _value.friends
                : friends // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserEntityImplCopyWith<$Res>
    implements $UserEntityCopyWith<$Res> {
  factory _$$UserEntityImplCopyWith(
    _$UserEntityImpl value,
    $Res Function(_$UserEntityImpl) then,
  ) = __$$UserEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String name,
    String username,
    String? phoneNumber,
    String? avatarUrl,
    String? upiId,
    bool isSearchable,
    bool isManual,
    String? ownerId,
    List<String> friends,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserEntityImplCopyWithImpl<$Res>
    extends _$UserEntityCopyWithImpl<$Res, _$UserEntityImpl>
    implements _$$UserEntityImplCopyWith<$Res> {
  __$$UserEntityImplCopyWithImpl(
    _$UserEntityImpl _value,
    $Res Function(_$UserEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? username = null,
    Object? phoneNumber = freezed,
    Object? avatarUrl = freezed,
    Object? upiId = freezed,
    Object? isSearchable = null,
    Object? isManual = null,
    Object? ownerId = freezed,
    Object? friends = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        upiId: freezed == upiId
            ? _value.upiId
            : upiId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isSearchable: null == isSearchable
            ? _value.isSearchable
            : isSearchable // ignore: cast_nullable_to_non_nullable
                  as bool,
        isManual: null == isManual
            ? _value.isManual
            : isManual // ignore: cast_nullable_to_non_nullable
                  as bool,
        ownerId: freezed == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        friends: null == friends
            ? _value._friends
            : friends // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserEntityImpl implements _UserEntity {
  const _$UserEntityImpl({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.phoneNumber,
    this.avatarUrl,
    this.upiId,
    this.isSearchable = true,
    this.isManual = false,
    this.ownerId,
    final List<String> friends = const [],
    required this.createdAt,
    this.updatedAt,
  }) : _friends = friends;

  factory _$UserEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  final String username;
  @override
  final String? phoneNumber;
  @override
  final String? avatarUrl;
  @override
  final String? upiId;
  @override
  @JsonKey()
  final bool isSearchable;
  @override
  @JsonKey()
  final bool isManual;
  @override
  final String? ownerId;
  final List<String> _friends;
  @override
  @JsonKey()
  List<String> get friends {
    if (_friends is EqualUnmodifiableListView) return _friends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friends);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name, username: $username, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, upiId: $upiId, isSearchable: $isSearchable, isManual: $isManual, ownerId: $ownerId, friends: $friends, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.upiId, upiId) || other.upiId == upiId) &&
            (identical(other.isSearchable, isSearchable) ||
                other.isSearchable == isSearchable) &&
            (identical(other.isManual, isManual) ||
                other.isManual == isManual) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            const DeepCollectionEquality().equals(other._friends, _friends) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    name,
    username,
    phoneNumber,
    avatarUrl,
    upiId,
    isSearchable,
    isManual,
    ownerId,
    const DeepCollectionEquality().hash(_friends),
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserEntityImplCopyWith<_$UserEntityImpl> get copyWith =>
      __$$UserEntityImplCopyWithImpl<_$UserEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserEntityImplToJson(this);
  }
}

abstract class _UserEntity implements UserEntity {
  const factory _UserEntity({
    required final String id,
    required final String email,
    required final String name,
    required final String username,
    final String? phoneNumber,
    final String? avatarUrl,
    final String? upiId,
    final bool isSearchable,
    final bool isManual,
    final String? ownerId,
    final List<String> friends,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$UserEntityImpl;

  factory _UserEntity.fromJson(Map<String, dynamic> json) =
      _$UserEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  String get username;
  @override
  String? get phoneNumber;
  @override
  String? get avatarUrl;
  @override
  String? get upiId;
  @override
  bool get isSearchable;
  @override
  bool get isManual;
  @override
  String? get ownerId;
  @override
  List<String> get friends;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserEntityImplCopyWith<_$UserEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

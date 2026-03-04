// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_day_card_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TripDayCardEntity _$TripDayCardEntityFromJson(Map<String, dynamic> json) {
  return _TripDayCardEntity.fromJson(json);
}

/// @nodoc
mixin _$TripDayCardEntity {
  String get id => throw _privateConstructorUsedError;
  String get tripPlanId => throw _privateConstructorUsedError;
  int get dayNumber => throw _privateConstructorUsedError;
  List<String> get notes => throw _privateConstructorUsedError;

  /// Serializes this TripDayCardEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripDayCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripDayCardEntityCopyWith<TripDayCardEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripDayCardEntityCopyWith<$Res> {
  factory $TripDayCardEntityCopyWith(
    TripDayCardEntity value,
    $Res Function(TripDayCardEntity) then,
  ) = _$TripDayCardEntityCopyWithImpl<$Res, TripDayCardEntity>;
  @useResult
  $Res call({String id, String tripPlanId, int dayNumber, List<String> notes});
}

/// @nodoc
class _$TripDayCardEntityCopyWithImpl<$Res, $Val extends TripDayCardEntity>
    implements $TripDayCardEntityCopyWith<$Res> {
  _$TripDayCardEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripDayCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripPlanId = null,
    Object? dayNumber = null,
    Object? notes = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tripPlanId: null == tripPlanId
                ? _value.tripPlanId
                : tripPlanId // ignore: cast_nullable_to_non_nullable
                      as String,
            dayNumber: null == dayNumber
                ? _value.dayNumber
                : dayNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TripDayCardEntityImplCopyWith<$Res>
    implements $TripDayCardEntityCopyWith<$Res> {
  factory _$$TripDayCardEntityImplCopyWith(
    _$TripDayCardEntityImpl value,
    $Res Function(_$TripDayCardEntityImpl) then,
  ) = __$$TripDayCardEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String tripPlanId, int dayNumber, List<String> notes});
}

/// @nodoc
class __$$TripDayCardEntityImplCopyWithImpl<$Res>
    extends _$TripDayCardEntityCopyWithImpl<$Res, _$TripDayCardEntityImpl>
    implements _$$TripDayCardEntityImplCopyWith<$Res> {
  __$$TripDayCardEntityImplCopyWithImpl(
    _$TripDayCardEntityImpl _value,
    $Res Function(_$TripDayCardEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TripDayCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripPlanId = null,
    Object? dayNumber = null,
    Object? notes = null,
  }) {
    return _then(
      _$TripDayCardEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tripPlanId: null == tripPlanId
            ? _value.tripPlanId
            : tripPlanId // ignore: cast_nullable_to_non_nullable
                  as String,
        dayNumber: null == dayNumber
            ? _value.dayNumber
            : dayNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: null == notes
            ? _value._notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TripDayCardEntityImpl implements _TripDayCardEntity {
  const _$TripDayCardEntityImpl({
    required this.id,
    required this.tripPlanId,
    required this.dayNumber,
    final List<String> notes = const [],
  }) : _notes = notes;

  factory _$TripDayCardEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripDayCardEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String tripPlanId;
  @override
  final int dayNumber;
  final List<String> _notes;
  @override
  @JsonKey()
  List<String> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  String toString() {
    return 'TripDayCardEntity(id: $id, tripPlanId: $tripPlanId, dayNumber: $dayNumber, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripDayCardEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripPlanId, tripPlanId) ||
                other.tripPlanId == tripPlanId) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tripPlanId,
    dayNumber,
    const DeepCollectionEquality().hash(_notes),
  );

  /// Create a copy of TripDayCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripDayCardEntityImplCopyWith<_$TripDayCardEntityImpl> get copyWith =>
      __$$TripDayCardEntityImplCopyWithImpl<_$TripDayCardEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TripDayCardEntityImplToJson(this);
  }
}

abstract class _TripDayCardEntity implements TripDayCardEntity {
  const factory _TripDayCardEntity({
    required final String id,
    required final String tripPlanId,
    required final int dayNumber,
    final List<String> notes,
  }) = _$TripDayCardEntityImpl;

  factory _TripDayCardEntity.fromJson(Map<String, dynamic> json) =
      _$TripDayCardEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get tripPlanId;
  @override
  int get dayNumber;
  @override
  List<String> get notes;

  /// Create a copy of TripDayCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripDayCardEntityImplCopyWith<_$TripDayCardEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

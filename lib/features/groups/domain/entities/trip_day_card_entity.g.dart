// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_day_card_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripDayCardEntityImpl _$$TripDayCardEntityImplFromJson(
  Map<String, dynamic> json,
) => _$TripDayCardEntityImpl(
  id: json['id'] as String,
  tripPlanId: json['tripPlanId'] as String,
  dayNumber: (json['dayNumber'] as num).toInt(),
  notes:
      (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$TripDayCardEntityImplToJson(
  _$TripDayCardEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'tripPlanId': instance.tripPlanId,
  'dayNumber': instance.dayNumber,
  'notes': instance.notes,
};

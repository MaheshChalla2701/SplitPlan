// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_plan_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripPlanEntityImpl _$$TripPlanEntityImplFromJson(Map<String, dynamic> json) =>
    _$TripPlanEntityImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TripPlanEntityImplToJson(
  _$TripPlanEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'name': instance.name,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'estimatedBudget': instance.estimatedBudget,
};

import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_plan_entity.freezed.dart';
part 'trip_plan_entity.g.dart';

@freezed
class TripPlanEntity with _$TripPlanEntity {
  const factory TripPlanEntity({
    required String id,
    required String groupId,
    required String name,
    required String createdBy,
    required DateTime createdAt,
    DateTime? startDate,
    DateTime? endDate,
    double? estimatedBudget,
  }) = _TripPlanEntity;

  factory TripPlanEntity.fromJson(Map<String, dynamic> json) =>
      _$TripPlanEntityFromJson(json);
}

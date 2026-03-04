import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_day_card_entity.freezed.dart';
part 'trip_day_card_entity.g.dart';

@freezed
class TripDayCardEntity with _$TripDayCardEntity {
  const factory TripDayCardEntity({
    required String id,
    required String tripPlanId,
    required int dayNumber,
    @Default([]) List<String> notes,
  }) = _TripDayCardEntity;

  factory TripDayCardEntity.fromJson(Map<String, dynamic> json) =>
      _$TripDayCardEntityFromJson(json);
}

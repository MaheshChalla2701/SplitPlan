import '../entities/trip_day_card_entity.dart';
import '../entities/trip_plan_entity.dart';

abstract class TripPlanRepository {
  Stream<List<TripPlanEntity>> watchTripPlans(String groupId);
  Future<TripPlanEntity> createTripPlan({
    required String groupId,
    required String name,
    required String createdBy,
    DateTime? startDate,
    DateTime? endDate,
    double? estimatedBudget,
  });
  Future<void> updateTripPlan(TripPlanEntity plan);
  Future<void> deleteTripPlan(String groupId, String tripPlanId);
  Future<void> reorderDayCards(
    String tripPlanId,
    List<TripDayCardEntity> cards,
  );

  Stream<List<TripDayCardEntity>> watchDayCards(String tripPlanId);
  Future<TripDayCardEntity> addDayCard({
    required String tripPlanId,
    required int dayNumber,
  });
  Future<void> updateDayCard(TripDayCardEntity card);
  Future<void> deleteDayCard(String tripPlanId, String cardId);
}

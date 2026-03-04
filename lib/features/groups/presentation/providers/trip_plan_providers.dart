import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/trip_plan_repository_impl.dart';
import '../../domain/entities/trip_day_card_entity.dart';
import '../../domain/entities/trip_plan_entity.dart';
import '../../domain/repositories/trip_plan_repository.dart';

part 'trip_plan_providers.g.dart';

@riverpod
TripPlanRepository tripPlanRepository(Ref ref) {
  return TripPlanRepositoryImpl(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<TripPlanEntity>> groupTripPlans(Ref ref, String groupId) {
  return ref.watch(tripPlanRepositoryProvider).watchTripPlans(groupId);
}

@riverpod
Stream<List<TripDayCardEntity>> tripDayCards(Ref ref, String tripPlanId) {
  return ref.watch(tripPlanRepositoryProvider).watchDayCards(tripPlanId);
}

@riverpod
class TripPlanController extends _$TripPlanController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<TripPlanEntity?> createPlan({
    required String groupId,
    required String name,
    DateTime? startDate,
    DateTime? endDate,
    double? estimatedBudget,
  }) async {
    state = const AsyncValue.loading();
    TripPlanEntity? result;
    state = await AsyncValue.guard(() async {
      final userId = ref.read(authStateProvider).value?.id ?? '';
      result = await ref
          .read(tripPlanRepositoryProvider)
          .createTripPlan(
            groupId: groupId,
            name: name,
            createdBy: userId,
            startDate: startDate,
            endDate: endDate,
            estimatedBudget: estimatedBudget,
          );
      ref.invalidate(groupTripPlansProvider(groupId));
    });
    return result;
  }

  Future<void> updatePlan(TripPlanEntity plan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(tripPlanRepositoryProvider).updateTripPlan(plan),
    );
  }

  Future<void> deletePlan(String groupId, String tripPlanId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(tripPlanRepositoryProvider)
          .deleteTripPlan(groupId, tripPlanId);
      ref.invalidate(groupTripPlansProvider(groupId));
    });
  }

  Future<void> reorderDays(
    String tripPlanId,
    List<TripDayCardEntity> cards,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(tripPlanRepositoryProvider)
          .reorderDayCards(tripPlanId, cards);
      ref.invalidate(tripDayCardsProvider(tripPlanId));
    });
  }

  Future<TripDayCardEntity?> addDayCard({
    required String tripPlanId,
    required int dayNumber,
  }) async {
    state = const AsyncValue.loading();
    TripDayCardEntity? result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(tripPlanRepositoryProvider)
          .addDayCard(tripPlanId: tripPlanId, dayNumber: dayNumber);
      ref.invalidate(tripDayCardsProvider(tripPlanId));
    });
    return result;
  }

  Future<void> updateDayCard(TripDayCardEntity card) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(tripPlanRepositoryProvider).updateDayCard(card);
      ref.invalidate(tripDayCardsProvider(card.tripPlanId));
    });
  }

  Future<void> deleteDayCard(String tripPlanId, String cardId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(tripPlanRepositoryProvider)
          .deleteDayCard(tripPlanId, cardId);
      ref.invalidate(tripDayCardsProvider(tripPlanId));
    });
  }
}

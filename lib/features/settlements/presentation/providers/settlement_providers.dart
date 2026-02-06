import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/settlement_repository_impl.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';

part 'settlement_providers.g.dart';

@riverpod
SettlementRepository settlementRepository(Ref ref) {
  return SettlementRepositoryImpl(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<SettlementEntity>> groupSettlements(Ref ref, String groupId) {
  return ref.watch(settlementRepositoryProvider).watchGroupSettlements(groupId);
}

@riverpod
class SettlementController extends _$SettlementController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> recordSettlement({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final settlement = SettlementEntity(
        id: '', // Repo will assign
        groupId: groupId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
        settledAt: DateTime.now(),
        settledBy: user.id,
      );

      await ref.read(settlementRepositoryProvider).recordSettlement(settlement);
    });
  }
}

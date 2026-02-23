import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/services/expense_calculator.dart';

import '../../../groups/presentation/providers/group_providers.dart';
import '../../../settlements/presentation/providers/settlement_providers.dart';

part 'expense_providers.g.dart';

@riverpod
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepositoryImpl(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<ExpenseEntity>> groupExpenses(Ref ref, String groupId) {
  return ref.watch(expenseRepositoryProvider).watchGroupExpenses(groupId);
}

@riverpod
class ExpenseController extends _$ExpenseController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> addExpense({
    required String groupId,
    required String description,
    required double amount,
    required String payerId,
    required List<String> splitBetweenIds,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final paymentShares = [PaymentShare(userId: payerId, amount: amount)];
      final splitAmount = amount / splitBetweenIds.length;
      final expenseShares = splitBetweenIds.map((id) {
        return ExpenseShare(userId: id, amount: splitAmount);
      }).toList();

      final expense = ExpenseEntity(
        id: '',
        groupId: groupId,
        description: description,
        amount: amount,
        paidBy: paymentShares,
        splitBetween: expenseShares,
        createdAt: DateTime.now(),
        createdBy: user.id,
      );

      await ref.read(expenseRepositoryProvider).addExpense(expense);
    });
  }

  /// Saves an expense where each member's share is already computed.
  /// Used by the split-mode UI (by amount / shares / percentage).
  Future<void> addExpenseWithShares({
    required String groupId,
    required String description,
    required double amount,
    required String payerId,
    required Map<String, double> splitShares, // userId -> amount owed
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final paymentShares = [PaymentShare(userId: payerId, amount: amount)];

      final expenseShares = splitShares.entries
          .map((e) => ExpenseShare(userId: e.key, amount: e.value))
          .toList();

      final expense = ExpenseEntity(
        id: '',
        groupId: groupId,
        description: description,
        amount: amount,
        paidBy: paymentShares,
        splitBetween: expenseShares,
        createdAt: DateTime.now(),
        createdBy: user.id,
      );

      await ref.read(expenseRepositoryProvider).addExpense(expense);
    });
  }
}

// Balances Provider — reactive; re-runs whenever expenses or settlements change
@riverpod
Future<Map<String, double>> groupBalances(Ref ref, String groupId) async {
  // Watching these stream providers means this Future re-evaluates on every emission
  final expenses = await ref.watch(groupExpensesProvider(groupId).future);
  final settlements = await ref.watch(groupSettlementsProvider(groupId).future);

  // Fetch the group membership to get all member IDs
  final group = await ref.watch(groupRepositoryProvider).getGroup(groupId);

  final calculator = ExpenseCalculator();
  final balancesMap = calculator.calculateBalances(
    expenses,
    settlements,
    group.memberIds,
  );

  return balancesMap.map((key, value) => MapEntry(key, value.netBalance));
}

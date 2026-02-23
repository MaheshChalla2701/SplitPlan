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
        acceptedBy: [user.id],
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
        acceptedBy: [user.id],
        createdAt: DateTime.now(),
        createdBy: user.id,
      );

      await ref.read(expenseRepositoryProvider).addExpense(expense);
    });
  }

  /// Updates an existing expense where each member's share is already computed.
  Future<void> updateExpenseWithShares({
    required String expenseId,
    required String groupId,
    required String description,
    required double amount,
    required String payerId,
    required Map<String, double> splitShares, // userId -> amount owed
    required List<String> originalAcceptedBy, // Preserve original accepted list
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final paymentShares = [PaymentShare(userId: payerId, amount: amount)];

      final expenseShares = splitShares.entries
          .map((e) => ExpenseShare(userId: e.key, amount: e.value))
          .toList();

      // If the creator edits the expense, we usually reset approvals except for them or preserve them.
      // Let's reset the acceptedBy list to just the person who edited it (the current user),
      // or optionally keep the ones who still agree. Safest is to reset approvals on edit.
      final expense = ExpenseEntity(
        id: expenseId,
        groupId: groupId,
        description: description,
        amount: amount,
        paidBy: paymentShares,
        splitBetween: expenseShares,
        acceptedBy: [user.id],
        createdAt:
            DateTime.now(), // Ignored by update usually, or keep original if needed.
        createdBy: user.id,
      );

      await ref.read(expenseRepositoryProvider).updateExpense(expense);
    });
  }

  Future<void> acceptExpense(String expenseId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');
      await ref
          .read(expenseRepositoryProvider)
          .acceptExpense(expenseId, user.id);
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).deleteExpense(expenseId);
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

  // Filter to only APPROVED expenses:
  // An expense is approved if everyone who is involved (paidBy or splitBetween)
  // has their userId in the acceptedBy list.
  final approvedExpenses = expenses.where((expense) {
    final involvedIds = <String>{};
    for (var p in expense.paidBy) {
      if (p.amount > 0) involvedIds.add(p.userId);
    }
    for (var s in expense.splitBetween) {
      if (s.amount > 0) involvedIds.add(s.userId);
    }
    return involvedIds.every((id) => expense.acceptedBy.contains(id));
  }).toList();

  final calculator = ExpenseCalculator();
  final balancesMap = calculator.calculateBalances(
    approvedExpenses,
    settlements,
    group.memberIds,
  );

  return balancesMap.map((key, value) => MapEntry(key, value.netBalance));
}

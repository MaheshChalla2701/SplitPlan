import '../entities/expense_entity.dart';
import '../../../settlements/domain/entities/settlement_entity.dart';

class Balance {
  final String userId;
  final Map<String, double> owes; // userId -> amount user owes to them
  final Map<String, double> owedBy; // userId -> amount they owe to user
  final double netBalance; // Positive = owed, Negative = owes

  Balance({
    required this.userId,
    required this.owes,
    required this.owedBy,
    required this.netBalance,
  });
}

class SimplifiedDebt {
  final String fromUserId;
  final String toUserId;
  final double amount;

  SimplifiedDebt({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });
}

class ExpenseCalculator {
  // Calculate balances from list of expenses and settlements
  Map<String, Balance> calculateBalances(
    List<ExpenseEntity> expenses,
    List<SettlementEntity> settlements,
    List<String> memberIds,
  ) {
    // 1. Initialize net balances for all members
    final Map<String, double> netBalances = {for (var id in memberIds) id: 0.0};

    // 2. Process Expenses
    for (final expense in expenses) {
      // Add amount paid by users (creditors)
      for (final payment in expense.paidBy) {
        netBalances[payment.userId] =
            (netBalances[payment.userId] ?? 0) + payment.amount;
      }

      // Subtract amount owed by users (debtors)
      for (final split in expense.splitBetween) {
        netBalances[split.userId] =
            (netBalances[split.userId] ?? 0) - split.amount;
      }
    }

    // 3. Process Settlements (payments between users)
    for (final settlement in settlements) {
      // Payer (fromUserId) pays money, so their "debt" decreases (or credit increases?)
      // Wait, net balance: Positive = owed money (credit), Negative = owes money (debt).
      // If A pays B 100:
      // A was -100 (debt), now becomes 0. A gave money.
      // B was +100 (credit), now becomes 0. B received money.

      // So A's balance INCREASES (gets less negative).
      netBalances[settlement.fromUserId] =
          (netBalances[settlement.fromUserId] ?? 0) + settlement.amount;

      // B's balance DECREASES (gets less positive).
      netBalances[settlement.toUserId] =
          (netBalances[settlement.toUserId] ?? 0) - settlement.amount;
    }

    // 4. Create Balance objects for each user
    // Note: The 'owes' and 'owedBy' maps in Balance object are complex to calculate individually
    // without simplifying debts globally first.
    // Usually, we just present the simplified debts or the net balance.
    // However, the Balance object signature I proposed has owes/owedBy.
    // For MVP, netBalance is the most critical. owes/owedBy can be derived from simplified debts.

    // Let's simplify debts first to populate owes/owedBy properly based on optimal settlement.
    final simplifiedDebts = simplifyDebts(netBalances);

    final Map<String, Balance> result = {};

    for (final userId in memberIds) {
      final owes = <String, double>{};
      final owedBy = <String, double>{};

      for (final debt in simplifiedDebts) {
        if (debt.fromUserId == userId) {
          owes[debt.toUserId] = debt.amount;
        }
        if (debt.toUserId == userId) {
          owedBy[debt.fromUserId] = debt.amount;
        }
      }

      result[userId] = Balance(
        userId: userId,
        owes: owes,
        owedBy: owedBy,
        netBalance: netBalances[userId] ?? 0.0,
      );
    }

    return result;
  }

  // Simplify debts using greedy algorithm
  List<SimplifiedDebt> simplifyDebts(Map<String, double> netBalances) {
    final List<SimplifiedDebt> debts = [];

    // Separate into debtors (negative balance) and creditors (positive balance)
    final debtors = netBalances.entries
        .where((e) => e.value < -0.01) // Use small epsilon for float comparison
        .map((e) => MapEntry(e.key, e.value)) // Keep negative value
        .toList();

    final creditors = netBalances.entries
        .where((e) => e.value > 0.01)
        .map((e) => MapEntry(e.key, e.value))
        .toList();

    // Sort to handle largest amounts first (greedy approach)
    debtors.sort(
      (a, b) => a.value.compareTo(b.value),
    ); // Ascending (most negative first)
    creditors.sort(
      (a, b) => b.value.compareTo(a.value),
    ); // Descending (most positive first)

    int debtorIndex = 0;
    int creditorIndex = 0;

    while (debtorIndex < debtors.length && creditorIndex < creditors.length) {
      final debtor = debtors[debtorIndex];
      final creditor = creditors[creditorIndex];

      final amountToSettle = (-debtor.value).clamp(0.0, creditor.value);

      if (amountToSettle > 0.01) {
        debts.add(
          SimplifiedDebt(
            fromUserId: debtor.key,
            toUserId: creditor.key,
            amount: double.parse(amountToSettle.toStringAsFixed(2)),
          ),
        );
      }

      // Update remaining amounts
      final remainingDebt = debtor.value + amountToSettle;
      final remainingCredit = creditor.value - amountToSettle;

      // Update the entries in the lists (hacky but works for this algorithm)
      // Actually we should just consume them.

      if (remainingDebt.abs() < 0.01) {
        debtorIndex++; // Debtor settled
      } else {
        debtors[debtorIndex] = MapEntry(debtor.key, remainingDebt);
      }

      if (remainingCredit < 0.01) {
        creditorIndex++; // Creditor settled
      } else {
        creditors[creditorIndex] = MapEntry(creditor.key, remainingCredit);
      }
    }

    return debts;
  }
}

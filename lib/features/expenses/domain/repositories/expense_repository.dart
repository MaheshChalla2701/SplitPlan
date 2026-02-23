import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<ExpenseEntity> addExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String expenseId);
  Future<void> acceptExpense(String expenseId, String userId);
  Future<List<ExpenseEntity>> getGroupExpenses(String groupId);
  Stream<List<ExpenseEntity>> watchGroupExpenses(String groupId);
}

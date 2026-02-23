import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore _firestore;

  ExpenseRepositoryImpl(this._firestore);

  @override
  Future<ExpenseEntity> addExpense(ExpenseEntity expense) async {
    final docRef = _firestore.collection('expenses').doc();
    final now = DateTime.now();

    final newExpense = expense.copyWith(id: docRef.id, createdAt: now);

    await docRef.set({
      'groupId': newExpense.groupId,
      'description': newExpense.description,
      'amount': newExpense.amount,
      'paidBy': newExpense.paidBy.map((e) => e.toJson()).toList(),
      'splitBetween': newExpense.splitBetween.map((e) => e.toJson()).toList(),
      'acceptedBy': newExpense.acceptedBy,
      'createdAt': Timestamp.fromDate(now),
      'createdBy': newExpense.createdBy,
    });

    return newExpense;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }

  @override
  Future<void> acceptExpense(String expenseId, String userId) async {
    await _firestore.collection('expenses').doc(expenseId).update({
      'acceptedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<List<ExpenseEntity>> getGroupExpenses(String groupId) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .get();

    final expenses = snapshot.docs.map((doc) {
      final data = doc.data();
      return ExpenseEntity.fromJson({
        'id': doc.id,
        ...data,
        'acceptedBy': List<String>.from(data['acceptedBy'] ?? []),
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    }).toList();

    // Sort in Dart to avoid needing a composite Firestore index
    expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return expenses;
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    await _firestore.collection('expenses').doc(expense.id).update({
      'description': expense.description,
      'amount': expense.amount,
      'paidBy': expense.paidBy.map((e) => e.toJson()).toList(),
      'splitBetween': expense.splitBetween.map((e) => e.toJson()).toList(),
      'acceptedBy': expense.acceptedBy,
    });
  }

  @override
  Stream<List<ExpenseEntity>> watchGroupExpenses(String groupId) {
    return _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) {
          final expenses = snapshot.docs.map((doc) {
            final data = doc.data();
            return ExpenseEntity.fromJson({
              'id': doc.id,
              ...data,
              'acceptedBy': List<String>.from(data['acceptedBy'] ?? []),
              'createdAt': (data['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
            });
          }).toList();
          // Sort in Dart to avoid needing a composite Firestore index
          expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return expenses;
        });
  }
}

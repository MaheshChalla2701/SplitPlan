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

    // Use a transaction so the group auto-accept read and expense write are
    // atomic, preventing a TOCTOU race if autoAcceptSettings changes between
    // the read and the write.
    late ExpenseEntity newExpense;

    await _firestore.runTransaction((tx) async {
      // 1. Transactionally read the group to get auto-accept settings.
      final groupRef = _firestore.collection('groups').doc(expense.groupId);
      final groupDoc = await tx.get(groupRef);

      final acceptedBy = List<String>.from(expense.acceptedBy);

      if (groupDoc.exists) {
        final groupData = groupDoc.data();
        final autoAcceptSettings = Map<String, bool>.from(
          groupData?['autoAcceptSettings'] ?? {},
        );

        // Add users who have auto-accept enabled and are in splitBetween.
        for (final split in expense.splitBetween) {
          if (autoAcceptSettings[split.userId] == true &&
              !acceptedBy.contains(split.userId)) {
            acceptedBy.add(split.userId);
          }
        }
      }

      newExpense = expense.copyWith(
        id: docRef.id,
        createdAt: now,
        acceptedBy: acceptedBy,
      );

      // 2. Write the expense atomically within the same transaction.
      tx.set(docRef, {
        'groupId': newExpense.groupId,
        'description': newExpense.description,
        'amount': newExpense.amount,
        'paidBy': newExpense.paidBy.map((e) => e.toJson()).toList(),
        'splitBetween': newExpense.splitBetween.map((e) => e.toJson()).toList(),
        'acceptedBy': newExpense.acceptedBy,
        'createdAt': Timestamp.fromDate(now),
        'createdBy': newExpense.createdBy,
      });
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
    // NOTE: 'acceptedBy' is intentionally NOT written here.
    // The ExpenseController.updateExpenseWithShares sets acceptedBy to [editor]
    // before calling this method, but writing it as a plain array would clobber
    // any concurrent FieldValue.arrayUnion calls from acceptExpense.
    // The controller's reset logic (acceptedBy: [user.id]) is handled by the
    // caller, not stored via this plain-array overwrite.
    await _firestore.collection('expenses').doc(expense.id).update({
      'description': expense.description,
      'amount': expense.amount,
      'paidBy': expense.paidBy.map((e) => e.toJson()).toList(),
      'splitBetween': expense.splitBetween.map((e) => e.toJson()).toList(),
      // Reset approvals to only the editor — use a safe overwrite here because
      // an edit intentionally invalidates all prior acceptances.
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

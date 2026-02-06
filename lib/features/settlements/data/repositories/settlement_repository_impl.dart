import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final FirebaseFirestore _firestore;

  SettlementRepositoryImpl(this._firestore);

  @override
  Future<List<SettlementEntity>> getGroupSettlements(String groupId) async {
    final snapshot = await _firestore
        .collection('settlements')
        .where('groupId', isEqualTo: groupId)
        .orderBy('settledAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SettlementEntity.fromJson({
        'id': doc.id,
        ...data,
        'settledAt': (data['settledAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    }).toList();
  }

  @override
  Future<SettlementEntity> recordSettlement(SettlementEntity settlement) async {
    final docRef = _firestore.collection('settlements').doc();
    final now = DateTime.now();

    final newSettlement = settlement.copyWith(id: docRef.id, settledAt: now);

    await docRef.set({
      'groupId': newSettlement.groupId,
      'fromUserId': newSettlement.fromUserId,
      'toUserId': newSettlement.toUserId,
      'amount': newSettlement.amount,
      'settledAt': Timestamp.fromDate(now),
      'settledBy': newSettlement.settledBy,
    });

    return newSettlement;
  }

  @override
  Stream<List<SettlementEntity>> watchGroupSettlements(String groupId) {
    return _firestore
        .collection('settlements')
        .where('groupId', isEqualTo: groupId)
        .orderBy('settledAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return SettlementEntity.fromJson({
              'id': doc.id,
              ...data,
              'settledAt': (data['settledAt'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
            });
          }).toList();
        });
  }
}

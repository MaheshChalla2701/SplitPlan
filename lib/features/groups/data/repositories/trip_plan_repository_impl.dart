import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trip_day_card_entity.dart';
import '../../domain/entities/trip_plan_entity.dart';
import '../../domain/repositories/trip_plan_repository.dart';

class TripPlanRepositoryImpl implements TripPlanRepository {
  final FirebaseFirestore _firestore;

  TripPlanRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _plansRef(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('trip_plans');

  CollectionReference<Map<String, dynamic>> _cardsRef(String tripPlanId) =>
      _firestore
          .collection('trip_plans_cards')
          .doc(tripPlanId)
          .collection('day_cards');

  @override
  Stream<List<TripPlanEntity>> watchTripPlans(String groupId) {
    return _plansRef(groupId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => _planFromDoc(doc)).toList());
  }

  @override
  Future<TripPlanEntity> createTripPlan({
    required String groupId,
    required String name,
    required String createdBy,
    DateTime? startDate,
    DateTime? endDate,
    double? estimatedBudget,
  }) async {
    final now = DateTime.now();
    final docRef = _plansRef(groupId).doc();

    final plan = TripPlanEntity(
      id: docRef.id,
      groupId: groupId,
      name: name,
      createdBy: createdBy,
      createdAt: now,
      startDate: startDate,
      endDate: endDate,
      estimatedBudget: estimatedBudget,
    );

    await docRef.set({
      'groupId': groupId,
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(now),
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate),
      'estimatedBudget': ?estimatedBudget,
    });

    return plan;
  }

  @override
  Future<void> updateTripPlan(TripPlanEntity plan) async {
    await _plansRef(plan.groupId).doc(plan.id).update({
      'name': plan.name,
      if (plan.startDate != null)
        'startDate': Timestamp.fromDate(plan.startDate!)
      else
        'startDate': FieldValue.delete(),
      if (plan.endDate != null)
        'endDate': Timestamp.fromDate(plan.endDate!)
      else
        'endDate': FieldValue.delete(),
      if (plan.estimatedBudget != null)
        'estimatedBudget': plan.estimatedBudget
      else
        'estimatedBudget': FieldValue.delete(),
    });
  }

  @override
  Future<void> deleteTripPlan(String groupId, String tripPlanId) async {
    final cardDocs = await _cardsRef(tripPlanId).get();
    final batch = _firestore.batch();
    for (final doc in cardDocs.docs) {
      batch.delete(doc.reference);
    }
    // Also delete the top-level cards doc for this trip
    batch.delete(_firestore.collection('trip_plans_cards').doc(tripPlanId));
    // Delete the plan itself from the group subcollection
    batch.delete(_plansRef(groupId).doc(tripPlanId));
    await batch.commit();
  }

  @override
  Future<void> reorderDayCards(
    String tripPlanId,
    List<TripDayCardEntity> cards,
  ) async {
    final batch = _firestore.batch();
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final newDayNumber = i + 1;
      if (card.dayNumber != newDayNumber) {
        batch.update(_cardsRef(tripPlanId).doc(card.id), {
          'dayNumber': newDayNumber,
        });
      }
    }
    await batch.commit();
  }

  @override
  Stream<List<TripDayCardEntity>> watchDayCards(String tripPlanId) {
    return _cardsRef(tripPlanId)
        .orderBy('dayNumber', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => _cardFromDoc(doc)).toList());
  }

  @override
  Future<TripDayCardEntity> addDayCard({
    required String tripPlanId,
    required int dayNumber,
  }) async {
    final docRef = _cardsRef(tripPlanId).doc();
    final card = TripDayCardEntity(
      id: docRef.id,
      tripPlanId: tripPlanId,
      dayNumber: dayNumber,
    );
    await docRef.set({'tripPlanId': tripPlanId, 'dayNumber': dayNumber});
    return card;
  }

  @override
  Future<void> updateDayCard(TripDayCardEntity card) async {
    await _cardsRef(card.tripPlanId).doc(card.id).update({'notes': card.notes});
  }

  @override
  Future<void> deleteDayCard(String tripPlanId, String cardId) async {
    await _cardsRef(tripPlanId).doc(cardId).delete();
  }

  // ────────────── helpers ──────────────

  TripPlanEntity _planFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return TripPlanEntity(
      id: doc.id,
      groupId: data['groupId'] as String,
      name: data['name'] as String,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      estimatedBudget: (data['estimatedBudget'] as num?)?.toDouble(),
    );
  }

  TripDayCardEntity _cardFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return TripDayCardEntity(
      id: doc.id,
      tripPlanId: data['tripPlanId'] as String,
      dayNumber: data['dayNumber'] as int,
      notes: _parseNotes(data['notes']),
    );
  }

  /// Safely parses the `notes` field from Firestore.
  /// Handles old String format (migrates to single-item list) and
  /// new List<String> format.
  static List<String> _parseNotes(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.cast<String>();
    if (raw is String && raw.isNotEmpty) return [raw]; // old format
    return [];
  }
}

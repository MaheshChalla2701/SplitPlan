import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_request_entity.dart';
import '../../domain/repositories/payment_request_repository.dart';

class PaymentRequestRepositoryImpl implements PaymentRequestRepository {
  final FirebaseFirestore _firestore;

  PaymentRequestRepositoryImpl(this._firestore);

  @override
  Future<void> createPaymentRequest(PaymentRequestEntity request) async {
    try {
      // 1. Pre-query the friendship document reference.
      // Firestore transactions do not support queries (.where().get()), only
      // direct document reads (.get(docRef)). We find the DocumentReference first
      // outside the transaction, then read its actual data atomically inside.
      DocumentReference? friendshipRef;

      var fwdSnap = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: request.toUserId)
          .where('friendId', isEqualTo: request.fromUserId)
          .limit(1)
          .get();

      if (fwdSnap.docs.isNotEmpty) {
        friendshipRef = fwdSnap.docs.first.reference;
      } else {
        var revSnap = await _firestore
            .collection('friendships')
            .where('userId', isEqualTo: request.fromUserId)
            .where('friendId', isEqualTo: request.toUserId)
            .limit(1)
            .get();
        if (revSnap.docs.isNotEmpty) {
          friendshipRef = revSnap.docs.first.reference;
        }
      }

      // 2. Execute the atomic transaction for all reads & the single write.
      await _firestore.runTransaction((tx) async {
        // --- Read 1: target user doc ---
        final toUserRef = _firestore.collection('users').doc(request.toUserId);
        final toUserSnap = await tx.get(toUserRef);

        var status = request.status;

        if (!toUserSnap.exists) {
          throw Exception('Recipient user not found');
        }

        final toUserData = toUserSnap.data()!;
        final isManual = toUserData['isManual'] ?? false;

        if (isManual) {
          // Manual friends always auto-accept.
          status = PaymentRequestStatus.accepted;
        } else {
          // Check soft-block: sender must still be in receiver's friends list.
          final friends = List<String>.from(toUserData['friends'] ?? []);
          if (!friends.contains(request.fromUserId)) {
            throw Exception(
              'User is not your friend. Please send a friend request to reconnect.',
            );
          }

          // --- Read 2: friendship doc (transactional read) ---
          if (friendshipRef != null) {
            final friendshipSnap = await tx.get(friendshipRef);
            if (friendshipSnap.exists) {
              final friendshipData =
                  friendshipSnap.data() as Map<String, dynamic>;
              final autoAcceptSettings =
                  friendshipData['autoAcceptSettings'] as Map<String, dynamic>?;
              if (autoAcceptSettings != null &&
                  autoAcceptSettings[request.toUserId] == true) {
                status = PaymentRequestStatus.accepted;
              }
            }
          }
        }

        // --- Write: create the payment request with the computed status ---
        final newRef = _firestore.collection('payment_requests').doc();
        tx.set(newRef, {
          'fromUserId': request.fromUserId,
          'toUserId': request.toUserId,
          'amount': request.amount,
          'description': request.description,
          'type': request.type.name,
          'status': status.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to create payment request: $e');
    }
  }

  @override
  Future<void> updateRequestStatus(
    String requestId,
    PaymentRequestStatus status,
  ) async {
    try {
      await _firestore.collection('payment_requests').doc(requestId).update({
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  @override
  Future<void> deletePaymentRequest(String requestId) async {
    try {
      await _firestore.collection('payment_requests').doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to delete payment request: $e');
    }
  }

  @override
  Future<void> updatePaymentRequest(PaymentRequestEntity request) async {
    try {
      await _firestore.collection('payment_requests').doc(request.id).update({
        'amount': request.amount,
        'description': request.description,
        // We generally don't update fromUserId/toUserId/type/createdAt for an edit
      });
    } catch (e) {
      throw Exception('Failed to update payment request: $e');
    }
  }

  @override
  Stream<List<PaymentRequestEntity>> getPaymentRequests(String userId) {
    // Combine two queries to get all requests where user is sender or receiver
    // Use a simple merge approach since Dart's StreamGroup isn't directly available without async package
    // Alternatively, we can just listen to both and merge in memory.
    // But a cleaner way without extra packages is to query OR if firestore supported it (it does with 'or' queries but requires index).
    // Let's use the 'or' query if possible, or manual merge.

    // Firestore 'or' query:
    return _firestore
        .collection('payment_requests')
        .where(
          Filter.or(
            Filter('fromUserId', isEqualTo: userId),
            Filter('toUserId', isEqualTo: userId),
          ),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return PaymentRequestEntity.fromJson({
              'id': doc.id,
              ...data,
              'createdAt': (data['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
            });
          }).toList();
        });
  }

  @override
  Stream<List<PaymentRequestEntity>> getPaymentRequestsWithFriend(
    String userId,
    String friendId,
  ) {
    // Use a composite OR filter so only the two specific directional pairs
    // (userId→friendId and friendId→userId) are fetched from Firestore.
    // This avoids the previous over-fetch where ALL requests by either user
    // were downloaded just to filter the pair client-side.
    return _firestore
        .collection('payment_requests')
        .where(
          Filter.or(
            Filter.and(
              Filter('fromUserId', isEqualTo: userId),
              Filter('toUserId', isEqualTo: friendId),
            ),
            Filter.and(
              Filter('fromUserId', isEqualTo: friendId),
              Filter('toUserId', isEqualTo: userId),
            ),
          ),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return PaymentRequestEntity.fromJson({
              'id': doc.id,
              ...data,
              'createdAt': (data['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
            });
          }).toList();
        });
  }

  @override
  Future<PaymentRequestEntity?> getPaymentRequest(String requestId) async {
    try {
      final doc = await _firestore
          .collection('payment_requests')
          .doc(requestId)
          .get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return PaymentRequestEntity.fromJson({
        'id': doc.id,
        ...data,
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    } catch (e) {
      return null;
    }
  }
}

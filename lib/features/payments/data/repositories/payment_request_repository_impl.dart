import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../domain/entities/payment_request_entity.dart';
import '../../domain/repositories/payment_request_repository.dart';

class PaymentRequestRepositoryImpl implements PaymentRequestRepository {
  final FirebaseFirestore _firestore;

  PaymentRequestRepositoryImpl(this._firestore);

  @override
  Future<void> createPaymentRequest(PaymentRequestEntity request) async {
    try {
      var status = request.status;

      // Check if target user is a manual friend to auto-accept
      final toUserDoc = await _firestore
          .collection('users')
          .doc(request.toUserId)
          .get();

      if (toUserDoc.exists && (toUserDoc.data()?['isManual'] ?? false)) {
        status = PaymentRequestStatus.accepted;
      } else if (toUserDoc.exists) {
        // Check if the sender is still in the receiver's friend list
        // This handles the "Soft Block" where if a user deleted me, I can't send them requests
        final friends = List<String>.from(toUserDoc.data()?['friends'] ?? []);
        if (!friends.contains(request.fromUserId)) {
          throw Exception(
            'User is not your friend. Please send a friend request to reconnect.',
          );
        }

        // Check for Auto-Accept
        try {
          // Find friendship doc (bidirectional check)
          var friendshipQuery = await _firestore
              .collection('friendships')
              .where('userId', isEqualTo: request.toUserId)
              .where('friendId', isEqualTo: request.fromUserId)
              .limit(1)
              .get();

          if (friendshipQuery.docs.isEmpty) {
            friendshipQuery = await _firestore
                .collection('friendships')
                .where('userId', isEqualTo: request.fromUserId)
                .where('friendId', isEqualTo: request.toUserId)
                .limit(1)
                .get();
          }

          if (friendshipQuery.docs.isNotEmpty) {
            final data = friendshipQuery.docs.first.data();
            final autoAcceptSettings =
                data['autoAcceptSettings'] as Map<String, dynamic>?;
            if (autoAcceptSettings != null &&
                autoAcceptSettings[request.toUserId] == true) {
              status = PaymentRequestStatus.accepted;
            }
          }
        } catch (e) {
          // Ignore error, proceed with default status
          developer.log('Error checking auto-accept', error: e);
        }
      }

      await _firestore.collection('payment_requests').add({
        'fromUserId': request.fromUserId,
        'toUserId': request.toUserId,
        'amount': request.amount,
        'description': request.description,
        'type': request.type.name,
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
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
    return _firestore
        .collection('payment_requests')
        .where('fromUserId', whereIn: [userId, friendId])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final from = data['fromUserId'] as String;
                final to = data['toUserId'] as String;
                return (from == userId && to == friendId) ||
                    (from == friendId && to == userId);
              })
              .map((doc) {
                final data = doc.data();
                return PaymentRequestEntity.fromJson({
                  'id': doc.id,
                  ...data,
                  'createdAt': (data['createdAt'] as Timestamp)
                      .toDate()
                      .toIso8601String(),
                });
              })
              .toList();
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

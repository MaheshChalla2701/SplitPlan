import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/friendship_request.dart';
import '../../domain/entities/friendship_entity.dart';
import '../../domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FriendsRepositoryImpl(this._firestore, this._auth);

  String get _currentUserId => _auth.currentUser!.uid;

  @override
  Future<List<UserEntity>> searchByPhone(String phone) async {
    try {
      final normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      final query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: normalized)
          .where('isSearchable', isEqualTo: true)
          .limit(10)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return UserEntity.fromJson({
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String(),
          if (data['updatedAt'] != null)
            'updatedAt': (data['updatedAt'] as Timestamp)
                .toDate()
                .toIso8601String(),
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to search by phone: $e');
    }
  }

  @override
  Future<List<UserEntity>> searchByUsername(String username) async {
    try {
      final searchLower = username.toLowerCase();
      // Simple orderBy query without isSearchable to avoid index issues
      final query = await _firestore
          .collection('users')
          .orderBy('username')
          .startAt([searchLower])
          .endAt(['$searchLower\uf8ff'])
          .limit(10)
          .get();

      // Filter searchable users in the app
      return query.docs.where((doc) => doc.data()['isSearchable'] == true).map((
        doc,
      ) {
        final data = doc.data();
        return UserEntity.fromJson({
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String(),
          if (data['updatedAt'] != null)
            'updatedAt': (data['updatedAt'] as Timestamp)
                .toDate()
                .toIso8601String(),
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to search by username: $e');
    }
  }

  @override
  Future<void> sendFriendRequest(String friendId) async {
    try {
      // Check if friendship already exists
      final existing = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: _currentUserId)
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Friend request already exists');
      }

      // Create friendship document
      await _firestore.collection('friendships').add({
        'userId': _currentUserId,
        'friendId': friendId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  @override
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      print('DEBUG: Accepting friendship $friendshipId');

      // First, get the friendship data
      final friendship = await _firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();

      if (!friendship.exists) {
        print('DEBUG: Friendship not found!');
        throw Exception('Friendship not found');
      }

      final data = friendship.data()!;
      final userId = data['userId'] as String;
      final friendId = data['friendId'] as String;

      print('DEBUG: userId=$userId, friendId=$friendId');

      // Update status to accepted
      await _firestore.collection('friendships').doc(friendshipId).update({
        'status': 'accepted',
      });
      print('DEBUG: Updated friendship status to accepted');

      // Update both users' friends arrays (create if doesn't exist)
      await _firestore.collection('users').doc(userId).set({
        'friends': FieldValue.arrayUnion([friendId]),
      }, SetOptions(merge: true));
      print('DEBUG: Updated userId friends array');

      await _firestore.collection('users').doc(friendId).set({
        'friends': FieldValue.arrayUnion([userId]),
      }, SetOptions(merge: true));
      print('DEBUG: Updated friendId friends array');

      print('DEBUG: Successfully accepted friend request!');
    } catch (e) {
      print('DEBUG: Error accepting friend request: $e');
      throw Exception('Failed to accept friend request: $e');
    }
  }

  @override
  Future<void> rejectFriendRequest(String friendshipId) async {
    try {
      await _firestore.collection('friendships').doc(friendshipId).update({
        'status': 'rejected',
      });
    } catch (e) {
      throw Exception('Failed to reject friend request: $e');
    }
  }

  @override
  Stream<List<UserEntity>> getUserFriends(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().asyncMap((
      doc,
    ) async {
      final data = doc.data();
      if (data == null) return <UserEntity>[];

      final friendIds = List<String>.from(data['friends'] ?? []);
      if (friendIds.isEmpty) return <UserEntity>[];

      // Fetch all friends' data
      final friendDocs = await Future.wait(
        friendIds.map((id) => _firestore.collection('users').doc(id).get()),
      );

      return friendDocs.where((doc) => doc.exists).map((doc) {
        final friendData = doc.data()!;
        return UserEntity.fromJson({
          'id': doc.id,
          ...friendData,
          'createdAt': (friendData['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String(),
          if (friendData['updatedAt'] != null)
            'updatedAt': (friendData['updatedAt'] as Timestamp)
                .toDate()
                .toIso8601String(),
        });
      }).toList();
    });
  }

  @override
  Stream<List<FriendshipRequest>> getPendingFriendRequests(String userId) {
    return _firestore
        .collection('friendships')
        .where('friendId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return <FriendshipRequest>[];

          final requests = <FriendshipRequest>[];

          for (final doc in snapshot.docs) {
            final friendshipData = doc.data();
            final requesterId = friendshipData['userId'] as String;

            final requesterDoc = await _firestore
                .collection('users')
                .doc(requesterId)
                .get();

            if (requesterDoc.exists) {
              final userData = requesterDoc.data()!;
              final requester = UserEntity.fromJson({
                'id': requesterDoc.id,
                ...userData,
                'createdAt': (userData['createdAt'] as Timestamp)
                    .toDate()
                    .toIso8601String(),
                if (userData['updatedAt'] != null)
                  'updatedAt': (userData['updatedAt'] as Timestamp)
                      .toDate()
                      .toIso8601String(),
              });

              requests.add(
                FriendshipRequest(
                  id: doc.id,
                  requester: requester,
                  createdAt:
                      (friendshipData['createdAt'] as Timestamp? ??
                              Timestamp.now())
                          .toDate(),
                  status: friendshipData['status'] as String,
                ),
              );
            }
          }

          return requests;
        });
  }

  @override
  Future<String?> getFriendshipStatus(String userId, String friendId) async {
    try {
      final query = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first.data()['status'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<FriendshipEntity?> getFriendship(
    String userId,
    String friendId,
  ) async {
    try {
      // Check forward direction
      var query = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      // Check reverse direction if not found
      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('friendships')
            .where('userId', isEqualTo: friendId)
            .where('friendId', isEqualTo: userId)
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      final data = doc.data();

      // Get user-specific clear time
      DateTime? lastClearedAt;
      if (data['chatClearHistory'] != null) {
        final history = data['chatClearHistory'] as Map<String, dynamic>;
        final userClearTime = history[userId];
        if (userClearTime is Timestamp) {
          lastClearedAt = userClearTime.toDate();
        }
      } else if (data['lastClearedAt'] != null &&
          data['lastClearedAt'] is Timestamp) {
        // Fallback for legacy data (global clear)
        lastClearedAt = (data['lastClearedAt'] as Timestamp).toDate();
      }

      return FriendshipEntity.fromJson({
        'id': doc.id,
        'userId': data['userId'],
        'friendId': data['friendId'],
        'status': data['status'],
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
        if (lastClearedAt != null)
          'lastClearedAt': lastClearedAt.toIso8601String(),
        'isAutoAccept':
            (data['autoAcceptSettings'] != null &&
            (data['autoAcceptSettings'] as Map<String, dynamic>)[userId] ==
                true),
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearChatHistory(String userId, String friendId) async {
    try {
      // Check forward direction
      var query = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      // Check reverse direction if not found
      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('friendships')
            .where('userId', isEqualTo: friendId)
            .where('friendId', isEqualTo: userId)
            .limit(1)
            .get();
      }

      if (query.docs.isNotEmpty) {
        // Update user-specific clear time in the map
        await query.docs.first.reference.update({
          'chatClearHistory.$userId': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to clear chat history: $e');
    }
  }

  @override
  Future<void> updateAutoAccept(
    String userId,
    String friendId,
    bool isAutoAccept,
  ) async {
    try {
      // Check forward direction
      var query = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      // Check reverse direction if not found
      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('friendships')
            .where('userId', isEqualTo: friendId)
            .where('friendId', isEqualTo: userId)
            .limit(1)
            .get();
      }

      if (query.docs.isNotEmpty) {
        // Update user-specific auto-accept setting in the map
        await query.docs.first.reference.update({
          'autoAcceptSettings.$userId': isAutoAccept,
        });
      }
    } catch (e) {
      throw Exception('Failed to update auto-accept setting: $e');
    }
  }

  @override
  Future<void> createManualFriend(String name) async {
    try {
      final now = DateTime.now();
      final manualFriendDoc = _firestore.collection('users').doc();
      final userId = _currentUserId;

      // 1. Create the manual friend user document
      await manualFriendDoc.set({
        'name': name,
        'username': 'manual_${manualFriendDoc.id.substring(0, 8)}',
        'email': 'manual_${manualFriendDoc.id}@splitplan.manual',
        'isManual': true,
        'isSearchable': false,
        'ownerId': userId,
        'friends': [userId],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': null,
        'avatarUrl': null,
      });

      // 2. Add manual friend to current user's friends list
      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([manualFriendDoc.id]),
      });

      // 3. Create an automatically accepted friendship
      await _firestore.collection('friendships').add({
        'userId': userId,
        'friendId': manualFriendDoc.id,
        'status': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create manual friend: $e');
    }
  }

  @override
  Future<void> mergeManualFriendToReal(
    String manualFriendId,
    String realUserId,
  ) async {
    try {
      final userId = _currentUserId;

      // 1. Get all payment requests involving the manual friend
      final requestsFromQuery = await _firestore
          .collection('payment_requests')
          .where('fromUserId', isEqualTo: manualFriendId)
          .get();

      final requestsToQuery = await _firestore
          .collection('payment_requests')
          .where('toUserId', isEqualTo: manualFriendId)
          .get();

      // 2. Perform updates in a batch for atomicity
      final batch = _firestore.batch();

      // Update requests where manual friend was the sender
      for (final doc in requestsFromQuery.docs) {
        batch.update(doc.reference, {'fromUserId': realUserId});
      }

      // Update requests where manual friend was the receiver
      for (final doc in requestsToQuery.docs) {
        batch.update(doc.reference, {'toUserId': realUserId});
      }

      // 3. Update current user's friends list: remove manual, add real
      batch.update(_firestore.collection('users').doc(userId), {
        'friends': FieldValue.arrayRemove([manualFriendId]),
      });
      batch.update(_firestore.collection('users').doc(userId), {
        'friends': FieldValue.arrayUnion([realUserId]),
      });

      // 4. Update real user's friends list: add current user
      batch.update(_firestore.collection('users').doc(realUserId), {
        'friends': FieldValue.arrayUnion([userId]),
      });

      // 5. Delete the manual friend user document
      batch.delete(_firestore.collection('users').doc(manualFriendId));

      // 6. Delete the friendship document for the manual friend
      final manualFriendshipQuery = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: manualFriendId)
          .get();

      for (final doc in manualFriendshipQuery.docs) {
        batch.delete(doc.reference);
      }

      // 7. Create/Update friendship with real user
      final realFriendshipQuery = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: realUserId)
          .get();

      if (realFriendshipQuery.docs.isEmpty) {
        final newFriendshipRef = _firestore.collection('friendships').doc();
        batch.set(newFriendshipRef, {
          'userId': userId,
          'friendId': realUserId,
          'status': 'accepted',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to merge manual friend: $e');
    }
  }

  @override
  Future<void> deleteFriend(String friendId) async {
    try {
      final userId = _currentUserId;

      // 1. Get friend data to check if manual
      final friendDoc = await _firestore
          .collection('users')
          .doc(friendId)
          .get();
      if (!friendDoc.exists) throw Exception('Friend not found');

      final friendData = friendDoc.data()!;
      final isManual = friendData['isManual'] == true;

      // 2. Prepare Batch
      final batch = _firestore.batch();

      if (isManual) {
        // --- MANUAL FRIEND DELETION (Hard Delete) ---

        // Delete Transaction History (All requests between users)
        final allRequestsFrom = await _firestore
            .collection('payment_requests')
            .where('fromUserId', isEqualTo: friendId)
            .where('toUserId', isEqualTo: userId)
            .get();

        final allRequestsTo = await _firestore
            .collection('payment_requests')
            .where('fromUserId', isEqualTo: userId)
            .where('toUserId', isEqualTo: friendId)
            .get();

        for (final doc in allRequestsFrom.docs) batch.delete(doc.reference);
        for (final doc in allRequestsTo.docs) batch.delete(doc.reference);

        // Delete manual user doc
        batch.delete(_firestore.collection('users').doc(friendId));

        // Remove from current user's friends list
        batch.update(_firestore.collection('users').doc(userId), {
          'friends': FieldValue.arrayRemove([friendId]),
        });
      } else {
        // --- REAL FRIEND DELETION (Soft Delete) ---

        // 1. Remove from current user's list ONLY
        batch.update(_firestore.collection('users').doc(userId), {
          'friends': FieldValue.arrayRemove([friendId]),
        });

        // 2. DO NOT remove current user from friend's list (One-sided)
        // 3. DO NOT delete transaction history (Keep history)
      }

      // 3. Delete Friendship Document (Common for both)
      // This breaks the link so they can't simply send requests again without re-friending.
      final friendshipAsSender = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .get();

      final friendshipAsReceiver = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: friendId)
          .where('friendId', isEqualTo: userId)
          .get();

      for (final doc in friendshipAsSender.docs) batch.delete(doc.reference);
      for (final doc in friendshipAsReceiver.docs) batch.delete(doc.reference);

      // 4. Commit
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete friend: $e');
    }
  }
}

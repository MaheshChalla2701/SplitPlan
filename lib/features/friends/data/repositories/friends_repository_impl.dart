import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/friendship_request.dart';
import '../../domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FriendsRepositoryImpl(this._firestore, this._auth);

  String get _currentUserId => _auth.currentUser!.uid;

  @override
  Future<List<UserEntity>> searchUserByPhone(String phone) async {
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
  Future<List<UserEntity>> searchUserByUsername(String username) async {
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
}

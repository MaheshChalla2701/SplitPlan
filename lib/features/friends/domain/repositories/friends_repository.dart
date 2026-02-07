import '../../../auth/domain/entities/user_entity.dart';
import '../entities/friendship_request.dart';

abstract class FriendsRepository {
  // Search users
  Future<List<UserEntity>> searchUserByPhone(String phone);
  Future<List<UserEntity>> searchUserByUsername(String username);

  // Friend requests
  Future<void> sendFriendRequest(String friendId);
  Future<void> acceptFriendRequest(String friendshipId);
  Future<void> rejectFriendRequest(String friendshipId);

  // Get friends
  Stream<List<UserEntity>> getUserFriends(String userId);
  Stream<List<FriendshipRequest>> getPendingFriendRequests(String userId);

  // Check friendship status
  Future<String?> getFriendshipStatus(String userId, String friendId);
}

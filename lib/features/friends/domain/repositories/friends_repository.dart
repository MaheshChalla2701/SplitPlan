import '../entities/friendship_request.dart';
import '../entities/friendship_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class FriendsRepository {
  // Search
  Future<List<UserEntity>> searchByUsername(String username);
  Future<List<UserEntity>> searchByPhone(String phone);

  // Friend Request Management
  Future<void> sendFriendRequest(String friendId);
  Future<void> acceptFriendRequest(String friendshipId);
  Future<void> rejectFriendRequest(String friendshipId);

  // Friendship Management
  Stream<List<UserEntity>> getUserFriends(String userId);
  Stream<List<FriendshipRequest>> getPendingFriendRequests(String userId);
  Future<String?> getFriendshipStatus(String userId, String friendId);
  Future<FriendshipEntity?> getFriendship(String userId, String friendId);
  Future<void> clearChatHistory(String userId, String friendId);
  Future<void> updateAutoAccept(
    String userId,
    String friendId,
    bool isAutoAccept,
  );

  Future<void> deleteFriend(String friendId);

  // Manual Friends
  Future<void> createManualFriend(String name);
  Future<void> mergeManualFriendToReal(
    String manualFriendId,
    String realUserId,
  );
}

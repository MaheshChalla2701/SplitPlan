import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/friendship_request.dart';
import '../../domain/entities/friendship_entity.dart';
import '../../domain/repositories/friends_repository.dart';
import '../../../payments/domain/entities/payment_request_entity.dart';
import '../../../payments/presentation/providers/payment_request_providers.dart';

part 'friends_providers.g.dart';

// Friends Repository Provider
@riverpod
FriendsRepository friendsRepository(Ref ref) {
  return FriendsRepositoryImpl(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
}

// User Friends Stream Provider
@riverpod
Stream<List<UserEntity>> userFriends(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(friendsRepositoryProvider).getUserFriends(user.id);
}

// Pending Friend Requests Provider
@riverpod
Stream<List<FriendshipRequest>> pendingFriendRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(friendsRepositoryProvider).getPendingFriendRequests(user.id);
}

// Specific Friend Provider
@riverpod
Future<UserEntity?> specificFriend(Ref ref, String friendId) async {
  final friends = await ref.watch(userFriendsProvider.future);
  try {
    return friends.firstWhere((friend) => friend.id == friendId);
  } catch (_) {
    return null;
  }
}

// Friendship Status Provider
@riverpod
Future<String?> friendshipStatus(Ref ref, String friendId) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref
      .watch(friendsRepositoryProvider)
      .getFriendshipStatus(user.id, friendId);
}

// Search Users Controller
@riverpod
class SearchUsersController extends _$SearchUsersController {
  @override
  AsyncValue<List<UserEntity>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> searchByUsername(String username) async {
    if (username.length < 3) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(friendsRepositoryProvider)
          .searchByUsername(username);
    });
  }

  Future<void> searchByPhone(String phone) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(friendsRepositoryProvider).searchByPhone(phone);
    });
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

// Send Friend Request Controller
@riverpod
class SendFriendRequestController extends _$SendFriendRequestController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> sendRequest(String friendId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(friendsRepositoryProvider).sendFriendRequest(friendId);
    });
  }
}

// Accept Friend Request Controller
@riverpod
class AcceptFriendRequestController extends _$AcceptFriendRequestController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> accept(String friendshipId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(friendsRepositoryProvider)
          .acceptFriendRequest(friendshipId);
    });
  }

  Future<void> reject(String friendshipId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(friendsRepositoryProvider)
          .rejectFriendRequest(friendshipId);
    });
  }
}

// Create Manual Friend Controller
@riverpod
class CreateManualFriendController extends _$CreateManualFriendController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> create(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(friendsRepositoryProvider).createManualFriend(name);
    });
  }
}

// Merge Manual Friend Controller
@riverpod
class MergeManualFriendController extends _$MergeManualFriendController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> merge({
    required String manualFriendId,
    required String realUserId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(friendsRepositoryProvider)
          .mergeManualFriendToReal(manualFriendId, realUserId),
    );
  }
}

// Delete Friend Controller
@riverpod
class DeleteFriendController extends _$DeleteFriendController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> deleteFriend(String friendId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(friendsRepositoryProvider).deleteFriend(friendId),
    );
  }
}

// Friendship Details Provider
@riverpod
Future<FriendshipEntity?> friendshipDetails(Ref ref, String friendId) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.watch(friendsRepositoryProvider).getFriendship(user.id, friendId);
}

// Clear Chat History Controller
@riverpod
class ClearChatHistoryController extends _$ClearChatHistoryController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> clearHistory(String friendId, double netBalance) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Fetch ALL existing requests between these two users
      final existingRequests = await ref
          .read(paymentRequestRepositoryProvider)
          .getPaymentRequestsWithFriend(user.id, friendId)
          .first;

      // 2. Delete each request
      for (final request in existingRequests) {
        await ref
            .read(paymentRequestRepositoryProvider)
            .deletePaymentRequest(request.id);
      }

      // 3. Clear the chat history timestamp (optional but good for consistency)
      await ref
          .read(friendsRepositoryProvider)
          .clearChatHistory(user.id, friendId);

      // 4. If there's a non-zero balance, create a "Balance Forwarded" request
      if (netBalance != 0) {
        // Prepare the request
        // If netBalance > 0: Friend owes User -> User requests "receive" from Friend (accepted)
        // If netBalance < 0: User owes Friend -> User requests "pay" to Friend (accepted)

        final isReceiving = netBalance > 0;
        final type = isReceiving
            ? PaymentRequestType.receive
            : PaymentRequestType.pay;

        final request = PaymentRequestEntity(
          id: '', // ID handled by firestore add()
          fromUserId: user.id,
          toUserId: friendId,
          amount: netBalance.abs(),
          description: 'Balance Forwarded',
          type: type,
          status: PaymentRequestStatus.accepted,
          createdAt: DateTime.now(),
        );

        await ref
            .read(paymentRequestRepositoryProvider)
            .createPaymentRequest(request);
      }

      // Invalidate providers
      ref.invalidate(friendshipDetailsProvider(friendId));
      ref.invalidate(paymentRequestsWithFriendProvider(friendId));
    });
  }
}

// Update Auto Accept Controller
@riverpod
class UpdateAutoAcceptController extends _$UpdateAutoAcceptController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> updateAutoAccept(String friendId, bool isAutoAccept) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(friendsRepositoryProvider)
          .updateAutoAccept(user.id, friendId, isAutoAccept);

      // Invalidate friendship details to refresh the UI
      ref.invalidate(friendshipDetailsProvider(friendId));
    });
  }
}

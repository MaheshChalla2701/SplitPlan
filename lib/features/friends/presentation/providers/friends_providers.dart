import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/friendship_request.dart';
import '../../domain/repositories/friends_repository.dart';

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
          .searchUserByUsername(username);
    });
  }

  Future<void> searchByPhone(String phone) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(friendsRepositoryProvider).searchUserByPhone(phone);
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

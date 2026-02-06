import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';

part 'group_providers.g.dart';

@riverpod
GroupRepository groupRepository(Ref ref) {
  return GroupRepositoryImpl(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<GroupEntity>> userGroups(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  // Note: userGroups in repo returns Future<List>, but we might want a stream.
  // The repo implementation has 'getUserGroups' as Future.
  // Let's create a Stream version or just use Stream.fromFuture in a provider that invalidates.
  // Actually, for real-time updates, we should probably add a watchUserGroups method to Repo.
  // For now, I'll allow simple fetching.
  // To make it reactive, I'll use FutureProvider and invalidate it on changes,
  // or (better) implement a stream in repo.
  // Firestore queries are easily streams.
  // Let's stick to FutureProvider for the list for now to match interface, or wrap with Stream.

  return Stream.fromFuture(
    ref.watch(groupRepositoryProvider).getUserGroups(user.id),
  );
}

@riverpod
Stream<GroupEntity> group(Ref ref, String groupId) {
  return ref.watch(groupRepositoryProvider).watchGroup(groupId);
}

@riverpod
class GroupController extends _$GroupController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createGroup(String name, List<String> memberIds) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(groupRepositoryProvider).createGroup(name, memberIds),
    );

    // Invalidate list to refresh
    ref.invalidate(userGroupsProvider);
  }

  Future<void> deleteGroup(String groupId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(groupRepositoryProvider).deleteGroup(groupId),
    );

    ref.invalidate(userGroupsProvider);
  }

  Future<void> addMember(String groupId, String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(groupRepositoryProvider).addMember(groupId, userId);
    });
  }
}

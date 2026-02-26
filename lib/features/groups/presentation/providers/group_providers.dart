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
  return ref.watch(groupRepositoryProvider).watchUserGroups(user.id);
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

  Future<void> makeAdmin(String groupId, String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(groupRepositoryProvider).makeAdmin(groupId, userId);
    });
  }
}

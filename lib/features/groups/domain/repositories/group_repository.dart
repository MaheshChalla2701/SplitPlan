import '../entities/group_entity.dart';

abstract class GroupRepository {
  Future<GroupEntity> createGroup(String name, List<String> memberIds);
  Future<void> updateGroup(GroupEntity group);
  Future<void> deleteGroup(String groupId);
  Future<List<GroupEntity>> getUserGroups(String userId);
  Stream<List<GroupEntity>> watchUserGroups(String userId);
  Stream<GroupEntity> watchGroup(String groupId);
  Future<void> addMember(String groupId, String userId);
  Future<void> removeMember(String groupId, String userId);
  Future<GroupEntity> getGroup(String groupId);
  Future<void> makeAdmin(String groupId, String userId);
  Future<void> updateAutoAccept(
    String groupId,
    String userId,
    bool isAutoAccept,
  );
}

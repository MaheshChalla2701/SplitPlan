import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final FirebaseFirestore _firestore;

  GroupRepositoryImpl(this._firestore);

  @override
  Future<GroupEntity> createGroup(String name, List<String> memberIds) async {
    final now = DateTime.now();
    final docRef = _firestore.collection('groups').doc();

    // Assuming the first member is the admin if not specified logic is handled in UseCase
    // Ideally, the UseCase or caller provides the adminId.
    // For now, I'll assume the first member is the creator/admin.
    final adminId = memberIds.isNotEmpty ? memberIds.first : '';

    final group = GroupEntity(
      id: docRef.id,
      name: name,
      adminId: adminId,
      memberIds: memberIds,
      createdAt: now,
      metadata: {},
    );

    await docRef.set({
      'name': name,
      'adminId': adminId,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(now),
      'metadata': {},
    });

    return group;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }

  @override
  Future<List<GroupEntity>> getUserGroups(String userId) async {
    final snapshot = await _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .get();

    final groups = snapshot.docs.map((doc) {
      final data = doc.data();
      return GroupEntity.fromJson({
        'id': doc.id,
        ...data,
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    }).toList();

    groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return groups;
  }

  @override
  Stream<List<GroupEntity>> watchUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final groups = snapshot.docs.map((doc) {
            final data = doc.data();
            return GroupEntity.fromJson({
              'id': doc.id,
              ...data,
              'createdAt': (data['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
            });
          }).toList();
          // Sort in Dart to avoid needing a composite Firestore index
          groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return groups;
        });
  }

  @override
  Future<void> updateGroup(GroupEntity group) async {
    await _firestore.collection('groups').doc(group.id).update({
      'name': group.name,
      'adminId': group.adminId,
      'memberIds': group.memberIds,
      'metadata': group.metadata,
    });
  }

  @override
  Stream<GroupEntity> watchGroup(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Group not found');
      }
      final data = doc.data()!;
      return GroupEntity.fromJson({
        'id': doc.id,
        ...data,
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    });
  }

  @override
  Future<void> addMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<GroupEntity> getGroup(String groupId) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Group not found');
    }
    final data = doc.data()!;
    return GroupEntity.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendEntityImpl _$$FriendEntityImplFromJson(Map<String, dynamic> json) =>
    _$FriendEntityImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FriendEntityImplToJson(_$FriendEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'friendId': instance.friendId,
      'status': _$FriendshipStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'pending',
  FriendshipStatus.accepted: 'accepted',
  FriendshipStatus.rejected: 'rejected',
};

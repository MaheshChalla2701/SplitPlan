// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendshipEntityImpl _$$FriendshipEntityImplFromJson(
  Map<String, dynamic> json,
) => _$FriendshipEntityImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  friendId: json['friendId'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastClearedAt: json['lastClearedAt'] == null
      ? null
      : DateTime.parse(json['lastClearedAt'] as String),
  isAutoAccept: json['isAutoAccept'] as bool? ?? false,
);

Map<String, dynamic> _$$FriendshipEntityImplToJson(
  _$FriendshipEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'friendId': instance.friendId,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastClearedAt': instance.lastClearedAt?.toIso8601String(),
  'isAutoAccept': instance.isAutoAccept,
};

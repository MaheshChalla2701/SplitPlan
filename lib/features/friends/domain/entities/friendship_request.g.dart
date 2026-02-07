// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendshipRequestImpl _$$FriendshipRequestImplFromJson(
  Map<String, dynamic> json,
) => _$FriendshipRequestImpl(
  id: json['id'] as String,
  requester: UserEntity.fromJson(json['requester'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$$FriendshipRequestImplToJson(
  _$FriendshipRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'requester': instance.requester,
  'createdAt': instance.createdAt.toIso8601String(),
  'status': instance.status,
};

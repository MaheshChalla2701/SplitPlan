// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserEntityImpl _$$UserEntityImplFromJson(Map<String, dynamic> json) =>
    _$UserEntityImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      upiId: json['upiId'] as String?,
      isSearchable: json['isSearchable'] as bool? ?? true,
      isManual: json['isManual'] as bool? ?? false,
      ownerId: json['ownerId'] as String?,
      friends:
          (json['friends'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserEntityImplToJson(_$UserEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'username': instance.username,
      'phoneNumber': instance.phoneNumber,
      'avatarUrl': instance.avatarUrl,
      'upiId': instance.upiId,
      'isSearchable': instance.isSearchable,
      'isManual': instance.isManual,
      'ownerId': instance.ownerId,
      'friends': instance.friends,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupEntityImpl _$$GroupEntityImplFromJson(Map<String, dynamic> json) =>
    _$GroupEntityImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      adminIds: (json['adminIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      memberIds: (json['memberIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$GroupEntityImplToJson(_$GroupEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'adminIds': instance.adminIds,
      'memberIds': instance.memberIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

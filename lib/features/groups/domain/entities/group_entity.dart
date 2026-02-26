import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_entity.freezed.dart';
part 'group_entity.g.dart';

@freezed
class GroupEntity with _$GroupEntity {
  const factory GroupEntity({
    required String id,
    required String name,
    required List<String> adminIds,
    required List<String> memberIds,
    required DateTime createdAt,
    Map<String, dynamic>? metadata, // For future planning features
  }) = _GroupEntity;

  factory GroupEntity.fromJson(Map<String, dynamic> json) =>
      _$GroupEntityFromJson(json);
}

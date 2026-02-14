import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_entity.freezed.dart';
part 'friendship_entity.g.dart';

@freezed
class FriendshipEntity with _$FriendshipEntity {
  const factory FriendshipEntity({
    required String id,
    required String userId,
    required String friendId,
    required String status,
    required DateTime createdAt,
    DateTime? lastClearedAt,
    @Default(false) bool isAutoAccept,
  }) = _FriendshipEntity;

  factory FriendshipEntity.fromJson(Map<String, dynamic> json) =>
      _$FriendshipEntityFromJson(json);
}

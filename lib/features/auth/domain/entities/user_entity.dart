import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String name,
    required String username,
    String? phoneNumber,
    String? avatarUrl,
    String? upiId,
    @Default(true) bool isSearchable,
    @Default(false) bool isManual,
    @Default(true) bool notificationsEnabled,
    String? ownerId,
    @Default([]) List<String> friends,
    @Default([]) List<String> mutedUids,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}

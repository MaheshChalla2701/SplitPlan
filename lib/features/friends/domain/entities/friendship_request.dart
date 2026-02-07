import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/entities/user_entity.dart';

part 'friendship_request.freezed.dart';
part 'friendship_request.g.dart';

@freezed
class FriendshipRequest with _$FriendshipRequest {
  const factory FriendshipRequest({
    required String id,
    required UserEntity requester,
    required DateTime createdAt,
    required String status,
  }) = _FriendshipRequest;

  factory FriendshipRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendshipRequestFromJson(json);
}

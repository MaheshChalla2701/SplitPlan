import 'package:freezed_annotation/freezed_annotation.dart';

part 'settlement_entity.freezed.dart';
part 'settlement_entity.g.dart';

@freezed
class SettlementEntity with _$SettlementEntity {
  const factory SettlementEntity({
    required String id,
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required DateTime settledAt,
    required String settledBy,
  }) = _SettlementEntity;

  factory SettlementEntity.fromJson(Map<String, dynamic> json) =>
      _$SettlementEntityFromJson(json);
}

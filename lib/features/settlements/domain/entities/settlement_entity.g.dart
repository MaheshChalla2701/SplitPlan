// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettlementEntityImpl _$$SettlementEntityImplFromJson(
  Map<String, dynamic> json,
) => _$SettlementEntityImpl(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  amount: (json['amount'] as num).toDouble(),
  settledAt: DateTime.parse(json['settledAt'] as String),
  settledBy: json['settledBy'] as String,
);

Map<String, dynamic> _$$SettlementEntityImplToJson(
  _$SettlementEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'fromUserId': instance.fromUserId,
  'toUserId': instance.toUserId,
  'amount': instance.amount,
  'settledAt': instance.settledAt.toIso8601String(),
  'settledBy': instance.settledBy,
};

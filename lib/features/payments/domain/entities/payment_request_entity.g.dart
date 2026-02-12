// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentRequestEntityImpl _$$PaymentRequestEntityImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentRequestEntityImpl(
  id: json['id'] as String,
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String?,
  type: $enumDecode(_$PaymentRequestTypeEnumMap, json['type']),
  status: $enumDecode(_$PaymentRequestStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$PaymentRequestEntityImplToJson(
  _$PaymentRequestEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'fromUserId': instance.fromUserId,
  'toUserId': instance.toUserId,
  'amount': instance.amount,
  'description': instance.description,
  'type': _$PaymentRequestTypeEnumMap[instance.type]!,
  'status': _$PaymentRequestStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$PaymentRequestTypeEnumMap = {
  PaymentRequestType.pay: 'pay',
  PaymentRequestType.receive: 'receive',
  PaymentRequestType.settle: 'settle',
};

const _$PaymentRequestStatusEnumMap = {
  PaymentRequestStatus.pending: 'pending',
  PaymentRequestStatus.accepted: 'accepted',
  PaymentRequestStatus.paid: 'paid',
  PaymentRequestStatus.rejected: 'rejected',
};

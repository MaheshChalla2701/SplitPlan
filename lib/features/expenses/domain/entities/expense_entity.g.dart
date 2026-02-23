// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseEntityImpl _$$ExpenseEntityImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseEntityImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: (json['paidBy'] as List<dynamic>)
          .map((e) => PaymentShare.fromJson(e as Map<String, dynamic>))
          .toList(),
      splitBetween: (json['splitBetween'] as List<dynamic>)
          .map((e) => ExpenseShare.fromJson(e as Map<String, dynamic>))
          .toList(),
      acceptedBy:
          (json['acceptedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$$ExpenseEntityImplToJson(_$ExpenseEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'description': instance.description,
      'amount': instance.amount,
      'paidBy': instance.paidBy,
      'splitBetween': instance.splitBetween,
      'acceptedBy': instance.acceptedBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };

_$PaymentShareImpl _$$PaymentShareImplFromJson(Map<String, dynamic> json) =>
    _$PaymentShareImpl(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$PaymentShareImplToJson(_$PaymentShareImpl instance) =>
    <String, dynamic>{'userId': instance.userId, 'amount': instance.amount};

_$ExpenseShareImpl _$$ExpenseShareImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseShareImpl(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$ExpenseShareImplToJson(_$ExpenseShareImpl instance) =>
    <String, dynamic>{'userId': instance.userId, 'amount': instance.amount};

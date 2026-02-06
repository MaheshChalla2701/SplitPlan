import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_entity.freezed.dart';
part 'expense_entity.g.dart';

@freezed
class ExpenseEntity with _$ExpenseEntity {
  const factory ExpenseEntity({
    required String id,
    required String groupId,
    required String description,
    required double amount,
    required List<PaymentShare> paidBy,
    required List<ExpenseShare> splitBetween,
    required DateTime createdAt,
    required String createdBy,
  }) = _ExpenseEntity;

  factory ExpenseEntity.fromJson(Map<String, dynamic> json) =>
      _$ExpenseEntityFromJson(json);
}

@freezed
class PaymentShare with _$PaymentShare {
  const factory PaymentShare({required String userId, required double amount}) =
      _PaymentShare;

  factory PaymentShare.fromJson(Map<String, dynamic> json) =>
      _$PaymentShareFromJson(json);
}

@freezed
class ExpenseShare with _$ExpenseShare {
  const factory ExpenseShare({required String userId, required double amount}) =
      _ExpenseShare;

  factory ExpenseShare.fromJson(Map<String, dynamic> json) =>
      _$ExpenseShareFromJson(json);
}

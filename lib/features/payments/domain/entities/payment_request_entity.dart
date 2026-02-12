import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_request_entity.freezed.dart';
part 'payment_request_entity.g.dart';

@freezed
class PaymentRequestEntity with _$PaymentRequestEntity {
  const factory PaymentRequestEntity({
    required String id,
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? description,
    required PaymentRequestType type,
    required PaymentRequestStatus status,
    required DateTime createdAt,
  }) = _PaymentRequestEntity;

  factory PaymentRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestEntityFromJson(json);
}

enum PaymentRequestType {
  pay, // I want to PAY someone
  receive, // I want to RECEIVE money from someone
  settle, // I am SETTLING a debt (partial or full)
}

enum PaymentRequestStatus { pending, accepted, paid, rejected }

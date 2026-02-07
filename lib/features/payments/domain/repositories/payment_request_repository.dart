import '../entities/payment_request_entity.dart';

abstract class PaymentRequestRepository {
  // Create and manage payment requests
  Future<void> createPaymentRequest(PaymentRequestEntity request);
  Future<void> updateRequestStatus(
    String requestId,
    PaymentRequestStatus status,
  );
  Future<void> deletePaymentRequest(String requestId);

  // Get payment requests
  Stream<List<PaymentRequestEntity>> getPaymentRequests(String userId);
  Stream<List<PaymentRequestEntity>> getPaymentRequestsWithFriend(
    String userId,
    String friendId,
  );

  // Get individual request
  Future<PaymentRequestEntity?> getPaymentRequest(String requestId);
}

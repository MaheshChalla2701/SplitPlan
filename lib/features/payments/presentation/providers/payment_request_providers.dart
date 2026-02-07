import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/payment_request_repository_impl.dart';
import '../../domain/entities/payment_request_entity.dart';
import '../../domain/repositories/payment_request_repository.dart';

part 'payment_request_providers.g.dart';

// Payment Request Repository Provider
@riverpod
PaymentRequestRepository paymentRequestRepository(Ref ref) {
  return PaymentRequestRepositoryImpl(ref.watch(firebaseFirestoreProvider));
}

// User Payment Requests Stream Provider
@riverpod
Stream<List<PaymentRequestEntity>> userPaymentRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(paymentRequestRepositoryProvider)
      .getPaymentRequests(user.id);
}

// Payment Requests with Friend Provider
@riverpod
Stream<List<PaymentRequestEntity>> paymentRequestsWithFriend(
  Ref ref,
  String friendId,
) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(paymentRequestRepositoryProvider)
      .getPaymentRequestsWithFriend(user.id, friendId);
}

// Create Payment Request Controller
@riverpod
class CreatePaymentRequestController extends _$CreatePaymentRequestController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createRequest(PaymentRequestEntity request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(paymentRequestRepositoryProvider)
          .createPaymentRequest(request);
    });
  }
}

// Update Payment Request Status Controller
@riverpod
class UpdatePaymentRequestController extends _$UpdatePaymentRequestController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> updateStatus(
    String requestId,
    PaymentRequestStatus status,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(paymentRequestRepositoryProvider)
          .updateRequestStatus(requestId, status);
    });
  }

  Future<void> deleteRequest(String requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(paymentRequestRepositoryProvider)
          .deletePaymentRequest(requestId);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../payments/domain/entities/payment_request_entity.dart';
import '../../../payments/presentation/providers/payment_request_providers.dart';

class FriendDetailScreen extends ConsumerWidget {
  final String friendId;

  const FriendDetailScreen({super.key, required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentRequestsAsync = ref.watch(userPaymentRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: paymentRequestsAsync.when(
        data: (allRequests) {
          // Filter requests related to this friend
          final friendRequests = allRequests.where((request) {
            return request.fromUserId == friendId ||
                request.toUserId == friendId;
          }).toList();

          if (friendRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No payment history',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to create payment request
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Payment Request'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              final request = friendRequests[index];
              final isPayer = request.fromUserId == friendId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPayer ? Colors.green : Colors.red,
                    child: Icon(
                      isPayer ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(request.description),
                  subtitle: Text(
                    '${isPayer ? "They owe you" : "You owe"} \$${request.amount.toStringAsFixed(2)}',
                  ),
                  trailing: _buildStatusChip(request.status),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create payment request with this friend
        },
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  Widget _buildStatusChip(PaymentRequestStatus status) {
    Color color;
    String label;

    switch (status) {
      case PaymentRequestStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case PaymentRequestStatus.paid:
        color = Colors.green;
        label = 'Paid';
        break;
      case PaymentRequestStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
    }

    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
    );
  }
}

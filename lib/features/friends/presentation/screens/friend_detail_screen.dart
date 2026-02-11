import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../payments/domain/entities/payment_request_entity.dart';
import '../../../payments/presentation/providers/payment_request_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class FriendDetailScreen extends ConsumerWidget {
  final String friendId;

  const FriendDetailScreen({super.key, required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentRequestsAsync = ref.watch(userPaymentRequestsProvider);
    final currentUserId = ref.watch(authStateProvider).value?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: paymentRequestsAsync.when(
        data: (allRequests) {
          // Filter requests related to this friend
          final friendRequests = allRequests.where((request) {
            return request.fromUserId == friendId ||
                request.toUserId == friendId;
          }).toList();

          // Sort by creation date (Newest first for reversed list)
          friendRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
                      context.push('/friends/$friendId/create-request');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Payment Request'),
                  ),
                ],
              ),
            );
          }

          // Calculate Net Balance for this friend
          double toPay = 0;
          double toReceive = 0;

          for (final request in friendRequests) {
            if (request.status != PaymentRequestStatus.accepted) continue;

            if (request.fromUserId == currentUserId) {
              if (request.type == PaymentRequestType.receive) {
                toReceive += request.amount;
              } else {
                toPay += request.amount;
              }
            } else {
              if (request.type == PaymentRequestType.receive) {
                toPay += request.amount;
              } else {
                toReceive += request.amount;
              }
            }
          }

          final netBalance = toReceive - toPay;

          return Column(
            children: [
              // Net Balance Summary Card
              if (friendRequests.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Net Balance',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            netBalance >= 0 ? 'Owes you' : 'You owe',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${netBalance.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: netBalance >= 0
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(
                    top: 0, // Removed top padding as card provides it
                    left: 16,
                    right: 16,
                    bottom: 80, // Space for FAB
                  ),
                  itemCount: friendRequests.length,
                  itemBuilder: (context, index) {
                    final request = friendRequests[index];
                    final isOutgoing = request.fromUserId == currentUserId;
                    final isIncoming = request.toUserId == currentUserId;

                    // Determine subtitle text
                    String subtitleText;
                    if (request.status == PaymentRequestStatus.pending) {
                      if (request.type == PaymentRequestType.receive) {
                        subtitleText = isIncoming
                            ? 'Asking for'
                            : 'You asked for';
                      } else {
                        subtitleText = isIncoming
                            ? 'Recorded payment of'
                            : 'You recorded payment of';
                      }
                    } else if (request.status ==
                        PaymentRequestStatus.accepted) {
                      if (request.type == PaymentRequestType.receive) {
                        if (request.fromUserId == friendId) {
                          subtitleText = 'You owe';
                        } else {
                          subtitleText = 'They owe';
                        }
                      } else {
                        subtitleText = 'Payment accepted';
                      }
                    } else {
                      subtitleText = 'Paid';
                    }

                    subtitleText += ' \$${request.amount.toStringAsFixed(2)}';

                    // WhatsApp Style Colors
                    final sentColor = Colors.grey[200]; // Light gray for sent
                    final receivedColor = Colors.white;

                    return Align(
                      alignment: isOutgoing
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.85,
                        child: Card(
                          color: isOutgoing ? sentColor : receivedColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isOutgoing
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: isOutgoing
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Leading Icon (Smaller)
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: _getStatusColor(
                                        request.status,
                                      ).withOpacity(0.2),
                                      child: Icon(
                                        (request.type ==
                                                    PaymentRequestType
                                                        .receive) ==
                                                isOutgoing
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        color: _getStatusColor(request.status),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Title & Subtitle
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (request.description?.isNotEmpty ==
                                                    true)
                                                ? request.description!
                                                : (request.type ==
                                                          PaymentRequestType
                                                              .receive
                                                      ? 'Payment Request'
                                                      : 'Payment Sent'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            subtitleText,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Trailing Status + Actions
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _buildStatusChip(request.status),
                                        if (request.status ==
                                                PaymentRequestStatus.pending &&
                                            isIncoming) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  ref
                                                      .read(
                                                        updatePaymentRequestControllerProvider
                                                            .notifier,
                                                      )
                                                      .updateStatus(
                                                        request.id,
                                                        PaymentRequestStatus
                                                            .rejected,
                                                      );
                                                },
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              InkWell(
                                                onTap: () {
                                                  final newStatus =
                                                      request.type ==
                                                          PaymentRequestType
                                                              .receive
                                                      ? PaymentRequestStatus
                                                            .accepted
                                                      : PaymentRequestStatus
                                                            .paid;
                                                  ref
                                                      .read(
                                                        updatePaymentRequestControllerProvider
                                                            .notifier,
                                                      )
                                                      .updateStatus(
                                                        request.id,
                                                        newStatus,
                                                      );
                                                },
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                  size: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                // Mark as Paid Row
                                if (request.status ==
                                        PaymentRequestStatus.accepted &&
                                    request.fromUserId != friendId &&
                                    request.type ==
                                        PaymentRequestType.receive) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          ref
                                              .read(
                                                updatePaymentRequestControllerProvider
                                                    .notifier,
                                              )
                                              .updateStatus(
                                                request.id,
                                                PaymentRequestStatus.paid,
                                              );
                                        },
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Mark as Paid',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 2,
                                          ),
                                          minimumSize: const Size(0, 28),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/friends/$friendId/create-request');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  Widget _buildStatusChip(PaymentRequestStatus status) {
    String label;
    Color color = _getStatusColor(status);

    switch (status) {
      case PaymentRequestStatus.pending:
        label = 'Pending';
        break;
      case PaymentRequestStatus.accepted:
        label = 'Accepted';
        break;
      case PaymentRequestStatus.paid:
        label = 'Paid';
        break;
      case PaymentRequestStatus.rejected:
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentRequestStatus status) {
    switch (status) {
      case PaymentRequestStatus.pending:
        return Colors.orange;
      case PaymentRequestStatus.accepted:
        return Colors.blue;
      case PaymentRequestStatus.paid:
        return Colors.green;
      case PaymentRequestStatus.rejected:
        return Colors.red;
    }
  }
}

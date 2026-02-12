import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../payments/domain/entities/payment_request_entity.dart';
import '../../../payments/presentation/providers/payment_request_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../presentation/providers/friends_providers.dart';

class FriendDetailScreen extends ConsumerWidget {
  final String friendId;

  const FriendDetailScreen({super.key, required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentRequestsAsync = ref.watch(userPaymentRequestsProvider);
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final friendAsync = ref.watch(specificFriendProvider(friendId));

    ref.listen(mergeManualFriendControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend merged successfully!')),
          );
          context.pop(); // Go back to friends list since manual friend is gone
        },
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        },
      );
    });

    return friendAsync.when(
      data: (friend) {
        if (friend == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Friend not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.name),
                Text(
                  friend.isManual
                      ? '#${friend.name.toLowerCase().replaceAll(' ', '_')}'
                      : '@${friend.username}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              if (friend.isManual)
                TextButton.icon(
                  onPressed: () => _showMergeDialog(context, ref, friend),
                  icon: const Icon(Icons.merge_type, size: 20),
                  label: const Text('Merge'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
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
                if (request.status != PaymentRequestStatus.accepted &&
                    request.status != PaymentRequestStatus.paid)
                  continue;

                if (request.fromUserId == currentUserId) {
                  if (request.type == PaymentRequestType.receive ||
                      request.type == PaymentRequestType.settle) {
                    toReceive += request.amount;
                  } else {
                    toPay += request.amount;
                  }
                } else {
                  if (request.type == PaymentRequestType.receive ||
                      request.type == PaymentRequestType.settle) {
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Net Balance',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.7),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
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
                              if (netBalance != 0) ...[
                                const SizedBox(height: 8),
                                FilledButton.tonalIcon(
                                  onPressed: () => _showSettleDialog(
                                    context,
                                    ref,
                                    friendId,
                                    netBalance,
                                  ),
                                  icon: const Icon(Icons.handshake, size: 16),
                                  label: Text(
                                    netBalance < 0
                                        ? 'Settle Up'
                                        : 'Record Payment',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.green[50],
                                    foregroundColor: Colors.green[700],
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ],
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
                          } else if (request.type == PaymentRequestType.pay) {
                            subtitleText = isIncoming
                                ? 'Recorded payment of'
                                : 'You recorded payment of';
                          } else {
                            // Settle
                            subtitleText = isIncoming
                                ? 'Wants to settle'
                                : 'You offered to settle';
                          }
                        } else if (request.status ==
                            PaymentRequestStatus.accepted) {
                          if (request.type == PaymentRequestType.receive) {
                            if (request.fromUserId == friendId) {
                              subtitleText = 'You owe';
                            } else {
                              subtitleText = 'They owe';
                            }
                          } else if (request.type == PaymentRequestType.pay) {
                            subtitleText = 'Payment accepted';
                          } else {
                            subtitleText = 'Settlement accepted';
                          }
                        } else {
                          subtitleText = 'Paid';
                        }

                        subtitleText +=
                            ' \$${request.amount.toStringAsFixed(2)}';

                        // WhatsApp Style Colors
                        final sentColor =
                            Colors.grey[200]; // Light gray for sent
                        final receivedColor = Colors.white;
                        final settleColor =
                            Colors.green[50]; // Revert to Green for settlements

                        final cardColor =
                            request.type == PaymentRequestType.settle
                            ? settleColor
                            : (isOutgoing ? sentColor : receivedColor);

                        return Align(
                          alignment: isOutgoing
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.85,
                            child: Card(
                              color: cardColor,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: _getStatusColor(
                                              request.status,
                                            ),
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
                                                (request
                                                            .description
                                                            ?.isNotEmpty ==
                                                        true)
                                                    ? request.description!
                                                    : (request.type ==
                                                              PaymentRequestType
                                                                  .receive
                                                          ? 'Payment Request'
                                                          : (request.type ==
                                                                    PaymentRequestType
                                                                        .pay
                                                                ? 'Payment Sent'
                                                                : 'Settlement Request')),
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
                                                    PaymentRequestStatus
                                                        .pending &&
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
            onPressed: () => context.push('/friends/$friendId/create-request'),
            icon: const Icon(Icons.add),
            label: const Text('New Request'),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading friend: $err')),
      ),
    );
  }

  Future<void> _showMergeDialog(
    BuildContext context,
    WidgetRef ref,
    UserEntity manualFriend,
  ) async {
    final searchController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Merge ${manualFriend.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find a real user account to link with this manual friend.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by username',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    onChanged: (val) => ref
                        .read(searchUsersControllerProvider.notifier)
                        .searchByUsername(val),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final results = ref.watch(searchUsersControllerProvider);
                  return results.when(
                    data: (users) {
                      final filteredUsers = users
                          .where((u) => !u.isManual) // Only real users
                          .toList();

                      if (filteredUsers.isEmpty) {
                        return const Center(child: Text('No real users found'));
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(user.name[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(user.name),
                            subtitle: Text('@${user.username}'),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Merge'),
                                  content: Text(
                                    'Are you sure you want to merge #${manualFriend.name} into @${user.username}?\n\nThis will transfer all history and delete the manual record.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Merge'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                Navigator.pop(context); // Close sheet
                                ref
                                    .read(
                                      mergeManualFriendControllerProvider
                                          .notifier,
                                    )
                                    .merge(
                                      manualFriendId: manualFriend.id,
                                      realUserId: user.id,
                                    );
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSettleDialog(
    BuildContext context,
    WidgetRef ref,
    String friendId,
    double netBalance,
  ) async {
    final isOwesYou = netBalance >= 0;
    final maxAmount = netBalance.abs();

    final amountController = TextEditingController(
      text: maxAmount.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isOwesYou ? 'Record Settlement' : 'Settle Up'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isOwesYou
                    ? 'Enter the amount you received. This will record a payment from your friend.'
                    : 'Enter the amount you paid. This will send a request to your friend to confirm the settlement.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                final currentUser = ref.read(authStateProvider).value!;

                try {
                  final request = PaymentRequestEntity(
                    id: const Uuid().v4(),
                    fromUserId: currentUser.id,
                    toUserId: friendId,
                    amount: amount,
                    type: isOwesYou
                        ? PaymentRequestType.pay
                        : PaymentRequestType.settle,
                    description: isOwesYou
                        ? 'Settlement Received'
                        : 'Settlement',
                    status: isOwesYou
                        ? PaymentRequestStatus.accepted
                        : PaymentRequestStatus.pending,
                    createdAt: DateTime.now(),
                  );

                  await ref
                      .read(createPaymentRequestControllerProvider.notifier)
                      .createRequest(request);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isOwesYou
                              ? 'Settlement recorded'
                              : 'Settlement request sent',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            child: Text(isOwesYou ? 'Record' : 'Send Request'),
          ),
        ],
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../payments/domain/entities/payment_request_entity.dart';
import '../../../payments/presentation/providers/payment_request_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/friendship_entity.dart';
import '../../presentation/providers/friends_providers.dart';
import '../../../settlements/domain/services/nudge_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../groups/presentation/providers/group_providers.dart';

class FriendDetailScreen extends ConsumerWidget {
  final String friendId;

  const FriendDetailScreen({super.key, required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentRequestsAsync = ref.watch(userPaymentRequestsProvider);
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final friendAsync = ref.watch(specificFriendProvider(friendId));
    final friendshipStatusAsync = ref.watch(friendshipStatusProvider(friendId));
    final friendshipDetailsAsync = ref.watch(
      friendshipDetailsProvider(friendId),
    );

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
    ref.listen(sendFriendRequestControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Friend request sent!')));
          ref.invalidate(friendshipStatusProvider(friendId));
        },
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        },
      );
    });

    // Listen to Clear Chat errors/success
    ref.listen(clearChatHistoryControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Chat history cleared')));
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing chat: $error')),
          );
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

        // Check if the other user still has us as a friend (Soft Delete Check)
        // Manual friends don't have a reciprocal list to check, so we assume true.
        final isMutuallyConnected =
            friend.isManual || (friend.friends.contains(currentUserId));

        // Hoist friendship details for AppBar use
        final friendshipDetails = ref
            .watch(friendshipDetailsProvider(friendId))
            .value;

        return Scaffold(
          appBar: AppBar(
            title: Builder(
              builder: (context) => InkWell(
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                ),
              ),
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
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),
          endDrawer: _buildFriendDrawer(
            context,
            ref,
            friend,
            friendshipDetails,
          ),
          body: Column(
            children: [
              // Warning Banner if deleted
              if (!isMutuallyConnected)
                Container(
                  width: double.infinity,
                  color: Colors.red[50],
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'User removed you from friends to continue chat click on re-friend',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: paymentRequestsAsync.when(
                  data: (allRequests) {
                    // Filter requests related to this friend
                    var allFriendRequests = allRequests.where((request) {
                      return request.fromUserId == friendId ||
                          request.toUserId == friendId;
                    }).toList();

                    // Sort by creation date (Newest first)
                    allFriendRequests.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    );

                    // Calculate Net Balance for this friend (using ALL requests)
                    double toPay = 0;
                    double toReceive = 0;

                    for (final request in allFriendRequests) {
                      if (request.status != PaymentRequestStatus.accepted &&
                          request.status != PaymentRequestStatus.paid) {
                        continue;
                      }

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

                    // Apply Clear Chat Filter for UI Display
                    var visibleRequests = List<PaymentRequestEntity>.from(
                      allFriendRequests,
                    );
                    final friendshipDetails = friendshipDetailsAsync.value;
                    if (friendshipDetails?.lastClearedAt != null) {
                      final clearedAt = friendshipDetails!.lastClearedAt!;
                      visibleRequests = visibleRequests
                          .where((r) => r.createdAt.isAfter(clearedAt))
                          .toList();
                    }

                    return Column(
                      children: [
                        // Net Balance Summary Card
                        if (visibleRequests.isNotEmpty || netBalance != 0)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
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
                                            .withValues(alpha: 0.7),
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
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '₹${netBalance.abs().toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: netBalance >= 0
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    if (netBalance != 0 &&
                                        isMutuallyConnected) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: 8,
                                        runSpacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.end,
                                        children: [
                                          if (netBalance > 0 &&
                                              friend.phoneNumber != null)
                                            IconButton(
                                              onPressed: () async {
                                                final currentUserPos = ref.read(
                                                  authStateProvider,
                                                );
                                                final currentUpiId =
                                                    currentUserPos.value?.upiId;

                                                await ref
                                                    .read(nudgeServiceProvider)
                                                    .sendWhatsAppNudge(
                                                      phone:
                                                          friend.phoneNumber!,
                                                      friendName: friend.name,
                                                      amount: netBalance.abs(),
                                                      upiId: currentUpiId,
                                                    );
                                              },
                                              icon: const Icon(
                                                Icons
                                                    .notifications_active_outlined,
                                                size: 20,
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor:
                                                    Colors.green[100],
                                                foregroundColor:
                                                    Colors.green[800],
                                                visualDensity:
                                                    VisualDensity.compact,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              tooltip: 'Send Reminder',
                                            ),
                                          FilledButton.tonalIcon(
                                            onPressed: () => _showSettleDialog(
                                              context,
                                              ref,
                                              friend,
                                              netBalance,
                                            ),
                                            icon: const Icon(
                                              Icons.handshake,
                                              size: 16,
                                            ),
                                            label: Text(
                                              netBalance < 0
                                                  ? 'Settle Up'
                                                  : 'Record Payment',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.green[50],
                                              foregroundColor:
                                                  Colors.green[700],
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                        if (visibleRequests.isEmpty)
                          Expanded(
                            child: Center(
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
                                    'No visible history',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.only(
                                top: 0,
                                left: 16,
                                right: 16,
                                bottom: 80,
                              ),
                              itemCount: visibleRequests.length,
                              itemBuilder: (context, index) {
                                final request = visibleRequests[index];
                                final isOutgoing =
                                    request.fromUserId == currentUserId;
                                final isIncoming =
                                    request.toUserId == currentUserId;

                                // Determine subtitle text
                                String subtitleText;
                                if (request.status ==
                                    PaymentRequestStatus.pending) {
                                  if (request.type ==
                                      PaymentRequestType.receive) {
                                    subtitleText = isIncoming
                                        ? 'Asking for'
                                        : 'You asked for';
                                  } else if (request.type ==
                                      PaymentRequestType.pay) {
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
                                  if (request.type ==
                                      PaymentRequestType.receive) {
                                    if (request.fromUserId == friendId) {
                                      subtitleText = 'You owe';
                                    } else {
                                      subtitleText = 'They owe';
                                    }
                                  } else if (request.type ==
                                      PaymentRequestType.pay) {
                                    subtitleText = 'Payment accepted';
                                  } else {
                                    subtitleText = 'Settlement accepted';
                                  }
                                } else {
                                  subtitleText = 'Paid';
                                }

                                subtitleText +=
                                    ' \$${request.amount.toStringAsFixed(2)}';

                                // Theme-aware colors
                                final isDark =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                final sentColor = isDark
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest
                                    : Colors.grey[200];
                                final receivedColor = Theme.of(
                                  context,
                                ).cardColor;
                                final settleColor = isDark
                                    ? Colors.green[900]?.withValues(alpha: 0.3)
                                    : Colors.green[50];

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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Leading Icon (Smaller)
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor:
                                                      _getStatusColor(
                                                        request.status,
                                                      ).withValues(alpha: 0.2),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        (request
                                                                    .description
                                                                    ?.isNotEmpty ==
                                                                true)
                                                            ? request
                                                                  .description!
                                                            : (request.type ==
                                                                      PaymentRequestType
                                                                          .receive
                                                                  ? 'Payment Request'
                                                                  : (request.type ==
                                                                            PaymentRequestType.pay
                                                                        ? 'Payment Sent'
                                                                        : 'Settlement Request')),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        subtitleText,
                                                        style: TextStyle(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Trailing Status + Actions
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    _buildStatusChip(
                                                      request.status,
                                                    ),
                                                    // Edit/Delete for Outgoing Pending Requests
                                                    if (request.status ==
                                                            PaymentRequestStatus
                                                                .pending &&
                                                        !isIncoming) ...[
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          InkWell(
                                                            onTap: () =>
                                                                _showEditRequestDialog(
                                                                  context,
                                                                  ref,
                                                                  request,
                                                                ),
                                                            child: const Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.blue,
                                                              size: 22,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          InkWell(
                                                            onTap: () =>
                                                                _deleteRequest(
                                                                  context,
                                                                  ref,
                                                                  request,
                                                                ),
                                                            child: const Icon(
                                                              Icons.close,
                                                              color: Colors.red,
                                                              size: 22,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                    if (request.status ==
                                                            PaymentRequestStatus
                                                                .pending &&
                                                        isIncoming &&
                                                        isMutuallyConnected) ...[
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
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
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
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
                                                              color:
                                                                  Colors.green,
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
          floatingActionButton: isMutuallyConnected
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      context.push('/friends/$friendId/create-request'),
                  icon: const Icon(Icons.add),
                  label: const Text('New Request'),
                )
              : friendshipStatusAsync.when(
                  data: (status) {
                    if (status == 'pending') {
                      return FloatingActionButton.extended(
                        onPressed: null,
                        icon: const Icon(Icons.schedule),
                        label: const Text('Requested'),
                        backgroundColor: Colors.grey,
                      );
                    }
                    return FloatingActionButton.extended(
                      onPressed: () async {
                        await ref
                            .read(sendFriendRequestControllerProvider.notifier)
                            .sendRequest(friendId);
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Re-Friend'),
                      backgroundColor: Colors.orange,
                    );
                  },
                  loading: () => const FloatingActionButton(
                    onPressed: null,
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, stack) => FloatingActionButton.extended(
                    onPressed: () async {
                      await ref
                          .read(sendFriendRequestControllerProvider.notifier)
                          .sendRequest(friendId);
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Re-Friend'),
                    backgroundColor: Colors.orange,
                  ),
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
    UserEntity friend,
    double netBalance,
  ) async {
    final friendId = friend.id;
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
                  prefixText: '₹ ',
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
              if (!isOwesYou &&
                  friend.upiId != null &&
                  friend.upiId!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        HapticFeedback.lightImpact();
                        Clipboard.setData(ClipboardData(text: friend.upiId!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text('UPI ID copied to clipboard'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Copy UPI ID',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    friend.upiId!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Copy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (!isOwesYou) ...[
                const SizedBox(height: 16),
                Text(
                  'No UPI ID found for ${friend.name}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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

  Future<void> _showEditRequestDialog(
    BuildContext context,
    WidgetRef ref,
    PaymentRequestEntity request,
  ) async {
    final amountController = TextEditingController(
      text: request.amount.toStringAsFixed(2),
    );
    final descriptionController = TextEditingController(
      text: request.description ?? '',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Request'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹',
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
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
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
                final updatedRequest = request.copyWith(
                  amount: amount,
                  description: descriptionController.text.trim(),
                );

                try {
                  await ref
                      .read(updatePaymentRequestControllerProvider.notifier)
                      .updateDetails(updatedRequest);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request updated')),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRequest(
    BuildContext context,
    WidgetRef ref,
    PaymentRequestEntity request,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request?'),
        content: const Text(
          'Are you sure you want to delete this specific request? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ref
            .read(updatePaymentRequestControllerProvider.notifier)
            .deleteRequest(request.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Request deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
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

  Widget _buildFriendDrawer(
    BuildContext context,
    WidgetRef ref,
    UserEntity friend,
    FriendshipEntity? friendshipDetails,
  ) {
    final currentUser = ref.watch(authStateProvider).value;
    final groupsAsync = ref.watch(userGroupsProvider);
    final isMuted = currentUser?.mutedUids.contains(friend.id) ?? false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(friend.name),
            accountEmail: Text(
              friend.isManual ? '#Manual Friend' : '@${friend.username}',
            ),
            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundImage: friend.avatarUrl != null
                  ? NetworkImage(friend.avatarUrl!)
                  : null,
              child: friend.avatarUrl == null
                  ? Text(
                      friend.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (friend.phoneNumber != null)
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Phone Number'),
              subtitle: Text(friend.phoneNumber!),
              onTap: () {
                // Future enhancement: copy to clipboard or launch dialer
                Clipboard.setData(ClipboardData(text: friend.phoneNumber!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone number copied to clipboard'),
                  ),
                );
              },
            ),
          if (friend.upiId != null)
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('UPI ID'),
              subtitle: Text(friend.upiId!),
              onTap: () {
                Clipboard.setData(ClipboardData(text: friend.upiId!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UPI ID copied to clipboard')),
                );
              },
            ),
          if (friend.phoneNumber != null || friend.upiId != null)
            const Divider(),
          if (currentUser != null && !friend.isManual)
            SwitchListTile(
              title: const Text('Mute Notifications'),
              subtitle: const Text('For direct payments and common groups'),
              secondary: const Icon(Icons.notifications_off_outlined),
              value: isMuted,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (value) async {
                try {
                  final updatedMutedUids = List<String>.from(
                    currentUser.mutedUids,
                  );
                  if (value) {
                    if (!updatedMutedUids.contains(friend.id)) {
                      updatedMutedUids.add(friend.id);
                    }
                  } else {
                    updatedMutedUids.remove(friend.id);
                  }

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.id)
                      .update({'mutedUids': updatedMutedUids});

                  // ignore: unused_result
                  ref.refresh(authStateProvider);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating setting: $e')),
                  );
                }
              },
            ),
          SwitchListTile(
            title: const Text('Auto Accept Requests'),
            subtitle: const Text(
              'Automatically accept payments from this friend',
            ),
            value: friendshipDetails?.isAutoAccept ?? false,
            onChanged: (value) async {
              await ref
                  .read(updateAutoAcceptControllerProvider.notifier)
                  .updateAutoAccept(friendId, value);
            },
            secondary: Icon(
              Icons.task_alt,
              color: (friendshipDetails?.isAutoAccept ?? false)
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
          const Divider(),
          if (!friend.isManual)
            groupsAsync.when(
              data: (allGroups) {
                final commonGroups = allGroups.where((group) {
                  return group.memberIds.contains(friend.id);
                }).toList();

                if (commonGroups.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Common Groups (${commonGroups.length})',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    ...commonGroups.map(
                      (group) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.groups,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        title: Text(group.name),
                        subtitle: Text('${group.memberIds.length} members'),
                        trailing: const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          context.push('/groups/${group.id}');
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading common groups: $err'),
              ),
            ),
          ListTile(
            leading: const Icon(
              Icons.delete_sweep_outlined,
              color: Colors.orange,
            ),
            title: const Text('Clear Chat'),
            onTap: () async {
              Navigator.pop(context); // Close drawer

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat?'),
                  content: const Text(
                    'This will hide all transaction history from this view.\n\nYour net balance with this friend will remain unchanged.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // Calculate Net Balance for this friend (using ALL requests)
                final allRequests = await ref.read(
                  paymentRequestsWithFriendProvider(friendId).future,
                );

                double toPay = 0;
                double toReceive = 0;
                final currentUserId = ref.read(authStateProvider).value?.id;

                for (final request in allRequests) {
                  if (request.status != PaymentRequestStatus.accepted &&
                      request.status != PaymentRequestStatus.paid) {
                    continue;
                  }

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

                await ref
                    .read(clearChatHistoryControllerProvider.notifier)
                    .clearHistory(friendId, netBalance);
              }
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.person_remove_outlined,
              color: Colors.red,
            ),
            title: const Text(
              'Delete Friend',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context); // Close drawer

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Friend?'),
                  content: Text(
                    friend.isManual
                        ? 'This will permanently delete this manual friend and all associated history.'
                        : 'This will remove ${friend.name} from your friends list.\n\nYour transaction history will be kept, but you won\'t be able to send new requests until you re-friend them.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                try {
                  await ref
                      .read(deleteFriendControllerProvider.notifier)
                      .deleteFriend(friend.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Friend deleted successfully'),
                      ),
                    );
                    context.go('/'); // Go back to home
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting friend: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

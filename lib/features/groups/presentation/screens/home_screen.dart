import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../friends/presentation/providers/friends_providers.dart';
import '../../../payments/domain/entities/payment_request_entity.dart';
import '../../../payments/presentation/providers/payment_request_providers.dart';
import '../providers/group_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final friendsAsync = ref.watch(userFriendsProvider);
    final groupsAsync = ref.watch(userGroupsProvider);
    final paymentRequestsAsync = ref.watch(userPaymentRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SplitPlan'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () {
              // Show notifications bottom sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) => _buildNotificationsSheet(context, ref),
              );
            },
            icon: const Badge(
              // TODO: Wire up real pending count if needed, or just show dot
              label: Text('!'),
              isLabelVisible: false,
              child: Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Menu',
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'add_group':
                  context.push('/create-group');
                  break;
                case 'change_password':
                  context.push('/change-password');
                  break;
                case 'sign_out':
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ref
                                .read(signOutControllerProvider.notifier)
                                .signOut();
                          },
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_group',
                child: Row(
                  children: [
                    Icon(Icons.group_add, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Add Group'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(Icons.vpn_key, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Change Password'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sign_out',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userFriendsProvider);
          ref.invalidate(userGroupsProvider);
          ref.invalidate(pendingFriendRequestsProvider);
          ref.invalidate(userPaymentRequestsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Welcome
              if (userAsync.value != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome back, ${userAsync.value!.name}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

              // Net Balance Card
              if (paymentRequestsAsync.value != null) ...[
                Builder(
                  builder: (context) {
                    final requests = paymentRequestsAsync.value!;
                    final userId = ref.watch(authStateProvider).value?.id;

                    if (userId == null) return const SizedBox.shrink();

                    double toPay = 0;
                    double toReceive = 0;

                    for (final request in requests) {
                      if (request.status != PaymentRequestStatus.accepted)
                        continue;

                      // Logic for Net Balance (Only Accepted Requests):
                      if (request.fromUserId == userId) {
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

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.tertiary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left Side: Net Balance
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Net Balance',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${netBalance < 0 ? '-' : ''}\$${netBalance.abs().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28, // Slightly smaller font
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  netBalance >= 0 ? 'You are owed' : 'You owe',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Vertical Divider
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.white24,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          // Right Side: Breakdown
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // To Receive
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_upward,
                                      color: Colors.greenAccent,
                                      size: 20, // Increased from 16
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '\$${toReceive.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18, // Increased from 14
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12), // Increased from 8
                                // To Pay
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_downward,
                                      color: Colors.orangeAccent,
                                      size: 20, // Increased from 16
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '\$${toPay.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18, // Increased from 14
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              // Unified List Calculation
              Builder(
                builder: (context) {
                  // 1. Get Data
                  final friends = friendsAsync.value ?? [];
                  final groups = groupsAsync.value ?? [];
                  final paymentRequests = paymentRequestsAsync.value ?? [];
                  final currentUserId = ref.read(authStateProvider).value?.id;

                  // 2. Map Friends to ConversationItems
                  final friendItems = friends.map((friend) {
                    // Find last activity (latest payment request involving this friend)
                    DateTime? lastActivity;
                    String? subtitle;

                    // Filter requests involving this friend
                    final validRequests = paymentRequests
                        .where(
                          (req) =>
                              (req.fromUserId == friend.id &&
                                  req.toUserId == currentUserId) ||
                              (req.fromUserId == currentUserId &&
                                  req.toUserId == friend.id),
                        )
                        .toList();

                    if (validRequests.isNotEmpty) {
                      // Sort by createdAt desc
                      validRequests.sort(
                        (a, b) => b.createdAt.compareTo(a.createdAt),
                      );
                      final latest = validRequests.first;
                      lastActivity = latest.createdAt;

                      // Smart Subtitle
                      if (latest.status == PaymentRequestStatus.accepted) {
                        if (latest.type == PaymentRequestType.receive) {
                          if (latest.fromUserId == currentUserId) {
                            subtitle = 'They owe you \$${latest.amount}';
                          } else {
                            subtitle = 'You owe \$${latest.amount}';
                          }
                        } else {
                          subtitle = 'Payment settled';
                        }
                      } else if (latest.status ==
                          PaymentRequestStatus.pending) {
                        if (latest.toUserId == currentUserId) {
                          subtitle = 'Request pending';
                        } else {
                          subtitle = 'You requested \$${latest.amount}';
                        }
                      } else {
                        subtitle = '${latest.status.name.toUpperCase()}';
                      }
                    } else {
                      // Fallback
                      lastActivity = friend.createdAt;
                      subtitle = 'No recent activity';
                    }

                    return _ConversationItem(
                      id: friend.id,
                      name: friend.name,
                      avatarUrl: friend.avatarUrl,
                      isGroup: false,
                      lastActivity: lastActivity,
                      subtitle: subtitle,
                    );
                  }).toList();

                  // 3. Map Groups to ConversationItems
                  final groupItems = groups.map((group) {
                    // TODO: Fetch real group expense activity.
                    // For now, use createdAt.
                    return _ConversationItem(
                      id: group.id,
                      name: group.name,
                      avatarUrl:
                          null, // Groups don't have avatarUrl in entity yet, handle in UI
                      isGroup: true,
                      lastActivity: group.createdAt,
                      subtitle: '${group.memberIds.length} members',
                    );
                  }).toList();

                  // 4. Combine and Sort
                  final allItems = [...friendItems, ...groupItems];
                  // Sort descending (newest first)
                  allItems.sort(
                    (a, b) => b.lastActivity.compareTo(a.lastActivity),
                  );

                  if (allItems.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No friends or groups yet.'),
                      ),
                    );
                  }

                  // 5. Render
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      final item = allItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: item.isGroup
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceVariant,
                            backgroundImage: item.avatarUrl != null
                                ? NetworkImage(item.avatarUrl!)
                                : null,
                            child: item.avatarUrl == null
                                ? (item.isGroup
                                      ? Icon(
                                          Icons.groups,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        )
                                      : Text(
                                          item.name.isNotEmpty
                                              ? item.name[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ))
                                : null,
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            item.subtitle,
                            style: TextStyle(
                              color: item.isGroup
                                  ? Colors.grey[600]
                                  : (item.subtitle.contains('owe')
                                        ? Colors.orange[800]
                                        : Colors.grey),
                              fontWeight: item.subtitle.contains('owe')
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(item.lastActivity),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (item.isGroup)
                                const Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                          onTap: () {
                            if (item.isGroup) {
                              context.push('/groups/${item.id}');
                            } else {
                              context.push('/friends/${item.id}');
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-chat'),
        tooltip: 'New Chat',
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildNotificationsSheet(BuildContext context, WidgetRef ref) {
    final paymentRequestsAsync = ref.watch(userPaymentRequestsProvider);
    final friendsAsync = ref.watch(userFriendsProvider);
    final userId = ref.read(authStateProvider).value?.id;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: paymentRequestsAsync.when(
              data: (requests) {
                // Filter for PENDING requests from OTHERS
                // OR ACCEPTED requests that I need to PAY (if I am the Payer)
                final relevantRequests = requests.where((req) {
                  // User wants to see ALL PENDING requests (Incoming and Outgoing)
                  return req.status == PaymentRequestStatus.pending;
                }).toList();

                if (relevantRequests.isEmpty) {
                  return const Center(child: Text('No new notifications'));
                }

                // Prepare friends map for quick lookup
                final friends = friendsAsync.value ?? [];
                final friendsMap = {for (var f in friends) f.id: f};

                return ListView.builder(
                  itemCount: relevantRequests.length,
                  itemBuilder: (context, index) {
                    final request = relevantRequests[index];
                    final isIncoming = request.toUserId == userId;

                    final isMyActionRequired =
                        isIncoming &&
                        request.type == PaymentRequestType.receive;

                    final friendId = isIncoming
                        ? request.fromUserId
                        : request.toUserId;

                    final friendName =
                        friendsMap[friendId]?.name ?? 'Unknown User';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            isIncoming
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                          ),
                        ),
                        title: Text(
                          friendName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${isIncoming ? "Requested from you" : "You requested"} \$${request.amount}${request.description != null && request.description!.isNotEmpty ? "\n${request.description}" : ""}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isMyActionRequired
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      // Reject
                                      await ref
                                          .read(
                                            updatePaymentRequestControllerProvider
                                                .notifier,
                                          )
                                          .updateStatus(
                                            request.id,
                                            PaymentRequestStatus.rejected,
                                          );
                                      // Don't pop, allow multiple actions
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      // Accept (Adds to balance)
                                      await ref
                                          .read(
                                            updatePaymentRequestControllerProvider
                                                .notifier,
                                          )
                                          .updateStatus(
                                            request.id,
                                            PaymentRequestStatus.accepted,
                                          );
                                    },
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              )
                            : Chip(
                                label: const Text(
                                  'Pending',
                                  style: TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.orange.withOpacity(0.1),
                                labelPadding: EdgeInsets.zero,
                              ),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/friends/$friendId');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final aDate = DateTime(date.year, date.month, date.day);

  if (aDate == today) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else if (now.difference(date).inDays < 7) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  } else {
    return '${date.day}/${date.month}';
  }
}

class _ConversationItem {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isGroup;
  final DateTime lastActivity;
  final String subtitle;

  _ConversationItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.isGroup,
    required this.lastActivity,
    required this.subtitle,
  });
}

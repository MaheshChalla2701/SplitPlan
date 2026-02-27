import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../friends/presentation/providers/friends_providers.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../payments/domain/entities/payment_request_entity.dart';
import '../../../payments/presentation/providers/payment_request_providers.dart';
import '../providers/group_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _deleteSelectedFriends() async {
    final idsToDelete = _selectedIds.toList();

    // Show confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${idsToDelete.length} selected?'),
        content: const Text(
          'This will permanently delete manual friends and remove real friends. Transaction history will be deleted.',
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

    if (confirmed != true) return;

    try {
      for (final id in idsToDelete) {
        await ref
            .read(deleteFriendControllerProvider.notifier)
            .deleteFriend(id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chats deleted successfully')),
        );
        _exitSelectionMode();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(userFriendsProvider);
    final groupsAsync = ref.watch(userGroupsProvider);
    final paymentRequestsAsync = ref.watch(userPaymentRequestsProvider);

    return Scaffold(
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth:
          MediaQuery.of(context).size.width *
          0.7, // High sensitivity for easy access
      drawer: _buildDrawer(context, ref),
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              ),
              title: Text('${_selectedIds.length} Selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedFriends,
                ),
              ],
            )
          : AppBar(
              title: const Text('SplitPlan'),
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    tooltip: 'Menu',
                  );
                },
              ),

              actions: [
                IconButton(
                  onPressed: () {
                    // Show notifications bottom sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) =>
                          _buildNotificationsSheet(context, ref),
                    );
                  },
                  icon: const Badge(
                    label: Text('!'),
                    isLabelVisible: false,
                    child: Icon(Icons.notifications_outlined),
                  ),
                  tooltip: 'Notifications',
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
              // Content
              const SizedBox(height: 16),

              // Net Balance Card
              if (paymentRequestsAsync.value != null) ...[
                Builder(
                  builder: (context) {
                    final requests = paymentRequestsAsync.value!;
                    final userId = ref.watch(authStateProvider).value?.id;
                    final friends = friendsAsync.value ?? [];

                    if (userId == null) return const SizedBox.shrink();

                    double toPay = 0;
                    double toReceive = 0;
                    final toPayBreakdown = <String, double>{};
                    final toReceiveBreakdown = <String, double>{};

                    final userBalances = <String, double>{};

                    for (final request in requests) {
                      if (request.status != PaymentRequestStatus.accepted &&
                          request.status != PaymentRequestStatus.paid) {
                        continue;
                      }

                      final isFromMe = request.fromUserId == userId;
                      final otherId = isFromMe
                          ? request.toUserId
                          : request.fromUserId;

                      double impact = 0;
                      if (request.type == PaymentRequestType.receive ||
                          request.type == PaymentRequestType.settle) {
                        // Requesting money
                        // If I sent it, they owe me (+). If they sent it, I owe them (-).
                        impact = isFromMe ? request.amount : -request.amount;
                      } else {
                        // Payment/Settlement recording
                        // If I sent it (Record Settlement), it means I received money -> Reduces what they owe me (-).
                        // If they sent it, it means they received money -> Reduces what I owe them (+).
                        impact = isFromMe ? -request.amount : request.amount;
                      }

                      userBalances.update(
                        otherId,
                        (value) => value + impact,
                        ifAbsent: () => impact,
                      );
                    }

                    // Filter out balances from users who are NO LONGER friends
                    // This implements the "Hide Balance" part of Soft Delete
                    userBalances.removeWhere((key, value) {
                      final isFriend = friends.any((f) => f.id == key);
                      return !isFriend;
                    });

                    for (final entry in userBalances.entries) {
                      final balance = entry.value;
                      if (balance > 0) {
                        toReceive += balance;
                        toReceiveBreakdown[entry.key] = balance;
                      } else if (balance < 0) {
                        toPay += balance.abs();
                        toPayBreakdown[entry.key] = balance.abs();
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
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left Side: Net Balance
                          Expanded(
                            flex: 1,
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
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${netBalance < 0 ? '-' : ''}₹${netBalance.abs().toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                Text(
                                  netBalance >= 0 ? 'You are owed' : 'You owe',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
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
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // To Pay
                                InkWell(
                                  onTap: () => _showBreakdown(
                                    context,
                                    'People you owe',
                                    toPayBreakdown,
                                    friends,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.orangeAccent,
                                          size: 20, // Increased from 16
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            '₹${toPay.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18, // Increased from 14
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12), // Increased from 8
                                // To Receive
                                InkWell(
                                  onTap: () => _showBreakdown(
                                    context,
                                    'People who owe you',
                                    toReceiveBreakdown,
                                    friends,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.greenAccent,
                                          size: 20, // Increased from 16
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            '₹${toReceive.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18, // Increased from 14
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                            subtitle = 'They owe you ₹${latest.amount}';
                          } else {
                            subtitle = 'You owe ₹${latest.amount}';
                          }
                        } else {
                          subtitle = 'Payment settled';
                        }
                      } else if (latest.status ==
                          PaymentRequestStatus.pending) {
                        if (latest.toUserId == currentUserId) {
                          subtitle = 'Request pending';
                        } else {
                          subtitle = 'You requested ₹${latest.amount}';
                        }
                      } else {
                        subtitle = latest.status.name.toUpperCase();
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
                      final isSelected = _selectedIds.contains(item.id);

                      return Card(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.5)
                            : null,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          onLongPress: () {
                            // Only allow selecting friends, not groups for now (as per plan implication)
                            if (!item.isGroup) {
                              _enterSelectionMode(item.id);
                            }
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: item.isGroup
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
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
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            item.isGroup
                                ? item.name
                                : (friends.any(
                                        (f) => f.id == item.id && f.isManual,
                                      )
                                      ? '#${item.name.toLowerCase().replaceAll(' ', '_')}'
                                      : '@${friends.firstWhere((f) => f.id == item.id).username}'),
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
                            if (_isSelectionMode) {
                              if (!item.isGroup) {
                                _toggleSelection(item.id);
                              }
                            } else {
                              if (item.isGroup) {
                                context.push('/groups/${item.id}');
                              } else {
                                context.push('/friends/${item.id}');
                              }
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Friend Requests Section
                  Consumer(
                    builder: (context, ref, child) {
                      final friendRequestsAsync = ref.watch(
                        pendingFriendRequestsProvider,
                      );
                      return friendRequestsAsync.when(
                        data: (requests) {
                          if (requests.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Friend Requests (${requests.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ...requests.map((request) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          request.requester.avatarUrl != null
                                          ? NetworkImage(
                                              request.requester.avatarUrl!,
                                            )
                                          : null,
                                      child: request.requester.avatarUrl == null
                                          ? Text(
                                              request.requester.name[0]
                                                  .toUpperCase(),
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      request.requester.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '@${request.requester.username}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await ref
                                                .read(
                                                  acceptFriendRequestControllerProvider
                                                      .notifier,
                                                )
                                                .reject(request.id);
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await ref
                                                .read(
                                                  acceptFriendRequestControllerProvider
                                                      .notifier,
                                                )
                                                .accept(request.id);
                                          },
                                          icon: const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const Divider(),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: LinearProgressIndicator()),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Error loading requests: $err'),
                        ),
                      );
                    },
                  ),
                  // Payment Requests Section
                  paymentRequestsAsync.when(
                    data: (requests) {
                      // Filter for PENDING requests from OTHERS
                      // OR ACCEPTED requests that I need to PAY (if I am the Payer)
                      final relevantRequests = requests.where((req) {
                        // User wants to see ALL PENDING requests (Incoming and Outgoing)
                        return req.status == PaymentRequestStatus.pending;
                      }).toList();

                      if (relevantRequests.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No payment requests'),
                          ),
                        );
                      }

                      // Prepare friends map for quick lookup
                      final friends = friendsAsync.value ?? [];
                      final friendsMap = {for (var f in friends) f.id: f};

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                  (request.type ==
                                              PaymentRequestType.receive) !=
                                          isIncoming
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                ),
                              ),
                              title: Text(
                                friendName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${isIncoming ? "Requested from you" : "You requested"} ₹${request.amount}${request.description != null && request.description!.isNotEmpty ? "\n${request.description}" : ""}',
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
                                      backgroundColor: Colors.orange.withValues(
                                        alpha: 0.1,
                                      ),
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
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBreakdown(
    BuildContext context,
    String title,
    Map<String, double> breakdown,
    List<UserEntity> friends,
  ) {
    if (breakdown.isEmpty) return;

    final friendsMap = {for (var f in friends) f.id: f};

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: breakdown.length,
                  itemBuilder: (context, index) {
                    final friendId = breakdown.keys.elementAt(index);
                    final amount = breakdown.values.elementAt(index);
                    final friend = friendsMap[friendId];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: friend?.avatarUrl != null
                            ? NetworkImage(friend!.avatarUrl!)
                            : null,
                        child: friend?.avatarUrl == null
                            ? Text(friend?.name[0].toUpperCase() ?? '?')
                            : null,
                      ),
                      title: Text(
                        friend != null
                            ? (friend.isManual
                                  ? '#${friend.name.toLowerCase().replaceAll(' ', '_')}'
                                  : '@${friend.username}')
                            : 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Text(
                        '₹${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (friend != null) {
                          context.push('/friends/${friend.id}');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final user = ref.read(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text('@${user.username}'),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
              child: CircleAvatar(
                radius: 40,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add_outlined),
            title: const Text('New Group'),
            onTap: () {
              Navigator.pop(context);
              context.push('/create-group');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              context.push('/change-password');
            },
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: user.notificationsEnabled,
            onChanged: (value) async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .update({'notificationsEnabled': value});
                // ignore: unused_result
                ref.refresh(authStateProvider);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            secondary: const Icon(Icons.notifications_active_outlined),
            activeThumbColor: Theme.of(context).primaryColor,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              _showSignOutConfirmation(context, ref);
            },
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context, WidgetRef ref) {
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
              ref.read(signOutControllerProvider.notifier).signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
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

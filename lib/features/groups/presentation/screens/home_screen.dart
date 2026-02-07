import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../friends/presentation/providers/friends_providers.dart';
import '../../../payments/domain/entities/payment_request_entity.dart';
import '../../../payments/presentation/providers/payment_request_providers.dart';
import '../../domain/entities/group_entity.dart';
import '../providers/group_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(userFriendsProvider);
    final groupsAsync = ref.watch(userGroupsProvider);
    final pendingRequestsAsync = ref.watch(pendingFriendRequestsProvider);
    final paymentRequestsAsync = ref.watch(userPaymentRequestsProvider);

    // Count pending items
    final pendingFriendRequests = pendingRequestsAsync.value?.length ?? 0;
    final pendingPaymentRequests =
        paymentRequestsAsync.value
            ?.where((r) => r.status == PaymentRequestStatus.pending)
            .length ??
        0;
    final totalPending = pendingFriendRequests + pendingPaymentRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.home),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/friends/search'),
            tooltip: 'Find Friends',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
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
        child: ListView(
          children: [
            // Pending requests notification
            if (totalPending > 0)
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(
                      '$totalPending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: const Text('Pending Requests'),
                  subtitle: Text(
                    '$pendingFriendRequests friend${pendingFriendRequests == 1 ? "" : "s"}, '
                    '$pendingPaymentRequests payment${pendingPaymentRequests == 1 ? "" : "s"}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show bottom sheet with pending requests
                    _showPendingRequestsSheet(
                      context,
                      ref,
                      pendingRequestsAsync.value ?? [],
                      paymentRequestsAsync.value
                              ?.where(
                                (r) => r.status == PaymentRequestStatus.pending,
                              )
                              .toList() ??
                          [],
                    );
                  },
                ),
              ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Conversations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            // Unified conversations list
            _buildConversationsList(
              context,
              ref,
              friendsAsync.value ?? [],
              groupsAsync.value ?? [],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionMenu(context),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Add Friend'),
            onTap: () {
              Navigator.pop(context);
              context.push('/friends/search');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Create Group'),
            onTap: () {
              Navigator.pop(context);
              context.push('/create-group');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
    BuildContext context,
    WidgetRef ref,
    List<UserEntity> friends,
    List<GroupEntity> groups,
  ) {
    if (friends.isEmpty && groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No conversations yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Add friends or create a group to get started!',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Friends
        ...friends.map((friend) => _buildFriendTile(context, friend)),

        // Groups
        ...groups.map((group) => _buildGroupTile(context, group)),
      ],
    );
  }

  Widget _buildFriendTile(BuildContext context, UserEntity friend) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friend.avatarUrl != null
            ? NetworkImage(friend.avatarUrl!)
            : null,
        child: friend.avatarUrl == null
            ? Text(friend.name[0].toUpperCase())
            : null,
      ),
      title: Text(friend.name),
      subtitle: const Text('Tap to view payment history'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/friends/${friend.id}'),
    );
  }

  Widget _buildGroupTile(BuildContext context, GroupEntity group) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.group)),
      title: Text(group.name),
      subtitle: Text('${group.memberIds.length} members'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/groups/${group.id}'),
    );
  }

  void _showPendingRequestsSheet(
    BuildContext context,
    WidgetRef ref,
    List pendingFriendRequests,
    List pendingPaymentRequests,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Pending Requests',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // Friend requests section
                  if (pendingFriendRequests.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Friend Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...pendingFriendRequests.map((request) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(request.requester.name[0].toUpperCase()),
                        ),
                        title: Text(request.requester.name),
                        subtitle: Text('@${request.requester.username}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                ref
                                    .read(
                                      acceptFriendRequestControllerProvider
                                          .notifier,
                                    )
                                    .accept(request.id);
                                // Refresh the friend requests and friends list
                                ref.invalidate(pendingFriendRequestsProvider);
                                ref.invalidate(userFriendsProvider);
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                ref
                                    .read(
                                      acceptFriendRequestControllerProvider
                                          .notifier,
                                    )
                                    .reject(request.id);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Payment requests section
                  if (pendingPaymentRequests.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Payment Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...pendingPaymentRequests.map((request) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.attach_money),
                        ),
                        title: Text(request.description),
                        subtitle: Text(
                          '\$${request.amount.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Handle payment
                                Navigator.pop(context);
                              },
                              child: const Text('Pay'),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Empty state
                  if (pendingFriendRequests.isEmpty &&
                      pendingPaymentRequests.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No pending requests'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

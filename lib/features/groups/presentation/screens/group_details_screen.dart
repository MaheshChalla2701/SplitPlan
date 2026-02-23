import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../friends/presentation/providers/friends_providers.dart';
import '../providers/group_providers.dart';

class GroupDetailsScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(groupId));
    final expensesAsync = ref.watch(groupExpensesProvider(groupId));
    final currentUserId = ref.watch(authStateProvider).value?.id;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: groupAsync.when(
          data: (group) => Text(group.name),
          loading: () => const Text(AppConstants.loading),
          error: (_, _) => const Text(AppConstants.error),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: AppConstants.expenses),
                Tab(text: AppConstants.balances),
                Tab(text: AppConstants.members),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ─── Expenses Tab ─────────────────────────────────────
                  expensesAsync.when(
                    data: (expenses) {
                      if (expenses.isEmpty) {
                        return const Center(child: Text('No expenses yet'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          final payerId = expense.paidBy.isNotEmpty
                              ? expense.paidBy.first.userId
                              : null;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Consumer(
                              builder: (context, ref, _) {
                                final payerAsync = payerId != null
                                    ? ref.watch(specificFriendProvider(payerId))
                                    : null;

                                final isMe = payerId == currentUserId;
                                final payerLabel = payerId == null
                                    ? 'Unknown payer'
                                    : isMe
                                    ? 'Paid by you'
                                    : payerAsync?.when(
                                            data: (user) =>
                                                'Paid by ${user?.name ?? payerId}',
                                            loading: () => 'Loading...',
                                            error: (_, _) => 'Paid by $payerId',
                                          ) ??
                                          'Paid by $payerId';

                                final involvedIds = <String>{};
                                for (var p in expense.paidBy) {
                                  if (p.amount > 0) involvedIds.add(p.userId);
                                }
                                for (var s in expense.splitBetween) {
                                  if (s.amount > 0) involvedIds.add(s.userId);
                                }

                                final isAcceptedByAll = involvedIds.every(
                                  (id) => expense.acceptedBy.contains(id),
                                );
                                final needsMyAcceptance =
                                    currentUserId != null &&
                                    involvedIds.contains(currentUserId) &&
                                    !expense.acceptedBy.contains(currentUserId);

                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.85,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer
                                          : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(
                                          isMe ? 16 : 4,
                                        ),
                                        bottomRight: Radius.circular(
                                          isMe ? 4 : 16,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(
                                      left: 14,
                                      right: 4,
                                      top: 4,
                                      bottom: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!isAcceptedByAll && !isMe) ...[
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  top: 8,
                                                  right: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_filled,
                                                      size: 12,
                                                      color: Colors.orange,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Pending',
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Text(
                                                  expense.description,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (!isAcceptedByAll && isMe) ...[
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  top: 8,
                                                  left: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_filled,
                                                      size: 12,
                                                      color: Colors.orange,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Pending',
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: PopupMenuButton<String>(
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  size: 18,
                                                  color: isMe
                                                      ? Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer
                                                            .withValues(
                                                              alpha: 0.7,
                                                            )
                                                      : Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                ),
                                                padding: EdgeInsets.zero,
                                                onSelected: (value) {
                                                  if (value == 'info') {
                                                    _showExpenseInfo(
                                                      context,
                                                      ref,
                                                      expense,
                                                      involvedIds,
                                                    );
                                                  } else if (value == 'edit') {
                                                    context.push(
                                                      '/groups/$groupId/add-expense',
                                                      extra: expense,
                                                    );
                                                  } else if (value ==
                                                      'delete') {
                                                    ref
                                                        .read(
                                                          expenseControllerProvider
                                                              .notifier,
                                                        )
                                                        .deleteExpense(
                                                          expense.id,
                                                        );
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'info',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.info_outline,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text('Info'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text('Edit'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${expense.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: isMe
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          payerLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isMe
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer
                                                      .withValues(alpha: 0.7)
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                          ),
                                        ),
                                        if (!isAcceptedByAll) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Accepted by ${expense.acceptedBy.length}/${involvedIds.length}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isMe
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer
                                                        .withValues(alpha: 0.6)
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                        if (needsMyAcceptance) ...[
                                          const SizedBox(height: 12),
                                          FilledButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    expenseControllerProvider
                                                        .notifier,
                                                  )
                                                  .acceptExpense(expense.id);
                                            },
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              foregroundColor: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              minimumSize: const Size(0, 36),
                                              elevation: 0,
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_outline,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Accept Required',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
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

                  // ─── Balances Tab ─────────────────────────────────────
                  Consumer(
                    builder: (context, ref, child) {
                      final balancesAsync = ref.watch(
                        groupBalancesProvider(groupId),
                      );

                      return balancesAsync.when(
                        data: (balances) {
                          if (balances.isEmpty) {
                            return const Center(
                              child: Text('No balances to settle'),
                            );
                          }

                          // Filter out zero balances
                          final balanceEntries = balances.entries
                              .where((e) => e.value.abs() > 0.01)
                              .toList();

                          if (balanceEntries.isEmpty) {
                            return const Center(
                              child: Text('All settled up! 🎉'),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: balanceEntries.length,
                            itemBuilder: (context, index) {
                              final entry = balanceEntries[index];
                              final amount = entry.value;
                              final isPositive = amount > 0;
                              final color = isPositive
                                  ? Colors.green
                                  : Colors.red;

                              return Consumer(
                                builder: (context, ref, _) {
                                  final userAsync = ref.watch(
                                    specificFriendProvider(entry.key),
                                  );

                                  final displayName = userAsync.when(
                                    data: (user) => user?.name ?? entry.key,
                                    loading: () => '...',
                                    error: (_, _) => entry.key,
                                  );

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: color.withValues(
                                        alpha: 0.15,
                                      ),
                                      child: Text(
                                        displayName.isNotEmpty
                                            ? displayName[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      isPositive ? 'Gets back' : 'Owes',
                                      style: TextStyle(color: color),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${amount.abs().toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (!isPositive) ...[
                                          const SizedBox(width: 8),
                                          FilledButton.tonal(
                                            onPressed: () {
                                              context.push(
                                                Uri(
                                                  path:
                                                      '/groups/$groupId/settle',
                                                  queryParameters: {
                                                    'toUserId': entry.key,
                                                    'amount': amount
                                                        .abs()
                                                        .toString(),
                                                  },
                                                ).toString(),
                                              );
                                            },
                                            child: const Text('Settle'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      );
                    },
                  ),
                  // ─── Members Tab ──────────────────────────────────────
                  groupAsync.when(
                    data: (group) => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: group.memberIds.length,
                      itemBuilder: (context, index) {
                        final memberId = group.memberIds[index];
                        final isCurrentUser = memberId == currentUserId;

                        return Consumer(
                          builder: (context, ref, _) {
                            final memberAsync = ref.watch(
                              specificFriendProvider(memberId),
                            );

                            return memberAsync.when(
                              data: (member) {
                                final name =
                                    member?.name ??
                                    (isCurrentUser ? 'You' : memberId);
                                final username = member?.isManual == true
                                    ? null
                                    : member?.username;
                                final initial = name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : '?';

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    isCurrentUser ? '$name (You)' : name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: username != null
                                      ? Text('@$username')
                                      : null,
                                  trailing: group.adminId == memberId
                                      ? Chip(
                                          label: const Text('Admin'),
                                          padding: EdgeInsets.zero,
                                          labelStyle: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          side: BorderSide(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                        )
                                      : null,
                                );
                              },
                              loading: () => const ListTile(
                                leading: CircleAvatar(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                title: Text('Loading...'),
                              ),
                              error: (_, _) => ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(
                                  isCurrentUser ? 'You' : 'Unknown member',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    loading: () => const SizedBox(),
                    error: (_, _) => const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/groups/$groupId/add-expense');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showExpenseInfo(
    BuildContext context,
    WidgetRef ref,
    dynamic expense, // Expects ExpenseEntity
    Set<String> involvedIds,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final List<String> acceptedIds = List<String>.from(
              expense.acceptedBy ?? [],
            );
            final pendingIds = involvedIds.difference(acceptedIds.toSet());

            return SafeArea(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  // Premium Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          expense.description,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₹${expense.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Accepted Section
                  if (acceptedIds.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Accepted (${acceptedIds.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...acceptedIds.map(
                      (id) => Consumer(
                        builder: (context, ref, _) {
                          final userAsync = ref.watch(
                            specificFriendProvider(id),
                          );
                          return userAsync.when(
                            data: (user) {
                              final name = user?.name ?? 'User $id';
                              final initial = name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : '?';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.withValues(
                                      alpha: 0.15,
                                    ),
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.green,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Accepted',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            loading: () =>
                                const ListTile(title: Text('Loading...')),
                            error: (_, _) => ListTile(title: Text('User $id')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Pending Section
                  if (pendingIds.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time_filled,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pending (${pendingIds.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...pendingIds.map(
                      (id) => Consumer(
                        builder: (context, ref, _) {
                          final userAsync = ref.watch(
                            specificFriendProvider(id),
                          );
                          return userAsync.when(
                            data: (user) {
                              final name = user?.name ?? 'User $id';
                              final initial = name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : '?';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.orange.withValues(
                                      alpha: 0.15,
                                    ),
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_filled,
                                          color: Colors.orange,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Pending',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            loading: () =>
                                const ListTile(title: Text('Loading...')),
                            error: (_, _) => ListTile(title: Text('User $id')),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

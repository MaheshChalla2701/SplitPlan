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

                          return Card(
                            child: Consumer(
                              builder: (context, ref, _) {
                                final payerAsync = payerId != null
                                    ? ref.watch(specificFriendProvider(payerId))
                                    : null;

                                final payerLabel = payerId == null
                                    ? 'Unknown payer'
                                    : payerId == currentUserId
                                    ? 'Paid by you'
                                    : payerAsync?.when(
                                            data: (user) =>
                                                'Paid by ${user?.name ?? payerId}',
                                            loading: () => 'Loading...',
                                            error: (_, _) => 'Paid by $payerId',
                                          ) ??
                                          'Paid by $payerId';

                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.receipt),
                                  ),
                                  title: Text(expense.description),
                                  subtitle: Text(payerLabel),
                                  trailing: Text(
                                    '₹${expense.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../providers/group_providers.dart';

class GroupDetailsScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(groupId));
    final expensesAsync = ref.watch(groupExpensesProvider(groupId));

    return Scaffold(
      appBar: AppBar(
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
                  // Expenses Tab
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
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.receipt),
                              ),
                              title: Text(expense.description),
                              subtitle: Text('Paid by you'),
                              trailing: Text(
                                '₹${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),

                  // Balances Tab
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

                          // Convert map to list for display
                          final balanceEntries = balances.entries.toList();

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

                              return ListTile(
                                title: Text(
                                  'User ${entry.key}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                              path: '/groups/$groupId/settle',
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
                                subtitle: Text(
                                  isPositive ? 'Gets back' : 'Owes',
                                  style: TextStyle(color: color),
                                ),
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

                  // Members Tab
                  groupAsync.when(
                    data: (group) => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: group.memberIds.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text('Member ID: ${group.memberIds[index]}'),
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
          context.go('/groups/$groupId/add-expense');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

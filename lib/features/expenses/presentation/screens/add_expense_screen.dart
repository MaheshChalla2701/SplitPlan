import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../providers/expense_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String groupId;

  const AddExpenseScreen({super.key, required this.groupId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authStateProvider).value;
      final groupAsync = ref.read(groupProvider(widget.groupId));

      if (user != null && groupAsync.value != null) {
        final group = groupAsync.value!;
        final amount = double.tryParse(_amountController.text) ?? 0.0;

        ref
            .read(expenseControllerProvider.notifier)
            .addExpense(
              groupId: widget.groupId,
              description: _descriptionController.text.trim(),
              amount: amount,
              payerId: user.id, // Defaults to current user paying
              splitBetweenIds:
                  group.memberIds, // Defaults to split equally among all
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseControllerProvider);

    ref.listen(expenseControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        data: (_) {
          if (previous?.isLoading == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense added successfully')),
            );
            context.pop();
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Dinner, Taxi',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Paid by you, split equally
              const Text(
                'Paid by you, split equally',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

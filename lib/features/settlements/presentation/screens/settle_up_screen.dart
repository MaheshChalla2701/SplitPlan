import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:splitplan/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitplan/features/friends/presentation/providers/friends_providers.dart';
import 'package:splitplan/features/settlements/presentation/providers/settlement_providers.dart';
import 'package:splitplan/features/settlements/domain/services/nudge_service.dart';

class SettleUpScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String toUserId;
  final double amount; // Recommended amount
  final bool isReceiving;

  const SettleUpScreen({
    super.key,
    required this.groupId,
    required this.toUserId,
    required this.amount,
    this.isReceiving = false,
  });

  @override
  ConsumerState<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends ConsumerState<SettleUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.amount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authStateProvider).value;

      if (user != null) {
        final amount = double.tryParse(_amountController.text) ?? 0.0;

        ref
            .read(settlementControllerProvider.notifier)
            .recordSettlement(
              groupId: widget.groupId,
              fromUserId: widget.isReceiving ? widget.toUserId : user.id,
              toUserId: widget.isReceiving ? user.id : widget.toUserId,
              amount: amount,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settlementControllerProvider);
    final friendAsync = ref.watch(specificFriendProvider(widget.toUserId));

    ref.listen(settlementControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        data: (_) {
          if (previous?.isLoading == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settlement recorded')),
            );
            context.pop();
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Settle Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              friendAsync.when(
                data: (friend) => Text(
                  widget.isReceiving
                      ? 'Receiving ₹${_amountController.text} from ${friend?.name ?? "User"}'
                      : 'Paying ${friend?.name ?? "User"}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text(
                  widget.isReceiving
                      ? 'Receiving payment from ${widget.toUserId}'
                      : 'Paying User ${widget.toUserId}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
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

              friendAsync.when(
                data: (friend) {
                  final hasUpi =
                      friend?.upiId != null && friend!.upiId!.isNotEmpty;
                  final hasPhone =
                      friend?.phoneNumber != null &&
                      friend!.phoneNumber!.isNotEmpty;

                  if (!hasUpi && !hasPhone) {
                    return Text(
                      'No UPI ID or Phone found for ${friend?.name ?? "this user"}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasUpi)
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
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                HapticFeedback.lightImpact();
                                Clipboard.setData(
                                  ClipboardData(text: friend.upiId!),
                                );
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
                                        const Text(
                                          'UPI ID copied to clipboard',
                                        ),
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
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Copy UPI ID',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            friend.upiId!,
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Copy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (hasUpi && hasPhone) const SizedBox(height: 12),

                      if (hasPhone)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green[50],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                HapticFeedback.lightImpact();
                                final currentUpiId = ref
                                    .read(authStateProvider)
                                    .value
                                    ?.upiId;
                                final amount =
                                    double.tryParse(_amountController.text) ??
                                    widget.amount;

                                await ref
                                    .read(nudgeServiceProvider)
                                    .sendWhatsAppNudge(
                                      phone: friend.phoneNumber!,
                                      friendName: friend.name,
                                      amount: amount,
                                      upiId: currentUpiId,
                                    );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_active_outlined,
                                      color: Colors.green[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Send Reminder',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.isReceiving
                            ? 'Confirm & Record Payment Received'
                            : 'Confirm & Record Settlement',
                      ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: "Record Settlement" marks the debt as paid in the app.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

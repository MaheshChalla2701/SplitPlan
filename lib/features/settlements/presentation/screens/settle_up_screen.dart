import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:upi_india/upi_india.dart';
import 'package:uuid/uuid.dart';

import 'package:splitplan/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitplan/features/friends/presentation/providers/friends_providers.dart';
import 'package:splitplan/features/settlements/presentation/providers/settlement_providers.dart';

class SettleUpScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String toUserId;
  final double amount; // Recommended amount

  const SettleUpScreen({
    super.key,
    required this.groupId,
    required this.toUserId,
    required this.amount,
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

  Future<void> _showUpiAppPicker(
    String upiId,
    String receiverName,
    double amount,
  ) async {
    final UpiIndia upiIndia = UpiIndia();
    List<UpiApp> apps = [];
    try {
      apps = await upiIndia.getAllUpiApps(mandatoryTransactionId: false);
    } catch (_) {
      apps = [];
    }

    if (!mounted) return;

    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No UPI apps found. Please install PhonePe, GPay or Paytm.',
          ),
        ),
      );
      return;
    }

    // Show app picker bottom sheet
    final UpiApp? selectedApp = await showModalBottomSheet<UpiApp>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Choose a UPI App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: apps.length,
                itemBuilder: (ctx, i) {
                  final app = apps[i];
                  return GestureDetector(
                    onTap: () => Navigator.pop(ctx, app),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(app.icon, width: 48, height: 48),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedApp == null || !mounted) return;

    // Start transaction
    final String txnRef = const Uuid().v4().substring(0, 35); // max 35 chars
    UpiResponse? response;
    try {
      response = await upiIndia.startTransaction(
        app: selectedApp,
        receiverUpiId: upiId,
        receiverName: receiverName,
        transactionRefId: txnRef,
        transactionNote: 'SplitPlan Settlement',
        amount: amount,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment error: $e')));
      }
      return;
    }

    if (!mounted) return;

    final String? statusStr = response.status;
    if (statusStr == UpiPaymentStatus.SUCCESS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Payment successful! Recording settlement...'),
          backgroundColor: Colors.green,
        ),
      );
      // Auto-record the settlement
      _submit();
    } else if (statusStr == UpiPaymentStatus.SUBMITTED) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Payment submitted. Will update once cleared.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Payment failed or cancelled. Status: ${statusStr ?? "Unknown"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              fromUserId: user.id,
              toUserId: widget.toUserId,
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
                  'Paying ${friend?.name ?? "User"}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text(
                  'Paying User ${widget.toUserId}',
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

              // Smart UPI Pay Button
              friendAsync.when(
                data: (friend) {
                  if (friend?.upiId != null && friend!.upiId!.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            final amount =
                                double.tryParse(_amountController.text) ?? 0.0;
                            if (amount > 0) {
                              _showUpiAppPicker(
                                friend.upiId!,
                                friend.name,
                                amount,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a valid amount first',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.qr_code_scanner,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pay via UPI',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        friend.upiId!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Text(
                    'No UPI ID found for ${friend?.name ?? "this user"}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                    : const Text('Confirm & Record Settlement'),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/payment_request_entity.dart';
import '../providers/payment_request_providers.dart';

class CreatePaymentRequestScreen extends ConsumerStatefulWidget {
  final String friendId;

  const CreatePaymentRequestScreen({super.key, required this.friendId});

  @override
  ConsumerState<CreatePaymentRequestScreen> createState() =>
      _CreatePaymentRequestScreenState();
}

class _CreatePaymentRequestScreenState
    extends ConsumerState<CreatePaymentRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  PaymentRequestType _type = PaymentRequestType.receive;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitPayload() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      final request = PaymentRequestEntity(
        id: const Uuid()
            .v4(), // We might need uuid package or let firestore gen
        fromUserId: currentUser.id,
        toUserId: widget.friendId,
        amount: amount,
        description: description,
        type: _type,
        status: PaymentRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await ref
          .read(createPaymentRequestControllerProvider.notifier)
          .createRequest(request);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type Selection
            SegmentedButton<PaymentRequestType>(
              segments: const [
                ButtonSegment(
                  value: PaymentRequestType.receive,
                  label: Text('Receive'),
                  icon: Icon(Icons.download),
                ),
                ButtonSegment(
                  value: PaymentRequestType.pay,
                  label: Text('Pay'),
                  icon: Icon(Icons.upload),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<PaymentRequestType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              _type == PaymentRequestType.receive
                  ? 'Request money from your friend (They owe you)'
                  : 'Record a payment to your friend (You owe them)',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Amount
            TextFormField(
              controller: _amountController,
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
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Lunch, Movies, Rent',
                border: OutlineInputBorder(),
              ),
              validator: null,
            ),
            const SizedBox(height: 32),

            // Submit Button
            FilledButton.icon(
              onPressed: _isLoading ? null : _submitPayload,
              icon: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isLoading ? 'Sending...' : 'Send Request'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}

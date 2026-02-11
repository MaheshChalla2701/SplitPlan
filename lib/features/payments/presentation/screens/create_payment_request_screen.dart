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

      // If "Receive", I am requester (from). If "Pay", I am payer (to)?
      // Wait, let's stick to the entity definition:
      // Entity has fromUserId and toUserId.
      // Usually "Payment Request" means:
      // "Receive": I (from) ask You (to) for money.
      // "Pay": I (from) tell You (to) that I owe you / I am recording a debt.
      // Actually, let's look at the types:
      // pay: "I want to PAY someone" -> Record that I owe them? Or I sent money?
      // receive: "I want to RECEIVE money" -> Standard request.

      // Let's standardise:
      // If Type is RECEIVE (User wants money FROM friend):
      // fromUser = Current User
      // toUser = Friend
      // type = receive

      // If Type is PAY (User wants to record they OWE friend):
      // formUser = Current User
      // toUser = Friend
      // type = pay

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

      // We will let the repository handle ID generation if we pass empty ID or handle it there.
      // But repo uses .add() which generates ID.
      // So we can pass empty string for ID in entity if we modify repo,
      // OR we just use uuid here.
      // Since repo uses .add(), the ID in entity might be ignored or defined.
      // Let's look at repo: .add({...}) -> ID is gen by firestore.
      // The entity passed to createPaymentRequest has an ID but it's not used in .add() map!
      // Wait, repo: 'fromUserId': request.fromUserId...
      // It does NOT save request.id.
      // So passing any string here is fine, Firestore will make a new one.

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
                prefixText: '\$ ',
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

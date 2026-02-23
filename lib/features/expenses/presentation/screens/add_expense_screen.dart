import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/ocr_service.dart';
import '../providers/expense_providers.dart';
import '../../../friends/presentation/providers/friends_providers.dart';

// ─── Split mode enum ──────────────────────────────────────────────────────────

enum SplitMode { evenly, amount, shares, percentage }

extension SplitModeX on SplitMode {
  String get label {
    switch (this) {
      case SplitMode.evenly:
        return 'Evenly';
      case SplitMode.amount:
        return 'Amount';
      case SplitMode.shares:
        return 'Shares';
      case SplitMode.percentage:
        return '%';
    }
  }

  IconData get icon {
    switch (this) {
      case SplitMode.evenly:
        return Icons.people_outline;
      case SplitMode.amount:
        return Icons.onetwothree;
      case SplitMode.shares:
        return Icons.pie_chart_outline;
      case SplitMode.percentage:
        return Icons.percent;
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String groupId;
  final ExpenseEntity? existingExpense;
  const AddExpenseScreen({
    super.key,
    required this.groupId,
    this.existingExpense,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isScanning = false;
  SplitMode _splitMode = SplitMode.evenly;

  Set<String> _selectedMemberIds = {};

  // Int share counts for stepper mode
  final Map<String, int> _shareValues = {};

  // Text controllers for amount / percentage modes
  final Map<String, TextEditingController> _customControllers = {};

  @override
  void initState() {
    super.initState();
    final expense = widget.existingExpense;
    if (expense != null) {
      _descriptionController.text = expense.description;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _selectedMemberIds = expense.splitBetween.map((s) => s.userId).toSet();
      for (final share in expense.splitBetween) {
        _customControllers[share.userId] = TextEditingController(
          text: share.amount.toStringAsFixed(2),
        );
        _shareValues[share.userId] = 1; // Default fallback for shares mode
      }
      _splitMode = SplitMode.amount; // Safest default for reconstructed splits
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initMembersIfNeeded(List<String> memberIds) {
    if (_selectedMemberIds.isNotEmpty) return;
    _selectedMemberIds = memberIds.toSet();
    for (final id in memberIds) {
      _customControllers[id] ??= TextEditingController(text: '0');
      _shareValues[id] ??= 1;
    }
  }

  double get _totalAmount => double.tryParse(_amountController.text) ?? 0.0;

  String? _validateSplit() {
    if (_selectedMemberIds.isEmpty) return 'Select at least one member';
    if (_totalAmount <= 0) return null;

    switch (_splitMode) {
      case SplitMode.evenly:
        return null;
      case SplitMode.amount:
        final sum = _selectedMemberIds.fold<double>(
          0,
          (acc, id) =>
              acc + (double.tryParse(_customControllers[id]?.text ?? '0') ?? 0),
        );
        if ((sum - _totalAmount).abs() > 0.01) {
          return 'Amounts must add up to ₹${_totalAmount.toStringAsFixed(2)} (currently ₹${sum.toStringAsFixed(2)})';
        }
        return null;
      case SplitMode.percentage:
        final sum = _selectedMemberIds.fold<double>(
          0,
          (acc, id) =>
              acc + (double.tryParse(_customControllers[id]?.text ?? '0') ?? 0),
        );
        if ((sum - 100).abs() > 0.01) {
          return 'Percentages must add up to 100% (currently ${sum.toStringAsFixed(1)}%)';
        }
        return null;
      case SplitMode.shares:
        final total = _selectedMemberIds.fold<int>(
          0,
          (acc, id) => acc + (_shareValues[id] ?? 1),
        );
        if (total <= 0) return 'Total shares must be greater than 0';
        return null;
    }
  }

  Map<String, double> _computeShares() {
    final n = _selectedMemberIds.length;

    switch (_splitMode) {
      case SplitMode.evenly:
        final each = _totalAmount / n;
        return {for (final id in _selectedMemberIds) id: each};

      case SplitMode.amount:
        return {
          for (final id in _selectedMemberIds)
            id: double.tryParse(_customControllers[id]?.text ?? '0') ?? 0,
        };

      case SplitMode.percentage:
        return {
          for (final id in _selectedMemberIds)
            id:
                _totalAmount *
                ((double.tryParse(_customControllers[id]?.text ?? '0') ?? 0) /
                    100),
        };

      case SplitMode.shares:
        final totalShares = _selectedMemberIds.fold<int>(
          0,
          (acc, id) => acc + (_shareValues[id] ?? 1),
        );
        return {
          for (final id in _selectedMemberIds)
            id: totalShares > 0
                ? _totalAmount * ((_shareValues[id] ?? 1) / totalShares)
                : 0,
        };
    }
  }

  Future<void> _scanReceipt() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.camera);
    if (xfile == null) return;

    setState(() => _isScanning = true);
    try {
      final ocrService = ref.read(ocrServiceProvider);
      final amount = await ocrService.extractTotalAmount(xfile.path);
      if (mounted) {
        if (amount != null) {
          _amountController.text = amount.toStringAsFixed(2);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Amount extracted from receipt!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not find a valid amount in the image.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error scanning: $e')));
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _submit() {
    final splitError = _validateSplit();
    if (splitError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(splitError)));
      return;
    }

    if (_formKey.currentState!.validate()) {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final shares = _computeShares();
      if (widget.existingExpense != null) {
        ref
            .read(expenseControllerProvider.notifier)
            .updateExpenseWithShares(
              expenseId: widget.existingExpense!.id,
              groupId: widget.groupId,
              description: _descriptionController.text.trim(),
              amount: _totalAmount,
              payerId: user.id, // Or keep original payer
              splitShares: shares,
              originalAcceptedBy: widget.existingExpense!.acceptedBy,
            );
      } else {
        ref
            .read(expenseControllerProvider.notifier)
            .addExpenseWithShares(
              groupId: widget.groupId,
              description: _descriptionController.text.trim(),
              amount: _totalAmount,
              payerId: user.id,
              splitShares: shares,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseControllerProvider);
    final groupAsync = ref.watch(groupProvider(widget.groupId));
    final currentUserId = ref.watch(authStateProvider).value?.id ?? '';

    ref.listen(expenseControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        data: (_) {
          if (previous?.isLoading == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.existingExpense != null
                      ? 'Expense updated!'
                      : 'Expense added!',
                ),
              ),
            );
            context.pop();
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Add Expense'),
      ),
      body: groupAsync.when(
        data: (group) {
          if (_selectedMemberIds.isEmpty) {
            _initMembersIfNeeded(group.memberIds);
          }
          for (final id in group.memberIds) {
            _customControllers[id] ??= TextEditingController(text: '0');
            _shareValues[id] ??= 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'e.g. Dinner, Taxi',
                      prefixIcon: Icon(Icons.edit_note_outlined),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹ ',
                      suffixIcon: _isScanning
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.document_scanner_outlined),
                              tooltip: 'Scan Receipt',
                              onPressed: state.isLoading ? null : _scanReceipt,
                            ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount is required';
                      if (double.tryParse(v) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Split mode selector
                  const Text(
                    'Split method',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  _SplitModeSelector(
                    current: _splitMode,
                    onChanged: (m) => setState(() {
                      _splitMode = m;
                      for (final c in _customControllers.values) {
                        c.text = '0';
                      }
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Member rows
                  const Text(
                    'Split between',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ...group.memberIds.map(
                    (memberId) => _MemberSplitRow(
                      memberId: memberId,
                      currentUserId: currentUserId,
                      isSelected: _selectedMemberIds.contains(memberId),
                      splitMode: _splitMode,
                      totalAmount: _totalAmount,
                      selectedCount: _selectedMemberIds.length,
                      selectedMemberIds: _selectedMemberIds,
                      shareValues: _shareValues,
                      controller: _customControllers[memberId]!,
                      shareValue: _shareValues[memberId] ?? 1,
                      onShareChanged: (delta) {
                        setState(() {
                          final current = _shareValues[memberId] ?? 1;
                          _shareValues[memberId] = (current + delta).clamp(
                            1,
                            99,
                          );
                        });
                      },
                      onToggle: () {
                        setState(() {
                          if (_selectedMemberIds.contains(memberId)) {
                            if (_selectedMemberIds.length > 1) {
                              _selectedMemberIds.remove(memberId);
                            }
                          } else {
                            _selectedMemberIds.add(memberId);
                          }
                        });
                      },
                    ),
                  ),

                  // Evenly summary bar
                  if (_splitMode == SplitMode.evenly &&
                      _totalAmount > 0 &&
                      _selectedMemberIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SplitSummaryBar(
                      label: 'Each person pays',
                      value:
                          '₹${(_totalAmount / _selectedMemberIds.length).toStringAsFixed(2)}',
                    ),
                  ],

                  // Remaining bar for amount mode
                  if (_splitMode == SplitMode.amount && _totalAmount > 0) ...[
                    const SizedBox(height: 8),
                    _RemainingBar(
                      total: _totalAmount,
                      assigned: _selectedMemberIds.fold<double>(
                        0,
                        (acc, id) =>
                            acc +
                            (double.tryParse(
                                  _customControllers[id]?.text ?? '0',
                                ) ??
                                0),
                      ),
                      unit: '₹',
                    ),
                  ],

                  // Remaining bar for percentage mode
                  if (_splitMode == SplitMode.percentage) ...[
                    const SizedBox(height: 8),
                    _RemainingBar(
                      total: 100,
                      assigned: _selectedMemberIds.fold<double>(
                        0,
                        (acc, id) =>
                            acc +
                            (double.tryParse(
                                  _customControllers[id]?.text ?? '0',
                                ) ??
                                0),
                      ),
                      unit: '%',
                    ),
                  ],

                  const SizedBox(height: 28),

                  FilledButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Expense'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// ─── Split Mode Selector ──────────────────────────────────────────────────────

class _SplitModeSelector extends StatelessWidget {
  final SplitMode current;
  final ValueChanged<SplitMode> onChanged;
  const _SplitModeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SplitMode.values.map((mode) {
        final isSelected = mode == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    mode.icon,
                    size: 22,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Member Split Row ─────────────────────────────────────────────────────────

class _MemberSplitRow extends ConsumerWidget {
  final String memberId;
  final String currentUserId;
  final bool isSelected;
  final SplitMode splitMode;
  final double totalAmount;
  final int selectedCount;
  final Set<String> selectedMemberIds;
  final Map<String, int> shareValues;
  final TextEditingController controller;
  final int shareValue;
  final ValueChanged<int> onShareChanged;
  final VoidCallback onToggle;

  const _MemberSplitRow({
    required this.memberId,
    required this.currentUserId,
    required this.isSelected,
    required this.splitMode,
    required this.totalAmount,
    required this.selectedCount,
    required this.selectedMemberIds,
    required this.shareValues,
    required this.controller,
    required this.shareValue,
    required this.onShareChanged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(specificFriendProvider(memberId));
    final isMe = memberId == currentUserId;

    final name = memberAsync.when(
      data: (u) => u?.name ?? (isMe ? 'You' : memberId),
      loading: () => isMe ? 'You' : '...',
      error: (_, _) => isMe ? 'You' : memberId,
    );

    final displayName = isMe ? 'You' : name;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    // ₹ subtitle shown below name in shares mode
    String? sharesAmountLabel;
    if (splitMode == SplitMode.shares && isSelected) {
      final totalShares = selectedMemberIds.fold<int>(
        0,
        (acc, id) => acc + (shareValues[id] ?? 1),
      );
      final myAmount = totalShares > 0
          ? totalAmount * (shareValue / totalShares)
          : 0.0;
      sharesAmountLabel = '₹${myAmount.toStringAsFixed(2)}';
    }

    // Evenly label
    String? evenlyLabel;
    if (splitMode == SplitMode.evenly && isSelected && selectedCount > 0) {
      evenlyLabel = totalAmount > 0
          ? '₹${(totalAmount / selectedCount).toStringAsFixed(2)}'
          : '₹0.00';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Checkbox circle
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 17, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name + ₹ subtitle (shares mode)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sharesAmountLabel != null)
                  Text(
                    sharesAmountLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Right side widget based on mode
          if (splitMode == SplitMode.evenly)
            Text(
              isSelected ? (evenlyLabel ?? '') : '—',
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (splitMode == SplitMode.shares && isSelected)
            // GPay-style stepper: − n +
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  onTap: shareValue > 1 ? () => onShareChanged(-1) : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$shareValue',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                _StepperButton(icon: Icons.add, onTap: () => onShareChanged(1)),
              ],
            )
          else if (isSelected)
            SizedBox(
              width: 90,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixText: splitMode == SplitMode.amount ? '₹ ' : null,
                  suffixText: splitMode == SplitMode.percentage ? '%' : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          else
            const Text('—', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─── Stepper Button ───────────────────────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Colors.transparent,
          border: Border.all(
            color: enabled
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ─── Summary Bar ──────────────────────────────────────────────────────────────

class _SplitSummaryBar extends StatelessWidget {
  final String label;
  final String value;
  const _SplitSummaryBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Remaining Bar ────────────────────────────────────────────────────────────

class _RemainingBar extends StatelessWidget {
  final double total;
  final double assigned;
  final String unit;
  const _RemainingBar({
    required this.total,
    required this.assigned,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = total - assigned;
    final isOver = remaining < -0.01;
    final isExact = remaining.abs() <= 0.01;
    final color = isExact
        ? Colors.green
        : (isOver ? Colors.red : Colors.orange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isExact
                ? '✓ Split complete'
                : isOver
                ? 'Over by $unit${remaining.abs().toStringAsFixed(2)}'
                : 'Remaining to assign',
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          if (!isExact)
            Text(
              '$unit${remaining.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          else
            Icon(Icons.check_circle, color: color, size: 20),
        ],
      ),
    );
  }
}

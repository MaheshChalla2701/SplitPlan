import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trip_day_card_entity.dart';
import '../../domain/entities/trip_plan_entity.dart';
import '../providers/trip_plan_providers.dart';

class GroupPlansTabView extends ConsumerStatefulWidget {
  final String groupId;

  const GroupPlansTabView({super.key, required this.groupId});

  @override
  ConsumerState<GroupPlansTabView> createState() => _GroupPlansTabViewState();
}

class _GroupPlansTabViewState extends ConsumerState<GroupPlansTabView> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    // Listen for controller errors
    ref.listen<AsyncValue<void>>(tripPlanControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${err.toString()}')));
        },
      );
    });

    final plansAsync = ref.watch(groupTripPlansProvider(widget.groupId));

    return plansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (plans) {
        // Handle plan selection logic more robustly
        if (plans.isEmpty) {
          _selectedPlanId = null;
        } else if (_selectedPlanId == null) {
          // Auto-select first if none selected
          _selectedPlanId = plans.first.id;
        } else if (!plans.any((p) => p.id == _selectedPlanId)) {
          // If selected plan was deleted, select the first available one
          _selectedPlanId = plans.first.id;
        }

        final selectedPlan = _selectedPlanId == null
            ? null
            : plans.firstWhere(
                (p) => p.id == _selectedPlanId,
                orElse: () => plans.first,
              );

        return plans.isEmpty || selectedPlan == null
            ? _EmptyPlansState(
                groupId: widget.groupId,
                onPlanCreated: (id) => setState(() => _selectedPlanId = id),
              )
            : _PlanDetailView(
                plan: selectedPlan,
                plans: plans,
                selectedPlanId: _selectedPlanId,
                groupId: widget.groupId,
                onPlanSelected: (id) => setState(() => _selectedPlanId = id),
                onPlanCreated: (id) => setState(() => _selectedPlanId = id),
              );
      },
    );
  }
}

// ─── Horizontal plan chip selector ───────────────────────────────────────────

class _PlanSelectorRow extends ConsumerWidget {
  final List<TripPlanEntity> plans;
  final String? selectedPlanId;
  final String groupId;
  final ValueChanged<String> onPlanSelected;
  final ValueChanged<String> onPlanCreated;

  const _PlanSelectorRow({
    required this.plans,
    required this.selectedPlanId,
    required this.groupId,
    required this.onPlanSelected,
    required this.onPlanCreated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(26),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...plans.map((plan) {
                final isSelected = plan.id == selectedPlanId;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => onPlanSelected(plan.id),
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        plan.name,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const VerticalDivider(width: 16, indent: 8, endIndent: 8),
              // Compact "Add" button
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () =>
                    _showPlanEditorSheet(context, ref, groupId, onPlanCreated),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Create plan bottom sheet ─────────────────────────────────────────────────

Future<void> _showPlanEditorSheet(
  BuildContext context,
  WidgetRef ref,
  String groupId,
  ValueChanged<String>? onCreated, {
  TripPlanEntity? initialPlan,
}) async {
  final isEditing = initialPlan != null;
  final nameCtrl = TextEditingController(text: initialPlan?.name);
  DateTime? startDate = initialPlan?.startDate;
  DateTime? endDate = initialPlan?.endDate;
  String? budgetText = initialPlan?.estimatedBudget?.toString();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Plan' : 'Create New Plan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                autofocus: !isEditing,
                decoration: InputDecoration(
                  labelText: 'Trip Name *',
                  hintText: 'e.g. Vizag, Goa, Mumbai',
                  prefixIcon: const Icon(Icons.place_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateBtn(
                      label: 'Start Date (optional)',
                      date: startDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => startDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DateBtn(
                      label: 'End Date (optional)',
                      date: endDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: endDate ?? startDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => endDate = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: budgetText),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Estimated Budget (optional)',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => budgetText = v,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    Navigator.of(ctx).pop();

                    final budget = budgetText != null
                        ? double.tryParse(budgetText!)
                        : null;

                    if (isEditing) {
                      await ref
                          .read(tripPlanControllerProvider.notifier)
                          .updatePlan(
                            initialPlan.copyWith(
                              name: name,
                              startDate: startDate,
                              endDate: endDate,
                              estimatedBudget: budget,
                            ),
                          );
                    } else {
                      final plan = await ref
                          .read(tripPlanControllerProvider.notifier)
                          .createPlan(
                            groupId: groupId,
                            name: name,
                            startDate: startDate,
                            endDate: endDate,
                            estimatedBudget: budget,
                          );
                      if (plan != null) onCreated?.call(plan.id);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Plan',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateBtn({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date == null
                  ? 'Tap to select'
                  : '${date!.day}/${date!.month}/${date!.year}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: date == null
                    ? theme.colorScheme.outline
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyPlansState extends ConsumerWidget {
  final String groupId;
  final ValueChanged<String> onPlanCreated;

  const _EmptyPlansState({required this.groupId, required this.onPlanCreated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No trip plans yet!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "+ Add" above to start planning your first trip.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  _showPlanEditorSheet(context, ref, groupId, onPlanCreated),
              icon: const Icon(Icons.add),
              label: const Text('Create Plan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Plan detail (day cards list) ─────────────────────────────────────────────

class _PlanDetailView extends ConsumerWidget {
  final TripPlanEntity plan;
  final List<TripPlanEntity> plans;
  final String? selectedPlanId;
  final String groupId;
  final ValueChanged<String> onPlanSelected;
  final ValueChanged<String> onPlanCreated;

  const _PlanDetailView({
    required this.plan,
    required this.plans,
    required this.selectedPlanId,
    required this.groupId,
    required this.onPlanSelected,
    required this.onPlanCreated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(tripDayCardsProvider(plan.id));

    return cardsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (cards) {
        return ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          buildDefaultDragHandles: false,
          header: Column(
            children: [
              _PlanSelectorRow(
                plans: plans,
                selectedPlanId: selectedPlanId,
                groupId: groupId,
                onPlanSelected: onPlanSelected,
                onPlanCreated: onPlanCreated,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
                child: _TripPlanHeader(plan: plan, groupId: groupId),
              ),
            ],
          ),
          itemCount: cards.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final updatedCards = List<TripDayCardEntity>.from(cards);
            final item = updatedCards.removeAt(oldIndex);
            updatedCards.insert(newIndex, item);
            ref
                .read(tripPlanControllerProvider.notifier)
                .reorderDays(plan.id, updatedCards);
          },
          itemBuilder: (context, index) {
            final card = cards[index];
            return Padding(
              key: ValueKey(card.id),
              padding: const EdgeInsets.only(bottom: 12),
              child: _DayCardWidget(card: card, index: index),
            );
          },
          footer: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref
                    .read(tripPlanControllerProvider.notifier)
                    .addDayCard(
                      tripPlanId: plan.id,
                      dayNumber: cards.length + 1,
                    );
              },
              icon: const Icon(Icons.add),
              label: Text(
                cards.isEmpty
                    ? 'Start with Day 1'
                    : 'Add Day ${cards.length + 1}',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Trip plan header ─────────────────────────────────────────────────────────

class _TripPlanHeader extends ConsumerWidget {
  final TripPlanEntity plan;
  final String groupId;

  const _TripPlanHeader({required this.plan, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDates = plan.startDate != null || plan.endDate != null;
    final hasBudget = plan.estimatedBudget != null;

    final theme = Theme.of(context);
    return InkWell(
      onTap: () =>
          _showPlanEditorSheet(context, ref, groupId, null, initialPlan: plan),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surfaceContainerHigh,
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (hasDates) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _fmtRange(plan.startDate, plan.endDate),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _confirmDeletePlan(context, ref),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
            if (hasBudget) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Budget: ₹${plan.estimatedBudget!.toStringAsFixed(0)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
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
  }

  void _confirmDeletePlan(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(tripPlanControllerProvider.notifier)
          .deletePlan(groupId, plan.id);
    }
  }

  String _fmtRange(DateTime? s, DateTime? e) {
    String f(DateTime d) => '${d.day}/${d.month}/${d.year}';
    if (s != null && e != null) return '${f(s)} → ${f(e)}';
    if (s != null) return 'From ${f(s)}';
    if (e != null) return 'Until ${f(e)}';
    return '';
  }
}

// ─── Day Card ─────────────────────────────────────────────────────────────────

class _DayCardWidget extends ConsumerStatefulWidget {
  final TripDayCardEntity card;
  final int index;

  const _DayCardWidget({required this.card, required this.index});

  @override
  ConsumerState<_DayCardWidget> createState() => _DayCardWidgetState();
}

class _DayCardWidgetState extends ConsumerState<_DayCardWidget> {
  late List<TextEditingController> _noteControllers;

  @override
  void initState() {
    super.initState();
    _noteControllers = widget.card.notes.isEmpty
        ? [TextEditingController()]
        : widget.card.notes.map((n) => TextEditingController(text: n)).toList();
  }

  @override
  void didUpdateWidget(_DayCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.notes.length != _noteControllers.length) {
      // Very simple sync for reorders or external updates
      for (var c in _noteControllers) {
        c.dispose();
      }
      _noteControllers = widget.card.notes.isEmpty
          ? [TextEditingController()]
          : widget.card.notes
                .map((n) => TextEditingController(text: n))
                .toList();
    }
  }

  @override
  void dispose() {
    for (final c in _noteControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addNote() {
    setState(() => _noteControllers.add(TextEditingController()));
    _save();
  }

  void _save() {
    final notes = _noteControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Check if anything actually changed to avoid infinite cycles
    if (notes.length == widget.card.notes.length) {
      bool changed = false;
      for (int i = 0; i < notes.length; i++) {
        if (notes[i] != widget.card.notes[i]) {
          changed = true;
          break;
        }
      }
      if (!changed) return;
    }

    final updated = widget.card.copyWith(notes: notes);
    ref.read(tripPlanControllerProvider.notifier).updateDayCard(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header row ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${card.dayNumber}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Day ${card.dayNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 4),

                // ─── Reorderable note fields ──────────────────────────
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _noteControllers.removeAt(oldIndex);
                      _noteControllers.insert(newIndex, item);
                    });
                    _save();
                  },
                  children: [
                    ..._noteControllers.asMap().entries.map((entry) {
                      final i = entry.key;
                      final ctrl = entry.value;
                      return Row(
                        key: ValueKey(ctrl.hashCode),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReorderableDragStartListener(
                            index: i,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 12, right: 8),
                              child: Icon(Icons.drag_indicator, size: 20),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (!hasFocus && ctrl.text.trim().isEmpty) {
                                    if (_noteControllers.length > 1) {
                                      setState(() {
                                        _noteControllers.removeAt(i);
                                        ctrl.dispose();
                                      });
                                      _save();
                                    }
                                  }
                                },
                                child: TextField(
                                  controller: ctrl,
                                  maxLines: null,
                                  onChanged: (_) => _save(),
                                  decoration: InputDecoration(
                                    hintText: 'Add a activity or note...',
                                    hintStyle: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                        ),
                                    isDense: true,
                                    filled: true,
                                    fillColor: theme
                                        .colorScheme
                                        .surfaceContainerLow
                                        .withValues(alpha: 0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outlineVariant
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 8),

                // ─── + Add Note button ─────────────────────────────
                Center(
                  child: TextButton.icon(
                    onPressed: _addNote,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Add Activity'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

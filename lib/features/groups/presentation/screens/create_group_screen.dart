import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../friends/presentation/providers/friends_providers.dart';
import '../providers/group_providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  // Step 1 = pick members, Step 2 = enter group name
  int _step = 1;
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleMember(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        // Current user is always included as first member (admin)
        final memberIds = [user.id, ..._selectedIds];
        ref
            .read(groupControllerProvider.notifier)
            .createGroup(_nameController.text.trim(), memberIds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupControllerProvider);
    final friendsAsync = ref.watch(userFriendsProvider);

    ref.listen(groupControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        data: (_) {
          if (previous?.isLoading == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppConstants.groupCreated)),
            );
            context.pop();
          }
        },
      );
    });

    if (_step == 1) {
      return _buildStep1(context, friendsAsync);
    }
    return _buildStep2(context, friendsAsync, state);
  }

  // ─── Step 1: Pick members ────────────────────────────────────────────────

  Widget _buildStep1(BuildContext context, AsyncValue friendsAsync) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Group'),
            Text(
              'Add participants',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Theme.of(
                  context,
                ).appBarTheme.foregroundColor?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedIds.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _step = 2),
              child: const Text('Next'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),

          // Selected members chips strip
          if (_selectedIds.isNotEmpty)
            friendsAsync.when(
              data: (friends) {
                final selected = friends
                    .where((f) => _selectedIds.contains(f.id))
                    .toList();
                return Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selected.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final f = selected[index];
                      final initial = f.name.isNotEmpty
                          ? f.name[0].toUpperCase()
                          : '?';
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                backgroundImage: f.avatarUrl != null
                                    ? NetworkImage(f.avatarUrl!)
                                    : null,
                                child: f.avatarUrl == null
                                    ? Text(
                                        initial,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: GestureDetector(
                                  onTap: () => _toggleMember(f.id),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 52,
                            child: Text(
                              f.name.split(' ').first,
                              style: const TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

          if (_selectedIds.isNotEmpty) const Divider(height: 1),

          // Friends list
          Expanded(
            child: friendsAsync.when(
              data: (friends) {
                final filtered = _searchQuery.isEmpty
                    ? friends
                    : friends
                          .where(
                            (f) =>
                                f.name.toLowerCase().contains(_searchQuery) ||
                                (f.username?.toLowerCase().contains(
                                      _searchQuery,
                                    ) ??
                                    false),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No friends yet.\nAdd friends first to create a group.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final friend = filtered[index];
                    final isSelected = _selectedIds.contains(friend.id);
                    final initial = friend.name.isNotEmpty
                        ? friend.name[0].toUpperCase()
                        : '?';

                    return ListTile(
                      onTap: () => _toggleMember(friend.id),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        backgroundImage: friend.avatarUrl != null
                            ? NetworkImage(friend.avatarUrl!)
                            : null,
                        child: friend.avatarUrl == null
                            ? Text(
                                initial,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        friend.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        friend.isManual
                            ? '#${friend.name.toLowerCase().replaceAll(' ', '_')}'
                            : '@${friend.username}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      trailing: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
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
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      // Floating Next button (visible when members are selected)
      floatingActionButton: _selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _step = 2),
              icon: const Icon(Icons.arrow_forward),
              label: Text('Next (${_selectedIds.length})'),
            )
          : null,
    );
  }

  // ─── Step 2: Name the group ──────────────────────────────────────────────

  Widget _buildStep2(
    BuildContext context,
    AsyncValue friendsAsync,
    AsyncValue<void> state,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _step = 1),
        ),
        title: const Text('New Group'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group Icon placeholder
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.group,
                        size: 44,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Group Name input
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  hintText: 'e.g. Weekend Trip, Roommates',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.groupNameRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // Members preview
              Text(
                'Members (${_selectedIds.length + 1})',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),

              friendsAsync.when(
                data: (friends) {
                  final selectedFriends = friends
                      .where((f) => _selectedIds.contains(f.id))
                      .toList();
                  final currentUser = ref.read(authStateProvider).value;

                  return Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // You (current user)
                      Chip(
                        avatar: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            (currentUser?.name.isNotEmpty == true)
                                ? currentUser!.name[0].toUpperCase()
                                : 'Y',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        label: const Text('You (Admin)'),
                      ),
                      ...selectedFriends.map(
                        (f) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            backgroundImage: f.avatarUrl != null
                                ? NetworkImage(f.avatarUrl!)
                                : null,
                            child: f.avatarUrl == null
                                ? Text(
                                    f.name.isNotEmpty
                                        ? f.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : null,
                          ),
                          label: Text(f.name),
                          onDeleted: () {
                            _toggleMember(f.id);
                            if (_selectedIds.isEmpty) {
                              setState(() => _step = 1);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),

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
                    : const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/friends_providers.dart';

class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final _searchController = TextEditingController();
  bool _searchByPhone = false;
  final Set<String> _sentRequests = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      ref.read(searchUsersControllerProvider.notifier).clearSearch();
      return;
    }

    if (_searchByPhone) {
      ref.read(searchUsersControllerProvider.notifier).searchByPhone(query);
    } else {
      ref.read(searchUsersControllerProvider.notifier).searchByUsername(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchUsersControllerProvider);
    final currentUser = ref.watch(authStateProvider).value;

    ref.listen(createManualFriendControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Manual friend added!')));
          _searchController.clear();
          ref.read(searchUsersControllerProvider.notifier).clearSearch();
        },
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Find Friends')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _searchByPhone
                        ? 'Search by phone number'
                        : 'Search by username',
                    prefixIcon: Icon(
                      _searchByPhone ? Icons.phone : Icons.alternate_email,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(searchUsersControllerProvider.notifier)
                                  .clearSearch();
                            },
                          )
                        : null,
                  ),
                  onChanged: _performSearch,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Username'),
                        selected: !_searchByPhone,
                        onSelected: (selected) {
                          setState(() {
                            _searchByPhone = false;
                            _searchController.clear();
                            ref
                                .read(searchUsersControllerProvider.notifier)
                                .clearSearch();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Phone Number'),
                        selected: _searchByPhone,
                        onSelected: (selected) {
                          setState(() {
                            _searchByPhone = true;
                            _searchController.clear();
                            ref
                                .read(searchUsersControllerProvider.notifier)
                                .clearSearch();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: searchResults.when(
              data: (users) {
                final query = _searchController.text.trim();
                if (query.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Search for friends',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filter out current user
                final filteredUsers = users
                    .where((user) => user.id != currentUser?.id)
                    .toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_search,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found for "$query"',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Friend not on the app?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(
                                  createManualFriendControllerProvider.notifier,
                                )
                                .create(query);
                          },
                          icon: const Icon(Icons.add),
                          label: Text('Add "$query" as #manual friend'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final isAlreadyFriend =
                              currentUser?.friends.contains(user.id) ?? false;

                          return FutureBuilder<String?>(
                            future: ref
                                .read(friendsRepositoryProvider)
                                .getFriendshipStatus(currentUser!.id, user.id),
                            builder: (context, snapshot) {
                              final status = snapshot.data;
                              final hasPendingRequest = status == 'pending';
                              final isAccepted = status == 'accepted';
                              final isSentLocal = _sentRequests.contains(
                                user.id,
                              );

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? Text(user.name[0].toUpperCase())
                                      : null,
                                ),
                                title: Text(user.name),
                                subtitle: Text(
                                  user.isManual
                                      ? '#${user.name.toLowerCase().replaceAll(' ', '_')}'
                                      : '@${user.username}',
                                  style: TextStyle(
                                    color: user.isManual
                                        ? Colors.blueGrey
                                        : Colors.grey,
                                  ),
                                ),
                                trailing: isAlreadyFriend || isAccepted
                                    ? const Chip(
                                        label: Text('Friends'),
                                        backgroundColor: AppTheme.primaryColor,
                                      )
                                    : (hasPendingRequest || isSentLocal)
                                    ? const Chip(
                                        label: Text('Requested'),
                                        backgroundColor: Colors.orange,
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: () {
                                          ref
                                              .read(
                                                sendFriendRequestControllerProvider
                                                    .notifier,
                                              )
                                              .sendRequest(user.id);
                                          setState(() {
                                            _sentRequests.add(user.id);
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.person_add,
                                          size: 16,
                                        ),
                                        label: const Text('Add'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                        ),
                                      ),
                                onTap: () {},
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Option to add manual friend even if real users are found
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(
                                createManualFriendControllerProvider.notifier,
                              )
                              .create(query);
                        },
                        icon: const Icon(Icons.add),
                        label: Text('Add "$query" as #manual friend instead'),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/friends_providers.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(userFriendsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Options & Friend List
          Expanded(
            child: friendsAsync.when(
              data: (friends) {
                final filteredFriends = friends.where((friend) {
                  return friend.name.toLowerCase().contains(_searchQuery) ||
                      friend.username.toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView(
                  children: [
                    // Options
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.group_add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: const Text('New Group'),
                      onTap: () {
                        context.replace(
                          '/create-group',
                        ); // Replace to avoid stacking
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.person_add,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      title: const Text('Add New Friend'),
                      onTap: () {
                        context.push('/friends/search');
                      },
                    ),

                    const Divider(height: 32),

                    if (filteredFriends.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No friends found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...filteredFriends.map((friend) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: friend.avatarUrl != null
                                ? NetworkImage(friend.avatarUrl!)
                                : null,
                            child: friend.avatarUrl == null
                                ? Text(
                                    friend.name.isNotEmpty
                                        ? friend.name[0].toUpperCase()
                                        : '?',
                                  )
                                : null,
                          ),
                          title: Text(
                            friend.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('@${friend.username}'),
                          onTap: () {
                            context.replace('/friends/${friend.id}');
                          },
                        );
                      }),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

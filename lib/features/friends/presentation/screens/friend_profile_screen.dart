import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../presentation/providers/friends_providers.dart';
import '../../../groups/presentation/providers/group_providers.dart';

class FriendProfileScreen extends ConsumerWidget {
  final String friendId;

  const FriendProfileScreen({super.key, required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final friendAsync = ref.watch(specificFriendProvider(friendId));
    final groupsAsync = ref.watch(userGroupsProvider);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Info')),
      body: friendAsync.when(
        data: (friend) {
          if (friend == null) {
            return const Center(child: Text('User not found'));
          }

          final isMuted = currentUser.mutedUids.contains(friendId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Header (Avatar, Name, Username)
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: friend.avatarUrl != null
                        ? NetworkImage(friend.avatarUrl!)
                        : null,
                    child: friend.avatarUrl == null
                        ? Text(
                            friend.name.isNotEmpty
                                ? friend.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 48),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  friend.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  friend.isManual
                      ? '#${friend.name.toLowerCase().replaceAll(' ', '_')}'
                      : '@${friend.username}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                if (friend.phoneNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    friend.phoneNumber!,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),

                // Mute Notifications Toggle
                SwitchListTile(
                  title: const Text(
                    'Mute Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('For direct payments and common groups'),
                  secondary: const Icon(Icons.notifications_off_outlined),
                  value: isMuted,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) async {
                    try {
                      final updatedMutedUids = List<String>.from(
                        currentUser.mutedUids,
                      );
                      if (value) {
                        if (!updatedMutedUids.contains(friendId)) {
                          updatedMutedUids.add(friendId);
                        }
                      } else {
                        updatedMutedUids.remove(friendId);
                      }

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.id)
                          .update({'mutedUids': updatedMutedUids});

                      // ignore: unused_result
                      ref.refresh(authStateProvider);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating setting: $e')),
                      );
                    }
                  },
                ),
                const Divider(),

                // Common Groups Section
                groupsAsync.when(
                  data: (allGroups) {
                    final commonGroups = allGroups.where((group) {
                      // Check if the friend is in this group
                      // Manual friends might not be in the memberIds string list but could be mapped differently if the app supports it.
                      // For now, assume standard memberIds check.
                      return group.memberIds.contains(friendId);
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Common Groups (${commonGroups.length})',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                        if (commonGroups.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'No common groups found.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: commonGroups.length,
                            itemBuilder: (context, index) {
                              final group = commonGroups[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.groups,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                title: Text(group.name),
                                subtitle: Text(
                                  '${group.memberIds.length} members',
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  context.push('/groups/${group.id}');
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading common groups: $err'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

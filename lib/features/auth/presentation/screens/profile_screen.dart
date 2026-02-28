import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Use refresh instead of invalidate - more targeted
              // ignore: unused_result
              ref.refresh(authStateProvider);
              // Small delay for visual feedback
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _ProfileItem(
                  icon: Icons.person,
                  label: 'Name',
                  value: user.name,
                ),
                _ProfileItem(
                  icon: Icons.alternate_email,
                  label: 'Username',
                  value: '@${user.username}',
                ),
                _ProfileItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: user.email,
                ),
                if (user.phoneNumber != null)
                  _ProfileItem(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: user.phoneNumber!,
                  ),
                if (user.upiId != null)
                  _ProfileItem(
                    icon: Icons.payment,
                    label: 'UPI ID',
                    value: user.upiId!,
                  ),
                const SizedBox(height: 24),
                const SizedBox(height: 32),

                // Edit Details Button
                ElevatedButton.icon(
                  onPressed: () {
                    final nameController = TextEditingController(
                      text: user.name,
                    );
                    final usernameController = TextEditingController(
                      text: user.username,
                    );
                    final phoneController = TextEditingController(
                      text: user.phoneNumber ?? '',
                    );
                    final upiController = TextEditingController(
                      text: user.upiId ?? '',
                    );

                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Edit Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: upiController,
                              decoration: const InputDecoration(
                                labelText: 'UPI ID',
                                prefixIcon: Icon(Icons.payment),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              final username = usernameController.text
                                  .trim()
                                  .toLowerCase();
                              final phone = phoneController.text.trim();
                              final upi = upiController.text.trim();

                              if (name.isEmpty || username.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Name and username are required',
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                // Get current user ID
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId == null) {
                                  throw Exception('Not authenticated');
                                }

                                // Check if username is already taken by another user
                                final usernameQuery = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .where('username', isEqualTo: username)
                                    .where(
                                      FieldPath.documentId,
                                      isNotEqualTo: userId,
                                    )
                                    .limit(1)
                                    .get();

                                if (usernameQuery.docs.isNotEmpty) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Username already taken'),
                                    ),
                                  );
                                  return;
                                }

                                // Update user profile in Firestore
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .update({
                                      'name': name,
                                      'username': username,
                                      'phoneNumber': phone.isNotEmpty
                                          ? phone
                                          : null,
                                      'upiId': upi.isNotEmpty ? upi : null,
                                    });

                                if (!context.mounted) return;
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile updated!'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Change Password and Sign Out buttons removed
                // They are now accessible from the Home Screen menu
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

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

                                // Update user profile in Firestore
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .update({
                                      'name': name,
                                      'username': username,
                                      if (phone.isNotEmpty)
                                        'phoneNumber': phone,
                                    });

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

                // Change Password Button
                ElevatedButton.icon(
                  onPressed: () {
                    final currentPasswordController = TextEditingController();
                    final newPasswordController = TextEditingController();
                    final confirmPasswordController = TextEditingController();
                    bool showCurrentPassword = false;
                    bool showNewPassword = false;
                    bool showConfirmPassword = false;

                    showDialog(
                      context: context,
                      builder: (dialogContext) => StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: const Text('Change Password'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: currentPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'Current Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        showCurrentPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setDialogState(() {
                                          showCurrentPassword =
                                              !showCurrentPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: !showCurrentPassword,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: newPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        showNewPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setDialogState(() {
                                          showNewPassword = !showNewPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: !showNewPassword,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm New Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        showConfirmPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setDialogState(() {
                                          showConfirmPassword =
                                              !showConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: !showConfirmPassword,
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
                                  final currentPassword =
                                      currentPasswordController.text.trim();
                                  final newPassword = newPasswordController.text
                                      .trim();
                                  final confirmPassword =
                                      confirmPasswordController.text.trim();

                                  if (currentPassword.isEmpty ||
                                      newPassword.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'All fields are required',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (newPassword != confirmPassword) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'New passwords do not match',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (newPassword.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password must be at least 6 characters',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user?.email == null) {
                                      throw Exception('No user logged in');
                                    }

                                    // Re-authenticate user with current password
                                    final credential =
                                        EmailAuthProvider.credential(
                                          email: user!.email!,
                                          password: currentPassword,
                                        );
                                    await user.reauthenticateWithCredential(
                                      credential,
                                    );

                                    // Update password
                                    await user.updatePassword(newPassword);

                                    Navigator.pop(dialogContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password updated successfully!',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    String message =
                                        'Failed to update password';
                                    if (e.toString().contains(
                                      'wrong-password',
                                    )) {
                                      message = 'Current password is incorrect';
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  }
                                },
                                child: const Text('Update'),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('Change Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    foregroundColor: Colors.orange,
                  ),
                ),

                const SizedBox(height: 16),

                // Sign Out Button
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                          'Are you sure you want to sign out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref
                                  .read(signOutControllerProvider.notifier)
                                  .signOut();
                            },
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
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

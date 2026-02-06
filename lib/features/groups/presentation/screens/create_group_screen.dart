import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/group_providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        ref.read(groupControllerProvider.notifier).createGroup(
          _nameController.text.trim(),
          [user.id], // Creator is the first member
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupControllerProvider);

    ref.listen(groupControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        data: (_) {
          if (previous?.isLoading == true) {
            // Only pop if we were loading (success after action)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppConstants.groupCreated)),
            );
            context.pop();
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.createGroup)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'e.g. Summer Trip, roommates',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.groupNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text(AppConstants.createGroup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

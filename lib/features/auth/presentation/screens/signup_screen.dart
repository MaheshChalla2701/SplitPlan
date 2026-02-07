import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/form_validators.dart';
import '../providers/auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(signupControllerProvider.notifier)
          .signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
            _usernameController.text.trim(),
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          );
    }
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = FormValidators.getPasswordStrength(value);
    });
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _getStrengthText() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupControllerProvider);

    ref.listen(signupControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join SplitPlan',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start splitting expenses with ease',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),

                  // Name field (required)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: FormValidators.validateName,
                  ),
                  const SizedBox(height: 16),

                  // Email field (required)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'Enter your email address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Username field (required)
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username *',
                      hintText: 'Choose a unique username',
                      prefixIcon: Icon(Icons.alternate_email),
                      helperText:
                          'Lowercase letters, numbers, and underscores only',
                    ),
                    validator: FormValidators.validateUsername,
                    onChanged: (value) {
                      // Auto-convert to lowercase
                      if (value != value.toLowerCase()) {
                        _usernameController.value = TextEditingValue(
                          text: value.toLowerCase(),
                          selection: _usernameController.selection,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone field (optional)
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Optional',
                      prefixIcon: Icon(Icons.phone_outlined),
                      helperText: 'Helps friends find you',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: FormValidators.validatePhone,
                  ),
                  const SizedBox(height: 16),

                  // Password field (required)
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      hintText: 'At least 8 characters',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: FormValidators.validatePassword,
                    onChanged: _onPasswordChanged,
                  ),

                  // Password strength indicator
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _passwordStrength == PasswordStrength.weak
                                ? 0.33
                                : _passwordStrength == PasswordStrength.medium
                                ? 0.66
                                : 1.0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
                              _getStrengthColor(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStrengthText(),
                          style: TextStyle(
                            color: _getStrengthColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),
                  ElevatedButton(
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
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

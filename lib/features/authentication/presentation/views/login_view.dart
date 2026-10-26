import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/core/utilities/validators.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/google_sign_in_view_model.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/brand_header.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/google_sign_in_button.dart';
import 'package:mae_assignment/shared/ui/labeled_text_field.dart';
import 'package:mae_assignment/shared/ui/or_divider.dart';
import 'package:mae_assignment/shared/ui/password_field.dart';

/// Login page for every role: customers, Store Workers and Store Admin.
/// Email and password (plus Google for customers on mobile). After logging
/// in, each account opens its own home based on its role.
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogIn() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // One login for everyone: the account's role decides where it lands.
    final home = await ref
        .read(loginViewModelProvider.notifier)
        .signIn(
          emailOrPhone: _emailOrPhoneController.text,
          password: _passwordController.text,
        );
    // go() instead of push() so the user cannot go "back" to the login page.
    if (home != null && mounted) context.go(home);
  }

  Future<void> _onForgotPassword() async {
    var resetEmail = _emailOrPhoneController.text.contains('@')
        ? _emailOrPhoneController.text.trim()
        : '';
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset password'),
        content: TextFormField(
          initialValue: resetEmail,
          onChanged: (value) => resetEmail = value,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Email address',
            hintText: 'you@example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, resetEmail.trim()),
            child: const Text('Send reset link'),
          ),
        ],
      ),
    );
    if (!mounted || email == null) return;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      if (mounted) {
        _showMessage(
          'If this email has an account, a reset link is on its way.',
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    }
  }

  Future<void> _onGoogle() async {
    final signedIn = await ref
        .read(googleSignInViewModelProvider.notifier)
        .signIn();
    // Google sign-in is customer-only, so it lands on the catalogue.
    if (signedIn && mounted) context.go(AppRoutes.customerCatalogue);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isGoogleLoading = ref.watch(googleSignInViewModelProvider).isLoading;
    final isLoggingIn = ref.watch(loginViewModelProvider).isLoading;
    final isLoading = isLoggingIn || isGoogleLoading;

    // Show a message whenever logging in fails.
    ref.listen(loginViewModelProvider, (previous, next) {
      if (next is AsyncError) _showMessage(next.error.toString());
    });
    ref.listen(googleSignInViewModelProvider, (previous, next) {
      if (next is AsyncError) _showMessage(next.error.toString());
    });

    return Scaffold(
      body: SafeArea(
        // On tablets and web, keep the content phone-width in the middle.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const BrandHeader(showBackButton: !kIsWeb),
                            const SizedBox(height: 32),
                            Text(
                              'Log in to continue',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kIsWeb
                                  ? 'Log in with your HQ admin account.'
                                  : 'One account for shopping, packing, and '
                                        'running the store.',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 28),
                            LabeledTextField(
                              label: 'Email or phone',
                              hint: 'you@example.com',
                              controller: _emailOrPhoneController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.telephoneNumber,
                              ],
                              validator: Validators.emailOrPhone,
                            ),
                            const SizedBox(height: 16),
                            PasswordField(
                              hint: 'Your password',
                              controller: _passwordController,
                              validator: Validators.password,
                              // Enter or Done logs in, as on any login form.
                              onSubmitted: (_) {
                                if (!isLoading) unawaited(_onLogIn());
                              },
                              labelTrailing: _ForgotPasswordLink(
                                onPressed: _onForgotPassword,
                              ),
                            ),
                            const SizedBox(height: 28),
                            FilledButton.icon(
                              key: const Key('login_button'),
                              onPressed: isLoading ? null : _onLogIn,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                              ),
                              icon: isLoggingIn
                                  ? const ButtonLoadingIndicator()
                                  : const Icon(Icons.login_rounded),
                              label: const Text('Log in'),
                            ),
                            if (!kIsWeb) ...[
                              const SizedBox(height: 20),
                              const OrDivider(),
                              const SizedBox(height: 20),
                              GoogleSignInButton(
                                onPressed: isLoading ? null : _onGoogle,
                                isLoading: isGoogleLoading,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!kIsWeb)
                  BottomActionBar(
                    children: [
                      TextButton(
                        // Replace instead of push, so "back" from sign-up
                        // returns to onboarding, not to this page.
                        onPressed: () =>
                            context.pushReplacement(AppRoutes.register),
                        child: const Text('New to Grocerly? Create an account'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small "Forgot password?" link shown next to the password label.
class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: const Text('Forgot password?'),
    );
  }
}

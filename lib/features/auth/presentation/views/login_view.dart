import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/bottom_action_bar.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../../shared/widgets/google_sign_in_button.dart';
import '../../../../shared/widgets/labeled_text_field.dart';
import '../../../../shared/widgets/or_divider.dart';
import '../../../../shared/widgets/password_field.dart';

/// The three kinds of user who can sign in.
enum UserRole { storeAdmin, storeWorker, customer }

/// Sign-in page for every role. UI only for now, not connected to Firebase.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onContinueAs(UserRole role) {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // TODO: sign in with Firebase, then open the home page for this role.
    _showMessage('Signing in as ${_roleName(role)} (UI only for now).');
  }

  void _onForgotPassword() {
    // TODO: password reset page once the backend is connected.
    _showMessage('Password reset is not connected yet.');
  }

  void _onGoogle() {
    // TODO: Google sign-in once the backend is connected.
    _showMessage('Google sign-in is not connected yet.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  String _roleName(UserRole role) {
    switch (role) {
      case UserRole.storeAdmin:
        return 'Store Admin';
      case UserRole.storeWorker:
        return 'Store Worker';
      case UserRole.customer:
        return 'Customer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                            const BrandHeader(showBackButton: true),
                            const SizedBox(height: 32),
                            Text(
                              'Sign in to continue',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'One account for shopping, packing, and '
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
                              labelTrailing: _ForgotPasswordLink(
                                onPressed: _onForgotPassword,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'CONTINUE AS',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _RoleButton(
                              icon: Icons.dashboard_outlined,
                              title: 'Store Admin',
                              subtitle: 'Tablet dashboard',
                              onPressed: () =>
                                  _onContinueAs(UserRole.storeAdmin),
                            ),
                            const SizedBox(height: 12),
                            _RoleButton(
                              icon: Icons.inventory_2_outlined,
                              title: 'Store Worker',
                              subtitle: 'Packing and delivery',
                              onPressed: () =>
                                  _onContinueAs(UserRole.storeWorker),
                            ),
                            const SizedBox(height: 12),
                            _RoleButton(
                              icon: Icons.shopping_basket_outlined,
                              title: 'Customer',
                              subtitle: 'Browse and order',
                              onPressed: () => _onContinueAs(UserRole.customer),
                            ),
                            const SizedBox(height: 20),
                            const OrDivider(),
                            const SizedBox(height: 20),
                            GoogleSignInButton(onPressed: _onGoogle),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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

/// Big button for one role: icon, role name, what that role does, and ">".
/// Uses the app's FilledButton theme so it matches other primary buttons.
class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenTint,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

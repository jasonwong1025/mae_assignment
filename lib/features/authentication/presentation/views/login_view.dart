import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utilities/validators.dart';
import '../../../../shared/ui/bottom_action_bar.dart';
import '../../../../shared/ui/brand_header.dart';
import '../../../../shared/ui/button_loading_indicator.dart';
import '../../../../shared/ui/google_sign_in_button.dart';
import '../../../../shared/ui/labeled_text_field.dart';
import '../../../../shared/ui/or_divider.dart';
import '../../../../shared/ui/password_field.dart';
import '../../../../shared/models/app_user.dart';
import '../view_models/login_view_model.dart';

/// Sign-in page for every role. Uses email and password.
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  /// The role button that was tapped, so only that one shows a spinner.
  UserRole? _selectedRole;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onContinueAs(UserRole role) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => _selectedRole = role);
    final signedIn = await ref
        .read(loginViewModelProvider.notifier)
        .signIn(
          emailOrPhone: _emailOrPhoneController.text,
          password: _passwordController.text,
          role: role,
        );

    // go() instead of push() so the user cannot go "back" to sign-in.
    if (signedIn && mounted) context.go(AppRoutes.home);
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLoading = ref.watch(loginViewModelProvider).isLoading;

    // Show a message whenever sign-in fails.
    ref.listen(loginViewModelProvider, (previous, next) {
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
                              title: UserRole.storeAdmin.label,
                              subtitle: 'Tablet dashboard',
                              isLoading:
                                  isLoading &&
                                  _selectedRole == UserRole.storeAdmin,
                              onPressed: isLoading
                                  ? null
                                  : () => _onContinueAs(UserRole.storeAdmin),
                            ),
                            const SizedBox(height: 12),
                            _RoleButton(
                              icon: Icons.inventory_2_outlined,
                              title: UserRole.storeWorker.label,
                              subtitle: 'Packing and delivery',
                              isLoading:
                                  isLoading &&
                                  _selectedRole == UserRole.storeWorker,
                              onPressed: isLoading
                                  ? null
                                  : () => _onContinueAs(UserRole.storeWorker),
                            ),
                            const SizedBox(height: 12),
                            _RoleButton(
                              icon: Icons.shopping_basket_outlined,
                              title: UserRole.customer.label,
                              subtitle: 'Browse and order',
                              isLoading:
                                  isLoading &&
                                  _selectedRole == UserRole.customer,
                              onPressed: isLoading
                                  ? null
                                  : () => _onContinueAs(UserRole.customer),
                            ),
                            const SizedBox(height: 20),
                            const OrDivider(),
                            const SizedBox(height: 20),
                            GoogleSignInButton(
                              onPressed: isLoading ? null : _onGoogle,
                            ),
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
    required this.isLoading,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLoading;

  /// Null disables the button.
  final VoidCallback? onPressed;

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
          if (isLoading)
            const ButtonLoadingIndicator()
          else
            const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

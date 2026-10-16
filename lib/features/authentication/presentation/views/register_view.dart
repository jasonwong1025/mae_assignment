import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/validators.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/google_sign_in_view_model.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/register_view_model.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/brand_header.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/google_sign_in_button.dart';
import 'package:mae_assignment/shared/ui/labeled_text_field.dart';
import 'package:mae_assignment/shared/ui/or_divider.dart';
import 'package:mae_assignment/shared/ui/password_field.dart';

/// Sign-up page (customers only). Uses email and password.
class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    if (!_agreedToTerms) {
      _showMessage('Please agree to the Terms and Privacy Notice.');
      return;
    }

    final created = await ref
        .read(registerViewModelProvider.notifier)
        .createAccount(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );

    // go() instead of push() so the user cannot go "back" to sign-up.
    if (created && mounted) context.go(AppRoutes.home);
  }

  Future<void> _onGoogle() async {
    final signedIn = await ref
        .read(googleSignInViewModelProvider.notifier)
        .signIn();
    if (signedIn && mounted) context.go(AppRoutes.home);
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
    final isLoading =
        ref.watch(registerViewModelProvider).isLoading || isGoogleLoading;

    // Show a message whenever sign-up fails.
    ref.listen(registerViewModelProvider, (previous, next) {
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
                            const BrandHeader(showBackButton: true),
                            const SizedBox(height: 32),
                            Text(
                              'Create your account',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Takes less than a minute.',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 28),
                            LabeledTextField(
                              label: 'Full name',
                              hint: 'John',
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              autofillHints: const [AutofillHints.name],
                              validator: Validators.name,
                            ),
                            const SizedBox(height: 16),
                            LabeledTextField(
                              label: 'Email',
                              hint: 'you@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            LabeledTextField(
                              label: 'Phone number',
                              hint: '012-345 6789',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                              validator: Validators.phone,
                            ),
                            const SizedBox(height: 16),
                            PasswordField(
                              hint: 'At least 8 characters',
                              controller: _passwordController,
                              validator: Validators.newPassword,
                              isNewPassword: true,
                            ),
                            const SizedBox(height: 12),
                            _TermsCheckbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() => _agreedToTerms = value);
                              },
                            ),
                            const SizedBox(height: 20),
                            const OrDivider(),
                            const SizedBox(height: 20),
                            GoogleSignInButton(
                              onPressed: isLoading ? null : _onGoogle,
                              isLoading: isGoogleLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                BottomActionBar(
                  children: [
                    FilledButton(
                      onPressed: isLoading ? null : _onCreateAccount,
                      child: isLoading
                          ? const ButtonLoadingIndicator()
                          : const Text('Create account'),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      // Replace instead of push, so "back" from login
                      // returns to onboarding, not to this page.
                      onPressed: () => context.pushReplacement(AppRoutes.login),
                      child: const Text('Already have an account? Sign in'),
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

/// "[ ] I agree to the Terms and Privacy Notice." row.
/// The whole row is tappable, not just the small box.
class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.darkGreen,
    );

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
            activeColor: AppColors.darkGreen,
            side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: const [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(text: 'Terms', style: linkStyle),
                  TextSpan(text: ' and '),
                  TextSpan(text: 'Privacy Notice', style: linkStyle),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

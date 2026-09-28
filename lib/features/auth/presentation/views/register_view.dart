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

/// Sign-up page (customers only). UI only for now, not connected to Firebase.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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

  void _onCreateAccount() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    if (!_agreedToTerms) {
      _showMessage('Please agree to the Terms and Privacy Notice.');
      return;
    }

    // TODO: call Firebase sign-up once the backend is connected.
    _showMessage('Account created (UI only for now).');
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
                            GoogleSignInButton(onPressed: _onGoogle),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                BottomActionBar(
                  children: [
                    FilledButton(
                      onPressed: _onCreateAccount,
                      child: const Text('Create account'),
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

import 'package:flutter/material.dart';

import 'package:mae_assignment/shared/ui/labeled_text_field.dart';

/// LabeledTextField for passwords, with an eye icon to show or hide the text.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.label = 'Password',
    this.labelTrailing,
    this.controller,
    this.hint,
    this.validator,
    this.isNewPassword = false,
    this.onSubmitted,
  });

  final String label;
  final Widget? labelTrailing;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;

  /// True on sign-up, so password managers offer to create a new password.
  final bool isNewPassword;

  /// Called when Done or Enter is pressed, e.g. to submit the form.
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: widget.label,
      labelTrailing: widget.labelTrailing,
      controller: widget.controller,
      hint: widget.hint,
      validator: widget.validator,
      obscureText: _hidden,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: [
        if (widget.isNewPassword)
          AutofillHints.newPassword
        else
          AutofillHints.password,
      ],
      suffixIcon: IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        tooltip: _hidden ? 'Show password' : 'Hide password',
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';

/// A text field with a small uppercase label above it
/// (e.g. "FULL NAME" then the input box). Used by all forms in the app.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    required this.label,
    super.key,
    this.labelTrailing,
    this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.autofillHints,
    this.field,
    this.onFieldSubmitted,
  });

  final String label;

  /// Optional widget on the right of the label, e.g. "Forgot password?".
  final Widget? labelTrailing;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  /// Replaces the text box, e.g. with a dropdown.
  final Widget? field;

  /// Called when the keyboard's action key (Done, Enter) is pressed.
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed height so labels line up whether or not there is a trailing
        // widget next to them.
        SizedBox(
          height: 24,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ?labelTrailing, // only added when not null
            ],
          ),
        ),
        const SizedBox(height: 6),
        field ??
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onFieldSubmitted: onFieldSubmitted,
              obscureText: obscureText,
              validator: validator,
              autofillHints: autofillHints,
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: suffixIcon,
              ),
            ),
      ],
    );
  }
}

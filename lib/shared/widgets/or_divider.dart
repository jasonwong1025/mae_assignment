import 'package:flutter/material.dart';

/// Horizontal line with a word in the middle, e.g. "──── or ────".
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.text = 'or'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

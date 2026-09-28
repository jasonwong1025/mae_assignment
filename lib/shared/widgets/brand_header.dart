import 'package:flutter/material.dart';

import 'app_back_button.dart';

/// Logo with the app name and tagline next to it, optionally with the
/// back button on the left in the same row.
/// Shown at the top of the sign-in and sign-up pages.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        if (showBackButton) ...[
          const AppBackButton(),
          const SizedBox(width: 16),
        ],
        // Same height as the back button so the row lines up.
        Image.asset('assets/logo/logo.png', height: 48),
        const SizedBox(width: 12),
        // Flexible lets the tagline wrap on very small phones
        // instead of overflowing off the screen.
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Grocerly', style: textTheme.headlineSmall),
              Text('Local grocery, sorted.', style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

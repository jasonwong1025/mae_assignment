import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';

/// Bar pinned to the bottom of a page with a thin line on top.
/// Holds the page's main actions so they stay visible while the page scrolls.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    required this.children,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 12),
  });

  final List<Widget> children;

  /// Space around the actions. Pages ending in a text link can use less
  /// at the bottom, since the link already has its own tap area.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

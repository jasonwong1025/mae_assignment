import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

/// Side panel with a title, a close button and [child] below.
/// Used by the admin tabs for details and forms.
class SidePanelFrame extends StatelessWidget {
  const SidePanelFrame({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
  });

  final String title;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

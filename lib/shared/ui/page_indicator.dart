import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Row of dots showing which slide is active (the "● ○ ○" in the wireframe).
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8, // active dot stretches into a pill
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.darkGreen
                : AppColors.darkGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

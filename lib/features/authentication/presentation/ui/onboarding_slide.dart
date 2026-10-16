import 'package:flutter/material.dart';

/// The text of one onboarding slide.
class OnboardingSlideData {
  const OnboardingSlideData({required this.title, required this.description});

  final String title;
  final String description;
}

/// Title + description, centred. Used inside the PageView.
/// The logo is not part of the slide. It stays fixed above the slides.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({required this.data, super.key});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Scrollable in case the text is taller than the space available
    // (e.g. small phones or large system font size).
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../ui/onboarding_slide.dart';
import '../../../../shared/ui/page_indicator.dart';

/// First screen of the app: swipeable intro slides plus
/// "Get started" (register) and "I already have an account" (login).
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  static const List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Your neighbourhood grocer, online',
      description:
          'Shop from local stores near you and get your groceries '
          'delivered the same day, or pick them up yourself.',
    ),
    OnboardingSlideData(
      title: 'Know before you go',
      description:
          'Check what is in stock, compare nearby stores, and turn your '
          'grocery list or recipe into a cart.',
    ),
    OnboardingSlideData(
      title: 'No surprises',
      description:
          'Approve any replacement before it is packed, and follow your '
          'order until it reaches your door.',
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // On tablets and web, keep the content phone-width in the middle.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // The logo stays in place; only the text below it swipes.
                Image.asset('assets/logo/logo.png', height: 200),
                const SizedBox(height: 32),
                // Fixed height for the text. Each slide scrolls if its text
                // is taller than this (small phones / large system font).
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return OnboardingSlide(data: _slides[index]);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                PageIndicator(
                  count: _slides.length,
                  currentIndex: _currentPage,
                ),
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      FilledButton(
                        onPressed: () => context.push(AppRoutes.register),
                        child: const Text('Get started'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.login),
                        child: const Text('I already have an account'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

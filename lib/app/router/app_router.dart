import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/data/repositories/auth_repository.dart';
import '../../features/authentication/presentation/views/home_placeholder_view.dart';
import '../../features/authentication/presentation/views/login_view.dart';
import '../../features/authentication/presentation/views/onboarding_view.dart';
import '../../features/authentication/presentation/views/register_view.dart';

/// Route paths are kept in one place so we don't mistype them in screens.
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  /// Pages for people who are not signed in.
  static const List<String> signedOutPages = [onboarding, login, register];
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,

    // Runs before every navigation:
    // - signed in and on onboarding/login/sign-up: go to home
    // - not signed in and on any other page: go to onboarding
    // Screens still call context.go() themselves after signing in or out.
    redirect: (context, state) {
      final isSignedIn = authRepository.isSignedIn;
      final onSignedOutPage = AppRoutes.signedOutPages.contains(
        state.matchedLocation,
      );

      if (isSignedIn && onSignedOutPage) return AppRoutes.home;
      if (!isSignedIn && !onSignedOutPage) return AppRoutes.onboarding;
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePlaceholderView(),
      ),
    ],
  );
});

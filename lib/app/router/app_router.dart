import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/data/repositories/auth_repository.dart';
import '../../features/authentication/presentation/views/home_placeholder_view.dart';
import '../../features/authentication/presentation/views/login_view.dart';
import '../../features/authentication/presentation/views/onboarding_view.dart';
import '../../features/authentication/presentation/views/register_view.dart';
import '../../features/store_admin/dashboard/presentation/views/dashboard_view.dart';
import '../../features/store_admin/dispatch/presentation/views/dispatch_view.dart';
import '../../features/store_admin/inventory/presentation/views/inventory_view.dart';
import '../../features/store_admin/orders/presentation/views/orders_view.dart';
import '../../features/store_admin/staff/presentation/views/staff_view.dart';

/// Route paths are kept in one place so we don't mistype them in screens.
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminInventory = '/admin/inventory';
  static const String adminStaff = '/admin/staff';
  static const String adminDispatch = '/admin/dispatch';

  /// Pages for people who are not signed in.
  static const List<String> signedOutPages = [onboarding, login, register];
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes
        .onboarding, //the initial page that will be shown when the app is opened
    // Runs before every navigation:
    // - signed in and on onboarding/login/sign-up: go to home
    // - not signed in and on any other page: go to onboarding
    // Screens still call context.go() themselves after signing in or out.
    redirect: (context, state) {
      // checks if the user is signed in
      final isSignedIn = authRepository.isSignedIn;
      // checks if the user is on a signed out page
      final onSignedOutPage = AppRoutes.signedOutPages.contains(
        state.matchedLocation,
      );

      // if the user is signed in and on a signed out page, redirect to the home page
      if (isSignedIn && onSignedOutPage) return AppRoutes.home;
      // if the user is not signed in and not on a signed out page, redirect to the onboarding page
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

      // Store admin tabs. No page animation, so switching tabs changes
      // the page without the sidebar appearing to slide in again.
      GoRoute(
        path: AppRoutes.adminDashboard,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DashboardView()),
      ),
      GoRoute(
        path: AppRoutes.adminOrders,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OrdersView()),
      ),
      GoRoute(
        path: AppRoutes.adminInventory,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: InventoryView()),
      ),
      GoRoute(
        path: AppRoutes.adminStaff,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: StaffView()),
      ),
      GoRoute(
        path: AppRoutes.adminDispatch,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DispatchView()),
      ),
    ],
  );
});

import 'package:flutter/foundation.dart';
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
import '../../features/store_admin/reviews/presentation/views/reviews_view.dart';
import '../../features/store_admin/staff/presentation/views/staff_view.dart';
import '../../features/store_worker/delivery/presentation/views/delivery_detail_view.dart';
import '../../features/store_worker/delivery/presentation/views/delivery_tasks_view.dart';
import '../../features/store_worker/packing/presentation/views/packing_order_view.dart';
import '../../features/store_worker/packing/presentation/views/packing_tasks_view.dart';
import '../../features/store_worker/pickup/presentation/views/pickup_handover_view.dart';
import '../../features/store_worker/pickup/presentation/views/pickup_queue_view.dart';
import '../../features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import '../../features/store_worker/session/presentation/views/mock_worker_selector_view.dart';
import '../../features/store_worker/session/worker_preview.dart';
import '../../features/store_worker/shell/presentation/views/worker_account_view.dart';
import '../../features/store_worker/shell/worker_routes.dart';

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
  static const String adminReviews = '/admin/reviews';

  // Store Worker (mobile). Every worker page starts with workerRoot.
  static const String workerRoot = '/worker';
  static const String workerDevSelect = '/worker/dev-select';
  static const String workerPacking = '/worker/packing';
  static const String workerPickup = '/worker/pickup';
  static const String workerDelivery = '/worker/delivery';
  static const String workerAccount = '/worker/account';

  // Order pages inside the worker tabs (full screen, pushed over the tab).
  // The role guard covers them through their tab's path.
  static String workerPackingOrder(String orderId) => '$workerPacking/$orderId';
  static String workerPickupOrder(String orderId) => '$workerPickup/$orderId';
  static String workerDeliveryOrder(String orderId) =>
      '$workerDelivery/$orderId';

  /// Pages for people who are not signed in.
  static const List<String> signedOutPages = [onboarding, login, register];
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final workerPreviewEnabled = ref.watch(workerPreviewEnabledProvider);

  // Re-runs the redirect when the preview worker changes, so switching or
  // leaving a worker immediately applies the new role's pages.
  // listen (not watch), so the router is not rebuilt and history is kept.
  final workerSessionChanges = ValueNotifier<int>(0);
  ref.listen(workerSessionProvider, (previous, next) {
    workerSessionChanges.value++;
  });
  ref.onDispose(workerSessionChanges.dispose);

  return GoRouter(
    initialLocation: AppRoutes
        .onboarding, //the initial page that will be shown when the app is opened
    refreshListenable: workerSessionChanges,
    // Runs before every navigation:
    // - Store Worker pages: preview and role checks (workerRouteRedirect)
    // - signed in and on onboarding/login/sign-up: go to home
    // - not signed in and on any other page: go to onboarding
    // Screens still call context.go() themselves after signing in or out.
    redirect: (context, state) {
      // checks if the user is signed in
      final isSignedIn = authRepository.isSignedIn;

      // Worker pages are decided only by the preview session. It never
      // signs anyone in, so it cannot open admin pages.
      if (isWorkerLocation(state.matchedLocation)) {
        return workerRouteRedirect(
          location: state.matchedLocation,
          previewEnabled: workerPreviewEnabled,
          worker: ref.read(workerSessionProvider),
          isSignedIn: isSignedIn,
        );
      }

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

      // Store Worker preview. The selector is development-only (see
      // worker_preview.dart); the tabs have no page animation, like the
      // admin tabs.
      GoRoute(
        path: AppRoutes.workerDevSelect,
        builder: (context, state) => const MockWorkerSelectorView(),
      ),
      GoRoute(
        path: AppRoutes.workerPacking,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PackingTasksView()),
      ),
      // One order's packing screen. Full screen (no bottom navigation) and
      // pushed over My Tasks, so "back" returns to the list.
      GoRoute(
        path: '${AppRoutes.workerPacking}/:orderId',
        builder: (context, state) =>
            PackingOrderView(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: AppRoutes.workerPickup,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PickupQueueView()),
      ),
      // One pickup order's handover screen, pushed over Ready for Pickup.
      GoRoute(
        path: '${AppRoutes.workerPickup}/:orderId',
        builder: (context, state) =>
            PickupHandoverView(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: AppRoutes.workerDelivery,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DeliveryTasksView()),
      ),
      // One delivery's screen, pushed over My Deliveries.
      GoRoute(
        path: '${AppRoutes.workerDelivery}/:orderId',
        builder: (context, state) =>
            DeliveryDetailView(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: AppRoutes.workerAccount,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: WorkerAccountView()),
      ),
      GoRoute(
        path: AppRoutes.adminDispatch,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DispatchView()),
      ),
      GoRoute(
        path: AppRoutes.adminReviews,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ReviewsView()),
      ),
    ],
  );
});

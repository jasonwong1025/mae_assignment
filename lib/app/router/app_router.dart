import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/presentation/views/home_placeholder_view.dart';
import 'package:mae_assignment/features/authentication/presentation/views/login_view.dart';
import 'package:mae_assignment/features/authentication/presentation/views/onboarding_view.dart';
import 'package:mae_assignment/features/authentication/presentation/views/register_view.dart';
import 'package:mae_assignment/features/customer/account/presentation/views/customer_account_view.dart';
import 'package:mae_assignment/features/customer/cart/presentation/views/cart_view.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/views/catalogue_view.dart';
import 'package:mae_assignment/features/customer/orders/presentation/views/customer_orders_view.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/views/branches_view.dart';
import 'package:mae_assignment/features/store_admin/dashboard/presentation/views/dashboard_view.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/views/dispatch_view.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/views/inventory_view.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/views/orders_view.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/views/reviews_view.dart';
import 'package:mae_assignment/features/store_admin/sales/presentation/views/sales_view.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/views/staff_view.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/views/delivery_detail_view.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/views/delivery_tasks_view.dart';
import 'package:mae_assignment/features/store_worker/history/presentation/views/worker_history_view.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/views/packing_order_view.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/views/packing_tasks_view.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/views/pickup_handover_view.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/views/pickup_queue_view.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/views/mock_worker_selector_view.dart';
import 'package:mae_assignment/features/store_worker/session/worker_preview.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/views/worker_account_view.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

/// Route paths are kept in one place so we don't mistype them in screens.
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  // Customer (mobile). Four tabs: Home (catalogue), Cart, Orders, Account.
  static const String customerCatalogue = '/shop';
  static const String customerCart = '/shop/cart';
  static const String customerOrders = '/shop/orders';
  static const String customerAccount = '/shop/account';

  /// One customer order's tracking screen, pushed over Orders.
  static String customerOrder(String orderId) => '$customerOrders/$orderId';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminInventory = '/admin/inventory';
  static const String adminStaff = '/admin/staff';
  static const String adminDispatch = '/admin/dispatch';
  static const String adminReviews = '/admin/reviews';
  static const String adminSales = '/admin/sales';
  static const String adminBranches = '/admin/branches';

  // Store Worker (mobile). Every worker page starts with workerRoot.
  static const String workerRoot = '/worker';
  static const String workerDevSelect = '/worker/dev-select';
  static const String workerPacking = '/worker/packing';
  static const String workerPickup = '/worker/pickup';
  static const String workerDelivery = '/worker/delivery';
  static const String workerAccount = '/worker/account';

  /// My history, opened from Account (both roles).
  static const String workerHistory = '/worker/account/history';

  // Order pages inside the worker tabs (full screen, pushed over the tab).
  // The role guard covers them through their tab's path.
  static String workerPackingOrder(String orderId) => '$workerPacking/$orderId';
  static String workerPickupOrder(String orderId) => '$workerPickup/$orderId';
  static String workerDeliveryOrder(String orderId) =>
      '$workerDelivery/$orderId';

  /// Pages for people who are not signed in.
  static const List<String> signedOutPages = [onboarding, login, register];
}

Future<String?> _adminRedirect(AuthRepository authRepository) async {
  // This is a UI guard. Firestore rules must independently enforce access
  // when admin data moves from demo repositories to the backend.
  try {
    final user = await authRepository.getCurrentUser();
    return user?.role == UserRole.storeAdmin ? null : AppRoutes.home;
  } on Object catch (_) {
    return AppRoutes.home;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final workerPreviewEnabled = ref.watch(workerPreviewEnabledProvider);

  // Re-runs the redirect when the preview worker changes, so switching or
  // leaving a worker immediately applies the new role's pages.
  // listen (not watch), so the router is not rebuilt and history is kept.
  final workerSessionChanges = ValueNotifier<int>(0);
  ref
    ..listen(workerSessionProvider, (previous, next) {
      workerSessionChanges.value++;
    })
    ..onDispose(workerSessionChanges.dispose);

  return GoRouter(
    // The first page shown when the app opens.
    initialLocation: AppRoutes.onboarding,
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

      // Signed in but on a signed-out page: go home.
      if (isSignedIn && onSignedOutPage) return AppRoutes.home;
      // Signed out but on any other page: go to onboarding.
      if (!isSignedIn && !onSignedOutPage) return AppRoutes.onboarding;

      if (state.matchedLocation.startsWith('/admin/')) {
        return _adminRedirect(authRepository);
      }
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
      GoRoute(
        path: AppRoutes.customerCatalogue,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CatalogueView()),
      ),
      GoRoute(
        path: AppRoutes.customerCart,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CartView()),
      ),
      GoRoute(
        path: AppRoutes.customerOrders,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CustomerOrdersView()),
      ),
      GoRoute(
        path: AppRoutes.customerAccount,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CustomerAccountView()),
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
        path: AppRoutes.workerHistory,
        builder: (context, state) => const WorkerHistoryView(),
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
      GoRoute(
        path: AppRoutes.adminSales,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SalesView()),
      ),
      GoRoute(
        path: AppRoutes.adminBranches,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: BranchesView()),
      ),
    ],
  );
});

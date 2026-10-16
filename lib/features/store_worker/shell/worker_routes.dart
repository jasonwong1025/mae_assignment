import 'package:flutter/material.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/shared/models/worker_role.dart';

/// The tabs in the Store Worker bottom navigation.
enum WorkerTab {
  myTasks(
    'My Tasks',
    Icons.checklist_rounded,
    Icons.checklist_rounded,
    AppRoutes.workerPacking,
  ),
  readyForPickup(
    'Ready for Pickup',
    Icons.storefront_outlined,
    Icons.storefront,
    AppRoutes.workerPickup,
  ),
  myDeliveries(
    'My Deliveries',
    Icons.local_shipping_outlined,
    Icons.local_shipping,
    AppRoutes.workerDelivery,
  ),
  account(
    'Account',
    Icons.person_outline_rounded,
    Icons.person_rounded,
    AppRoutes.workerAccount,
  );

  const WorkerTab(this.label, this.icon, this.selectedIcon, this.route);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  /// The tabs a worker with [role] gets, in the order they are shown.
  static List<WorkerTab> forRole(WorkerRole role) {
    switch (role) {
      case WorkerRole.packingStaff:
        return const [myTasks, readyForPickup, account];
      case WorkerRole.deliveryDriver:
        return const [myDeliveries, account];
    }
  }
}

/// The page a worker lands on after choosing their profile.
String workerHomeFor(WorkerProfile worker) {
  return WorkerTab.forRole(worker.role).first.route;
}

/// True for every Store Worker page, including the selector.
bool isWorkerLocation(String location) {
  return location == AppRoutes.workerRoot ||
      location.startsWith('${AppRoutes.workerRoot}/');
}

/// True if [worker] may open [location]: one of their tabs, or a page
/// inside one (e.g. a packer's `/worker/packing/<orderId>` later on).
bool workerCanOpen(WorkerProfile worker, String location) {
  for (final tab in WorkerTab.forRole(worker.role)) {
    if (location == tab.route || location.startsWith('${tab.route}/')) {
      return true;
    }
  }
  return false;
}

/// Where to send someone trying to open a Store Worker page, or null to
/// let them through. Returns null for every non-worker page, so admin and
/// customer routing is not affected.
///
/// This only shapes the preview's navigation. It is not security: the
/// backend must still check every request once it is connected.
String? workerRouteRedirect({
  required String location,
  required bool previewEnabled,
  required WorkerProfile? worker,
  required bool isSignedIn,
}) {
  if (!isWorkerLocation(location)) return null;

  // Release builds (and profile builds without the flag) have no preview.
  if (!previewEnabled) {
    return isSignedIn ? AppRoutes.home : AppRoutes.onboarding;
  }

  // The selector is the way in, so it is always open.
  if (location == AppRoutes.workerDevSelect) return null;

  if (worker == null || !worker.isActive) return AppRoutes.workerDevSelect;
  if (!workerCanOpen(worker, location)) return workerHomeFor(worker);
  return null;
}

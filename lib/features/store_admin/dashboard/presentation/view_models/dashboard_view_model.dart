import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/features/store_admin/dashboard/data/models/dashboard_summary.dart';
import 'package:mae_assignment/features/store_admin/dashboard/data/repositories/dashboard_repository.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

final AsyncNotifierProvider<DashboardViewModel, DashboardSummary>
dashboardViewModelProvider =
    AsyncNotifierProvider.autoDispose<DashboardViewModel, DashboardSummary>(
      DashboardViewModel.new,
    );

/// State for the dashboard page: today's numbers for the selected branch.
/// - AsyncLoading: loading the numbers
/// - AsyncData: numbers to show
/// - AsyncError: loading failed
class DashboardViewModel extends AsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() async {
    // Watching the branch means this runs again, with the new branch,
    // every time the admin switches.
    // Read before the first await: the provider can be disposed while it
    // waits (for example on sign-out), and a disposed ref cannot be used.
    final repository = ref.watch(dashboardRepositoryProvider);
    final branchState = await ref.watch(branchViewModelProvider.future);
    final branch = branchState.selected;
    return await repository.getSummary(
      branch.id,
      openingHour: branch.hoursOn(DateTime.now()).opensAt ~/ 60,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dashboard_summary.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';

final dashboardViewModelProvider =
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
    final branchState = await ref.watch(branchViewModelProvider.future);
    final repository = ref.watch(dashboardRepositoryProvider);
    return repository.getSummary(branchState.selected.id);
  }
}

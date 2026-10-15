import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../session/presentation/view_models/worker_session_view_model.dart';
import '../../worker_routes.dart';

/// Mobile page frame shared by every Store Worker tab: a compact app bar
/// with the page title and branch, the page, and the role's bottom
/// navigation.
///
/// Built for phones held upright. On wider screens the page keeps a
/// phone-friendly width in the middle instead of stretching.
/// The store admin's desktop AdminScaffold is deliberately not used here.
class WorkerScaffold extends ConsumerWidget {
  const WorkerScaffold({
    super.key,
    required this.currentTab,
    required this.child,
    this.titleOverride,
    this.actions = const [],
  });

  /// Pages never get wider than this, even on tablets and web.
  static const double maxContentWidth = 600;

  /// The tab being shown, highlighted in the bottom navigation.
  final WorkerTab currentTab;
  final Widget child;

  /// Replaces the logo, page title and branch in the app bar while set,
  /// e.g. with a search field. The change animates.
  final Widget? titleOverride;

  /// Buttons on the right of the app bar, e.g. a search icon.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worker = ref.watch(workerSessionProvider);
    final tabs = worker == null
        ? const <WorkerTab>[]
        : WorkerTab.forRole(worker.role);
    final selectedIndex = tabs.indexOf(currentTab);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: AppSpacing.l,
        toolbarHeight: 64,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
        // Fades and slides in from the right when the title is replaced
        // (e.g. a search field opening from the search icon).
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              alignment: Alignment.centerRight,
              child: child,
            ),
          ),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.centerLeft,
            children: [...previous, ?current],
          ),
          child:
              titleOverride ??
              _AppBarTitle(
                key: const ValueKey('worker-title'),
                title: currentTab.label,
                branchName: worker?.branchName,
              ),
        ),
        actions: [...actions, if (actions.isNotEmpty) const SizedBox(width: 4)],
      ),
      body: SafeArea(
        // The app bar and bottom navigation already keep clear of the
        // notch and the home indicator.
        top: false,
        bottom: tabs.length < 2,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: child,
          ),
        ),
      ),
      // NavigationBar needs at least two tabs. Every role has two or more;
      // the check only matters for the moment the session is cleared.
      bottomNavigationBar: tabs.length < 2
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
              onDestinationSelected: (index) {
                final tab = tabs[index];
                if (tab != currentTab) context.go(tab.route);
              },
              destinations: [
                for (final tab in tabs)
                  NavigationDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: tab.label,
                  ),
              ],
            ),
    );
  }
}

/// Logo, page title, and "Grocerly · branch name" under it.
class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    super.key,
    required this.title,
    required this.branchName,
  });

  final String title;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Image.asset('assets/logo/logo.png', height: 32),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                branchName == null ? 'Grocerly' : 'Grocerly · $branchName',
                style: textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

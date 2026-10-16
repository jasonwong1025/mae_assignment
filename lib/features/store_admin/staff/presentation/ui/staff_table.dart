import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/ui/worker_labels.dart';
import 'package:mae_assignment/shared/models/branch.dart';

/// Staff table for tablet and web. Scrolls sideways if too narrow.
class StaffTable extends StatelessWidget {
  const StaffTable({
    required this.workers,
    required this.branches,
    required this.selectedWorkerId,
    required this.onWorkerTap,
    super.key,
  });

  /// Narrowest the table can be.
  static const double _minWidth = 880;

  final List<Worker> workers;

  /// Used to show branch names.
  final List<Branch> branches;

  /// Worker open in the side panel.
  final String? selectedWorkerId;
  final ValueChanged<Worker> onWorkerTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headingStyle = textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(_minWidth, constraints.maxWidth),
            height: constraints.maxHeight,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _RowLayout(
                      name: Text('NAME', style: headingStyle),
                      role: Text('ROLE', style: headingStyle),
                      branch: Text('BRANCH', style: headingStyle),
                      rightNow: Text('RIGHT NOW', style: headingStyle),
                      today: Text('TODAY', style: headingStyle),
                      phone: Text('PHONE', style: headingStyle),
                      status: Text('STATUS', style: headingStyle),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: workers.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final worker = workers[index];
                        return _WorkerRow(
                          worker: worker,
                          branchName: workerBranchName(worker, branches),
                          isSelected: worker.id == selectedWorkerId,
                          onTap: () => onWorkerTap(worker),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One widget per column. Used by the heading and every row so the
/// columns line up.
class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.name,
    required this.role,
    required this.branch,
    required this.rightNow,
    required this.today,
    required this.phone,
    required this.status,
  });

  final Widget name;
  final Widget role;
  final Widget branch;
  final Widget rightNow;
  final Widget today;
  final Widget phone;
  final Widget status;

  /// Adds a gap after a cell.
  Widget _spaced(Widget cell) {
    return Padding(padding: const EdgeInsets.only(right: 12), child: cell);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(flex: 4, child: _spaced(name)),
          Expanded(flex: 3, child: _spaced(role)),
          Expanded(flex: 3, child: _spaced(branch)),
          Expanded(flex: 4, child: _spaced(rightNow)),
          SizedBox(width: 64, child: today),
          Expanded(flex: 3, child: _spaced(phone)),
          SizedBox(
            width: 104,
            child: Align(alignment: Alignment.centerLeft, child: status),
          ),
        ],
      ),
    );
  }
}

class _WorkerRow extends StatelessWidget {
  const _WorkerRow({
    required this.worker,
    required this.branchName,
    required this.isSelected,
    required this.onTap,
  });

  final Worker worker;
  final String branchName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget cell(String text) {
      return Text(
        text,
        style: textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Material(
      color: isSelected ? AppColors.greenTint : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          // Fade deactivated workers.
          child: Opacity(
            opacity: worker.isActive ? 1 : 0.55,
            child: _RowLayout(
              name: Row(
                children: [
                  WorkerAvatar(name: worker.name),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      worker.name,
                      style: textTheme.titleMedium?.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              role: cell(worker.role.label),
              branch: cell(branchName),
              rightNow: cell(worker.rightNow),
              today: cell('${worker.ordersToday.length}'),
              phone: cell(worker.phone),
              status: WorkerStatusChip(isActive: worker.isActive),
            ),
          ),
        ),
      ),
    );
  }
}

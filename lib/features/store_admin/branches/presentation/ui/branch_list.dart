import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/ui/branch_labels.dart';
import 'package:mae_assignment/shared/models/branch.dart';

/// Branches table for tablet and web. Scrolls sideways if too narrow.
class BranchTable extends StatelessWidget {
  const BranchTable({
    required this.branches,
    required this.selectedBranchId,
    required this.onBranchTap,
    super.key,
  });

  static const double _minWidth = 860;

  final List<Branch> branches;
  final String? selectedBranchId;
  final ValueChanged<Branch> onBranchTap;

  @override
  Widget build(BuildContext context) {
    final headingStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      name: Text('BRANCH', style: headingStyle),
                      phone: Text('PHONE', style: headingStyle),
                      today: Text('TODAY', style: headingStyle),
                      delivery: Text('DELIVERY', style: headingStyle),
                      status: Text('STATUS', style: headingStyle),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: branches.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final branch = branches[index];
                        return _BranchRow(
                          branch: branch,
                          isSelected: branch.id == selectedBranchId,
                          onTap: () => onBranchTap(branch),
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

/// One widget per column, so the heading and rows line up.
class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.name,
    required this.phone,
    required this.today,
    required this.delivery,
    required this.status,
  });

  final Widget name;
  final Widget phone;
  final Widget today;
  final Widget delivery;
  final Widget status;

  Widget _spaced(Widget cell) {
    return Padding(padding: const EdgeInsets.only(right: 12), child: cell);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(flex: 5, child: _spaced(name)),
          Expanded(flex: 3, child: _spaced(phone)),
          Expanded(flex: 3, child: _spaced(today)),
          Expanded(flex: 2, child: _spaced(delivery)),
          SizedBox(
            width: 150,
            child: Align(alignment: Alignment.centerLeft, child: status),
          ),
        ],
      ),
    );
  }
}

class _BranchRow extends StatelessWidget {
  const _BranchRow({
    required this.branch,
    required this.isSelected,
    required this.onTap,
  });

  final Branch branch;
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
          child: _RowLayout(
            name: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  style: textTheme.titleMedium?.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  branch.address,
                  style: textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            phone: cell(branch.phone),
            today: cell(hoursText(branch.hoursOn(DateTime.now()))),
            delivery: cell('Up to ${branch.maxDeliveryKm.round()} km'),
            status: BranchStatusChip(branch: branch),
          ),
        ),
      ),
    );
  }
}

/// One branch as a card, for phones.
class BranchCard extends StatelessWidget {
  const BranchCard({required this.branch, required this.onTap, super.key});

  final Branch branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      branch.name,
                      style: textTheme.titleMedium?.copyWith(fontSize: 15),
                    ),
                  ),
                  BranchStatusChip(branch: branch),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                branch.address,
                style: textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Today: ${hoursText(branch.hoursOn(DateTime.now()))}',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

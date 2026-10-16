import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../../../shared/models/branch.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/worker.dart';
import '../view_models/staff_view_model.dart';
import '../../../shell/presentation/ui/side_panel_frame.dart';
import 'worker_form.dart';
import 'worker_labels.dart';

/// Details of one worker, with Edit and Deactivate buttons.
/// Edit shows the form in the same panel.
class WorkerDetailPanel extends ConsumerStatefulWidget {
  const WorkerDetailPanel({
    super.key,
    required this.workerId,
    required this.onClose,
  });

  final String workerId;
  final VoidCallback onClose;

  @override
  ConsumerState<WorkerDetailPanel> createState() => _WorkerDetailPanelState();
}

class _WorkerDetailPanelState extends ConsumerState<WorkerDetailPanel> {
  bool _isEditing = false;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Deactivating asks to confirm first. Reactivating does not.
  Future<void> _onToggleActive(Worker worker) async {
    if (worker.isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Deactivate ${worker.name}?'),
          content: const Text(
            'They will not be able to sign in until you reactivate them. '
            'Their history is kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Deactivate'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final error = await ref
        .read(staffViewModelProvider.notifier)
        .setActive(worker, active: !worker.isActive);
    if (!mounted) return;
    _showMessage(
      error ??
          (worker.isActive
              ? '${worker.name} was deactivated.'
              : '${worker.name} was reactivated.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workers =
        ref.watch(staffViewModelProvider).value?.items ?? const <Worker>[];
    final worker = workers
        .where((worker) => worker.id == widget.workerId)
        .firstOrNull;
    final branches =
        ref.watch(branchViewModelProvider).value?.branches ?? const <Branch>[];

    if (worker == null) {
      // E.g. a packer moved to another branch.
      return SidePanelFrame(
        title: 'Worker',
        onClose: widget.onClose,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'This worker is not in this list any more.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (_isEditing) {
      return SidePanelFrame(
        title: 'Edit worker',
        onClose: widget.onClose,
        child: WorkerForm(
          worker: worker,
          onCancel: () => setState(() => _isEditing = false),
          onSaved: (name) {
            setState(() => _isEditing = false);
            _showMessage('$name was saved.');
          },
        ),
      );
    }

    return SidePanelFrame(
      title: worker.name,
      onClose: widget.onClose,
      child: _WorkerDetails(
        worker: worker,
        branchName: workerBranchName(worker, branches),
        onEdit: () => setState(() => _isEditing = true),
        onToggleActive: () => _onToggleActive(worker),
      ),
    );
  }
}

class _WorkerDetails extends StatelessWidget {
  const _WorkerDetails({
    required this.worker,
    required this.branchName,
    required this.onEdit,
    required this.onToggleActive,
  });

  final Worker worker;
  final String branchName;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  /// "Packing order #2291 for 4m", "Free", "Off duty" or "Deactivated".
  String get _currentTask {
    final order = worker.currentOrderNumber;
    if (!worker.isActive || !worker.isOnDuty || order == null) {
      return worker.rightNow;
    }
    final verb = worker.isDriver ? 'Delivering' : 'Packing';
    final minutes = Formatters.minutes(worker.minutesOnCurrentOrder ?? 0);
    return '$verb order #$order for $minutes';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final doneWord = worker.isDriver ? 'delivered' : 'packed';
    // Smaller than the theme's buttons so two fit in a row.
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 44),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            WorkerAvatar(name: worker.name, radius: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.role.label, style: textTheme.titleMedium),
                  Text(branchName, style: textTheme.bodyMedium),
                ],
              ),
            ),
            WorkerStatusChip(isActive: worker.isActive),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: buttonStyle,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: buttonStyle,
                onPressed: onToggleActive,
                child: Text(worker.isActive ? 'Deactivate' : 'Reactivate'),
              ),
            ),
          ],
        ),

        const _SectionTitle('Contact'),
        _InfoRow(icon: Icons.phone_outlined, text: worker.phone),
        _InfoRow(icon: Icons.mail_outline_rounded, text: worker.email),

        const _SectionTitle('Right now'),
        _InfoRow(
          icon: worker.isDriver
              ? Icons.local_shipping_outlined
              : Icons.inventory_2_outlined,
          text: _currentTask,
        ),

        _SectionTitle('Today · ${worker.ordersToday.length} $doneWord'),
        if (worker.ordersToday.isEmpty)
          Text('No orders $doneWord yet today.', style: textTheme.bodyMedium)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final number in worker.ordersToday)
                Chip(
                  label: Text('#$number'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

        const _SectionTitle('Rating'),
        if (!worker.isDriver)
          Text(
            'Customers only rate delivery drivers.',
            style: textTheme.bodyMedium,
          )
        else if (worker.rating == null)
          Text('No ratings yet.', style: textTheme.bodyMedium)
        else
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.yellow),
              const SizedBox(width: 6),
              Text(
                '${worker.rating!.toStringAsFixed(1)} out of 5',
                style: textTheme.bodyLarge,
              ),
            ],
          ),

        const _SectionTitle('Joined'),
        _InfoRow(
          icon: Icons.event_outlined,
          text: Formatters.date(worker.joinedAt),
        ),
      ],
    );
  }
}

/// Small uppercase section heading.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Icon with text beside it.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

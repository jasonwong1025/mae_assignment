import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/ui/branch_form.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/ui/branch_labels.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/view_models/branches_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/side_panel_frame.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/ui/location_map.dart';

/// Details of one branch, with Edit and a temporarily closed switch.
/// Edit shows the form in the same panel.
class BranchDetailPanel extends ConsumerStatefulWidget {
  const BranchDetailPanel({
    required this.branchId,
    required this.onClose,
    super.key,
  });

  final String branchId;
  final VoidCallback onClose;

  @override
  ConsumerState<BranchDetailPanel> createState() => _BranchDetailPanelState();
}

class _BranchDetailPanelState extends ConsumerState<BranchDetailPanel> {
  bool _isEditing = false;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _setClosed(Branch branch, bool closed) async {
    final error = await ref
        .read(branchesViewModelProvider.notifier)
        .setTemporarilyClosed(branch, closed: closed);
    if (!mounted) return;
    _showMessage(
      error ??
          (closed
              ? '${branch.name} is closed to new orders.'
              : '${branch.name} is open again.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final branches =
        ref.watch(branchesViewModelProvider).value?.items ?? const <Branch>[];
    final branch = branches
        .where((branch) => branch.id == widget.branchId)
        .firstOrNull;

    if (branch == null) {
      return SidePanelFrame(
        title: 'Branch',
        onClose: widget.onClose,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'This branch is not in this list any more.',
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (_isEditing) {
      return SidePanelFrame(
        title: 'Edit branch',
        onClose: widget.onClose,
        child: BranchForm(
          branch: branch,
          onCancel: () => setState(() => _isEditing = false),
          onSaved: (name) {
            setState(() => _isEditing = false);
            _showMessage('$name was saved.');
          },
        ),
      );
    }

    final today = DateTime.now().weekday - 1;

    return SidePanelFrame(
      title: branch.name,
      onClose: widget.onClose,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text('Edit'),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Temporarily closed'),
            subtitle: const Text('Customers cannot place new orders here.'),
            value: branch.isTemporarilyClosed,
            onChanged: (closed) => _setClosed(branch, closed),
          ),
          const SizedBox(height: 8),
          LocationMap(location: branch.location),

          const _SectionTitle('Contact'),
          _InfoRow(icon: Icons.place_outlined, text: branch.address),
          _InfoRow(icon: Icons.phone_outlined, text: branch.phone),

          const _SectionTitle('Opening hours'),
          for (var day = 0; day < 7; day++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dayNames[day],
                      style: day == today
                          ? textTheme.titleMedium?.copyWith(fontSize: 15)
                          : textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    hoursText(branch.weeklyHours[day]),
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

          const _SectionTitle('Delivery'),
          _InfoRow(
            icon: Icons.local_shipping_outlined,
            text: deliveryText(branch),
          ),
          Text(
            'Distance is by road, worked out when the customer checks out.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

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

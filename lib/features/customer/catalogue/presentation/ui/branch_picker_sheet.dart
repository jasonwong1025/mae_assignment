import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/address_repository.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Opens the store picker. Choosing another store changes prices and stock,
/// so a cart that already has items is emptied, after the customer confirms.
Future<void> showBranchPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _BranchPickerSheet(),
  );
}

class _BranchPickerSheet extends ConsumerWidget {
  const _BranchPickerSheet();

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) async {
    final current = ref.read(selectedBranchProvider).value;
    if (current?.id == branch.id) {
      Navigator.of(context).pop();
      return;
    }

    final cart = ref.read(cartViewModelProvider);
    if (!cart.isEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Switch to ${branch.name}?'),
          content: const Text(
            'Prices and stock differ between stores, so your cart will be '
            'emptied.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep my cart'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Switch store'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      ref.read(cartViewModelProvider.notifier).clear();
    }

    ref.read(branchChoiceProvider.notifier).choose(branch.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(customerBranchesProvider);
    final selectedId = ref.watch(selectedBranchProvider).value?.id;
    final address = ref.watch(savedAddressesProvider).value?.defaultOrFirst;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: branches.when(
          loading: () => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => ErrorState(
            message:
                'Could not load the stores. Please check your '
                'connection.',
            onRetry: () => ref.invalidate(customerBranchesProvider),
          ),
          data: (all) {
            final ordered = address == null
                ? all
                : sortByDistance(all, address.location);
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.l,
              ),
              children: [
                Text('Choose a store', style: textTheme.titleLarge),
                if (address != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      'Distances are from ${address.label}.',
                      style: textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: AppSpacing.s),
                for (final branch in ordered)
                  _BranchTile(
                    branch: branch,
                    selected: branch.id == selectedId,
                    distanceMetres: address == null
                        ? null
                        : distanceBetween(branch.location, address.location),
                    onTap: () => _choose(context, ref, branch),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({
    required this.branch,
    required this.selected,
    required this.distanceMetres,
    required this.onTap,
  });

  final Branch branch;
  final bool selected;
  final double? distanceMetres;
  final VoidCallback onTap;

  String get _status {
    final hours = branch.hoursOn(DateTime.now());
    if (branch.isTemporarilyClosed) return 'Temporarily closed';
    if (hours.isClosed) return 'Closed today';
    return 'Open, closes ${Formatters.hour(hours.closesAt ~/ 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final closed = branch.isTemporarilyClosed;
    final details = [
      _status,
      if (distanceMetres != null) Formatters.distance(distanceMetres!),
    ].join(' · ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: !closed,
      selected: selected,
      selectedColor: AppColors.darkGreen,
      leading: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
      ),
      title: Text(branch.name),
      subtitle: Text('${branch.address}\n$details'),
      isThreeLine: true,
      onTap: closed ? null : onTap,
    );
  }
}

extension on List<CustomerAddress> {
  /// The default address, or the first one, or null when there are none.
  CustomerAddress? get defaultOrFirst {
    if (isEmpty) return null;
    return firstWhere((address) => address.isDefault, orElse: () => first);
  }
}

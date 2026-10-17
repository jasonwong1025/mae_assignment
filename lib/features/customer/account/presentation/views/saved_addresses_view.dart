import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/customer/account/presentation/views/address_picker_view.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/address_repository.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// The customer's saved delivery addresses. Opened two ways:
/// - from Account to manage them (add, edit, delete, set default);
/// - from the cart as a chooser ([selectable] true), where tapping one pops
///   with that address so checkout can use it.
class SavedAddressesView extends ConsumerWidget {
  const SavedAddressesView({super.key, this.selectable = false});

  /// When true, tapping an address returns it to the caller.
  final bool selectable;

  Future<void> _openPicker(
    BuildContext context, {
    CustomerAddress? existing,
  }) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddressPickerView(existing: existing)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(savedAddressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectable ? 'Choose address' : 'Saved addresses'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPicker(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add address'),
      ),
      body: SafeArea(
        child: addressesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(
            message: 'Could not load your addresses. Check your connection.',
            onRetry: () => ref.invalidate(savedAddressesProvider),
          ),
          data: (addresses) {
            if (addresses.isEmpty) {
              return const EmptyState(
                icon: Icons.location_on_outlined,
                title: 'No saved addresses',
                message: 'Add an address to use it at checkout.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                96, // clear of the floating button
              ),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(
                  address: address,
                  selectable: selectable,
                  onSelect: selectable
                      ? () => Navigator.of(context).pop(address)
                      : null,
                  onEdit: () => _openPicker(context, existing: address),
                  onDelete: () async {
                    await ref
                        .read(addressRepositoryProvider)
                        .deleteAddress(address.id);
                    ref.invalidate(savedAddressesProvider);
                  },
                  onSetDefault: address.isDefault
                      ? null
                      : () async {
                          await ref
                              .read(addressRepositoryProvider)
                              .setDefault(address.id);
                          ref.invalidate(savedAddressesProvider);
                        },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selectable,
    required this.onEdit,
    required this.onDelete,
    required this.onSelect,
    required this.onSetDefault,
  });

  final CustomerAddress address;
  final bool selectable;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final VoidCallback? onSelect;
  final Future<void> Function()? onSetDefault;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(address.label, style: textTheme.titleMedium),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenTint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Default',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(address.line, style: textTheme.bodyMedium),
            if (address.note.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                address.note,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                if (onSetDefault != null)
                  TextButton(
                    onPressed: () => onSetDefault!(),
                    child: const Text('Set default'),
                  ),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                TextButton(onPressed: onDelete, child: const Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

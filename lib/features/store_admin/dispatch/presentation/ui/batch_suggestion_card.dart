import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_state.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';

/// A suggested trip: ready orders whose customers are close together, with
/// a driver picker and "Assign together". Only a suggestion: the admin can
/// still assign the orders one by one instead.
class BatchSuggestionCard extends StatefulWidget {
  const BatchSuggestionCard({
    required this.state,
    required this.batch,
    required this.onAssign,
    super.key,
  });

  final DispatchState state;
  final DeliveryBatch batch;

  /// Returns an error message, or null if every order was assigned.
  final Future<String?> Function(DispatchDriver driver) onAssign;

  @override
  State<BatchSuggestionCard> createState() => _BatchSuggestionCardState();
}

class _BatchSuggestionCardState extends State<BatchSuggestionCard> {
  String? _driverId;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _driverId = widget.state.driversForBatch(widget.batch).firstOrNull?.id;
  }

  Future<void> _assign(DispatchDriver driver) async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final error = await widget.onAssign(driver);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final batch = widget.batch;
    final branch = widget.state.branch.location;
    final drivers = widget.state.driversForBatch(batch);
    // The picked driver may have just filled up.
    final selected = drivers
        .where((driver) => driver.id == _driverId)
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                size: 18,
                color: AppColors.darkGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  batch.orders.map((order) => '#${order.number}').join(' → '),
                  style: textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Customers ${Formatters.distance(batch.spreadMetres)} apart · '
            '~${Formatters.distance(batch.tripMetres)} trip (straight line)',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          if (drivers.isEmpty)
            Text(
              'No driver has room for ${batch.orders.length} more orders.',
              style: textTheme.bodySmall,
            )
          else
            DropdownButtonFormField<String>(
              // New key when the pick changes, so a driver who left the
              // list is never shown as picked.
              key: ValueKey(selected?.id),
              initialValue: selected?.id,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Driver',
                isDense: true,
              ),
              items: [
                for (final (index, driver) in drivers.indexed)
                  DropdownMenuItem(
                    value: driver.id,
                    child: Text(
                      '${driver.worker.name} · '
                      '${Formatters.distance(driver.metresTo(branch)!)} · '
                      '${driver.loadText}'
                      '${index == 0 ? ' · nearest' : ''}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: _isSaving
                  ? null
                  : (id) => setState(() => _driverId = id),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: selected == null || _isSaving
                ? null
                : () => _assign(selected),
            child: _isSaving
                ? const ButtonLoadingIndicator()
                : Text('Assign ${batch.orders.length} together'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../../../shared/ui/button_loading_indicator.dart';
import '../../../orders/data/models/order.dart';
import '../view_models/dispatch_state.dart';

/// "ASSIGN #2292" box: pick a free driver and press "Assign driver".
/// The nearest free driver is picked first.
class AssignDriverBox extends StatefulWidget {
  const AssignDriverBox({
    super.key,
    required this.state,
    required this.order,
    required this.onAssign,
    this.preselectedDriverId,
  });

  final DispatchState state;
  final Order order;

  /// Free driver to pick instead of the nearest one.
  final String? preselectedDriverId;

  /// Returns an error message, or null if it worked.
  final Future<String?> Function(DispatchDriver driver) onAssign;

  @override
  State<AssignDriverBox> createState() => _AssignDriverBoxState();
}

class _AssignDriverBoxState extends State<AssignDriverBox> {
  String? _driverId;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final freeDrivers = widget.state.freeDriversFor(widget.order);
    final preselected = freeDrivers.any(
      (driver) => driver.id == widget.preselectedDriverId,
    );
    _driverId = preselected
        ? widget.preselectedDriverId
        : freeDrivers.firstOrNull?.id;
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
    final order = widget.order;
    final currentDriver = widget.state.driverOf(order);
    final freeDrivers = widget.state.freeDriversFor(order);
    final pickUpPoint = widget.state.pickUpPoint(order);

    // The picked driver may have just become busy.
    final selected = freeDrivers
        .where((driver) => driver.id == _driverId)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentDriver == null
                ? 'ASSIGN #${order.number}'
                : 'REASSIGN #${order.number}',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentDriver == null
                ? '${order.customerName} · ${order.address ?? ''}'
                : 'Now with ${currentDriver.worker.name}. '
                      'The new driver collects it from them.',
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (freeDrivers.isEmpty)
            Text('No free drivers right now.', style: textTheme.bodyMedium)
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
                for (final (index, driver) in freeDrivers.indexed)
                  DropdownMenuItem(
                    value: driver.id,
                    child: Text(
                      '${driver.worker.name} · '
                      '${Formatters.distance(driver.metresTo(pickUpPoint)!)}'
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
          const SizedBox(height: 12),
          FilledButton(
            onPressed: selected == null || _isSaving
                ? null
                : () => _assign(selected),
            child: _isSaving
                ? const ButtonLoadingIndicator()
                : const Text('Assign driver'),
          ),
        ],
      ),
    );
  }
}

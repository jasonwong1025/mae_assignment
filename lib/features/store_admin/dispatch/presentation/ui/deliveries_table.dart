import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/dispatch_labels.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_state.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// Table of one page of deliveries. Scrolls sideways if too narrow.
class DeliveriesTable extends StatelessWidget {
  const DeliveriesTable({
    required this.orders,
    required this.state,
    required this.selectedOrderNumber,
    required this.onOrderTap,
    super.key,
  });

  /// Narrowest the table can be.
  static const double _minWidth = 860;

  final List<Order> orders;

  /// Used to find each order's driver.
  final DispatchState state;
  final int? selectedOrderNumber;
  final ValueChanged<Order> onOrderTap;

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
                      order: Text('ORDER', style: headingStyle),
                      customer: Text('CUSTOMER', style: headingStyle),
                      driver: Text('DRIVER', style: headingStyle),
                      status: Text('STATUS', style: headingStyle),
                      distance: Text('DISTANCE', style: headingStyle),
                      arrival: Text('ARRIVES IN', style: headingStyle),
                      waiting: Text('IN STATUS', style: headingStyle),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _DeliveryRow(
                          order: order,
                          driver: state.driverOf(order),
                          isSelected: order.number == selectedOrderNumber,
                          onTap: () => onOrderTap(order),
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
    required this.order,
    required this.customer,
    required this.driver,
    required this.status,
    required this.distance,
    required this.arrival,
    required this.waiting,
  });

  final Widget order;
  final Widget customer;
  final Widget driver;
  final Widget status;
  final Widget distance;
  final Widget arrival;
  final Widget waiting;

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
          SizedBox(width: 80, child: order),
          Expanded(flex: 5, child: _spaced(customer)),
          Expanded(flex: 3, child: _spaced(driver)),
          Expanded(flex: 4, child: _spaced(status)),
          SizedBox(width: 96, child: distance),
          SizedBox(width: 104, child: arrival),
          SizedBox(width: 88, child: waiting),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  const _DeliveryRow({
    required this.order,
    required this.driver,
    required this.isSelected,
    required this.onTap,
  });

  final Order order;
  final DispatchDriver? driver;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final driver = this.driver;

    Widget cell(String text, {TextStyle? style}) {
      return Text(
        text,
        style: style ?? textTheme.bodyMedium,
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
            order: cell(
              '#${order.number}',
              style: textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            customer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cell(order.customerName),
                cell(order.address ?? '', style: textTheme.bodySmall),
              ],
            ),
            driver: cell(driver?.worker.name ?? 'None'),
            status: Row(
              children: [
                StatusDot(color: deliveryColor(order)),
                const SizedBox(width: 8),
                Flexible(child: cell(deliveryStatusText(order, driver))),
              ],
            ),
            // Distance and time along the driver's route.
            distance: cell(
              driver == null ? '-' : Formatters.distance(driver.metresLeft),
            ),
            arrival: cell(
              driver == null ? '-' : Formatters.minutes(driver.minutesLeft),
            ),
            waiting: cell(
              Formatters.minutes(order.minutesInStatus(DateTime.now())),
            ),
          ),
        ),
      ),
    );
  }
}

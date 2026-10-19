import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

/// The stages of a delivery, in order.
const _steps = ['Packing', 'Ready', 'Verified', 'On the way', 'Delivered'];

/// How many stages [order] has finished, from the point of view of the
/// driver [workerId]. A bag verified by a previous driver does not count.
int deliveryStepsDone(Order order, String workerId) {
  switch (order.status) {
    case OrderStatus.pending:
    case OrderStatus.packing:
    case OrderStatus.cancelled:
      return 0;
    case OrderStatus.ready:
      return order.collectionVerifiedBy == workerId ? 3 : 2;
    case OrderStatus.outForDelivery:
      return 4;
    case OrderStatus.completed:
      return 5;
  }
}

/// Five dots joined by a line: done stages filled, the current one
/// outlined. Labels wrap under each dot, so it fits narrow phones.
class DeliveryStepper extends StatelessWidget {
  const DeliveryStepper({
    required this.order,
    required this.workerId,
    super.key,
  });

  final Order order;
  final String workerId;

  @override
  Widget build(BuildContext context) {
    final done = deliveryStepsDone(order, workerId);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label:
          'Delivery progress: ${done == 0 ? 'not started' : _steps[done - 1]}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _steps.length; i++)
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i == 0
                              ? Colors.transparent
                              : (i <= done
                                    ? AppColors.darkGreen
                                    : AppColors.border),
                        ),
                      ),
                      _Dot(isDone: i < done, isCurrent: i == done),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i == _steps.length - 1
                              ? Colors.transparent
                              : (i < done
                                    ? AppColors.darkGreen
                                    : AppColors.border),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _steps[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: i == done ? FontWeight.w800 : FontWeight.w600,
                      color: i <= done
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isDone, required this.isCurrent});

  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppColors.darkGreen : AppColors.surface,
        border: Border.all(
          color: isDone || isCurrent ? AppColors.darkGreen : AppColors.border,
          width: 2,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

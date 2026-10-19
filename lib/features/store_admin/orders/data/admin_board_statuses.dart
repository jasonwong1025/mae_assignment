import 'package:mae_assignment/shared/models/order_status.dart';

/// Columns of the admin orders board. Orders are paid at checkout, so the
/// board has no Cancelled column; cancelled orders are not shown on it.
const List<OrderStatus> adminBoardStatuses = [
  OrderStatus.pending,
  OrderStatus.packing,
  OrderStatus.ready,
  OrderStatus.outForDelivery,
  OrderStatus.completed,
];

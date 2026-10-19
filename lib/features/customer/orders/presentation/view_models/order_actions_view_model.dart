import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';
import 'package:mae_assignment/shared/repositories/order_repository.dart';

part 'order_actions_view_model.freezed.dart';

/// What happened when a past order was put back in the cart.
@freezed
abstract class ReorderResult with _$ReorderResult {
  const factory ReorderResult({
    /// A message for the screen when nothing could be added; null on success.
    String? error,

    /// How many products were added to the cart.
    @Default(0) int addedCount,

    /// Names of products that are no longer sold (or are out of stock) at the
    /// order's store, so were left out.
    @Default(<String>[]) List<String> unavailable,
  }) = _ReorderResult;

  const ReorderResult._();

  bool get isSuccess => error == null;
}

/// True while an order action (cancel or order again) is running, so its
/// buttons can show they are busy and ignore repeat taps. autoDispose: the
/// flag resets when the order screen is left.
final NotifierProvider<OrderActionsViewModel, bool>
orderActionsViewModelProvider =
    NotifierProvider.autoDispose<OrderActionsViewModel, bool>(
      OrderActionsViewModel.new,
    );

/// Actions on a past or pending order: cancel it, or order it again. Each
/// returns what the screen needs to show, instead of navigating itself.
class OrderActionsViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  /// Cancels a pending [order]. Returns an error message, or null if it
  /// worked.
  Future<String?> cancel(Order order) async {
    if (state) return null;
    state = true;
    try {
      await ref.read(orderRepositoryProvider).cancelOrder(order.id);
      return null;
    } on AppException catch (error) {
      return error.message;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Answers the replacement offered for [lineId] on [order]: accepts it, or
  /// (if [accept] is false) removes the item. Returns an error message, or
  /// null if it worked.
  Future<String?> respondToShortage(
    Order order,
    String lineId, {
    required bool accept,
  }) async {
    if (state) return null;
    state = true;
    try {
      await ref
          .read(orderRepositoryProvider)
          .respondToShortage(order.id, lineId, accept: accept);
      return null;
    } on AppException catch (error) {
      return error.message;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Replaces the cart with [order]'s products, priced and stocked as they
  /// are now at the order's store, and switches the customer to that store.
  ///
  /// The caller asks the customer to confirm first when the cart already has
  /// items. Nothing changes unless at least one product can be added.
  Future<ReorderResult> reorder(Order order) async {
    if (state) return const ReorderResult(error: 'Please wait a moment.');
    state = true;
    try {
      final branches = await ref.read(branchRepositoryProvider).getBranches();
      final branch = branches.where((b) => b.id == order.branchId).firstOrNull;
      if (branch == null) {
        return const ReorderResult(
          error: 'This order’s store is no longer available.',
        );
      }
      if (branch.isTemporarilyClosed) {
        return ReorderResult(error: '${branch.name} is closed right now.');
      }

      final catalogue = await ref
          .read(catalogueRepositoryProvider)
          .loadCatalogue(branch.id);
      final byId = {
        for (final product in catalogue.products) product.id: product,
      };

      // One cart line per product, even if the order listed it twice.
      final wanted = <String, int>{};
      for (final item in order.effectiveItems) {
        wanted.update(
          item.productId,
          (quantity) => quantity + item.quantity,
          ifAbsent: () => item.quantity,
        );
      }
      final lines = <CartLine>[];
      final unavailable = <String>[];
      for (final entry in wanted.entries) {
        final product = byId[entry.key];
        if (product == null || product.isOutOfStock) {
          unavailable.add(
            order.effectiveItems
                .firstWhere((item) => item.productId == entry.key)
                .name,
          );
          continue;
        }
        lines.add(
          CartLine(
            product: product,
            quantity: entry.value.clamp(1, product.stock),
          ),
        );
      }
      if (lines.isEmpty) {
        return ReorderResult(
          error:
              'None of these items are available at ${branch.name} right now.',
          unavailable: unavailable,
        );
      }

      ref.read(cartViewModelProvider.notifier)
        ..clear()
        ..restore(Cart(lines: lines))
        ..setFulfilment(
          order.isDelivery
              ? FulfilmentMethod.delivery
              : FulfilmentMethod.pickup,
        );
      ref.read(branchChoiceProvider.notifier).choose(branch.id);
      return ReorderResult(addedCount: lines.length, unavailable: unavailable);
    } on AppException catch (error) {
      return ReorderResult(error: error.message);
    } finally {
      if (ref.mounted) state = false;
    }
  }
}

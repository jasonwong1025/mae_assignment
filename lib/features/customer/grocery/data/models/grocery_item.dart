import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'grocery_item.freezed.dart';

/// One thing on a customer's grocery list: words ("fresh milk"), a quantity,
/// and optionally the product the customer picked for it. The match with the
/// catalogue is worked out when the list is shown, so a saved list never
/// holds stale prices or stock.
@freezed
abstract class GroceryItem with _$GroceryItem {
  const factory GroceryItem({
    /// Unique within the list.
    required String id,

    /// What the customer wrote, e.g. "fresh milk".
    required String name,
    @Default(1) int quantity,

    /// The product the customer chose for this item. Null: the app picks the
    /// best match itself.
    String? productId,
  }) = _GroceryItem;

  const GroceryItem._();

  /// Reads one entry of the list's `items` array.
  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    final quantity = map.integer(GroceryItemFields.quantity, fallback: 1);
    return GroceryItem(
      id: map.requiredString(GroceryItemFields.id),
      name: map.requiredString(GroceryItemFields.name),
      quantity: quantity < 1 ? 1 : quantity,
      productId: map.stringOrNull(GroceryItemFields.productId),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      GroceryItemFields.id: id,
      GroceryItemFields.name: name,
      GroceryItemFields.quantity: quantity,
      GroceryItemFields.productId: ?productId,
    };
  }
}

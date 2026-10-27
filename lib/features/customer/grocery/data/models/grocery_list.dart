import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';

part 'grocery_list.freezed.dart';

/// One of a customer's grocery lists, shown as a tab: the default
/// "My list", or one made from a recipe or a scanned list.
@freezed
abstract class GroceryList with _$GroceryList {
  const factory GroceryList({
    required String id,
    required String name,
    @Default(<GroceryItem>[]) List<GroceryItem> items,

    /// When the list was made. Null for the default list made before lists
    /// had names, which always sorts first anyway.
    DateTime? createdAt,
  }) = _GroceryList;

  const GroceryList._();

  /// The default list every customer has. It can be cleared but not deleted.
  static const String defaultId = GroceryListDocs.current;
  static const String defaultName = 'My list';

  /// Most lists a customer can keep, so the tabs stay usable on a phone.
  static const int maxLists = 5;

  /// Longest list name.
  static const int maxNameLength = 30;

  bool get isDefault => id == defaultId;
}

/// All of a customer's lists and the one that is open.
@freezed
abstract class GroceryLists with _$GroceryLists {
  const factory GroceryLists({
    /// The default list first, then the others oldest first.
    required List<GroceryList> lists,
    required String selectedId,
  }) = _GroceryLists;

  const GroceryLists._();

  GroceryList get selected => lists.firstWhere(
    (list) => list.id == selectedId,
    orElse: () => lists.first,
  );

  /// The open list's items.
  List<GroceryItem> get items => selected.items;

  bool get isFull => lists.length >= GroceryList.maxLists;

  /// A copy with [list] in place of the list with the same id.
  GroceryLists replace(GroceryList list) {
    return copyWith(
      lists: [
        for (final other in lists)
          if (other.id == list.id) list else other,
      ],
    );
  }
}

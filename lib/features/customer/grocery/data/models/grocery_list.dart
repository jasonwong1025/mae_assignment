import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';

/// One of a customer's grocery lists, shown as a tab: the default
/// "My list", or one made from a recipe or a scanned list.
class GroceryList {
  const GroceryList({
    required this.id,
    required this.name,
    this.items = const [],
    this.createdAt,
  });

  /// The default list every customer has. It can be cleared but not deleted.
  static const String defaultId = GroceryListDocs.current;
  static const String defaultName = 'My list';

  /// Most lists a customer can keep, so the tabs stay usable on a phone.
  static const int maxLists = 5;

  /// Longest list name.
  static const int maxNameLength = 30;

  final String id;
  final String name;
  final List<GroceryItem> items;

  /// When the list was made. Null for the default list made before lists
  /// had names, which always sorts first anyway.
  final DateTime? createdAt;

  bool get isDefault => id == defaultId;

  GroceryList copyWith({String? name, List<GroceryItem>? items}) {
    return GroceryList(
      id: id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt,
    );
  }
}

/// All of a customer's lists and the one that is open.
class GroceryLists {
  const GroceryLists({required this.lists, required this.selectedId});

  /// The default list first, then the others oldest first.
  final List<GroceryList> lists;
  final String selectedId;

  GroceryList get selected => lists.firstWhere(
    (list) => list.id == selectedId,
    orElse: () => lists.first,
  );

  /// The open list's items.
  List<GroceryItem> get items => selected.items;

  bool get isFull => lists.length >= GroceryList.maxLists;

  GroceryLists copyWith({List<GroceryList>? lists, String? selectedId}) {
    return GroceryLists(
      lists: lists ?? this.lists,
      selectedId: selectedId ?? this.selectedId,
    );
  }

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

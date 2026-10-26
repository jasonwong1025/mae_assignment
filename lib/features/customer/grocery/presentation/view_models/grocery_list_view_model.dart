import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_text_parser.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_list.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_row.dart';
import 'package:mae_assignment/features/customer/grocery/data/repositories/grocery_list_repository.dart';
import 'package:mae_assignment/features/customer/grocery/data/repositories/recipe_repository.dart';

part 'grocery_list_view_model.freezed.dart';

/// What happened when the matched items were added to the cart.
@freezed
abstract class AddToCartResult with _$AddToCartResult {
  const factory AddToCartResult({
    /// How many list items went to the cart.
    @Default(0) int added,

    /// Items that stayed on the list (not found or sold out here).
    @Default(0) int left,

    /// Items added with a smaller quantity than asked for, because the store
    /// has less in stock.
    @Default(0) int reduced,
  }) = _AddToCartResult;
}

/// The customer's grocery lists and the one that is open. Not autoDispose:
/// lists built on this tab must survive moving between tabs.
final AsyncNotifierProvider<GroceryListViewModel, GroceryLists>
groceryListViewModelProvider =
    AsyncNotifierProvider<GroceryListViewModel, GroceryLists>(
      GroceryListViewModel.new,
    );

/// The store's whole catalogue, for matching list items. A separate read from
/// the Home screen's, because Home applies the search and category filters.
final groceryCatalogueProvider =
    FutureProvider.autoDispose<List<CatalogueProduct>>((ref) async {
      final branch = await ref.watch(selectedBranchProvider.future);
      final data = await ref
          .watch(catalogueRepositoryProvider)
          .loadCatalogue(branch.id);
      return data.products;
    });

/// Each item of the open list with the product it means. Loading until both
/// the lists and the catalogue are in.
final groceryRowsProvider = Provider.autoDispose<AsyncValue<List<GroceryRow>>>((
  ref,
) {
  final items = ref.watch(groceryListViewModelProvider);
  final products = ref.watch(groceryCatalogueProvider);
  if (items.hasError) {
    return AsyncError(items.error!, items.stackTrace ?? StackTrace.empty);
  }
  if (products.hasError) {
    return AsyncError(products.error!, products.stackTrace ?? StackTrace.empty);
  }
  final list = items.value?.items;
  final catalogue = products.value;
  if (list == null || catalogue == null) return const AsyncLoading();
  return AsyncData([
    for (final item in list) GroceryRow.resolve(item, catalogue),
  ]);
});

/// Loads the signed-in customer's lists and changes them. Item changes
/// apply to the open list. Every change is saved; each method returns an
/// error message to show, or null if it worked.
class GroceryListViewModel extends AsyncNotifier<GroceryLists> {
  int _nextId = DateTime.now().microsecondsSinceEpoch;

  String? get _uid => ref.read(authUidProvider).value;

  GroceryListRepository get _repository =>
      ref.read(groceryListRepositoryProvider);

  List<GroceryItem> get _items => state.value?.items ?? const [];

  @override
  Future<GroceryLists> build() async {
    // A different account must not see the previous one's lists.
    final uid = await ref.watch(authUidProvider.future);
    if (uid == null) {
      return const GroceryLists(
        lists: [
          GroceryList(id: GroceryList.defaultId, name: GroceryList.defaultName),
        ],
        selectedId: GroceryList.defaultId,
      );
    }
    final lists = await _repository.loadLists(uid);
    return GroceryLists(lists: lists, selectedId: GroceryList.defaultId);
  }

  // ---------------------------------------------------------------------
  // Lists (tabs)
  // ---------------------------------------------------------------------

  /// Opens the list with [listId].
  void select(String listId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedId: listId));
  }

  /// Makes a new list called [name] holding [lines] and opens it. Returns an
  /// error message if there are already [GroceryList.maxLists] lists or
  /// saving fails.
  Future<String?> createList(String name, List<ParsedLine> lines) async {
    final current = state.value;
    final uid = _uid;
    if (current == null) return 'Your lists are still loading.';
    if (current.isFull) {
      return 'You can keep up to ${GroceryList.maxLists} lists. Delete one '
          'first.';
    }
    final list = GroceryList(
      id: uid == null ? 'local${_nextId++}' : _repository.newListId(uid),
      name: _cleanName(name),
      items: _merge(const [], lines),
      createdAt: DateTime.now(),
    );
    state = AsyncData(
      current.copyWith(lists: [...current.lists, list], selectedId: list.id),
    );
    if (uid == null) return null;
    try {
      await _repository.create(uid, list);
      return null;
    } on AppException catch (error) {
      return error.message;
    }
  }

  Future<String?> renameList(String listId, String name) {
    final current = state.value;
    if (current == null) return Future.value();
    final list = current.lists.firstWhere((list) => list.id == listId);
    return _save(current, list.copyWith(name: _cleanName(name)));
  }

  /// Deletes the list with [listId] and opens "My list". The default list
  /// cannot be deleted; it is emptied instead.
  Future<String?> deleteList(String listId) async {
    final current = state.value;
    final uid = _uid;
    if (current == null) return null;
    final list = current.lists.firstWhere((list) => list.id == listId);
    if (list.isDefault) {
      return await _save(current, list.copyWith(items: const []));
    }
    state = AsyncData(
      GroceryLists(
        lists: [
          for (final other in current.lists)
            if (other.id != listId) other,
        ],
        selectedId: GroceryList.defaultId,
      ),
    );
    if (uid == null) return null;
    try {
      await _repository.delete(uid, listId);
      return null;
    } on AppException catch (error) {
      return error.message;
    }
  }

  // ---------------------------------------------------------------------
  // Items of the open list
  // ---------------------------------------------------------------------

  /// Adds what [text] says: one item, or several ("milk, 2 eggs").
  Future<String?> addText(String text) {
    return addAll(GroceryTextParser.parse(text));
  }

  /// Adds the [lines] to the open list; an item already there gets the
  /// quantities added.
  Future<String?> addAll(List<ParsedLine> lines) {
    return _changeItems(_merge(_items, lines));
  }

  Future<String?> setQuantity(String id, int quantity) {
    final clamped = quantity.clamp(1, GroceryTextParser.maxQuantity);
    return _changeItems([
      for (final item in _items)
        if (item.id == id) item.copyWith(quantity: clamped) else item,
    ]);
  }

  /// Uses [productId] for the item from now on.
  Future<String?> chooseProduct(String id, String productId) {
    return _changeItems([
      for (final item in _items)
        if (item.id == id) item.copyWith(productId: productId) else item,
    ]);
  }

  Future<String?> remove(String id) {
    return _changeItems([
      for (final item in _items)
        if (item.id != id) item,
    ]);
  }

  /// Opens the scanner. Returns the items found for the customer to review
  /// first, or null if the scanner was closed. Throws a [GroceryException]
  /// with a message to show.
  Future<List<ParsedLine>?> scan() => _repository.scan();

  /// Ingredients an AI model suggests for [dish], for the customer to review.
  /// Throws a [RecipeException] with a message to show.
  Future<List<ParsedLine>> suggestFromRecipe(String dish, int servings) {
    return ref.read(recipeRepositoryProvider).suggest(dish, servings: servings);
  }

  /// Puts every matched item of the open list in the cart and takes it off
  /// the list. Items that were not found, or are sold out, stay.
  Future<AddToCartResult> addMatchedToCart(List<GroceryRow> rows) async {
    final cart = ref.read(cartViewModelProvider.notifier);
    final inCart = ref.read(cartViewModelProvider);
    var added = 0;
    var reduced = 0;
    final doneIds = <String>{};
    for (final row in rows) {
      final product = row.product;
      if (product == null) continue;
      final existing = inCart.quantityOf(product.id);
      final room = product.stock - existing;
      if (room <= 0) continue;
      final amount = math.min(row.item.quantity, room);
      if (amount < row.item.quantity) reduced++;
      cart.setQuantity(product, existing + amount);
      doneIds.add(row.item.id);
      added++;
    }
    final remaining = [
      for (final item in _items)
        if (!doneIds.contains(item.id)) item,
    ];
    await _changeItems(remaining);
    return AddToCartResult(
      added: added,
      left: remaining.length,
      reduced: reduced,
    );
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// [items] with [lines] added; an item already there (same name, any
  /// case) gets the quantities added.
  List<GroceryItem> _merge(List<GroceryItem> items, List<ParsedLine> lines) {
    final merged = [...items];
    for (final line in lines) {
      final index = merged.indexWhere(
        (item) => item.name.toLowerCase() == line.name.toLowerCase(),
      );
      if (index >= 0) {
        merged[index] = merged[index].copyWith(
          quantity: math.min(
            merged[index].quantity + line.quantity,
            GroceryTextParser.maxQuantity,
          ),
        );
      } else {
        merged.add(
          GroceryItem(
            id: 'g${_nextId++}',
            name: line.name,
            quantity: line.quantity,
          ),
        );
      }
    }
    return merged;
  }

  static String _cleanName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'New list';
    return trimmed.length <= GroceryList.maxNameLength
        ? trimmed
        : trimmed.substring(0, GroceryList.maxNameLength);
  }

  Future<String?> _changeItems(List<GroceryItem> items) {
    final current = state.value;
    if (current == null) return Future.value();
    return _save(current, current.selected.copyWith(items: items));
  }

  /// Shows [list] straight away and saves it; if saving fails the list
  /// stays as the customer made it and the message says the save failed.
  Future<String?> _save(GroceryLists current, GroceryList list) async {
    state = AsyncData(current.replace(list));
    final uid = _uid;
    if (uid == null) return null;
    try {
      await _repository.save(uid, list);
      return null;
    } on AppException catch (error) {
      return error.message;
    }
  }
}

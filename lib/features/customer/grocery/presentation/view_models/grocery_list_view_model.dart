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

/// The customer's grocery list. Not autoDispose: a list built on this tab
/// must survive moving between tabs.
final AsyncNotifierProvider<GroceryListViewModel, List<GroceryItem>>
groceryListViewModelProvider =
    AsyncNotifierProvider<GroceryListViewModel, List<GroceryItem>>(
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

/// Each list item with the product it means. Loading until both the list and
/// the catalogue are in.
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
  final list = items.value;
  final catalogue = products.value;
  if (list == null || catalogue == null) return const AsyncLoading();
  return AsyncData([
    for (final item in list) GroceryRow.resolve(item, catalogue),
  ]);
});

/// Loads the signed-in customer's list and changes it. Every change is saved;
/// each method returns an error message to show, or null if it worked.
class GroceryListViewModel extends AsyncNotifier<List<GroceryItem>> {
  int _nextId = DateTime.now().microsecondsSinceEpoch;

  String? get _uid => ref.read(authUidProvider).value;

  @override
  Future<List<GroceryItem>> build() async {
    // A different account must not see the previous one's list.
    final uid = await ref.watch(authUidProvider.future);
    if (uid == null) return const [];
    return await ref.read(groceryListRepositoryProvider).load(uid);
  }

  /// Adds what [text] says: one item, or several ("milk, 2 eggs").
  Future<String?> addText(String text) {
    return addAll(GroceryTextParser.parse(text));
  }

  /// Adds the [lines] to the list; an item already there gets the quantities
  /// added.
  Future<String?> addAll(List<ParsedLine> lines) {
    final items = [...state.value ?? const <GroceryItem>[]];
    for (final line in lines) {
      final index = items.indexWhere(
        (item) => item.name.toLowerCase() == line.name.toLowerCase(),
      );
      if (index >= 0) {
        final merged = items[index].quantity + line.quantity;
        items[index] = items[index].copyWith(
          quantity: math.min(merged, GroceryTextParser.maxQuantity),
        );
      } else {
        items.add(
          GroceryItem(
            id: 'g${_nextId++}',
            name: line.name,
            quantity: line.quantity,
          ),
        );
      }
    }
    return _change(items);
  }

  Future<String?> setQuantity(String id, int quantity) {
    final clamped = quantity.clamp(1, GroceryTextParser.maxQuantity);
    return _change([
      for (final item in state.value ?? const <GroceryItem>[])
        if (item.id == id) item.copyWith(quantity: clamped) else item,
    ]);
  }

  /// Uses [productId] for the item from now on.
  Future<String?> chooseProduct(String id, String productId) {
    return _change([
      for (final item in state.value ?? const <GroceryItem>[])
        if (item.id == id) item.copyWith(productId: productId) else item,
    ]);
  }

  Future<String?> remove(String id) {
    return _change([
      for (final item in state.value ?? const <GroceryItem>[])
        if (item.id != id) item,
    ]);
  }

  /// Opens the scanner and adds what it reads. Returns the items found for
  /// the customer to review first, or null if the scanner was closed. Throws
  /// a [GroceryException] with a message to show.
  Future<List<ParsedLine>?> scan() {
    return ref.read(groceryListRepositoryProvider).scan();
  }

  /// Ingredients an AI model suggests for [dish], for the customer to review.
  /// Throws a [RecipeException] with a message to show.
  Future<List<ParsedLine>> suggestFromRecipe(String dish, int servings) {
    return ref.read(recipeRepositoryProvider).suggest(dish, servings: servings);
  }

  /// Puts every matched item in the cart and takes it off the list. Items
  /// that were not found, or are sold out, stay.
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
      for (final item in state.value ?? const <GroceryItem>[])
        if (!doneIds.contains(item.id)) item,
    ];
    await _change(remaining);
    return AddToCartResult(
      added: added,
      left: remaining.length,
      reduced: reduced,
    );
  }

  /// Shows [items] straight away and saves them; if saving fails the list
  /// stays as the customer made it and the message says the save failed.
  Future<String?> _change(List<GroceryItem> items) async {
    state = AsyncData(items);
    final uid = _uid;
    if (uid == null) return null;
    try {
      await ref.read(groceryListRepositoryProvider).save(uid, items);
      return null;
    } on AppException catch (error) {
      return error.message;
    }
  }
}

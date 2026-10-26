import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_text_parser.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_list.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/grocery_list_service.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/list_scan_service.dart';

final groceryListRepositoryProvider = Provider<GroceryListRepository>((ref) {
  return GroceryListRepository(
    ref.watch(groceryListServiceProvider),
    ref.watch(listScanServiceProvider),
  );
});

/// Error with a message that is safe to show on screen.
class GroceryException extends AppException {
  const GroceryException(super.message);
}

/// The customer's grocery lists: loading and saving them, and reading items
/// from a photo of a written list.
class GroceryListRepository {
  GroceryListRepository(this._lists, this._scanner);

  final GroceryListService _lists;
  final ListScanService _scanner;

  /// True if this phone can scan a written list.
  bool get canScan => _scanner.isSupported;

  /// Every list, the default "My list" first (empty if never saved), then
  /// the others oldest first.
  Future<List<GroceryList>> loadLists(String uid) {
    return guard(
      () async {
        final saved = await _lists.getLists(uid);
        final others = saved.where((list) => !list.isDefault).toList()
          ..sort((a, b) {
            final at = a.createdAt;
            final bt = b.createdAt;
            if (at == null || bt == null) return a.name.compareTo(b.name);
            return at.compareTo(bt);
          });
        final mine =
            saved.where((list) => list.isDefault).firstOrNull ??
            const GroceryList(
              id: GroceryList.defaultId,
              name: GroceryList.defaultName,
            );
        return [mine, ...others];
      },
      label: 'load grocery lists',
      onError: () => const GroceryException(
        'Could not load your grocery lists. Please try again.',
      ),
    );
  }

  /// A new list id, made on the phone.
  String newListId(String uid) => _lists.newId(uid);

  Future<void> create(String uid, GroceryList list) {
    return guard(
      () => _lists.createList(uid, list),
      label: 'create grocery list',
      onError: () => const GroceryException(
        'Could not save the new list. Check your connection.',
      ),
    );
  }

  Future<void> save(String uid, GroceryList list) {
    return guard(
      () => _lists.saveList(uid, list),
      label: 'save grocery list',
      onError: () => const GroceryException(
        'Could not save your grocery list. Check your connection.',
      ),
    );
  }

  Future<void> delete(String uid, String listId) {
    return guard(
      () => _lists.deleteList(uid, listId),
      label: 'delete grocery list',
      onError: () => const GroceryException(
        'Could not delete the list. Check your connection.',
      ),
    );
  }

  /// Opens the scanner and returns the items it found. Null means the
  /// scanner was closed without a photo. An empty list means a photo was
  /// taken but no items could be read from it.
  Future<List<ParsedLine>?> scan() async {
    final String? text;
    try {
      text = await _scanner.scanText();
    } on ScanException catch (error) {
      throw GroceryException(switch (error.problem) {
        ScanProblem.unsupported =>
          'Scanning a list needs an Android phone. You can type items '
              'instead.',
        ScanProblem.failed =>
          'The list could not be scanned. Try again in better light.',
      });
    }
    if (text == null) return null;
    return GroceryTextParser.parse(text);
  }
}

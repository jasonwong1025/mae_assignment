import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_text_parser.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';
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

/// The customer's grocery list: saving it, and reading items from a photo of
/// a written list.
class GroceryListRepository {
  GroceryListRepository(this._lists, this._scanner);

  final GroceryListService _lists;
  final ListScanService _scanner;

  /// True if this phone can scan a written list.
  bool get canScan => _scanner.isSupported;

  Future<List<GroceryItem>> load(String uid) {
    return guard(
      () => _lists.getItems(uid),
      label: 'load grocery list',
      onError: () => const GroceryException(
        'Could not load your grocery list. Please try again.',
      ),
    );
  }

  Future<void> save(String uid, List<GroceryItem> items) {
    return guard(
      () => _lists.saveItems(uid, items),
      label: 'save grocery list',
      onError: () => const GroceryException(
        'Could not save your grocery list. Check your connection.',
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';

final Provider<GroceryListService> groceryListServiceProvider =
    Provider<GroceryListService>(
      (ref) => GroceryListService(ref.watch(firebaseFirestoreProvider)),
    );

/// Reads and writes a customer's grocery list in Firestore at
/// users/{uid}/groceryList/current. Owner-only; see `firestore.rules`.
class GroceryListService {
  GroceryListService(FirebaseFirestore firestore)
    : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// The saved list, empty if none has been saved. An entry that cannot be
  /// read is skipped rather than failing the whole list.
  Future<List<GroceryItem>> getItems(String uid) async {
    final snapshot = await _refs
        .groceryList(uid)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    final data = snapshot.data();
    if (data == null) return const [];
    final items = <GroceryItem>[];
    for (final map in data.maps(GroceryListFields.items)) {
      try {
        items.add(GroceryItem.fromMap(map));
      } on FormatException {
        continue;
      }
    }
    return items;
  }

  /// Replaces the saved list; deletes it when [items] is empty.
  Future<void> saveItems(String uid, List<GroceryItem> items) {
    if (items.isEmpty) return _refs.groceryList(uid).delete();
    return _refs
        .groceryList(uid)
        .set({
          GroceryListFields.items: [for (final item in items) item.toMap()],
          GroceryListFields.updatedAt: FieldValue.serverTimestamp(),
        })
        .timeout(FirestoreConfig.readTimeout);
  }
}

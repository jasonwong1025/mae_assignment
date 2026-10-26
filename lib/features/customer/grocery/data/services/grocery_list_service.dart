import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_list.dart';

final Provider<GroceryListService> groceryListServiceProvider =
    Provider<GroceryListService>(
      (ref) => GroceryListService(ref.watch(firebaseFirestoreProvider)),
    );

/// Reads and writes a customer's grocery lists in Firestore at
/// users/{uid}/groceryList/{listId}, one document per list. The default
/// list's id is `current`. Owner-only; see `firestore.rules`.
class GroceryListService {
  GroceryListService(FirebaseFirestore firestore)
    : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// Every saved list, in no particular order. An item that cannot be read
  /// is skipped rather than failing its list.
  Future<List<GroceryList>> getLists(String uid) async {
    final snapshot = await _refs
        .groceryLists(uid)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return [
      for (final doc in snapshot.docs)
        GroceryList(
          id: doc.id,
          name:
              doc.data().stringOrNull(GroceryListFields.name) ??
              (doc.id == GroceryList.defaultId
                  ? GroceryList.defaultName
                  : 'List'),
          items: _items(doc.data()),
          createdAt: doc.data().dateTime(GroceryListFields.createdAt),
        ),
    ];
  }

  /// A new, unused list id. Made on the phone, so a new list can be shown
  /// before it is saved.
  String newId(String uid) => _refs.groceryLists(uid).doc().id;

  /// Saves a new list.
  Future<void> createList(String uid, GroceryList list) {
    return _refs
        .groceryLists(uid)
        .doc(list.id)
        .set({
          GroceryListFields.name: list.name,
          GroceryListFields.items: _maps(list.items),
          GroceryListFields.createdAt: FieldValue.serverTimestamp(),
          GroceryListFields.updatedAt: FieldValue.serverTimestamp(),
        })
        .timeout(FirestoreConfig.readTimeout);
  }

  /// Saves a list's name and items. Merges, so the time it was made is
  /// kept; the default list is created the first time it is saved.
  Future<void> saveList(String uid, GroceryList list) {
    return _refs
        .groceryLists(uid)
        .doc(list.id)
        .set({
          GroceryListFields.name: list.name,
          GroceryListFields.items: _maps(list.items),
          GroceryListFields.updatedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .timeout(FirestoreConfig.readTimeout);
  }

  Future<void> deleteList(String uid, String listId) {
    return _refs
        .groceryLists(uid)
        .doc(listId)
        .delete()
        .timeout(FirestoreConfig.readTimeout);
  }

  static List<GroceryItem> _items(Map<String, dynamic> data) {
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

  static List<Map<String, dynamic>> _maps(List<GroceryItem> items) => [
    for (final item in items) item.toMap(),
  ];
}

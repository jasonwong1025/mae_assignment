import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/customer/wallet/data/models/wallet_entry.dart';

final Provider<WalletService> walletServiceProvider = Provider<WalletService>(
  (ref) => WalletService(ref.watch(firebaseFirestoreProvider)),
);

/// Reads the customer's simulated wallet from Firestore and asks the Cloud
/// Function to top it up. The balance is read-only for the app: nothing here
/// writes it (see `firestore.rules`).
class WalletService {
  WalletService(FirebaseFirestore firestore) : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// The balance, live. 0 until the wallet has been used.
  Stream<double> watchBalance(String uid) {
    return _refs.wallet(uid).snapshots().map((snapshot) {
      return snapshot.data()?.decimal(WalletFields.balance) ?? 0;
    });
  }

  /// The latest entries of the history, newest first, live.
  Stream<List<WalletEntry>> watchEntries(String uid, {int limit = 50}) {
    return _refs
        .walletTransactions(uid)
        .orderBy(WalletEntryFields.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return [
            for (final doc in snapshot.docs)
              WalletEntry.fromFirestore(doc.id, doc.data()),
          ];
        });
  }

  /// Adds [amount] ringgit through the `topUpWallet` Function and returns the
  /// new balance. [method] only labels the history entry ("Simulated card").
  Future<double> topUp(double amount, {required String method}) async {
    final result =
        await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
            .httpsCallable('topUpWallet')
            .call<Map<String, dynamic>>({'amount': amount, 'method': method});
    return (result.data['balance'] as num).toDouble();
  }
}

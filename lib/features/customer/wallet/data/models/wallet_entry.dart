import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'wallet_entry.freezed.dart';

/// Why the wallet balance changed.
enum WalletEntryType {
  /// The customer added money.
  topUp('Top up'),

  /// An order was paid for.
  payment('Payment'),

  /// Money came back: a cancelled order, or an item that was not delivered.
  refund('Refund'),

  /// A replacement that cost more than the item it replaced.
  adjustment('Adjustment');

  const WalletEntryType(this.label);

  final String label;
}

/// One line of the wallet history. The wallet is simulated: these are
/// entries in Firestore, written only by the Cloud Functions.
@freezed
abstract class WalletEntry with _$WalletEntry {
  const factory WalletEntry({
    required String id,
    required WalletEntryType type,

    /// Signed: positive adds money, negative takes it.
    required double amount,
    required double balanceAfter,
    required String description,
    String? orderId,

    /// Null until Firestore has saved the server time.
    DateTime? createdAt,
  }) = _WalletEntry;

  const WalletEntry._();

  factory WalletEntry.fromFirestore(String id, Map<String, dynamic> data) {
    return WalletEntry(
      id: id,
      type: data.enumValue(
        WalletEntryFields.type,
        WalletEntryType.values,
        fallback: WalletEntryType.adjustment,
      ),
      amount: data.decimal(WalletEntryFields.amount),
      balanceAfter: data.decimal(WalletEntryFields.balanceAfter),
      description: data.string(WalletEntryFields.description),
      orderId: data.stringOrNull(WalletEntryFields.orderId),
      createdAt: data.dateTime(WalletEntryFields.createdAt),
    );
  }

  /// True if this entry added money.
  bool get isCredit => amount > 0;
}

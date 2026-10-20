import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/customer/wallet/data/models/wallet_entry.dart';
import 'package:mae_assignment/features/customer/wallet/data/services/wallet_service.dart';

final Provider<WalletRepository> walletRepositoryProvider =
    Provider<WalletRepository>((ref) {
      return WalletRepository(ref.watch(walletServiceProvider));
    });

/// Error with a message that is safe to show on screen.
class WalletException extends AppException {
  const WalletException(super.message);
}

/// The customer's Grocerly Wallet. It is a simulation: a balance and history
/// kept in Firestore, with no real payment provider behind it.
class WalletRepository {
  WalletRepository(this._service);

  /// The most a single top up can be, in ringgit (also checked by the
  /// Function, which has the final say).
  static const double maxTopUp = 500;

  final WalletService _service;

  Stream<double> watchBalance(String uid) => _service.watchBalance(uid);

  Stream<List<WalletEntry>> watchEntries(String uid) {
    return _service.watchEntries(uid);
  }

  /// Adds [amount] to the wallet and returns the new balance. Throws a
  /// [WalletException] with the reason if the Function refuses.
  Future<double> topUp(double amount) async {
    if (amount < 1 || amount > maxTopUp) {
      throw const WalletException('Top up between RM 1 and RM 500.');
    }
    try {
      return await _service.topUp(amount, method: 'Simulated card');
    } on FirebaseFunctionsException catch (error) {
      if (error.code == 'invalid-argument' ||
          error.code == 'failed-precondition') {
        throw WalletException(error.message ?? 'The top up was refused.');
      }
      throw const WalletException(
        'Could not top up your wallet. Please check your connection.',
      );
    } on Object {
      throw const WalletException(
        'Could not top up your wallet. Please check your connection.',
      );
    }
  }
}

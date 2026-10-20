import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/wallet/data/models/wallet_entry.dart';
import 'package:mae_assignment/features/customer/wallet/data/repositories/wallet_repository.dart';

/// The signed-in customer's wallet balance, live. 0 when signed out.
final walletBalanceProvider = StreamProvider.autoDispose<double>((ref) async* {
  final uid = await ref.watch(authUidProvider.future);
  if (uid == null) {
    yield 0;
    return;
  }
  yield* ref.watch(walletRepositoryProvider).watchBalance(uid);
});

/// The wallet history, newest first, live.
final walletEntriesProvider = StreamProvider.autoDispose<List<WalletEntry>>((
  ref,
) async* {
  final uid = await ref.watch(authUidProvider.future);
  if (uid == null) {
    yield const [];
    return;
  }
  yield* ref.watch(walletRepositoryProvider).watchEntries(uid);
});

/// True while a top up is running, so its button shows it is busy and ignores
/// repeat taps. autoDispose: resets when the wallet screen is left.
final NotifierProvider<WalletTopUpViewModel, bool>
walletTopUpViewModelProvider =
    NotifierProvider.autoDispose<WalletTopUpViewModel, bool>(
      WalletTopUpViewModel.new,
    );

class WalletTopUpViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  /// Adds [amount] to the wallet. Returns an error message, or null if it
  /// worked.
  Future<String?> topUp(double amount) async {
    if (state) return null;
    state = true;
    try {
      await ref.read(walletRepositoryProvider).topUp(amount);
      return null;
    } on AppException catch (error) {
      return error.message;
    } finally {
      if (ref.mounted) state = false;
    }
  }
}

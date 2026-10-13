import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';

final registerViewModelProvider =
    NotifierProvider.autoDispose<RegisterViewModel, AsyncValue<void>>(
      RegisterViewModel.new,
    );

/// State for the sign-up page.
/// - AsyncData: idle, or finished successfully
/// - AsyncLoading: creating the account
/// - AsyncError: failed; the error is a message to show on screen
class RegisterViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns true if the account was created (the user is now signed in).
  Future<bool> createAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            name: name.trim(),
            // Lowercase to match how Firebase stores the account email.
            email: email.trim().toLowerCase(),
            // Save digits only, so "012-345 6789" and "0123456789" match.
            phone: phone.replaceAll(RegExp(r'[\s-]'), ''),
            password: password,
          );
      if (!ref.mounted) return false;
      state = const AsyncData(null);
      return true;
    } on AuthException catch (e, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncError(e.message, stackTrace);
      return false;
    }
  }
}

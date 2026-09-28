import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../users/data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, AsyncValue<void>>(
      LoginViewModel.new,
    );

/// State for the sign-in page.
/// - AsyncData: idle, or finished successfully
/// - AsyncLoading: signing in
/// - AsyncError: failed; the error is a message to show on screen
class LoginViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Signs in as [role]. Returns true if it worked.
  /// Fails if the account belongs to a different role.
  Future<bool> signIn({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    final email = emailOrPhone.trim();

    // Firebase email sign-in needs an email. Phone sign-in comes later.
    if (!email.contains('@')) {
      state = AsyncError(
        'Please sign in with your email for now.',
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);

    try {
      final user = await repository.signIn(email: email, password: password);

      if (user.role != role) {
        await repository.signOut();
        if (!ref.mounted) return false;
        state = AsyncError(
          'This is a ${user.role.label} account. '
          'Please continue as ${user.role.label}.',
          StackTrace.current,
        );
        return false;
      }

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

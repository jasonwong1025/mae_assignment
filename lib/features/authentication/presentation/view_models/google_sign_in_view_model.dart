import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';

final googleSignInViewModelProvider =
    NotifierProvider.autoDispose<GoogleSignInViewModel, AsyncValue<void>>(
      GoogleSignInViewModel.new,
    );

/// Shared by the sign-in and registration pages. Closing the Google chooser
/// returns to idle without showing an error.
class GoogleSignInViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> signIn() async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!ref.mounted) return false;
      state = const AsyncData(null);
      if (user == null) return false;
      ref.invalidate(currentUserProvider);
      return true;
    } on AuthException catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncError(error.message, stackTrace);
      return false;
    }
  }
}

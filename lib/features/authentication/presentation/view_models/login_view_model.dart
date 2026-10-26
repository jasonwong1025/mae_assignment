import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

final NotifierProvider<LoginViewModel, AsyncValue<void>>
loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, AsyncValue<void>>(
      LoginViewModel.new,
    );

/// True when this build is the HQ web console, which only Store Admin may
/// use. A provider so tests can check both builds.
final Provider<bool> adminConsoleOnlyProvider = Provider<bool>((ref) => kIsWeb);

/// State for the login page.
/// - AsyncData: idle, or finished successfully
/// - AsyncLoading: logging in
/// - AsyncError: failed; the error is a message to show on screen
///
/// There is one login for every role. The person does not say who they are:
/// the role comes from their profile (users/{uid}.role), and they land on
/// that role's home. What each role may do is enforced on the server by
/// `firestore.rules` and the Cloud Functions, not by this page.
class LoginViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Logs in and returns the page to open next (the account's home), or null
  /// if it failed, with the reason in the state.
  ///
  /// Signs the account out again when it cannot be used here: a customer or
  /// worker on the HQ web console, or a Store Worker whose profile cannot
  /// start a session (deactivated, or a packer with no branch).
  Future<String?> signIn({
    required String emailOrPhone,
    required String password,
  }) async {
    final email = emailOrPhone.trim();
    // Firebase email sign-in needs an email. Phone sign-in comes later.
    if (!email.contains('@')) {
      state = AsyncError(
        'Please log in with your email for now.',
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    try {
      final user = await repository.signIn(email: email, password: password);
      if (!ref.mounted) return null;

      if (ref.read(adminConsoleOnlyProvider) &&
          user.role != UserRole.storeAdmin) {
        return await _refuse(
          'The web console is for Store Admin. Please use the Grocerly app '
          'on your phone.',
        );
      }

      if (user.role == UserRole.storeWorker) {
        // Workers need their profile (job and branch) before any screen.
        final error = await ref.read(workerSessionProvider.notifier).start();
        if (!ref.mounted) return null;
        final worker = ref.read(workerSessionProvider);
        if (error != null || worker == null) {
          return await _refuse(error ?? 'Could not start your session.');
        }
        state = const AsyncData(null);
        return homeRouteFor(user.role, worker: worker);
      }

      state = const AsyncData(null);
      return homeRouteFor(user.role);
    } on AuthException catch (e, stackTrace) {
      if (!ref.mounted) return null;
      state = AsyncError(e.message, stackTrace);
      return null;
    }
  }

  /// Signs out the account that just logged in and shows [message].
  Future<String?> _refuse(String message) async {
    await ref.read(authRepositoryProvider).signOut();
    if (!ref.mounted) return null;
    state = AsyncError(message, StackTrace.current);
    return null;
  }
}

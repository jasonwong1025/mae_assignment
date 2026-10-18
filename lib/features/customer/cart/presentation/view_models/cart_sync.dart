import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/data/models/stored_cart.dart';
import 'package:mae_assignment/features/customer/cart/data/repositories/cart_repository.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/selected_address_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';

/// The signed-in uid (null when signed out), following every sign-in and
/// sign-out.
final StreamProvider<String?> authUidProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).uidChanges;
});

/// Keeps the in-memory cart and the saved cart in step. Watched once from
/// the app root so it lives for the whole session.
///
/// - Sign-in (or app start with a live session): loads the saved cart,
///   resolves it against the selected branch's catalogue, and merges it in.
/// - Every cart change after that is saved.
/// - Sign-out or switching account: the cart and picked address are cleared,
///   so one customer never sees another's cart.
///
/// Nothing is saved until the saved cart has been read once, so a failed or
/// slow load can never overwrite it with an empty cart. Saving is best
/// effort: a failed write leaves the in-memory cart intact.
final Provider<void> cartSyncProvider = Provider<void>((ref) {
  String? uid;
  var loaded = false;
  var loading = false;

  Future<void> load(String forUid) async {
    if (loading) return;
    loading = true;
    try {
      final stored = await ref.read(cartRepositoryProvider).load(forUid);
      if (uid != forUid) return;

      if (stored != null && !stored.isEmpty) {
        final branch = await ref.read(selectedBranchProvider.future);
        final data = await ref
            .read(catalogueRepositoryProvider)
            .loadCatalogue(branch.id);
        if (uid != forUid) return;
        loaded = true;
        ref
            .read(cartViewModelProvider.notifier)
            .restore(stored.resolve(data.products));
      } else {
        loaded = true;
      }
      // Save the merged result, which also tidies a saved cart whose items
      // are no longer sold, and keeps anything added while loading.
      _save(ref, forUid);
    } on Object catch (error) {
      // Offline or denied: keep the in-memory cart; retried on next change.
      debugPrint('Could not load the saved cart: $error');
    } finally {
      loading = false;
    }
  }

  ref
    ..listen<AsyncValue<String?>>(authUidProvider, (previous, next) {
      if (!next.hasValue) return;
      final nextUid = next.value;
      if (nextUid == uid) return;

      uid = nextUid;
      loaded = false;
      ref.read(cartViewModelProvider.notifier).clear();
      ref.read(selectedAddressProvider.notifier).clear();
      if (nextUid != null) unawaited(load(nextUid));
    }, fireImmediately: true)
    ..listen(cartViewModelProvider, (previous, next) {
      final currentUid = uid;
      if (currentUid == null) return;
      if (!loaded) {
        unawaited(load(currentUid));
        return;
      }
      _save(ref, currentUid);
    });
});

void _save(Ref ref, String uid) {
  final cart = ref.read(cartViewModelProvider);
  unawaited(
    ref
        .read(cartRepositoryProvider)
        .save(uid, StoredCart.fromCart(cart))
        .catchError((Object error) {
          debugPrint('Could not save the cart: $error');
        }),
  );
}

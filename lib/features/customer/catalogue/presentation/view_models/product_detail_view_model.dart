import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';

/// One product as sold at the customer's selected branch, looked up by id so
/// the detail screen always shows current price and stock (and works when
/// opened from a link). Null when the product is hidden, unavailable at the
/// branch, or does not exist.
///
/// `retry: (_, _) => null` so a failed load shows the retry state instead of
/// spinning.
final productDetailProvider = FutureProvider.autoDispose
    .family<CatalogueProduct?, String>((ref, productId) async {
      final branch = await ref.watch(selectedBranchProvider.future);
      final data = await ref
          .watch(catalogueRepositoryProvider)
          .loadCatalogue(branch.id);
      for (final product in data.products) {
        if (product.id == productId) return product;
      }
      return null;
    }, retry: (_, _) => null);

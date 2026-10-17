import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/catalogue_filter_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/shared/models/branch.dart';

final catalogueViewModelProvider =
    AsyncNotifierProvider.autoDispose<CatalogueViewModel, CatalogueState>(
      CatalogueViewModel.new,
    );

/// What the Home (catalogue) screen shows.
class CatalogueState {
  const CatalogueState({
    required this.branch,
    required this.categories,
    required this.products,
  });

  /// The store the customer is shopping from.
  final Branch branch;

  final List<CatalogueCategory> categories;

  /// Products after the category and search filters are applied.
  final List<CatalogueProduct> products;

  /// Up to [limit] genuinely low-stock products (a scarcity hint is shown),
  /// least stock first, for the "Going fast today" row. Empty when nothing
  /// is running low, so the row is hidden rather than duplicating the grid.
  List<CatalogueProduct> goingFast({int limit = 6}) {
    final lowStock = [
      for (final product in products)
        if (product.lowStockRemaining != null) product,
    ]..sort((a, b) => a.stock.compareTo(b.stock));
    return lowStock.take(limit).toList();
  }
}

/// Loads the catalogue for the customer's branch and applies the category
/// and search filters. Rebuilds when the branch, category or search change.
class CatalogueViewModel extends AsyncNotifier<CatalogueState> {
  @override
  Future<CatalogueState> build() async {
    final branch = await ref.watch(selectedBranchProvider.future);
    final filter = ref.watch(catalogueFilterViewModelProvider);
    final search = filter.searchText.trim().toLowerCase();

    final data = await ref
        .watch(catalogueRepositoryProvider)
        .loadCatalogue(branch.id);

    var products = data.productsIn(filter.categoryId);
    if (search.isNotEmpty) {
      products = [
        for (final product in products)
          if (product.name.toLowerCase().contains(search) ||
              product.brand.toLowerCase().contains(search))
            product,
      ];
    }

    return CatalogueState(
      branch: branch,
      categories: data.categories,
      products: products,
    );
  }
}

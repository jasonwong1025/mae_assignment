import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/catalogue_filter_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/shared/models/branch.dart';

part 'catalogue_view_model.freezed.dart';

final catalogueViewModelProvider =
    AsyncNotifierProvider.autoDispose<CatalogueViewModel, CatalogueState>(
      CatalogueViewModel.new,
    );

/// What the Home (catalogue) screen shows.
@freezed
abstract class CatalogueState with _$CatalogueState {
  const factory CatalogueState({
    /// The store the customer is shopping from.
    required Branch branch,
    required List<CatalogueCategory> categories,

    /// Products after the category and search filters are applied.
    required List<CatalogueProduct> products,
  }) = _CatalogueState;

  const CatalogueState._();

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

/// Loads the catalogue for the customer's branch and reapplies filters when
/// they change. Filter updates reuse the loaded branch data; branch changes
/// and explicit invalidation still reload it from the repository.
class CatalogueViewModel extends AsyncNotifier<CatalogueState> {
  CatalogueData? _loadedData;
  Branch? _loadedBranch;
  int _buildGeneration = 0;

  @override
  Future<CatalogueState> build() async {
    // A branch change or provider invalidation starts a fresh repository load.
    final generation = ++_buildGeneration;
    _loadedData = null;
    _loadedBranch = null;

    ref.listen(catalogueFilterViewModelProvider, (previous, filter) {
      final data = _loadedData;
      final branch = _loadedBranch;
      if (data != null && branch != null) {
        state = AsyncData(_applyFilter(branch, data, filter));
      }
    });

    final branch = await ref.watch(selectedBranchProvider.future);
    final data = await ref
        .watch(catalogueRepositoryProvider)
        .loadCatalogue(branch.id);

    // An older in-flight build may finish after a newer branch load. Riverpod
    // ignores its returned state, so keep it from replacing the filter cache.
    if (generation == _buildGeneration) {
      _loadedBranch = branch;
      _loadedData = data;
    }
    return _applyFilter(
      branch,
      data,
      ref.read(catalogueFilterViewModelProvider),
    );
  }

  CatalogueState _applyFilter(
    Branch branch,
    CatalogueData data,
    CatalogueFilter filter,
  ) {
    var products = data.productsIn(filter.categoryId);
    final search = filter.searchText.trim().toLowerCase();
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<CatalogueFilterViewModel, CatalogueFilter>
catalogueFilterViewModelProvider =
    NotifierProvider.autoDispose<CatalogueFilterViewModel, CatalogueFilter>(
      CatalogueFilterViewModel.new,
    );

/// How the customer is narrowing the catalogue on the Home screen: the
/// selected category (null means "all") and the search text.
class CatalogueFilter {
  const CatalogueFilter({this.categoryId, this.searchText = ''});

  /// Selected category id, or null for every category.
  final String? categoryId;
  final String searchText;
}

/// State for the Home screen's category tabs and search box.
class CatalogueFilterViewModel extends Notifier<CatalogueFilter> {
  @override
  CatalogueFilter build() => const CatalogueFilter();

  void setCategory(String? categoryId) {
    state = CatalogueFilter(
      categoryId: categoryId,
      searchText: state.searchText,
    );
  }

  void setSearchText(String text) {
    state = CatalogueFilter(categoryId: state.categoryId, searchText: text);
  }
}

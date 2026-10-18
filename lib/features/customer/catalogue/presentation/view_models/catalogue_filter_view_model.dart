import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalogue_filter_view_model.freezed.dart';

final NotifierProvider<CatalogueFilterViewModel, CatalogueFilter>
catalogueFilterViewModelProvider =
    NotifierProvider.autoDispose<CatalogueFilterViewModel, CatalogueFilter>(
      CatalogueFilterViewModel.new,
    );

/// How the customer is narrowing the catalogue on the Home screen: the
/// selected category (null means "all") and the search text.
@freezed
abstract class CatalogueFilter with _$CatalogueFilter {
  const factory CatalogueFilter({
    /// Selected category id, or null for every category.
    String? categoryId,
    @Default('') String searchText,
  }) = _CatalogueFilter;

  const CatalogueFilter._();
}

/// State for the Home screen's category tabs and search box.
class CatalogueFilterViewModel extends Notifier<CatalogueFilter> {
  @override
  CatalogueFilter build() => const CatalogueFilter();

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setSearchText(String text) {
    state = state.copyWith(searchText: text);
  }
}

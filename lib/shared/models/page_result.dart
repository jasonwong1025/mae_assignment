/// One page of a longer list, plus how long the whole list is.
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.totalCount,
    required this.page,
    this.pageSize = defaultPageSize,
  });

  static const int defaultPageSize = 20;

  /// Cuts one page out of [all]. A page number that is too high or too
  /// low is moved to the nearest real page.
  factory PageResult.fromList(
    List<T> all, {
    required int page,
    int pageSize = defaultPageSize,
  }) {
    final pageCount = all.isEmpty ? 1 : (all.length / pageSize).ceil();
    final realPage = page.clamp(1, pageCount);
    final start = (realPage - 1) * pageSize;

    return PageResult(
      items: all.skip(start).take(pageSize).toList(),
      totalCount: all.length,
      page: realPage,
      pageSize: pageSize,
    );
  }

  /// Rows on this page.
  final List<T> items;

  /// Rows on all pages together.
  final int totalCount;

  /// This page's number. The first page is 1.
  final int page;
  final int pageSize;

  int get pageCount => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();

  /// Position of the first and last row of this page, counting from 1.
  int get firstRow => totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastRow => firstRow == 0 ? 0 : firstRow + items.length - 1;
}

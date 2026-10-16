import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../shell/presentation/ui/admin_scaffold.dart';
import '../../../shell/presentation/ui/admin_sidebar.dart';
import '../../../shell/presentation/ui/pagination_bar.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../ui/category_sales_card.dart';
import '../ui/period_picker.dart';
import '../ui/revenue_chart.dart';
import '../ui/sales_summary_cards.dart';
import '../ui/top_products_rows.dart';
import '../view_models/sales_filter_view_model.dart';
import '../view_models/sales_view_model.dart';

/// Sales & revenue tab: what the selected branch earned in a period.
/// Every order is paid from the wallet at checkout. Read only.
class SalesView extends ConsumerStatefulWidget {
  const SalesView({super.key});

  @override
  ConsumerState<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends ConsumerState<SalesView> {
  /// Page widths where the layout changes.
  static const double _wideWidth = 720;
  static const double _chartBesideCategoriesWidth = 1000;

  /// Marks the top of the products table, to scroll there on a new page.
  final _tableKey = GlobalKey();

  void _goToPage(int page) {
    ref.read(salesFilterViewModelProvider.notifier).setPage(page);

    final tableContext = _tableKey.currentContext;
    if (tableContext != null) Scrollable.ensureVisible(tableContext);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sales = ref.watch(salesViewModelProvider);
    final filter = ref.watch(salesFilterViewModelProvider);
    final filterViewModel = ref.read(salesFilterViewModelProvider.notifier);
    final branchName = ref.watch(branchViewModelProvider).value?.selected.name;

    return AdminScaffold(
      currentPage: AdminPage.salesAndRevenue,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideWidth;
          final padding = isWide ? 32.0 : 16.0;

          final picker = PeriodPicker(
            period: filter.period,
            onPresetSelected: filterViewModel.setPreset,
            onCustomSelected: filterViewModel.setCustom,
          );

          return sales.when(
            // Keep the old numbers on screen while reloading.
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Could not load sales.', style: textTheme.bodyMedium),
            ),
            data: (state) {
              final report = state.report;
              final products = state.topProducts;
              final chart = RevenueChart(report: report);
              final categories = CategorySalesCard(report: report);

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
                    sliver: SliverList.list(
                      children: [
                        if (isWide) ...[
                          Text(
                            'Sales & revenue',
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            branchName == null
                                ? 'Paid by Grocerly Wallet at checkout'
                                : '$branchName · paid by Grocerly Wallet '
                                      'at checkout',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                        ],
                        picker,
                        const SizedBox(height: 16),
                        SalesSummaryCards(report: report),
                        const SizedBox(height: 16),
                        if (constraints.maxWidth >= _chartBesideCategoriesWidth)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: RevenueChart(
                                    report: report,
                                    fillHeight: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: categories),
                              ],
                            ),
                          )
                        else ...[
                          chart,
                          const SizedBox(height: 16),
                          categories,
                        ],
                        SizedBox(height: isWide ? 28 : 20),
                        Text(
                          'Top products',
                          key: _tableKey,
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (products.items.isEmpty)
                          Text(
                            'No products sold in this period.',
                            style: textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  if (products.items.isNotEmpty) ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      sliver: DecoratedSliver(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          border: Border.all(color: AppColors.border),
                        ),
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            if (isWide)
                              const SliverToBoxAdapter(
                                child: Column(
                                  children: [TopProductsHeading(), Divider()],
                                ),
                              ),
                            // Rows are built as they scroll into view.
                            SliverList.separated(
                              itemCount: products.items.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final rank = products.firstRow + index;
                                final product = products.items[index];
                                return isWide
                                    ? TopProductRow(
                                        rank: rank,
                                        product: product,
                                      )
                                    : TopProductTile(
                                        rank: rank,
                                        product: product,
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
                      sliver: SliverToBoxAdapter(
                        child: PaginationBar(
                          result: products,
                          itemName: 'products',
                          onPageChanged: _goToPage,
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(child: SizedBox(height: padding)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

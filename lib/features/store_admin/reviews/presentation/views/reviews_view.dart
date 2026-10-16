import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review_summary.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/ui/review_detail_panel.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/ui/review_rows.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/ui/review_summary_section.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/view_models/reviews_filter_view_model.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/view_models/reviews_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_scaffold.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_sidebar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/filter_menu_button.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/pagination_bar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

/// Reviews tab: what customers said about the selected branch and its
/// drivers. Read only.
class ReviewsView extends ConsumerStatefulWidget {
  const ReviewsView({super.key});

  @override
  ConsumerState<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends ConsumerState<ReviewsView> {
  /// Page widths where the layout changes.
  static const double _tableWidth = 720;
  static const double _sidePanelWidth = 1000;

  final _searchController = TextEditingController();

  /// Marks the top of the list, to scroll there on a new page.
  final GlobalKey<State<StatefulWidget>> _listKey = GlobalKey();

  /// Review open in the side panel.
  Review? _selected;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Opens a review in the side panel, or as a full page if no room.
  void _openReview(Review review, {required bool inSidePanel}) {
    if (inSidePanel) {
      setState(() => _selected = review);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) => Scaffold(
          body: SafeArea(
            child: ReviewDetailPanel(
              review: review,
              onClose: () => Navigator.of(pageContext).pop(),
            ),
          ),
        ),
      ),
    );
  }

  void _goToPage(int page) {
    setState(() => _selected = null);
    ref.read(reviewsFilterViewModelProvider.notifier).setPage(page);

    // Scroll back up to the start of the list.
    final listContext = _listKey.currentContext;
    if (listContext != null) Scrollable.ensureVisible(listContext);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reviews = ref.watch(reviewsViewModelProvider);
    final filter = ref.watch(reviewsFilterViewModelProvider);
    final branchName = ref.watch(branchViewModelProvider).value?.selected.name;

    // A new branch: close the panel.
    ref.listen(branchViewModelProvider, (previous, next) {
      if (previous?.value?.selected.id != next.value?.selected.id) {
        setState(() => _selected = null);
      }
    });

    return AdminScaffold(
      currentPage: AdminPage.reviews,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Width of the page without the sidebar.
          final isWide = constraints.maxWidth >= _tableWidth;
          final hasRoomForPanel = constraints.maxWidth >= _sidePanelWidth;
          final showPanel = hasRoomForPanel && _selected != null;
          final padding = isWide ? 32.0 : 16.0;

          final page = reviews.when(
            // Keep the old list on screen while reloading.
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(
                'Could not load reviews.',
                style: textTheme.bodyMedium,
              ),
            ),
            data: (state) {
              final result = state.page;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
                    sliver: SliverList.list(
                      children: [
                        if (isWide) ...[
                          Text('Reviews', style: textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text(
                            branchName == null
                                ? 'What customers say'
                                : 'What customers say about $branchName',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                        ],
                        ReviewSummarySection(
                          summary: state.summary,
                          isWide: isWide,
                          onDriverTap: ref
                              .read(reviewsFilterViewModelProvider.notifier)
                              .setDriver,
                        ),
                        SizedBox(height: isWide ? 28 : 16),
                        _Filters(
                          key: _listKey,
                          isWide: isWide,
                          searchController: _searchController,
                          filter: filter,
                          drivers: state.summary.drivers,
                        ),
                        const SizedBox(height: 12),
                        if (result.items.isEmpty)
                          Text(
                            filter.isNarrowing
                                ? 'No reviews match your search or filters.'
                                : 'No reviews yet.',
                            style: textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  if (result.items.isNotEmpty) ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      sliver: isWide
                          ? _tableSliver(result.items, hasRoomForPanel)
                          : _cardsSliver(result.items),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
                      sliver: SliverToBoxAdapter(
                        child: PaginationBar(
                          result: result,
                          itemName: 'reviews',
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

          if (!showPanel) return page;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: page),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 380,
                // The key resets the panel when another review is opened.
                child: ReviewDetailPanel(
                  key: ValueKey(_selected!.id),
                  review: _selected!,
                  onClose: () => setState(() => _selected = null),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The table in a white card. Rows are built as they scroll into view.
  Widget _tableSliver(List<Review> reviews, bool hasRoomForPanel) {
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(
            child: Column(children: [ReviewTableHeading(), Divider()]),
          ),
          SliverList.separated(
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewRow(
                review: review,
                isSelected: review.id == _selected?.id,
                onTap: () {
                  _openReview(review, inSidePanel: hasRoomForPanel);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _cardsSliver(List<Review> reviews) {
    return SliverList.separated(
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewCard(
          review: review,
          onTap: () => _openReview(review, inSidePanel: false),
        );
      },
    );
  }
}

/// Search box and filter buttons above the list.
class _Filters extends ConsumerWidget {
  const _Filters({
    required this.isWide,
    required this.searchController,
    required this.filter,
    required this.drivers,
    super.key,
  });

  final bool isWide;
  final TextEditingController searchController;
  final ReviewsFilter filter;

  /// Drivers to pick from.
  final List<DriverRating> drivers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(reviewsFilterViewModelProvider.notifier);

    final search = TextField(
      controller: searchController,
      onChanged: viewModel.setSearchText,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search customer or order',
        prefixIcon: Icon(Icons.search_rounded),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
    );

    final filters = [
      FilterMenuButton<int>(
        name: 'Rating',
        allLabel: 'Any rating',
        options: [
          for (var stars = 5; stars >= 1; stars--)
            FilterOption(
              value: stars,
              label: stars == 1 ? '1 star' : '$stars stars',
            ),
        ],
        selected: filter.stars,
        onSelected: viewModel.setStars,
      ),
      FilterMenuButton<String>(
        name: 'Driver',
        allLabel: 'All drivers',
        options: [
          for (final driver in drivers)
            FilterOption(value: driver.driverId, label: driver.name),
        ],
        selected: filter.driverId,
        onSelected: viewModel.setDriver,
      ),
      FilterMenuButton<ReviewPeriod>(
        name: 'Date',
        allLabel: 'Any date',
        options: [
          for (final period in ReviewPeriod.values)
            FilterOption(value: period, label: period.label),
        ],
        selected: filter.period,
        onSelected: viewModel.setPeriod,
      ),
      FilterMenuButton<bool>(
        name: 'Comment',
        allLabel: 'With or without comment',
        options: const [FilterOption(value: true, label: 'With comment')],
        selected: filter.commentsOnly ? true : null,
        onSelected: (value) =>
            viewModel.setCommentsOnly(commentsOnly: value ?? false),
      ),
    ];

    // Scrolls sideways if the filters do not fit.
    final filterRow = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final button in filters)
            Padding(padding: const EdgeInsets.only(right: 8), child: button),
        ],
      ),
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [search, const SizedBox(height: 8), filterRow],
      );
    }

    return Row(
      children: [
        SizedBox(width: 280, child: search),
        const SizedBox(width: 12),
        Expanded(child: filterRow),
      ],
    );
  }
}

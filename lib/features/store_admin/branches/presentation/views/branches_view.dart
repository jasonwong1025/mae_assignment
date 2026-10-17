import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/ui/branch_detail_panel.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/ui/branch_form.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/ui/branch_list.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/view_models/branches_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_scaffold.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_sidebar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/pagination_bar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/side_panel_frame.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';

/// Branches tab: every branch of the retailer. The admin can add a
/// branch, edit it, or close it to new orders for a while.
class BranchesView extends ConsumerStatefulWidget {
  const BranchesView({super.key});

  @override
  ConsumerState<BranchesView> createState() => _BranchesViewState();
}

class _BranchesViewState extends ConsumerState<BranchesView> {
  /// Page widths where the layout changes.
  static const double _tableWidth = 720;
  static const double _sidePanelWidth = 1000;

  final _searchController = TextEditingController();

  /// Branch open in the side panel.
  String? _selectedBranchId;

  /// True if the side panel shows the add form.
  bool _isAdding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _closePanel() {
    setState(() {
      _selectedBranchId = null;
      _isAdding = false;
    });
  }

  /// Opens a branch in the side panel, or as a full page if no room.
  void _openBranch(Branch branch, {required bool inSidePanel}) {
    if (inSidePanel) {
      setState(() {
        _selectedBranchId = branch.id;
        _isAdding = false;
      });
      return;
    }
    _pushPage(
      (pageContext) => BranchDetailPanel(
        branchId: branch.id,
        onClose: () => Navigator.of(pageContext).pop(),
      ),
    );
  }

  /// Opens the add form in the side panel, or as a full page if no room.
  void _openAddForm({required bool inSidePanel}) {
    if (inSidePanel) {
      setState(() {
        _selectedBranchId = null;
        _isAdding = true;
      });
      return;
    }
    _pushPage(
      (pageContext) => _AddBranchPanel(
        onClose: () => Navigator.of(pageContext).pop(),
        onAdded: (name) {
          Navigator.of(pageContext).pop();
          _showMessage('$name was added.');
        },
      ),
    );
  }

  Future<void> _addSampleBranches() async {
    final error = await ref
        .read(branchesViewModelProvider.notifier)
        .addSampleBranches();
    if (!mounted) return;
    _showMessage(error ?? 'The 3 sample branches were added.');
  }

  void _pushPage(WidgetBuilder panelBuilder) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) =>
            Scaffold(body: SafeArea(child: panelBuilder(pageContext))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final branches = ref.watch(branchesViewModelProvider);
    final filter = ref.watch(branchesFilterProvider);
    final filterViewModel = ref.read(branchesFilterProvider.notifier);

    return AdminScaffold(
      currentPage: AdminPage.branches,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showTable = constraints.maxWidth >= _tableWidth;
          final hasRoomForPanel = constraints.maxWidth >= _sidePanelWidth;
          final showPanel =
              hasRoomForPanel && (_isAdding || _selectedBranchId != null);

          final page = Padding(
            padding: EdgeInsets.all(showTable ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  isWide: showTable,
                  searchController: _searchController,
                  onSearchChanged: filterViewModel.setSearchText,
                  onAddBranch: () {
                    _openAddForm(inSidePanel: hasRoomForPanel);
                  },
                ),
                SizedBox(height: showTable ? 24 : 12),
                Expanded(
                  child: branches.when(
                    // Keep the old list on screen while reloading.
                    skipLoadingOnReload: true,
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Could not load the branches.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    data: (result) {
                      final shown = result.items;
                      if (shown.isEmpty) {
                        if (filter.searchText.trim().isNotEmpty) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'No branches match your search.',
                              style: textTheme.bodyMedium,
                            ),
                          );
                        }
                        return _NoBranches(onAddSamples: _addSampleBranches);
                      }

                      final Widget list;
                      if (!showTable) {
                        list = ListView.separated(
                          itemCount: shown.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final branch = shown[index];
                            return BranchCard(
                              branch: branch,
                              onTap: () {
                                _openBranch(branch, inSidePanel: false);
                              },
                            );
                          },
                        );
                      } else {
                        list = BranchTable(
                          branches: shown,
                          selectedBranchId: showPanel
                              ? _selectedBranchId
                              : null,
                          onBranchTap: (branch) {
                            _openBranch(branch, inSidePanel: hasRoomForPanel);
                          },
                        );
                      }

                      return Column(
                        children: [
                          // The key puts a new page back at the top.
                          Expanded(
                            child: KeyedSubtree(
                              key: ValueKey(result.page),
                              child: list,
                            ),
                          ),
                          const SizedBox(height: 8),
                          PaginationBar(
                            result: result,
                            itemName: 'branches',
                            onPageChanged: (page) {
                              _closePanel();
                              filterViewModel.setPage(page);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );

          if (!showPanel) return page;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: page),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 400,
                child: _isAdding
                    ? _AddBranchPanel(
                        onClose: _closePanel,
                        onAdded: (name) {
                          _closePanel();
                          _showMessage('$name was added.');
                        },
                      )
                    // The key resets the panel when another branch is opened.
                    : BranchDetailPanel(
                        key: ValueKey(_selectedBranchId),
                        branchId: _selectedBranchId!,
                        onClose: _closePanel,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shown when there are no branches yet. Adds the 3 sample branches that
/// the other tabs' sample data uses.
// TODO(team): delete with sampleBranches() once every tab reads Firestore.
class _NoBranches extends StatefulWidget {
  const _NoBranches({required this.onAddSamples});

  final Future<void> Function() onAddSamples;

  @override
  State<_NoBranches> createState() => _NoBranchesState();
}

class _NoBranchesState extends State<_NoBranches> {
  bool _isAdding = false;

  Future<void> _add() async {
    setState(() => _isAdding = true);
    await widget.onAddSamples();
    if (mounted) setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No branches yet. Add your own, or start with the 3 sample '
            'branches (SS15 Subang, Bukit Jalil, Puchong).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: _isAdding ? null : _add,
            child: _isAdding
                ? const ButtonLoadingIndicator()
                : const Text('Add sample branches'),
          ),
        ],
      ),
    );
  }
}

/// The add form inside the side panel.
class _AddBranchPanel extends StatelessWidget {
  const _AddBranchPanel({required this.onClose, required this.onAdded});

  final VoidCallback onClose;

  /// Called with the new branch's name.
  final ValueChanged<String> onAdded;

  @override
  Widget build(BuildContext context) {
    return SidePanelFrame(
      title: 'Add branch',
      onClose: onClose,
      child: BranchForm(onCancel: onClose, onSaved: onAdded),
    );
  }
}

/// Title, search box and "Add branch" button.
/// No title on phones (the app bar shows it).
class _Header extends StatelessWidget {
  const _Header({
    required this.isWide,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddBranch,
  });

  final bool isWide;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddBranch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final search = TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search branches',
        prefixIcon: Icon(Icons.search_rounded),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
    );

    final addButton = FilledButton.icon(
      onPressed: onAddBranch,
      // Theme buttons are full width; this one fits its label.
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      icon: const Icon(Icons.add_rounded),
      label: Text(isWide ? 'Add branch' : 'Add'),
    );

    if (!isWide) {
      return Row(
        children: [
          Expanded(child: search),
          const SizedBox(width: 8),
          addButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Branches', style: textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Store locations, opening hours and delivery',
                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 280, child: search),
        const SizedBox(width: 12),
        addButton,
      ],
    );
  }
}
